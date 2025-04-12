// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 Univention GmbH

package main

import (
	"fmt"
	"log/slog"
	"os"
	"path/filepath"

	"github.com/otiai10/copy"
)

func main() {
	if err := copyPlugins("/plugins", "/target"); err != nil {
		slog.Error("Error copying plugins", "error", err)
		os.Exit(1)
	}

	slog.Info("Finished copying plugins")
}

func copyPlugins(source string, destination string) error {
	slog.Info("Copying the Nubus extension files into the target volume", "source", source, "destination", destination)
	entries, err := os.ReadDir(source)
	if err != nil {
		return fmt.Errorf("failed to read source directory: %s, error: %w", source, err)
	}

	opts := copy.Options{
		Skip: func(info os.FileInfo, src, dest string) (bool, error) {
			if info.IsDir() {
				return false, nil
			}
			if _, err := os.Stat(dest); err == nil {
				slog.Info("This extension is overwriting an existing file from Nubus core or a previously loaded extension", "source", src, "destination", dest)
			}
			return false, nil
		},
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		pluginType := entry.Name()
		targetDir := filepath.Join(destination, pluginType)

		info, err := os.Stat(targetDir)
		if err != nil || !info.IsDir() {
			slog.Info("SKIP - Plugin type not in destination, skipping", "pluginType", pluginType, "destination", destination)
			continue
		}

		slog.Info("COPY - Plugin type in destination, copying files", "pluginType", pluginType, "destination", destination)
		err = copy.Copy(
			filepath.Join(source, pluginType),
			filepath.Join(destination, pluginType),
			opts,
		)
		if err != nil {
			return fmt.Errorf("failed to copy plugin files. pluginType: %s, error: %w", pluginType, err)
		}
	}
	return nil
}
