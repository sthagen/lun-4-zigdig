const std = @import("std");
const dns = @import("lib.zig");

const logger = std.log.scoped(.zigdig_main);
pub const std_options = struct {
    pub const log_level = .info;
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    var args_it = std.process.args();
    _ = args_it.skip();

    const name_string = (args_it.next() orelse {
        logger.warn("no name provided", .{});
        return error.InvalidArgs;
    });

    var addrs = try dns.helpers.getAddressList(name_string, allocator);
    defer addrs.deinit();

    var stdout = std.io.getStdOut().writer();

    for (addrs.addrs) |addr| {
        try stdout.print("{s} has address {any}\n", .{ name_string, addr });
    }
}
