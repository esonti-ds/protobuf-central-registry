# Video Viewer API

This repository contains the Protocol Buffer API definitions for the Video Viewer application.

## Overview

The Video Viewer API provides client-side video viewing capabilities including:
- User session management
- Viewing history tracking
- User preferences management
- Real-time session events
- Integration with Media Stream and Timestamp APIs

## Protocol Buffer Definitions

### Messages

- `UserProfile`: User information and preferences
- `ViewingSession`: Video viewing session tracking with timestamps
- `SessionStatistics`: Session performance metrics
- `DeviceInfo`: Client device information
- Various request/response pairs for service operations

### Services

- `VideoViewerService`: gRPC service for video viewer operations

## Dependencies

This API depends on:
- `timestamp/timestamp.proto` from the Timestamp API
- `mediastream/media_stream.proto` from the Media Stream API
- Google Protobuf standard types

All dependencies are accessed via the Central Registry.

## Usage

This API is designed to be consumed by the Flutter Video Viewer application and other clients through the Central Registry.

## Supported Languages

Generated code available for:
- Dart (primary for Flutter implementation)
- Go
- Java
- C#
- C++
- Python
- JavaScript/TypeScript

## Version

Current API version: v1
