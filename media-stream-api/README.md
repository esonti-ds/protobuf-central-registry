# Media Stream API

This repository contains the Protocol Buffer API definitions for the Media Stream service.

## Overview

The Media Stream API provides WebRTC-based video streaming capabilities including:
- Creating and managing video streams
- WebRTC signaling and configuration
- Viewer management and activity tracking
- Integration with Timestamp API for consistent timestamping

## Protocol Buffer Definitions

### Messages

- `StreamMetadata`: Core stream information with timestamp integration
- `WebRTCConfig`: WebRTC connection configuration
- `ViewerActivity`: Viewer actions with timestamp tracking
- `CreateStreamRequest`/`CreateStreamResponse`: Stream creation
- `JoinStreamRequest`/`JoinStreamResponse`: Stream joining
- `RecordViewerActivityRequest`/`RecordViewerActivityResponse`: Activity recording

### Services

- `MediaStreamService`: gRPC service for all media streaming operations

## Dependencies

This API depends on:
- `timestamp.proto` from the Timestamp API (via Central Registry)
- Google Protobuf standard types

## Usage

This API is designed to be consumed by other applications through the Central Registry as a submodule.

## Supported Languages

Generated code available for:
- Go (primary implementation language)
- Java
- C#
- C++
- Python
- JavaScript/TypeScript

## Version

Current API version: v1
