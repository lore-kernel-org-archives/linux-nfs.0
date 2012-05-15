Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:49696 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965299Ab2EOPjY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 11:39:24 -0400
Received: by dady13 with SMTP id y13so7470818dad.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2012 08:39:24 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH 1/2] NFS: call block plug around direct write
Date: Tue, 15 May 2012 23:38:22 +0800
Message-Id: <1337096303-2516-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We bypass generic_file_aio_write() but would want to call block plug.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/direct.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a1b81dd..a485560 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -46,6 +46,7 @@
 #include <linux/kref.h>
 #include <linux/slab.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blkdev.h>
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
@@ -922,6 +923,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	size_t count;
+	struct blk_plug plug;
 
 	count = iov_length(iov, nr_segs);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
@@ -948,7 +950,9 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_write(count);
 
+	blk_start_plug(&plug);
 	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
+	blk_finish_plug(&plug);
 	if (retval > 0) {
 		struct inode *inode = mapping->host;
 
-- 
1.7.1.262.g5ef3d

