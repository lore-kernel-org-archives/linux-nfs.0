Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:49737 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751020AbaIWNDt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 09:03:49 -0400
Date: Tue, 23 Sep 2014 14:03:52 +0100
From: Will Deacon <will.deacon@arm.com>
To: "dros@primarydata.com" <dros@primarydata.com>,
        "tao.peng@primarydata.com" <tao.peng@primarydata.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
Message-ID: <20140923130352.GK26472@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I've been running into the following warning on an arm64 system running
3.17-rc6 with 64k pages. I've been unable to reproduce with a smaller page
size (4k).

I don't yet have a concrete reproducer, but I've seen it hit a few times
today just running a machine with an NFS root filesystem and using ssh.
The warning seems to happen in parallel on the two CPUs, but I'm pretty
confident that our test_and_clear_bit implementation has the relevant
atomic instructions and memory barriers.

Any ideas?

Will

--->8

------------[ cut here ]------------
WARNING: CPU: 1 PID: 1023 at fs/nfs/write.c:743 nfs_inode_remove_request+0xe4/0xf0()
Modules linked in:
CPU: 1 PID: 1023 Comm: kworker/1:2 Not tainted 3.17.0-rc6 #1
Workqueue: nfsiod rpc_async_release
Call trace:
[<fffffe0000096410>] dump_backtrace+0x0/0x130
[<fffffe0000096550>] show_stack+0x10/0x1c
[<fffffe00004cda94>] dump_stack+0x74/0xbc
[<fffffe00000b4d20>] warn_slowpath_common+0x8c/0xb4
[<fffffe00000b4e0c>] warn_slowpath_null+0x14/0x20
[<fffffe000027a6a8>] nfs_inode_remove_request+0xe0/0xf0
[<fffffe000027b704>] nfs_write_completion+0xb4/0x150
[<fffffe0000276ef4>] nfs_pgio_release+0x34/0x44
[<fffffe00004ac2d0>] rpc_free_task+0x24/0x4c
[<fffffe00004ac5c0>] rpc_async_release+0xc/0x18
[<fffffe00000c89e8>] process_one_work+0x140/0x32c
[<fffffe00000c9338>] worker_thread+0x13c/0x470
[<fffffe00000cd9e4>] kthread+0xd0/0xe8
---[ end trace 6f044efb83f0811b ]---

------------[ cut here ]------------
WARNING: CPU: 0 PID: 621 at fs/nfs/write.c:743 nfs_inode_remove_request+0xe4/0xf0()
CPU: 0 PID: 621 Comm: kworker/0:2 Tainted: G        W      3.17.0-rc6 #1
Workqueue: nfsiod rpc_async_release
Call trace:
[<fffffe0000096410>] dump_backtrace+0x0/0x130
[<fffffe0000096550>] show_stack+0x10/0x1c
[<fffffe00004cda94>] dump_stack+0x74/0xbc
[<fffffe00000b4d20>] warn_slowpath_common+0x8c/0xb4
[<fffffe00000b4e0c>] warn_slowpath_null+0x14/0x20
[<fffffe000027a6a8>] nfs_inode_remove_request+0xe0/0xf0
[<fffffe000027b704>] nfs_write_completion+0xb4/0x150
[<fffffe0000276ef4>] nfs_pgio_release+0x34/0x44
[<fffffe00004ac2d0>] rpc_free_task+0x24/0x4c
[<fffffe00004ac5c0>] rpc_async_release+0xc/0x18
[<fffffe00000c89e8>] process_one_work+0x140/0x32c
[<fffffe00000c9338>] worker_thread+0x13c/0x470
[<fffffe00000cd9e4>] kthread+0xd0/0xe8
---[ end trace 6f044efb83f0811c ]---
