From: Eric Sesterhenn <eric.sesterhenn-9J169x0r4uIEe5DYm7f/Lg@public.gmane.org>
Subject: [Patch] Fix memory leak in write_pool_threads
Date: Tue, 28 Jul 2009 14:32:08 +0200
Message-ID: <1248784328.3250.30.camel@queen>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: catalin.marinas@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.pawisda.de ([213.157.4.156]:58613 "EHLO
	mailrelay.pawisda.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbZG1NLx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 09:11:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,

kmemcheck produces the following warning

unreferenced object 0xc9ec02a0 (size 8):
  comm "cat", pid 19048, jiffies 730243
  backtrace:
    [<c01bf970>] create_object+0x100/0x240
    [<c01bfadb>] kmemleak_alloc+0x2b/0x60
    [<c01bcd4b>] __kmalloc+0x14b/0x270
    [<c02fd027>] write_pool_threads+0x87/0x1d0
    [<c02fcc08>] nfsctl_transaction_write+0x58/0x70
    [<c02fcc6f>] nfsctl_transaction_read+0x4f/0x60
    [<c01c2574>] vfs_read+0x94/0x150
    [<c01c297d>] sys_read+0x3d/0x70
    [<c0102d6b>] sysenter_do_call+0x12/0x32
    [<ffffffff>] 0xffffffff

write_pool_threads() only frees nthreads on error paths, in the success case
we leak it.

Signed-off-by: Eric Sesterhenn <eric.sesterhenn-PIliufFCYSYOIzVOb1FTxg@public.gmane.org>

--- linux/fs/nfsd/nfsctl.c.orig	2009-07-28 14:19:19.000000000 +0200
+++ linux/fs/nfsd/nfsctl.c	2009-07-28 14:19:30.000000000 +0200
@@ -784,6 +784,7 @@ static ssize_t write_pool_threads(struct
 		mesg += len;
 	}
 
+	kfree(nthreads);
 	mutex_unlock(&nfsd_mutex);
 	return (mesg-buf);
 


