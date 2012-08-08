Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54248 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030385Ab2HIOnI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 10:43:08 -0400
Received: by pbbrr13 with SMTP id rr13so1006120pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 07:43:08 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2] NFSv41: fix DIO write_io calculation
Date: Wed,  8 Aug 2012 23:41:25 +0800
Message-Id: <1344440485-2046-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_within_mdsthreshold() is called inside pg_init. We need
to set read_io/write_io before that. Otherwise we fail
pnfs_within_mdsthreshold() and IO goes to MDS.
A simple test case:
dd if=foo of=/mnt/pnfs/bar bs=10M count=1 oflag=direct

Cc: Andy Adamson <andros@netapp.com>
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/direct.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1ba385b..34a6282 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -463,10 +463,10 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
+	NFS_I(inode)->read_io += iov_length(iov, nr_segs);
 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos, uio);
 	if (!result)
 		result = nfs_direct_wait(dreq);
-	NFS_I(inode)->read_io += result;
 out_release:
 	nfs_direct_req_release(dreq);
 out:
@@ -814,6 +814,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	get_dreq(dreq);
 	atomic_inc(&inode->i_dio_count);
 
+	NFS_I(dreq->inode)->write_io += iov_length(iov, nr_segs);
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
 		result = nfs_direct_write_schedule_segment(&desc, vec, pos, uio);
@@ -825,7 +826,6 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 		pos += vec->iov_len;
 	}
 	nfs_pageio_complete(&desc);
-	NFS_I(dreq->inode)->write_io += desc.pg_bytes_written;
 
 	/*
 	 * If no bytes were started, return the error, and let the
-- 
1.7.1.262.g5ef3d

