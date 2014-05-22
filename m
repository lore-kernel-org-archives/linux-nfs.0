Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isis.lip6.fr ([132.227.60.2]:57543 "EHLO isis.lip6.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498AbaEVOn5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 10:43:57 -0400
From: Benoit Taine <benoit.taine@lip6.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: benoit.taine@lip6.fr, kernel-janitors@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: Remove assignments inside conditions
Date: Thu, 22 May 2014 16:32:30 +0200
Message-Id: <1400769150-416-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Assignments should not happen inside an if conditional, but in the line
before. This issue was reported by checkpatch.

The semantic patch that makes this change is as follows
(http://coccinelle.lip6.fr/):

// <smpl>

@@
identifier i1;
expression e1;
statement S;
@@
-if(!(i1 = e1)) S
+i1 = e1;
+if(!i1)
+S

// </smpl>

It has been tested by compilation.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>
---
 fs/nfsd/nfs2acl.c |   12 ++++++++----
 fs/nfsd/nfs3acl.c |    6 ++++--
 fs/nfsd/nfs3xdr.c |   27 ++++++++++++++++++---------
 fs/nfsd/nfsxdr.c  |   15 ++++++++++-----
 4 files changed, 40 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 11c1fba..12b023a 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -182,7 +182,8 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp, struct nfsd3_accessarg
 static int nfsaclsvc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_getaclargs *argp)
 {
-	if (!(p = nfs2svc_decode_fh(p, &argp->fh)))
+	p = nfs2svc_decode_fh(p, &argp->fh);
+	if (!p)
 		return 0;
 	argp->mask = ntohl(*p); p++;
 
@@ -197,7 +198,8 @@ static int nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
 	unsigned int base;
 	int n;
 
-	if (!(p = nfs2svc_decode_fh(p, &argp->fh)))
+	p = nfs2svc_decode_fh(p, &argp->fh);
+	if (!p)
 		return 0;
 	argp->mask = ntohl(*p++);
 	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT) ||
@@ -218,7 +220,8 @@ static int nfsaclsvc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
 static int nfsaclsvc_decode_fhandleargs(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd_fhandle *argp)
 {
-	if (!(p = nfs2svc_decode_fh(p, &argp->fh)))
+	p = nfs2svc_decode_fh(p, &argp->fh);
+	if (!p)
 		return 0;
 	return xdr_argsize_check(rqstp, p);
 }
@@ -226,7 +229,8 @@ static int nfsaclsvc_decode_fhandleargs(struct svc_rqst *rqstp, __be32 *p,
 static int nfsaclsvc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_accessargs *argp)
 {
-	if (!(p = nfs2svc_decode_fh(p, &argp->fh)))
+	p = nfs2svc_decode_fh(p, &argp->fh);
+	if (!p)
 		return 0;
 	argp->access = ntohl(*p++);
 
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index adc5f1b..2a514e2 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -128,7 +128,8 @@ out:
 static int nfs3svc_decode_getaclargs(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_getaclargs *args)
 {
-	if (!(p = nfs3svc_decode_fh(p, &args->fh)))
+	p = nfs3svc_decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	args->mask = ntohl(*p); p++;
 
@@ -143,7 +144,8 @@ static int nfs3svc_decode_setaclargs(struct svc_rqst *rqstp, __be32 *p,
 	unsigned int base;
 	int n;
 
-	if (!(p = nfs3svc_decode_fh(p, &args->fh)))
+	p = nfs3svc_decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	args->mask = ntohl(*p++);
 	if (args->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT) ||
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index de6e39e..e6c01e8 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -278,7 +278,8 @@ void fill_post_wcc(struct svc_fh *fhp)
 int
 nfs3svc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p, struct nfsd_fhandle *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	return xdr_argsize_check(rqstp, p);
 }
@@ -287,7 +288,8 @@ int
 nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_sattrargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	p = decode_sattr3(p, &args->attrs);
 
@@ -315,7 +317,8 @@ int
 nfs3svc_decode_accessargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_accessargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	args->access = ntohl(*p++);
 
@@ -330,7 +333,8 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 	int v;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	p = xdr_decode_hyper(p, &args->offset);
 
@@ -360,7 +364,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	unsigned int len, v, hdr, dlen;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	p = xdr_decode_hyper(p, &args->offset);
 
@@ -535,7 +540,8 @@ int
 nfs3svc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_readlinkargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	args->buffer = page_address(*(rqstp->rq_next_page++));
 
@@ -558,7 +564,8 @@ int
 nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_readdirargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	p = xdr_decode_hyper(p, &args->cookie);
 	args->verf   = p; p += 2;
@@ -580,7 +587,8 @@ nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
 	int len;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	p = xdr_decode_hyper(p, &args->cookie);
 	args->verf     = p; p += 2;
@@ -605,7 +613,8 @@ int
 nfs3svc_decode_commitargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_commitargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	p = xdr_decode_hyper(p, &args->offset);
 	args->count = ntohl(*p++);
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 9c769a4..1ac306b 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -214,7 +214,8 @@ nfssvc_decode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
 int
 nfssvc_decode_fhandle(struct svc_rqst *rqstp, __be32 *p, struct nfsd_fhandle *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	return xdr_argsize_check(rqstp, p);
 }
@@ -248,7 +249,8 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 {
 	unsigned int len;
 	int v;
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 
 	args->offset    = ntohl(*p++);
@@ -281,7 +283,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	unsigned int len, hdr, dlen;
 	int v;
 
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 
 	p++;				/* beginoffset */
@@ -355,7 +358,8 @@ nfssvc_decode_renameargs(struct svc_rqst *rqstp, __be32 *p,
 int
 nfssvc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd_readlinkargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	args->buffer = page_address(*(rqstp->rq_next_page++));
 
@@ -391,7 +395,8 @@ int
 nfssvc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd_readdirargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
 	args->cookie = ntohl(*p++);
 	args->count  = ntohl(*p++);

