Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53604 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965299Ab2EOPjl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 11:39:41 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so7677495pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2012 08:39:41 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH 2/2] NFS: call block plug around direct read
Date: Tue, 15 May 2012 23:38:23 +0800
Message-Id: <1337096303-2516-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1337096303-2516-1-git-send-email-bergwolf@gmail.com>
References: <1337096303-2516-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/direct.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a485560..2cf3b45 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -866,6 +866,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
+	struct blk_plug plug;
 	size_t count;
 
 	count = iov_length(iov, nr_segs);
@@ -886,7 +887,9 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_read(count);
 
+	blk_start_plug(&plug);
 	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
+	blk_finish_plug(&plug);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
-- 
1.7.1.262.g5ef3d

