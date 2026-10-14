const std = @import("std");
const Io = std.Io;

const lfs = @import("lfs");
const lex = @import("lexer");

pub fn main(init: std.process.Init) !void {
    const source = try std.Io.Dir.cwd().readFileAlloc(init.io, "./test.txt", init.gpa, .unlimited);
    const tokens = try lex.tokenize(init.gpa, source);
    defer init.gpa.free(source);
    defer init.gpa.free(tokens);

    for (tokens) |t| {
        std.debug.print("{any}, \"{s}\"\n", .{t.type, t.value});
    }
}
