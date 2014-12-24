Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:34003 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbaLXHOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:14 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so7266369ieb.3
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:13 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 41/49] pnfs: allow LD to ask to resend read through pnfs
Date: Tue, 23 Dec 2014 23:13:20 -0800
Message-Id: <1419405208-25975-42-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

If current IO cannot be completed due to some transient errors,
LD may want to ask generic layer to resend the request through
pnfs again.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/pnfs.c | 15 ++++++++++++++-
 fs/nfs/pnfs.h |  2 ++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b822b17..685af4f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1880,15 +1880,28 @@ pnfs_try_to_read_data(struct nfs_pgio_header *hdr,
 	return trypnfs;
 }
 
+/* Resend all requests through pnfs. */
+int pnfs_read_resend_pnfs(struct nfs_pgio_header *hdr)
+{
+	struct nfs_pageio_descriptor pgio;
+
+	nfs_pageio_init_read(&pgio, hdr->inode, false, hdr->completion_ops);
+	return nfs_pageio_resend(&pgio, hdr);
+}
+EXPORT_SYMBOL_GPL(pnfs_read_resend_pnfs);
+
 static void
 pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	enum pnfs_try_status trypnfs;
+	int err = 0;
 
 	trypnfs = pnfs_try_to_read_data(hdr, call_ops, lseg);
-	if (trypnfs == PNFS_NOT_ATTEMPTED)
+	if (trypnfs == PNFS_TRY_AGAIN)
+		err = pnfs_read_resend_pnfs(hdr);
+	if (trypnfs == PNFS_NOT_ATTEMPTED || err)
 		pnfs_read_through_mds(desc, hdr);
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ebb4e82..26e7cd8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -72,6 +72,7 @@ struct pnfs_layout_segment {
 enum pnfs_try_status {
 	PNFS_ATTEMPTED     = 0,
 	PNFS_NOT_ATTEMPTED = 1,
+	PNFS_TRY_AGAIN     = 2,
 };
 
 #ifdef CONFIG_NFS_V4_1
@@ -268,6 +269,7 @@ int _pnfs_return_layout(struct inode *);
 int pnfs_commit_and_return_layout(struct inode *);
 void pnfs_ld_write_done(struct nfs_pgio_header *);
 void pnfs_ld_read_done(struct nfs_pgio_header *);
+int pnfs_read_resend_pnfs(struct nfs_pgio_header *);
 struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       struct nfs_open_context *ctx,
 					       loff_t pos,
-- 
1.9.3

