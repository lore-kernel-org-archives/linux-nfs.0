Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CDE45304C9
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170121; cv=none; b=PyAUR/4AymqkmsWGgg9o+AO416jBsdmClg0wQQU5NpmthmLwtKKduPulqHNH/nZYh7BcYM8TmG97cjv4bciY3L7INUOZ9JmIoLIoaCw+NQK1rd4wntG4HypaQM3J0T/KIWTnwD0ZqxAsptT2LEYhnAX9Eo8SqlnjIuIIb0mD0rw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170121; c=relaxed/simple;
	bh=MFltlayBlZk5MVhC61C00P8/xG7vyCYw9Ef8b8jaOvc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rcN7qhJEEnxljXY5938Qqd0kgrbKhMDUNnmdccVuobqvbk0VSdOzeHLay5HHohDoHE8ctTIjYAT5tc8uDQ+MHFpb+VaCc191VRUAQhuhMUuaS1hUtE6biwXMPkitODLivsL5ozTi0XbjVjhkioWs5nFJePtkKbtUsODQjypAGxc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CWWjyVUy; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CWWjyVUy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96C921F00893;
	Wed, 23 Sep 2026 13:28:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170120;
	bh=j0881IVm8y8dAeSP67oGSnYaB5U0y0YXUuK2uOPQOTo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=CWWjyVUyqACOZHtec1MAF2PiuuGcRIJKNgwvsxGvWh9m9+VWNFD15qUqxVanOyQ9U
	 PZfAWzK7pAEDUVDUJwed5SLC3SYZgNUKmvTBZ3A+z9qYlrB/Z6rXpRIS+iQMZnpzC3
	 mPCk+UBff2+1+flBUt1sk635YnGrgqTRWfgeAb3gneo8K6l+PSxaVZnYGBzw1HWSDi
	 VKOzGHYZycSFbpake9JrqmaAUWbHU9sqKQbQW8gSyNRCx9e+3yo/LAjjuCrw8508Nz
	 2LGHQtThe2uFmkHpEzQesmklP73Q5VAacGxjMu1eBaLTgETuN0QPieyXcRI/v4L5IS
	 KDx/9B5TSPlvQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 31/33] NFSD: Split struct nfsd3_readdirres
Date: Wed, 23 Sep 2026 09:28:09 -0400
Message-ID: <20260923132811.244160-32-cel@kernel.org>
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

Currently NFSv3 READDIR and READDIRPLUS share the same C structure
for encoding their results.

xdrgen defines two distinct result structures for the NFSv3 READDIR
and READDIRPLUS procedures since they are actually two distinct
procedures and have different result types.

Define a duplicate of struct nfsd3_readdirres to be used with
READDIRPLUS. Then duplicate nfsd3_init_dirlist_pages() and
nfs3svc_encode_readdirplusres() . These duplicates will use the new
result type for NFSv3 READDIRPLUS.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 30 ++++++++++++++++++++++++++----
 fs/nfsd/nfs3xdr.c  | 39 ++++++++++++++++++++++++++++++++++-----
 fs/nfsd/xdr3.h     | 17 +++++++++++++++++
 3 files changed, 77 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 0316bb60b50b..797c91fb7ad2 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -1242,6 +1242,27 @@ static __be32 nfsd3_proc_symlink(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
+static void
+nfsd3_init_dirlistplus_pages(struct svc_rqst *rqstp,
+			     struct nfsd3_readdirplusres *resp,
+			     u32 count)
+{
+	struct xdr_buf *buf = &resp->dirlist;
+	struct xdr_stream *xdr = &resp->xdr;
+	unsigned int sendbuf = min_t(unsigned int, rqstp->rq_res.buflen,
+				     svc_max_payload(rqstp));
+
+	memset(buf, 0, sizeof(*buf));
+
+	/* Reserve room for the NULL ptr & eof flag (-2 words) */
+	buf->buflen = clamp(count, (u32)(XDR_UNIT * 2), sendbuf);
+	buf->buflen -= XDR_UNIT * 2;
+	buf->pages = rqstp->rq_next_page;
+	rqstp->rq_next_page += (buf->buflen + PAGE_SIZE - 1) >> PAGE_SHIFT;
+
+	xdr_init_encode_pages(xdr, buf);
+}
+
 /**
  * nfsd3_proc_mknod - MKNOD: Create a special file
  * @rqstp: RPC transaction context
@@ -1575,7 +1596,7 @@ static __be32 nfsd3_proc_readdir(struct svc_rqst *rqstp)
 static __be32 nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 {
 	struct READDIRPLUS3args_wrapper *argp = rqstp->rq_argp;
-	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
+	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
 	loff_t offset = argp->xdrgen.cookie;
 	struct svc_fh *fhp = &argp->fh;
 
@@ -1583,7 +1604,7 @@ static __be32 nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 	trace_nfsd_vfs_readdir(rqstp, fhp, argp->xdrgen.maxcount,
 			       argp->xdrgen.cookie);
 
-	nfsd3_init_dirlist_pages(rqstp, resp, argp->xdrgen.maxcount);
+	nfsd3_init_dirlistplus_pages(rqstp, resp, argp->xdrgen.maxcount);
 	fh_copy(&resp->fh, fhp);
 	resp->common.err = nfs_ok;
 	resp->cookie_offset = 0;
@@ -2034,11 +2055,11 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 	[NFSPROC3_READDIRPLUS] = {
 		.pc_func	= nfsd3_proc_readdirplus,
 		.pc_decode	= nfs_svc_decode_READDIRPLUS3args,
-		.pc_encode	= nfs3svc_encode_readdirres,
+		.pc_encode	= nfs3svc_encode_readdirplusres,
 		.pc_release	= nfs3svc_release_fhandle,
 		.pc_argsize	= sizeof(struct READDIRPLUS3args_wrapper),
 		.pc_argzero	= 0,
-		.pc_ressize	= sizeof(struct nfsd3_readdirres),
+		.pc_ressize	= sizeof(struct nfsd3_readdirplusres),
 		.pc_cachetype	= RC_NOCACHE,
 		.pc_name	= "READDIRPLUS",
 	},
@@ -2125,6 +2146,7 @@ union nfsd3_xdrstore {
 	struct READ3res			readres;
 	struct nfsd3_writeres		writeres;
 	struct nfsd3_readdirres		readdirres;
+	struct nfsd3_readdirplusres	readdirplusres;
 	struct FSSTAT3args_wrapper	fsstatargs;
 	struct nfsd3_fsstatres		fsstatres;
 	struct FSINFO3args_wrapper	fsinfoargs;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index a28c3e636284..2d00343ed202 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -228,7 +228,6 @@ svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
  * XDR encode functions
  */
 
-/* READDIR */
 bool
 nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -259,8 +258,38 @@ nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return true;
 }
 
