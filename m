Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:65297 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015AbbANQqU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:46:20 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so11515570pab.7
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:46:19 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 47/50] nfs: add a helper to set NFS_ODIRECT_RESCHED_WRITES to direct writes
Date: Wed, 14 Jan 2015 08:44:53 -0800
Message-Id: <1421253896-73106-48-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
References: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

To allow pnfs LD to ask direct writes to be resend.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c   | 6 ++++++
 fs/nfs/internal.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index eb81478..4fad6b7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -116,6 +116,12 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
 	return atomic_dec_and_test(&dreq->io_count);
 }
 
+void nfs_direct_set_resched_writes(struct nfs_direct_req *dreq)
+{
+	dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+}
+EXPORT_SYMBOL_GPL(nfs_direct_set_resched_writes);
+
 static void
 nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ffe4b7a..44e8496 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -502,6 +502,7 @@ static inline void nfs_inode_dio_wait(struct inode *inode)
 	inode_dio_wait(inode);
 }
 extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
+extern void nfs_direct_set_resched_writes(struct nfs_direct_req *dreq);
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_pgio_header *);
-- 
1.9.3

