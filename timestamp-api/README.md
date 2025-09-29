# Timestamp API

This repository contains the Protocol Buffer API definitions for the Timestamp service.

## Overview

The Timestamp API provides standardized timestamp messages and services for:
- Getting current timestamps with configurable precision
- Streaming timestamps at regular intervals
- Supporting multiple timezones

## Protocol Buffer Definitions

### Messages

- `TimestampMessage`: Core timestamp message with timezone and precision support
- `GetCurrentTimestampRequest`/`GetCurrentTimestampResponse`: Single timestamp retrieval
- `StreamTimestampsRequest`: Streaming timestamp configuration

### Services

- `TimestampService`: gRPC service for timestamp operations

## Usage

This API is designed to be consumed by other applications through the Central Registry as a submodule.

## Supported Languages

Generated code available for:
- Go
- Java
- C#
- C++
- Python
- JavaScript/TypeScript

## Version

Current API version: v1
