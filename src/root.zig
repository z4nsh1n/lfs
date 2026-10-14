//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;
const lexer = @import("lexer");

/// This is a documentation comment to explain the `printAnotherMessage` function below.
///
/// Accepting an `Io.Writer` instance is a handy way to write reusable code.
pub fn printAnotherMessage() void {
    lexer.lexer();
}

