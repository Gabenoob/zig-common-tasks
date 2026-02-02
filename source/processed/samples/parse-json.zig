// {{ define name "JSON - Parse object" }}
// {{ define id "parse-json" }}
// {{ define category "Protocols and Serialization" }}
// {{ eval name }}
const std = @import("std");

const alloc = std.testing.allocator;

// Sample starts here{{ slot contents }}\
test "Parse JSON object" {
    const example_json: []const u8 =
        \\{"a_number": 10, "a_str": "hello"}
    ;
    const JsonStruct = struct {
        a_number: u32,
        a_str: []const u8,
    };

    const parsed = try std.json.parseFromSlice(JsonStruct, alloc, example_json, .{});
    defer parsed.deinit();

    const result = parsed.value;
    try std.testing.expectEqual(@as(u32, 10), result.a_number);
    try std.testing.expectEqualSlices(u8, "hello", result.a_str);
}

test "Parse a complex JSON object" {
    const example_json: []const u8 =
        \\{
        \\  "a_number": 10,
        \\  "a_str": "hello",
        \\  "a_float": 3.14,
        \\  "a_bool": true,
        \\  "a_null": null,
        \\  "a_number_array": [1, 2, 3],
        \\  "a_string_array": ["one", "two", "three"],
        \\  "nested": { "key": "value" }
        \\}
    ;

    const parsed: std.json.Parsed(std.json.Value) = try std.json.parseFromSlice(std.json.Value, alloc, example_json, .{});
    defer parsed.deinit();

    const result = parsed.value.object; // This is the root of the JSON structure, and it is a map of all the keys of the JSON.

    try std.testing.expectEqual(10, result.get("a_number").?.integer);

    try std.testing.expectEqualSlices(u8, "hello", result.get("a_str").?.string);

    try std.testing.expectEqual(3.14, result.get("a_float").?.float);

    try std.testing.expectEqual(true, result.get("a_bool").?.bool);

    try std.testing.expectEqual(.null, result.get("a_null").?);

    const number_array = result.get("a_number_array").?.array;
    const expected_array = [_]i32{ 1, 2, 3 };
    try std.testing.expectEqual(expected_array.len, number_array.items.len);
    for (0..expected_array.len) |i| {
        try std.testing.expectEqual(expected_array[i], number_array.items[i].integer);
    }

    const json_string_array = result.get("a_string_array").?.array;
    const expected_str_array = [_][]const u8{ "one", "two", "three" };
    try std.testing.expectEqual(expected_str_array.len, json_string_array.items.len);
    for (0..expected_str_array.len) |i| {
        try std.testing.expectEqualStrings(expected_str_array[i], json_string_array.items[i].string);
    }

    const nested = result.get("nested").?.object;
    try std.testing.expectEqualStrings("value", nested.get("key").?.string);
}
