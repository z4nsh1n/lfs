const std = @import("std");

pub const TokenType = enum {
    Number,
    Identifier,
    Equals,
    OpenParen,
    CloseParen,
    BinaryOperator,
    Let,
    EOF,
};

const Keywords = std.StaticStringMap(TokenType).initComptime(.{
    .{"let", TokenType.Let},
    }
);

pub const Token = struct {
    const Self = @This();
    value:[]const u8,
    type: TokenType,

    pub fn create(t:TokenType, v:[]const u8) Self {
        return Self{
            .type = t,
            .value = v
        };
    }
};
pub fn lexer() void {
    std.debug.print("Lexer test\n", .{});
}


pub fn tokenize(alloc:std.mem.Allocator, source_code:[]const u8) ![]Token {
    var tokens = try std.ArrayList(Token).initCapacity(alloc, 64);
    var idx:usize = 0;
    var offset:usize = idx;
    while (idx < source_code.len) :(idx += 1) {
        switch (source_code[idx]) {
            ' ', '\r', '\n', '\t' => continue,
            '=' => try tokens.append(alloc, Token.create(.Equals, "=")),
            '(' => try tokens.append(alloc, Token.create(.OpenParen,  "(")),
            ')' => try tokens.append(alloc, Token.create(.CloseParen,  ")")), 
            '+', '-', '*', '/' => try tokens.append(alloc, 
                Token.create(.BinaryOperator, source_code[idx..idx+1])),
            '0'...'9' => {
                // var num = std.ArrayList(u8).initCapacity(alloc, 10);
                offset = idx;
                while (offset < source_code.len and std.ascii.isDigit(source_code[offset])) : (offset += 1) {}
                try tokens.append(alloc, Token.create(.Number, source_code[idx..offset]));
                idx = offset-1;
            },
            'a'...'z','_','A'...'Z' => {
                offset = idx;
                while (offset<source_code.len and std.ascii.isAlphanumeric(source_code[offset])) : (offset += 1){}
                var new_token = Token.create(.Identifier, source_code[idx..offset]);
                if (Keywords.get(source_code[idx..offset])) |type_| {
                    new_token.type = type_;
                } else {
                    new_token.type = .Identifier;
                }
                try tokens.append(alloc, new_token);
                idx = offset-1;
            },
            else =>@panic("Unreachable code"),
        }
    }
    try tokens.append(alloc, Token.create(.EOF, ""));
    return tokens.toOwnedSlice(alloc);
}

test "Lexer: keywords and identifiers" {
    const t = std.testing;
    const alloc = t.allocator;
    // const code_string = "(1001)";
    const code_string = "let x=10";
    const output:[]const Token = &[_]Token{
        // Token{.type = .OpenParen, .value = "("},
        Token.create(.Let, "let"),
        Token.create(.Identifier, "x"),
        Token.create(.Equals, "="),
        Token.create(.Number, "10"),
        Token.create(.EOF, ""),
        // Token{.type = .CloseParen, .value = ")"},
    };
    const result = try tokenize(alloc, code_string);
    for (result,  output) |v1, v2| {
        try t.expectEqual(v1.type, v2.type);
        try t.expectEqualStrings(v1.value, v2.value);
    }

    alloc.free(result);
}
test "Lexer, number tokens" {
    const t = std.testing;
    const alloc = t.allocator;
    // const code_string = "(1001)";
    const code_string = "1001";
    const output:[]const Token = &[_]Token{
        // Token{.type = .OpenParen, .value = "("},
        Token.create(.Number, "1001"),
        Token.create(.EOF, ""),
        // Token{.type = .CloseParen, .value = ")"},
    };
    const result = try tokenize(alloc, code_string);
    try t.expectEqualSlices(Token, output, result);

    alloc.free(result);
}

test "Lexer, single tokens" {
    const t = std.testing;
    const alloc = t.allocator;
    const code_string = "(+*)";
    const output:[]const Token = &[_]Token{
        Token{.type = .OpenParen, .value = "("},
        Token{.type = .BinaryOperator, .value = "+"},
        Token{.type = .BinaryOperator, .value = "*"},
        Token{.type = .CloseParen, .value = ")"},
        Token.create(.EOF, ""),
    };
    const result = try tokenize(alloc, code_string);
    for (output, result) |v1, v2| {
        try t.expectEqual(v1.type, v2.type);
        try t.expectEqualStrings(v1.value, v2.value);
    }
    alloc.free(result);
}
