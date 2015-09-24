Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32985 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754517AbbIXMzd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:55:33 -0400
Received: by pacex6 with SMTP id ex6so72666621pac.0
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:55:33 -0700 (PDT)
Subject: [PATCH 1/8] NFS: Get rid of the unneeded addr stored in callback
 arguments
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F2B9.2060405@gmail.com>
Date: Thu, 24 Sep 2015 20:55:21 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c36fca52f5 "NFS refactor nfs_find_client and reference client
across callback processing" has store clp in cb_process_state
which is set in cb_sequence.

So that, it's unneeded to store address pointer in any callback arguments.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback.h     | 5 -----
 fs/nfs/callback_xdr.c | 5 -----
 2 files changed, 10 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 84326e9..0a590f0 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -61,7 +61,6 @@ struct cb_compound_hdr_res {
 };
 
 struct cb_getattrargs {
-	struct sockaddr *addr;
 	struct nfs_fh fh;
 	uint32_t bitmap[2];
 };
@@ -76,7 +75,6 @@ struct cb_getattrres {
 };
 
 struct cb_recallargs {
-	struct sockaddr *addr;
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	uint32_t truncate;
@@ -134,7 +132,6 @@ extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
 #define RCA4_TYPE_MASK_ALL 0xf31f
 
 struct cb_recallanyargs {
-	struct sockaddr	*craa_addr;
 	uint32_t	craa_objs_to_keep;
 	uint32_t	craa_type_mask;
 };
@@ -144,7 +141,6 @@ extern __be32 nfs4_callback_recallany(struct cb_recallanyargs *args,
 					struct cb_process_state *cps);
 
 struct cb_recallslotargs {
-	struct sockaddr	*crsa_addr;
 	uint32_t	crsa_target_highest_slotid;
 };
 extern __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args,
@@ -152,7 +148,6 @@ extern __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args,
 					 struct cb_process_state *cps);
 
 struct cb_layoutrecallargs {
-	struct sockaddr		*cbl_addr;
 	uint32_t		cbl_recall_type;
 	uint32_t		cbl_layout_type;
 	uint32_t		cbl_layoutchanged;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 6b1697a..e87d7f0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -198,7 +198,6 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	status = decode_fh(xdr, &args->fh);
 	if (unlikely(status != 0))
 		goto out;
-	args->addr = svc_addr(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
@@ -210,7 +209,6 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 *p;
 	__be32 status;
 
-	args->addr = svc_addr(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
@@ -236,7 +234,6 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 	__be32 status = 0;
 	uint32_t iomode;
 
-	args->cbl_addr = svc_addr(rqstp);
 	p = read_buf(xdr, 4 * sizeof(uint32_t));
 	if (unlikely(p == NULL)) {
 		status = htonl(NFS4ERR_BADXDR);
@@ -500,7 +497,6 @@ static __be32 decode_recallany_args(struct svc_rqst *rqstp,
 	uint32_t bitmap[2];
 	__be32 *p, status;
 
-	args->craa_addr = svc_addr(rqstp);
 	p = read_buf(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
@@ -519,7 +515,6 @@ static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
 {
 	__be32 *p;
 
-	args->crsa_addr = svc_addr(rqstp);
 	p = read_buf(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
-- 
2.5.0

