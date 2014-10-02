Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:38096 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751355AbaJBI6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Oct 2014 04:58:07 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.opinsys.fi (Postfix) with ESMTP id 8CCA62E8502
	for <linux-nfs@vger.kernel.org>; Thu,  2 Oct 2014 09:01:04 +0000 (UTC)
Received: from mail.opinsys.fi ([127.0.0.1])
	by localhost (mail.opinsys.fi [127.0.0.1]) (amavisd-new, port 10032)
	with ESMTP id XkFr6R2yUP0o for <linux-nfs@vger.kernel.org>;
	Thu,  2 Oct 2014 09:01:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by mail.opinsys.fi (Postfix) with ESMTP id E27672E847C
	for <linux-nfs@vger.kernel.org>; Thu,  2 Oct 2014 09:01:03 +0000 (UTC)
Received: from mail.opinsys.fi ([127.0.0.1])
	by localhost (mail.opinsys.fi [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id zeXiWz2FyXfE for <linux-nfs@vger.kernel.org>;
	Thu,  2 Oct 2014 09:01:03 +0000 (UTC)
Received: from mail.opinsys.fi (mail.opinsys.fi [10.246.133.21])
	by mail.opinsys.fi (Postfix) with ESMTP id BBC042E84FD
	for <linux-nfs@vger.kernel.org>; Thu,  2 Oct 2014 09:01:03 +0000 (UTC)
Date: Thu, 2 Oct 2014 09:01:03 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: linux-nfs@vger.kernel.org
Message-ID: <242225503.126017.1412240463629.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <1508157147.125995.1412239112248.JavaMail.zimbra@opinsys.fi>
Subject: [RFC]: make nfs_wait_on_request() KILLABLE
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

Before David Jefferey's commit:

  92a5655 nfs: Don't busy-wait on SIGKILL in __nfs_iocounter_wait

we often experienced softlockups in our systems due to busy-looping
after SIGKILL.

With that patch applied, the frequency of softlockups has decreased
but they are not completely gone. Now softlockups happen with
following kind of call traces:

 [<c1045c27>] ? kvm_clock_get_cycles+0x17/0x20
 [<c10b2028>] ? ktime_get_ts+0x48/0x140
 [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
 [<c1656fb6>] io_schedule+0x86/0x100
 [<f8b77bed>] nfs_wait_bit_uninterruptible+0xd/0x20 [nfs]
 [<c16572d1>] __wait_on_bit+0x51/0x70
 [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
 [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
 [<c165734b>] out_of_line_wait_on_bit+0x5b/0x70
 [<c1091470>] ? autoremove_wake_function+0x40/0x40
 [<f8b77f3e>] nfs_wait_on_request+0x2e/0x30 [nfs]
 [<f8b7c5ae>] nfs_updatepage+0x11e/0x7d0 [nfs]
 [<f8b7b15b>] ? nfs_page_find_request+0x3b/0x50 [nfs]
 [<f8b7c41d>] ? nfs_flush_incompatible+0x6d/0xe0 [nfs]
 [<f8b6f1a0>] nfs_write_end+0x110/0x280 [nfs]
 [<c10503f2>] ? kmap_atomic_prot+0xe2/0x100
 [<c1050283>] ? __kunmap_atomic+0x63/0x80
 [<c1121e52>] generic_file_buffered_write+0x132/0x210
 [<c112362d>] __generic_file_aio_write+0x25d/0x460
 [<f8b71df2>] ? __nfs_revalidate_inode+0x102/0x2e0 [nfs]
 [<c1123883>] generic_file_aio_write+0x53/0x90
 [<f8b6e267>] nfs_file_write+0xa7/0x1d0 [nfs]
 [<c12a78eb>] ? common_file_perm+0x4b/0xe0
 [<c11794f7>] do_sync_write+0x57/0x90
 [<c11794a0>] ? do_sync_readv_writev+0x80/0x80
 [<c1179975>] vfs_write+0x95/0x1b0
 [<c117a019>] SyS_write+0x49/0x90
 [<c165a297>] syscall_call+0x7/0x7
 [<c1650000>] ? balance_dirty_pages.isra.18+0x390/0x4c3

As I understand it, there are some outstanding requests going on which
nfs_wait_on_request() is waiting for. For some reason, they are not
finished in timely manner and the process is eventually killed with
SIGKILL by admin. However, nfs_wait_on_request() has set the task
state TASK_UNINTERRUPTIBLE and it does not get killed.

Why nfs_wait_on_request() is UNINTERRUPTIBLE instead of KILLABLE?

Would the following patch fix the issue?

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index be7cbce..6a1766d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -459,8 +459,9 @@ void nfs_release_request(struct nfs_page *req)
 int
 nfs_wait_on_request(struct nfs_page *req)
 {
-       return wait_on_bit_io(&req->wb_flags, PG_BUSY,
-                             TASK_UNINTERRUPTIBLE);
+       return wait_on_bit_action(&req->wb_flags, PG_BUSY,
+                               nfs_wait_bit_killable,
+                               TASK_KILLABLE);
 }
 
 /*

-- 
Tuomas
