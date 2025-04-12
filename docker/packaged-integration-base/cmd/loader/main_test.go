// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 Univention GmbH

package main

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/suite"
)

type LoaderSuite struct {
	suite.Suite
}

func TestRunLoader(t *testing.T) {
	suite.Run(t, new(LoaderSuite))
}

func (s *LoaderSuite) createPlugin(baseDir, pluginName, fileName, content string) {
	r := s.Require()
	pluginPath := filepath.Join(baseDir, pluginName)
	err := os.Mkdir(pluginPath, 0755)
	r.NoError(err)

	filePath := filepath.Join(pluginPath, fileName)
	err = os.WriteFile(filePath, []byte(content), 0644)
	r.NoError(err)
}

func (s *LoaderSuite) TestCopyPlugin_Success() {
	source := s.T().TempDir()
	destination := s.T().TempDir()
	pluginType := "udm-data-loader"

	s.createPlugin(source, pluginType, "just_testing.yaml", "global: 'foobar'")
	err := os.Mkdir(filepath.Join(destination, pluginType), 0755)
	s.Require().NoError(err)

	err = copyPlugins(source, destination)
	s.Require().NoError(err)

	testFileContents, err := os.ReadFile(
		filepath.Join(destination, pluginType, "just_testing.yaml"),
	)
	s.Require().NoError(err)
	s.Assert().Equal("global: 'foobar'", string(testFileContents))
}

func (s *LoaderSuite) TestCopyPlugins_SourceNotExist() {
	r := s.Require()
	nonExistingSource := filepath.Join(os.TempDir(), "non_existent_plugins")
	destination := s.T().TempDir()

	err := copyPlugins(nonExistingSource, destination)
	r.Error(err)
	s.Assert().Contains(err.Error(), "failed to read source directory")
}

func (s *LoaderSuite) TestOnlyCopyNeededPlugins() {
	source := s.T().TempDir()
	destination := s.T().TempDir()
	pluginType := "udm-data-loader"

	s.createPlugin(source, pluginType, "just_testing.yaml", "global: 'foobar'")

	err := copyPlugins(source, destination)
	s.Require().NoError(err)

	_, err = os.ReadFile(
		filepath.Join(destination, pluginType, "just_testing.yaml"),
	)
	s.Require().Error(err)
	s.Assert().True(os.IsNotExist(err))
}
