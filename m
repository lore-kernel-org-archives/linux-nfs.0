Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f42.google.com ([209.85.213.42]:58331 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935486AbaH0RfP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2014 13:35:15 -0400
Received: by mail-yh0-f42.google.com with SMTP id a41so584050yho.15
        for <linux-nfs@vger.kernel.org>; Wed, 27 Aug 2014 10:35:15 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 27 Aug 2014 13:35:14 -0400
Message-ID: <CAHVgHyWwoOyguyJa-tmQVQE56c2wSOR2xUnwOzPOfet_nK60Sw@mail.gmail.com>
Subject: nfsiod work_queue hang issue in RHEL 6.6 pre kernel (2.6.32-459)
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are seeing nfsiod hang for 5 to 20+ minutes.

This thread hung for 5-10 minutes then cleared.

Aug 26 05:10:01 scspr0012063007 kernel: nfsiod        S
0000000000000000     0  4931      2 0x00000080
Aug 26 05:05:01 scspr0012063007 kernel: ffff880037891e30
0000000000000046 ffff8800d130d400 ffffffffa01e1030
Aug 26 05:05:01 scspr0012063007 kernel: ffff880037891fd8
ffffe8ffff608ac8 ffff880037891dc0 ffffffffa0287e8d
Aug 26 05:05:01 scspr0012063007 kernel: ffff880104fb5098
ffff880037891fd8 000000000000fbc8 ffff880104fb5098
Aug 26 05:05:01 scspr0012063007 kernel: Call Trace:
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffffa01e1030>] ?
rpc_async_release+0x0/0x20 [sunrpc]
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffffa0287e8d>] ?
nfs_writedata_release+0x6d/0x90 [nfs]
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b7fe>] ?
prepare_to_wait+0x4e/0x80
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffffa01e1030>] ?
rpc_async_release+0x0/0x20 [sunrpc]
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff81094fdc>]
worker_thread+0x1fc/0x2a0
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b4d0>] ?
autoremove_wake_function+0x0/0x40
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff81094de0>] ?
worker_thread+0x0/0x2a0
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b126>] kthread+0x96/0xa0
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8100c20a>] child_rip+0xa/0x20
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8109b090>] ? kthread+0x0/0xa0
Aug 26 05:05:01 scspr0012063007 kernel: [<ffffffff8100c200>] ?
child_rip+0x0/0x20

This similar Call Trace, nfsiod hung for 20 minutest, then the client
was rebooted.

Aug 26 06:00:01 scspr0012063007 kernel: nfsiod        S
0000000000000000     0  1701      2 0x00000000
Aug 26 06:00:01 scspr0012063007 kernel: ffff880037a63e30
0000000000000046 ffff880037a62000 ffff880037a62000
Aug 26 06:00:01 scspr0012063007 kernel: ffff8800f3421140
0000000000000000 ffff8800f3421140 ffffffffa0316030
Aug 26 06:00:01 scspr0012063007 kernel: ffff880100e2f098
ffff880037a63fd8 000000000000fbc8 ffff880100e2f098
Aug 26 06:00:01 scspr0012063007 kernel: Call Trace:
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffffa0316030>] ?
rpc_async_release+0x0/0x20 [sunrpc]
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b7fe>] ?
prepare_to_wait+0x4e/0x80
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffffa0316030>] ?
rpc_async_release+0x0/0x20 [sunrpc]
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff81094fdc>]
worker_thread+0x1fc/0x2a0
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b4d0>] ?
autoremove_wake_function+0x0/0x40
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff81094de0>] ?
worker_thread+0x0/0x2a0
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b126>] kthread+0x96/0xa0
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8100c20a>] child_rip+0xa/0x20
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8109b090>] ? kthread+0x0/0xa0
Aug 26 06:00:01 scspr0012063007 kernel: [<ffffffff8100c200>] ?
child_rip+0x0/0x20

rpc_async_release calls rpc_free_task - which is unchanged in the
upstream kernel. I note this comment:

+/*
+ * rpc_free_task - release rpc task and perform cleanups
+ *
+ * Note that we free up the rpc_task _after_ rpc_release_calldata()
+ * in order to work around a workqueue dependency issue.
+ *
+ * Tejun Heo states:
+ * "Workqueue currently considers two work items to be the same if they're
+ * on the same address and won't execute them concurrently - ie. it
+ * makes a work item which is queued again while being executed wait
+ * for the previous execution to complete.
+ *
+ * If a work function frees the work item, and then waits for an event
+ * which should be performed by another work item and *that* work item
+ * recycles the freed work item, it can create a false dependency loop.
+ * There really is no reliable way to detect this short of verifying
+ * every memory free."
+ *

worker_thread calls prepare_to_wait....

Are there changes to the upstream work queue or RPC layer that may be
worth looking into back porting to help with this issue?

Thanks

-->Andy
