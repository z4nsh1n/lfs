//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;
// pub const lexer = @import("lexer");
pub const parser = @import("parser");
// pub const ast = @import("ast");
// pub const parser = @import("parser.zig");


/// This is a documentation comment to explain the `printAnotherMessage` function below.
///
/// Accepting an `Io.Writer` instance is a handy way to write reusable code.
pub fn printAnotherMessage() void {
    // lexer.lexer();
}

