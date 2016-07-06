Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33194 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755883AbcGFWas (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:48 -0400
Received: by mail-it0-f66.google.com with SMTP id y93so926204ita.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 11/28] pNFS: Files and flexfiles always need to commit before layoutcommit
Date: Wed,  6 Jul 2016 18:29:48 -0400
Message-Id: <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So ensure that we mark the layout for commit once the write is done,
and then ensure that the commit to ds is finished before sending
layoutcommit.

Note that by doing this, we're able to optimise away the commit
for the case of servers that don't need layoutcommit in order to
return updated attributes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c         |  9 ++++++---
 fs/nfs/flexfilelayout/flexfilelayout.c |  7 +++++--
 fs/nfs/nfs4xdr.c                       | 11 ++++++++---
 fs/nfs/pnfs.c                          |  5 ++++-
 fs/nfs/pnfs_nfs.c                      |  7 +++++++
 5 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index b4c1407e8fe4..25bd91a6e088 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -255,13 +255,16 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 static void
 filelayout_set_layoutcommit(struct nfs_pgio_header *hdr)
 {
+	loff_t end_offs = 0;
 
 	if (FILELAYOUT_LSEG(hdr->lseg)->commit_through_mds ||
-	    hdr->res.verf->committed != NFS_DATA_SYNC)
+	    hdr->res.verf->committed == NFS_FILE_SYNC)
 		return;
+	if (hdr->res.verf->committed == NFS_DATA_SYNC)
+		end_offs = hdr->mds_offset + (loff_t)hdr->res.count;
 
-	pnfs_set_layoutcommit(hdr->inode, hdr->lseg,
-			hdr->mds_offset + hdr->res.count);
+	/* Note: if the write is unstable, don't set end_offs until commit */
+	pnfs_set_layoutcommit(hdr->inode, hdr->lseg, end_offs);
 	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
 		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
 }
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 14f2ed3f1a5b..e6206eaf2bdf 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1470,6 +1470,7 @@ static void ff_layout_read_release(void *data)
 static int ff_layout_write_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
+	loff_t end_offs = 0;
 	int err;
 
 	trace_nfs4_pnfs_write(hdr, task->tk_status);
@@ -1495,8 +1496,10 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 
 	if (hdr->res.verf->committed == NFS_FILE_SYNC ||
 	    hdr->res.verf->committed == NFS_DATA_SYNC)
-		ff_layout_set_layoutcommit(hdr->inode, hdr->lseg,
-				hdr->mds_offset + (loff_t)hdr->res.count);
+		end_offs = hdr->mds_offset + (loff_t)hdr->res.count;
+
+	/* Note: if the write is unstable, don't set end_offs until commit */
+	ff_layout_set_layoutcommit(hdr->inode, hdr->lseg, end_offs);
 
 	/* zero out fattr since we don't care DS attr at all */
 	hdr->fattr.valid = 0;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 661e753fe1c9..7bd3a5c09d31 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1985,9 +1985,14 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->lastbytewritten + 1);	/* length */
 	*p = cpu_to_be32(0); /* reclaim */
 	encode_nfs4_stateid(xdr, &args->stateid);
-	p = reserve_space(xdr, 20);
-	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
-	p = xdr_encode_hyper(p, args->lastbytewritten);
+	if (args->lastbytewritten != U64_MAX) {
+		p = reserve_space(xdr, 20);
+		*p++ = cpu_to_be32(1); /* newoffset = TRUE */
+		p = xdr_encode_hyper(p, args->lastbytewritten);
+	} else {
+		p = reserve_space(xdr, 12);
+		*p++ = cpu_to_be32(0); /* newoffset = FALSE */
+	}
 	*p++ = cpu_to_be32(0); /* Never send time_modify_changed */
 	*p++ = cpu_to_be32(NFS_SERVER(args->inode)->pnfs_curr_ld->id);/* type */
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0c7e0d45a4de..62553182514e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2378,7 +2378,10 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	nfs_fattr_init(&data->fattr);
 	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
 	data->res.fattr = &data->fattr;
-	data->args.lastbytewritten = end_pos - 1;
+	if (end_pos != 0)
+		data->args.lastbytewritten = end_pos - 1;
+	else
+		data->args.lastbytewritten = U64_MAX;
 	data->res.server = NFS_SERVER(inode);
 
 	if (ld->prepare_layoutcommit) {
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 0dfc476da3e1..0d10cc280a23 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -932,6 +932,13 @@ EXPORT_SYMBOL_GPL(pnfs_layout_mark_request_commit);
 int
 pnfs_nfs_generic_sync(struct inode *inode, bool datasync)
 {
+	int ret;
+
+	if (!pnfs_layoutcommit_outstanding(inode))
+		return 0;
+	ret = nfs_commit_inode(inode, FLUSH_SYNC);
+	if (ret < 0)
+		return ret;
 	if (datasync)
 		return 0;
 	return pnfs_layoutcommit_inode(inode, true);
-- 
2.7.4

