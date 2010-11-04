Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33432 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471Ab0KDPWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:53 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMT029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:42 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/18] pnfs-submit: reorganize struct cb_layoutrecallargs
Date: Thu,  4 Nov 2010 11:22:20 -0400
Message-Id: <1288884151-11128-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback.h      |   12 ++++++++----
 fs/nfs/callback_proc.c |   16 ++++++++--------
 fs/nfs/callback_xdr.c  |   21 ++++++++++++---------
 3 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 89fee05..817b0f4 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -145,13 +145,17 @@ extern unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args,
 
 struct cb_layoutrecallargs {
 	struct sockaddr		*cbl_addr;
-	struct nfs_fh		cbl_fh;
-	struct pnfs_layout_range cbl_seg;
-	struct nfs_fsid		cbl_fsid;
 	uint32_t		cbl_recall_type;
 	uint32_t		cbl_layout_type;
 	uint32_t		cbl_layoutchanged;
-	nfs4_stateid		cbl_stateid;
+	union {
+		struct {
+			struct nfs_fh		cbl_fh;
+			struct pnfs_layout_range cbl_range;
+			nfs4_stateid		cbl_stateid;
+		};
+		struct nfs_fsid		cbl_fsid;
+	};
 };
 
 extern unsigned nfs4_callback_layoutrecall(
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 53a85648..1509c34 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -241,13 +241,13 @@ static int pnfs_recall_layout(void *data)
 	rl = *args->rl;
 
 	/* support whole file layouts only */
-	rl.cbl_seg.offset = 0;
-	rl.cbl_seg.length = NFS4_MAX_UINT64;
+	rl.cbl_range.offset = 0;
+	rl.cbl_range.length = NFS4_MAX_UINT64;
 
 	if (rl.cbl_recall_type == RETURN_FILE) {
 		if (pnfs_is_next_layout_stateid(NFS_I(inode)->layout,
 						rl.cbl_stateid))
-			status = pnfs_return_layout(inode, &rl.cbl_seg,
+			status = pnfs_return_layout(inode, &rl.cbl_range,
 						    &rl.cbl_stateid, RETURN_FILE,
 						    false);
 		else
@@ -269,7 +269,7 @@ static int pnfs_recall_layout(void *data)
 	/* IMPROVEME: This loop is inefficient, running in O(|s_inodes|^2) */
 	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
 		/* FIXME: need to check status on pnfs_return_layout */
-		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE, false);
+		pnfs_return_layout(ino, &rl.cbl_range, NULL, RETURN_FILE, false);
 		iput(ino);
 	}
 
@@ -285,7 +285,7 @@ static int pnfs_recall_layout(void *data)
 	lrp->args.layout_type = rl.cbl_layout_type;
 	lrp->args.return_type = rl.cbl_recall_type;
 	lrp->clp = clp;
-	lrp->args.range = rl.cbl_seg;
+	lrp->args.range = rl.cbl_range;
 	lrp->args.inode = inode;
 	nfs4_proc_layoutreturn(lrp, true);
 
@@ -346,9 +346,9 @@ static int pnfs_recall_all_layouts(struct nfs_client *clp)
 	int status = 0;
 
 	rl.cbl_recall_type = RETURN_ALL;
-	rl.cbl_seg.iomode = IOMODE_ANY;
-	rl.cbl_seg.offset = 0;
-	rl.cbl_seg.length = NFS4_MAX_UINT64;
+	rl.cbl_range.iomode = IOMODE_ANY;
+	rl.cbl_range.offset = 0;
+	rl.cbl_range.length = NFS4_MAX_UINT64;
 
 	/* we need the inode to get the nfs_server struct */
 	inode = nfs_layoutrecall_find_inode(clp, &rl);
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 1650ab0..695d15a 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -229,6 +229,7 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 {
 	__be32 *p;
 	__be32 status = 0;
+	uint32_t iomode;
 
 	args->cbl_addr = svc_addr(rqstp);
 	p = read_buf(xdr, 4 * sizeof(uint32_t));
@@ -238,11 +239,15 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 	}
 
 	args->cbl_layout_type = ntohl(*p++);
-	args->cbl_seg.iomode = ntohl(*p++);
+	/* Depite the spec's xdr, iomode really belongs in the FILE switch,
+	 * as it is unuseable and ignored with the other types.
+	 */
+	iomode = ntohl(*p++);
 	args->cbl_layoutchanged = ntohl(*p++);
 	args->cbl_recall_type = ntohl(*p++);
 
 	if (likely(args->cbl_recall_type == RETURN_FILE)) {
+		args->cbl_range.iomode = iomode;
 		status = decode_fh(xdr, &args->cbl_fh);
 		if (unlikely(status != 0))
 			goto out;
@@ -252,8 +257,8 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 			status = htonl(NFS4ERR_BADXDR);
 			goto out;
 		}
-		p = xdr_decode_hyper(p, &args->cbl_seg.offset);
-		p = xdr_decode_hyper(p, &args->cbl_seg.length);
+		p = xdr_decode_hyper(p, &args->cbl_range.offset);
+		p = xdr_decode_hyper(p, &args->cbl_range.length);
 		status = decode_stateid(xdr, &args->cbl_stateid);
 		if (unlikely(status != 0))
 			goto out;
@@ -266,12 +271,10 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
 		p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
 	}
-	dprintk("%s: ltype 0x%x iomode %d changed %d recall_type %d "
-		"fsid %llx-%llx fhsize %d\n", __func__,
-		args->cbl_layout_type, args->cbl_seg.iomode,
-		args->cbl_layoutchanged, args->cbl_recall_type,
-		args->cbl_fsid.major, args->cbl_fsid.minor,
-		args->cbl_fh.size);
+	dprintk("%s: ltype 0x%x iomode %d changed %d recall_type %d\n",
+		__func__,
+		args->cbl_layout_type, iomode,
+		args->cbl_layoutchanged, args->cbl_recall_type);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
-- 
1.7.2.1

