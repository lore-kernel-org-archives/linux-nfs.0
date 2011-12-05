Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.148.79]:60756 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932491Ab1LEQuX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 11:50:23 -0500
Date: Mon, 5 Dec 2011 17:50:21 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: 3.1.4: NFSv3 RPC scheduling issue?
Message-ID: <20111205165021.GA24165@janus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After upgrading 50+ NFSv3 (over UDP) client machines from 3.0.x to
3.1.4 I occasionally noticed a machine with lots of processes hanging
in __rpc_execute() for a specific mount point with no progress at all.
Stack:

	[<c17fe7e0>] schedule+0x30/0x50
	[<c177e259>] rpc_wait_bit_killable+0x19/0x30
	[<c17feeb5>] __wait_on_bit+0x45/0x70
	[<c177e240>] ? rpc_release_task+0x110/0x110
	[<c17fef3d>] out_of_line_wait_on_bit+0x5d/0x70
	[<c177e240>] ? rpc_release_task+0x110/0x110
	[<c108aed0>] ? autoremove_wake_function+0x40/0x40
	[<c177e89b>] __rpc_execute+0xdb/0x1a0
	...

Every reference to the specific mount point on the client machine hangs
and the server does not receive any related network traffic. The server
works fine for other identical client machines with the same export mounted.
Other mounts on the (now) broken client still work. Killing the hanging
client processes repairs the situation.

This has happened a couple of times on client machines with heavy (NFS)
load. The mount-point has originally been mounted by the automounter.

-- 
Frank