+bool
+nfs3svc_encode_readdirplusres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
+{
+	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
+	struct xdr_buf *dirlist = &resp->dirlist;
+
+	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
+		return false;
+	switch (resp->status) {
+	case nfs_ok:
+		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
+			return false;
+		if (!svcxdr_encode_cookieverf3(xdr, resp->verf))
+			return false;
+		svcxdr_encode_opaque_pages(rqstp, xdr, dirlist->pages, 0,
+					   dirlist->len);
+		/* no more entries */
+		if (xdr_stream_encode_item_absent(xdr) < 0)
+			return false;
+		if (xdr_stream_encode_bool(xdr, resp->common.err == nfserr_eof) < 0)
+			return false;
+		break;
+	default:
+		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
+			return false;
+	}
+
+	return true;
+}
+
 static __be32
-compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
+compose_entry_fh(struct nfsd3_readdirplusres *cd, struct svc_fh *fhp,
 		 const char *name, int namlen, u64 ino)
 {
 	struct svc_export	*exp;
@@ -373,7 +402,7 @@ int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
 }
 
 static bool
-svcxdr_encode_entry3_plus(struct nfsd3_readdirres *resp, const char *name,
+svcxdr_encode_entry3_plus(struct nfsd3_readdirplusres *resp, const char *name,
 			  int namlen, u64 ino)
 {
 	struct xdr_stream *xdr = &resp->xdr;
@@ -425,8 +454,8 @@ int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 			      loff_t offset, u64 ino, unsigned int d_type)
 {
 	struct readdir_cd *ccd = data;
-	struct nfsd3_readdirres *resp =
-		container_of(ccd, struct nfsd3_readdirres, common);
+	struct nfsd3_readdirplusres *resp =
+		container_of(ccd, struct nfsd3_readdirplusres, common);
 	unsigned int starting_length = resp->dirlist.len;
 	struct xdr_stream *xdr = &resp->xdr;
 
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index ad3cfd629494..a9e3ac100251 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -79,6 +79,22 @@ struct nfsd3_readdirres {
 
 };
 
+struct nfsd3_readdirplusres {
+	/* Components of the reply */
+	__be32			status;
+	struct svc_fh		fh;
+	__be32			verf[2];
+
+	/* Used to encode the reply's entry list */
+	struct xdr_stream	xdr;
+	struct xdr_buf		dirlist;
+	struct svc_fh		scratch;
+	struct readdir_cd	common;
+	unsigned int		cookie_offset;
+	struct svc_rqst *	rqstp;
+
+};
+
 struct nfsd3_fsstatres {
 	struct FSSTAT3res	xdrgen;
 	struct kstatfs		stats;
@@ -115,6 +131,7 @@ struct nfsd3_getaclres {
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
+bool nfs3svc_encode_readdirplusres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
 
-- 
2.55.0

