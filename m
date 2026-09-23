Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30043328B71
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170105; cv=none; b=N/RVdPIBOj/Tn0iEX1JBaOCL3KJJj0HTB6zTln/2mJhDNMSQTHWMan3giN+XDkdHHdgf8W+4zyxUczx6uM4P3o2Cjic0U3XRJgkbUiLcLA77znZK6/qi7jOT2edNzvEQW8CUnkzEitjmyhSyZZeJJzes4sayNvcEiGL4yOtr3nA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170105; c=relaxed/simple;
	bh=KS9TmCBCTb1bb+mJyoSYPc1EgdbxOHMGBUOhTqoXkQ8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lUj82DxkAAwWa1dmyUCzaNKu8ay13QVMqthEeGMAxaUofkajom3WSvneeEHMlqfKQ/MlCYYNEXr4NEtl3RB2LEUVq1oQ/GFrxklwU+C4U3Qwey1LD4SgMlmsCKO8ukvnj6HbqkJzChzxH3t5OlcUCxllUrWjo61SZKvijNSw1X8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UyVK028i; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UyVK028i"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C3751F00899;
	Wed, 23 Sep 2026 13:28:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170103;
	bh=R7AJ6vIygFwP7h6BidVZgmkVkbLXqXaiG+M+iR53vuQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UyVK028igE1ItFMgCCf7I0stV3mt0CCZKtF7M21pwyeMDJnz1Y1O09IuCBdM9aGwS
	 +PYmqrlg21W15N4+6BY7kMNhW4tb3IEKE+Rs2Nrbh57GMcs9jJehINRv1VZ5ucunUz
	 SPcF7eqQ+UE59cQOetukRppR+NVX7I7kvlmFlIAtD/eZ1rUQxcZmsBAZkqjFNPNnrT
	 7lKL/X+9HJhR9cLBFEnaxIGvjafZg6igBglWVB9eSIr/28fdjt8Re6ZDWDZdngJ4DA
	 aOTGAkxQazuwff1ZFY3BK8jEZyf7w3e5rZNzPZKIfI95zLDSrPc6ydAlru50g//31I
	 Z4Dk+cmahHY+A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 10/33] NFSD: Use xdrgen XDR functions for the NFSv3 LOOKUP procedure
Date: Wed, 23 Sep 2026 09:27:48 -0400
Message-ID: <20260923132811.244160-11-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260923132811.244160-1-cel@kernel.org>
References: <20260923132811.244160-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_LOOKUP entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_LOOKUP3args and nfs_svc_encode_LOOKUP3res. Wrapper
structures bridge the generated xdrgen types and the legacy svc_fh
representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv3 LOOKUP
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

nfs3svc_decode_diropargs() rejects an empty name, a name longer
than NFS3_MAXNAMLEN, and a name containing '/' or NUL. The
generated filename3 decoder checks none of these. Introduce
nfsd3_check_filename() so that nfsd3_proc_lookup() applies the same
checks before it calls nfsd_lookup(). After the change, a name that
fails them draws NFS3ERR_INVAL or NFS3ERR_NAMETOOLONG rather than
GARBAGE_ARGS. Later procedures that take a filename share the helper.

Because nfsd3_proc_lookup() now fills in the post-op attributes,
the fh_getattr() calls are made in the proc function rather than in
the XDR result encoder, and the references to the file handles can
be released directly by nfsd3_proc_lookup(). A separate ->pc_release
callback is thus no longer needed. This makes it straightforward to
confirm that the file handles are properly released during every
error flow.

