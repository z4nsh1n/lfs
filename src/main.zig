const std = @import("std");
const Io = std.Io;

const lfs = @import("lfs");
const lex = @import("lexer");

pub fn main(init: std.process.Init) !void {
    const tokens:[]lex.Token  = try lex.tokenize(init.gpa, "(1001");

    const output:[]const lex.Token = &[_]lex.Token{
        lex.Token{.type = .OpenParen, .value = "("},
        lex.Token.create(.Number, "1001"),
        // Token{.type = .CloseParen, .value = ")"},
    };
    try std.testing.expectEqualSlices(lex.Token, output, tokens);
    init.gpa.free(tokens);



}
