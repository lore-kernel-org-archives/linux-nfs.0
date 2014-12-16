Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:39812 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbaLPTDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:03:31 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so14441325pdi.17
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:03:30 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 43/50] nfs41: add range to layoutreturn args
Date: Tue, 16 Dec 2014 11:01:46 -0800
Message-Id: <1418756513-95187-44-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

So that callers can specify which range to return.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/nfs4xdr.c        |  6 +++---
 fs/nfs/pnfs.c           | 14 +++++++++-----
 include/linux/nfs_xdr.h |  2 +-
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3c3ff63..56d4c91 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2012,11 +2012,11 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(0);		/* reclaim. always 0 for now */
 	*p++ = cpu_to_be32(args->layout_type);
-	*p++ = cpu_to_be32(args->iomode);
+	*p++ = cpu_to_be32(args->range.iomode);
 	*p = cpu_to_be32(RETURN_FILE);
 	p = reserve_space(xdr, 16);
-	p = xdr_encode_hyper(p, 0);
-	p = xdr_encode_hyper(p, NFS4_MAX_UINT64);
+	p = xdr_encode_hyper(p, args->range.offset);
+	p = xdr_encode_hyper(p, args->range.length);
 	spin_lock(&args->inode->i_lock);
 	encode_nfs4_stateid(xdr, &args->stateid);
 	spin_unlock(&args->inode->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 10e9aaf..a368c74 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -52,7 +52,7 @@ static LIST_HEAD(pnfs_modules_tbl);
 
 static int
 pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
-		       enum pnfs_iomode iomode);
+		       enum pnfs_iomode iomode, u64 offset, u64 length);
 
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
@@ -391,7 +391,8 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 		if (need_return) {
 			spin_unlock(&inode->i_lock);
 			/* hdr reference dropped in nfs4_layoutreturn_release */
-			pnfs_send_layoutreturn(lo, stateid, iomode);
+			pnfs_send_layoutreturn(lo, stateid, iomode, 0,
+					       NFS4_MAX_UINT64);
 			spin_lock(&inode->i_lock);
 			pnfs_layout_remove_lseg(lo, lseg);
 			spin_unlock(&inode->i_lock);
@@ -904,7 +905,7 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
 
 static int
 pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
-		       enum pnfs_iomode iomode)
+		       enum pnfs_iomode iomode, u64 offset, u64 length)
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs4_layoutreturn *lrp;
@@ -923,7 +924,9 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 	lrp->args.stateid = stateid;
 	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
 	lrp->args.inode = ino;
-	lrp->args.iomode = iomode;
+	lrp->args.range.iomode = iomode;
+	lrp->args.range.offset = offset;
+	lrp->args.range.length = length;
 	lrp->args.layout = lo;
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
@@ -994,7 +997,8 @@ _pnfs_return_layout(struct inode *ino)
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
-	status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY);
+	status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
+					NFS4_MAX_UINT64);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6400a1e..3637923 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -293,7 +293,7 @@ struct nfs4_layoutreturn_args {
 	struct nfs4_sequence_args seq_args;
 	struct pnfs_layout_hdr *layout;
 	struct inode *inode;
-	enum pnfs_iomode iomode;
+	struct pnfs_layout_range range;
 	nfs4_stateid stateid;
 	__u32   layout_type;
 };
-- 
1.9.3