Following the precedent of commit 40ee5dc6af35 ("knfsd: 64 bit ino
support for NFS server"), lease_get_mtime() determines the file's
mtime when filling in post-op attributes, but is not used for WCC
data. This seems odd to me; NFSv4 does not use lease_get_mtime() at
all, and not using it for WCC data seems like an NFSv3 file's
reported mtime values might vary depending on how the file metadata
is queried.

nfs3svc_encode_lookupres() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 116 +++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs3xdr.c  |  25 ----------
 fs/nfsd/xdr3.h     |   1 -
 3 files changed, 90 insertions(+), 52 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 815722afde9a..735b4fc21336 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -56,6 +56,21 @@ struct SETATTR3args_wrapper {
 
 static_assert(offsetof(struct SETATTR3args_wrapper, xdrgen) == 0);
 
+struct LOOKUP3args_wrapper {
+	struct LOOKUP3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct LOOKUP3args_wrapper, xdrgen) == 0);
+
+struct LOOKUP3res_wrapper {
+	struct LOOKUP3res	xdrgen;
+	struct svc_fh		fh;
+	u8			fh_data[NFS3_FHSIZE];
+};
+
+static_assert(offsetof(struct LOOKUP3res_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -170,6 +185,14 @@ nfsd3_fh3_to_svc_fh(struct svc_fh *fhp, const struct nfs_fh3 *fh3)
 	memcpy(&fhp->fh_handle.fh_raw, fh3->data.data, fh3->data.len);
 }
 
+static __always_inline void
+nfsd3_svc_fh_to_fh3(struct nfs_fh3 *fh3, const struct svc_fh *fhp, u8 *scratch)
+{
+	memcpy(scratch, fhp->fh_handle.fh_raw, fhp->fh_handle.fh_size);
+	fh3->data.data = scratch;
+	fh3->data.len = fhp->fh_handle.fh_size;
+}
+
 static __always_inline void
 nfsd3_timespec64_to_nfstime3(struct nfstime3 *dst,
 			     const struct timespec64 *src)
@@ -178,6 +201,22 @@ nfsd3_timespec64_to_nfstime3(struct nfstime3 *dst,
 	dst->nseconds = src->tv_nsec;
 }
 
+static __be32
+nfsd3_check_filename(const unsigned char *name, u32 len)
+{
+	u32 i;
+
+	if (len == 0)
+		return nfserr_inval;
+	if (len > NFS3_MAXNAMLEN)
+		return nfserr_nametoolong;
+	for (i = 0; i < len; i++) {
+		if (name[i] == '\0' || name[i] == '/')
+			return nfserr_inval;
+	}
+	return nfs_ok;
+}
+
 static u32
 nfsd3_mode_to_ftype3(umode_t mode)
 {
@@ -458,27 +497,51 @@ static __be32 nfsd3_proc_setattr(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Look up a path name component
+/**
+ * nfsd3_proc_lookup - LOOKUP: Look up file name
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   LOOKUP3res NFSPROC3_LOOKUP(LOOKUP3args) = 3;
  */
-static __be32
-nfsd3_proc_lookup(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_lookup(struct svc_rqst *rqstp)
 {
-	struct nfsd3_diropargs *argp = rqstp->rq_argp;
-	struct nfsd3_diropres  *resp = rqstp->rq_resp;
+	struct LOOKUP3args_wrapper *argp = rqstp->rq_argp;
+	struct LOOKUP3res_wrapper *resp = rqstp->rq_resp;
+	struct diropargs3 *what = &argp->xdrgen.what;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
 
-	dprintk("nfsd: LOOKUP(3)   %s %.*s\n",
-				SVCFH_fmt(&argp->fh),
-				argp->len,
-				argp->name);
+	nfsd3_fh3_to_svc_fh(dirfhp, &what->dir);
 
-	fh_copy(&resp->dirfh, &argp->fh);
-	fh_init(&resp->fh, NFS3_FHSIZE);
+	fh_init(fhp, NFS3_FHSIZE);
+	resp->xdrgen.status = nfsd3_check_filename(what->name.data,
+						   what->name.len);
+	if (resp->xdrgen.status != nfs_ok)
+		goto out;
+	resp->xdrgen.status = nfsd_lookup(rqstp, dirfhp,
+					  (char *)what->name.data,
+					  what->name.len, fhp);
 
-	resp->status = nfsd_lookup(rqstp, &resp->dirfh,
-				   argp->name, argp->len,
-				   &resp->fh);
-	resp->status = nfsd3_map_status(resp->status);
+out:
+	if (resp->xdrgen.status == nfs_ok) {
+		struct LOOKUP3resok *resok = &resp->xdrgen.u.resok;
+
+		nfsd3_svc_fh_to_fh3(&resok->object, fhp, resp->fh_data);
+		nfsd3_fill_post_op_attr(rqstp, &resok->obj_attributes, fhp);
+		nfsd3_fill_post_op_attr(rqstp, &resok->dir_attributes, dirfhp);
+	} else {
+		struct LOOKUP3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		resp->xdrgen.status = nfsd3_map_status(resp->xdrgen.status);
+		nfsd3_fill_post_op_attr(rqstp, &resfail->dir_attributes, dirfhp);
+	}
+
+	fh_put(fhp);
+	fh_put(dirfhp);
 	return rpc_success;
 }
 
@@ -1224,16 +1287,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "SETATTR",
 	},
 	[NFSPROC3_LOOKUP] = {
-		.pc_func = nfsd3_proc_lookup,
-		.pc_decode = nfs3svc_decode_diropargs,
-		.pc_encode = nfs3svc_encode_lookupres,
-		.pc_release = nfs3svc_release_fhandle2,
-		.pc_argsize = sizeof(struct nfsd3_diropargs),
-		.pc_argzero = sizeof(struct nfsd3_diropargs),
-		.pc_ressize = sizeof(struct nfsd3_diropres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+FH+pAT+pAT,
-		.pc_name = "LOOKUP",
+		.pc_func	= nfsd3_proc_lookup,
+		.pc_decode	= nfs_svc_decode_LOOKUP3args,
+		.pc_encode	= nfs_svc_encode_LOOKUP3res,
+		.pc_argsize	= sizeof(struct LOOKUP3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct LOOKUP3res_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS3_LOOKUP3res_sz,
+		.pc_name	= "LOOKUP",
 	},
 	[NFSPROC3_ACCESS] = {
 		.pc_func = nfsd3_proc_access,
@@ -1456,6 +1518,8 @@ union nfsd3_xdrstore {
 	struct GETATTR3res_wrapper	getattrres;
 	struct SETATTR3args_wrapper	setattrargs;
 	struct SETATTR3res		setattrres;
+	struct LOOKUP3args_wrapper	lookupargs;
+	struct LOOKUP3res_wrapper	lookupres;
 	struct nfsd3_diropargs		diropargs;
 	struct nfsd3_readargs		readargs;
 	struct nfsd3_writeargs		writeargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index eb5f3148a0ab..36c22611370d 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -721,31 +721,6 @@ nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh);
 }
 
-/* LOOKUP */
-bool
-nfs3svc_encode_lookupres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_diropres *resp = rqstp->rq_resp;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_nfs_fh3(xdr, &resp->fh))
-			return false;
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->dirfh))
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->dirfh))
-			return false;
-	}
-
-	return true;
-}
-
 /* ACCESS */
 bool
 nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 354cff178b75..d17192f3c983 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -252,7 +252,6 @@ bool nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, struct xdr_stream *x
 bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_lookupres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0

