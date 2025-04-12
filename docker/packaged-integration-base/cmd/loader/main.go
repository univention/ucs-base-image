// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 Univention GmbH

package main

import (
	"io"
	"io/fs"
	"log/slog"
	"os"
	"path/filepath"
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
		return err
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		pluginType := entry.Name()
		srcPath := filepath.Join(source, pluginType)
		dstPath := filepath.Join(destination, pluginType)

		info, err := os.Stat(dstPath)
		if err != nil || !info.IsDir() {
			slog.Info("SKIP - Plugin type not in target", "pluginType", pluginType)
			continue
		}

		slog.Info("COPY - Plugin type found, copying files", "pluginType", pluginType)
		if err := copyDirectoryContents(srcPath, dstPath); err != nil {
			slog.Error("Error copying plugin", "pluginType", pluginType, "error", err)
			return err
		}
	}
	return nil
}

func copyDirectoryContents(src, dst string) error {
	entries, err := os.ReadDir(src)
	if err != nil {
		return err
	}

	for _, entry := range entries {
		srcPath := filepath.Join(src, entry.Name())
		dstPath := filepath.Join(dst, entry.Name())

		info, err := entry.Info()
		if err != nil {
			return err
		}

		if entry.IsDir() {
			if err := os.MkdirAll(dstPath, info.Mode()); err != nil {
				return err
			}
			if err := copyDirectoryContents(srcPath, dstPath); err != nil {
				return err
			}
		} else {
			if _, err := os.Stat(dstPath); err == nil {
				slog.Warn("This extension is overwriting an existing file from Nubus core or a previously loaded extension.", "file", dstPath)
			}
			if err := copyFile(srcPath, dstPath, info.Mode()); err != nil {
				return err
			}
		}
	}
	return nil
}

// copyFile opens the source file and copies its content to the destination,
// preserving its file mode.
func copyFile(srcPath, dstPath string, mode fs.FileMode) error {
	srcFile, err := os.Open(srcPath)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	dstFile, err := os.OpenFile(dstPath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, mode)
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	return err
}
