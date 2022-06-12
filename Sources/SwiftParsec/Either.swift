// ==============================================================================
// Either.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-09-18.
// Copyright © 2016 David Dufresne. All rights reserved.
//
// Either type
// ==============================================================================

// ==============================================================================
/// The Either enumeration represents values with two possibilities: a value of
/// type `Either<L, R>` is either `Left(L)` or `Right(R)`.
public enum Either<L, R> {
    /// Left posibility.
    case left(L)

    /// Right posibility.
    case right(R)
}
