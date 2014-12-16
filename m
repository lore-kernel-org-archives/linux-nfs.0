Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:65152 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbaLPTD1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:03:27 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so14435844pdi.16
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:03:27 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 42/50] pnfs: allow LD to ask to resend read through pnfs
Date: Tue, 16 Dec 2014 11:01:45 -0800
Message-Id: <1418756513-95187-43-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
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
index 732ab7a..10e9aaf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1887,15 +1887,28 @@ pnfs_try_to_read_data(struct nfs_pgio_header *hdr,
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

