Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9516598BF4
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576169; cv=none; b=JcmtXdPndjrq4dksolPZRAE023Zf6AUkDM9gfiJRweAVhI+LJmKQKsGLEJeNFSF4etLmhSyLmgMaZaxXSkHKhvOvqIlmWK+2XGdrhA3ByxX5H1kLouor3DHVxO4tHNcgXy20YilcIqY2PuoHE30b2r7XeQ5MbSPhthu5Cq2We9E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576169; c=relaxed/simple;
	bh=HxtmZv2tagehO8cxmPY9R/4VldPC1gpWcqbIbKngCmc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=W6w5J8siseFnydPSRfiguHEIJj75U1ntYDpg/1wfoUuVN1IlnvVX2EKOmG4vWSOjBbAJmkMQK+HujIGrtNIHHWAqrrR8JXVqnGoK79/03dceGyPmnoo7rrBxwtFkVsG3K52lEBaGKfjbwCtxYARi5Ue8atkF7MOy9dlm2lByglk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lLXDt3yu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lLXDt3yu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D7201F0089B;
	Wed, 16 Sep 2026 16:29:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576166;
	bh=3wjwDGpbkYwEdzCXecAoo5fdVDTlFQE0+mtdrQjIF5A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lLXDt3yuSpzGyzZOSSSIwavK9XeJ9YXfVh9azKH6fgBPwmFUXaqvmypeaG2qCdDyJ
	 e3XO+M9qb/jJiMbEWHraMKcFb0yacyZ0EyIvAqlstFYyhHWIqhfj+pLH4HqTRya/Og
	 b15K77NlyphTwft+e0a69ouIYtGb996XkuafmKpWOqmMdae9LntXqJwlP95jgsDKSx
	 pZcB3UNpRSn/pyeYB4P6W+hKXOvvkiovxy9z/ogVPPt+pwvVr5y5TQRRoK94VgGj8s
	 ilUuZw2M/A6PhejzENLLyR1BlgwyZMcZuLqhg6Awwa9RAcZO5Fy2Swsnt1lmjYENbH
	 owM6ImZ54cwow==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 22/27] NFSD: Use xdrgen XDR functions for NFSv2 RMDIR procedure
Date: Wed, 16 Sep 2026 12:28:53 -0400
Message-ID: <20260916162859.2051-25-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC_RMDIR entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_diropargs and nfs_svc_encode_nfsstat. A wrapper
structure bridges the generated xdrgen diropargs type and the
legacy svc_fh representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 RMDIR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

RMDIR is the last procedure to use the hand-coded
nfssvc_decode_diropargs() and nfssvc_encode_statres(), so they no
longer have any callers and are removed, along with the
svcxdr_decode_diropargs() and svcxdr_decode_filename() helpers
they relied on. The now-unused nfsd_diropargs and nfsd_stat
structures are removed as well.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 50 +++++++++++++++++++++++++++++------------------
 fs/nfsd/nfsxdr.c  | 48 ---------------------------------------------
 fs/nfsd/xdr.h     | 12 ------------
 3 files changed, 31 insertions(+), 79 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 8317029850c9..ddf743aea89c 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -1082,19 +1082,31 @@ static __be32 nfsd_proc_mkdir(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Remove a directory
+/**
+ * nfsd_proc_rmdir - RMDIR: Remove a directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   nfsstat NFSPROC_RMDIR(diropargs) = 15;
  */
-static __be32
-nfsd_proc_rmdir(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_rmdir(struct svc_rqst *rqstp)
 {
-	struct nfsd_diropargs *argp = rqstp->rq_argp;
-	struct nfsd_stat *resp = rqstp->rq_resp;
+	struct diropargs_wrapper *argp = rqstp->rq_argp;
+	struct diropargs *object = &argp->xdrgen;
+	nfsstat *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
-	resp->status = nfsd_unlink(rqstp, &argp->fh, S_IFDIR,
-				   argp->name, argp->len);
-	fh_put(&argp->fh);
-	resp->status = nfsd_map_status(resp->status);
+	nfsd_fhandle_to_svc_fh(fhp, &object->dir);
+
+	/* Unlink. S_IFDIR means file must be a directory */
+	*resp = nfsd_unlink(rqstp, fhp, S_IFDIR,
+			    (char *)object->name.data, object->name.len);
+	*resp = nfsd_map_status(*resp);
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1334,15 +1346,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "MKDIR",
 	},
 	[NFSPROC_RMDIR] = {
-		.pc_func = nfsd_proc_rmdir,
-		.pc_decode = nfssvc_decode_diropargs,
-		.pc_encode = nfssvc_encode_statres,
-		.pc_argsize = sizeof(struct nfsd_diropargs),
-		.pc_argzero = sizeof(struct nfsd_diropargs),
-		.pc_ressize = sizeof(struct nfsd_stat),
-		.pc_cachetype = RC_REPLSTAT,
-		.pc_xdrressize = ST,
-		.pc_name = "RMDIR",
+		.pc_func	= nfsd_proc_rmdir,
+		.pc_decode	= nfs_svc_decode_diropargs,
+		.pc_encode	= nfs_svc_encode_nfsstat,
+		.pc_argsize	= sizeof(struct diropargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(nfsstat),
+		.pc_cachetype	= RC_REPLSTAT,
+		.pc_xdrressize	= NFS2_nfsstat_sz,
+		.pc_name	= "RMDIR",
 	},
 	[NFSPROC_READDIR] = {
 		.pc_func = nfsd_proc_readdir,
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 8989957a94e0..e839de8c9815 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -92,38 +92,6 @@ encode_timeval(__be32 *p, const struct timespec64 *time)
 	return p;
 }
 
-static bool
-svcxdr_decode_filename(struct xdr_stream *xdr, char **name, unsigned int *len)
-{
-	u32 size, i;
-	__be32 *p;
-	char *c;
-
-	if (xdr_stream_decode_u32(xdr, &size) < 0)
-		return false;
-	if (size == 0 || size > NFS_MAXNAMLEN)
-		return false;
-	p = xdr_inline_decode(xdr, size);
-	if (!p)
-		return false;
-
-	*len = size;
-	*name = (char *)p;
-	for (i = 0, c = *name; i < size; i++, c++)
-		if (*c == '\0' || *c == '/')
-			return false;
-
-	return true;
-}
-
-static bool
-svcxdr_decode_diropargs(struct xdr_stream *xdr, struct svc_fh *fhp,
-			char **name, unsigned int *len)
-{
-	return svcxdr_decode_fhandle(xdr, fhp) &&
-		svcxdr_decode_filename(xdr, name, len);
-}
-
 /**
  * svcxdr_encode_fattr - Encode NFSv2 file attributes
  * @rqstp: Context of a completed RPC transaction
@@ -205,14 +173,6 @@ nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_fhandle(xdr, &args->fh);
 }
 
-bool
-nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_diropargs *args = rqstp->rq_argp;
-
-	return svcxdr_decode_diropargs(xdr, &args->fh, &args->name, &args->len);
-}
-
 bool
 nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -232,14 +192,6 @@ nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
  * XDR encode functions
  */
 
-bool
-nfssvc_encode_statres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_stat *resp = rqstp->rq_resp;
-
-	return svcxdr_encode_stat(xdr, resp->status);
-}
-
 bool
 nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index bd3123179f61..64e0febe32da 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -8,22 +8,12 @@
 
 #include "vfs.h"
 
-struct nfsd_diropargs {
-	struct svc_fh		fh;
-	char *			name;
-	unsigned int		len;
-};
-
 struct nfsd_readdirargs {
 	struct svc_fh		fh;
 	__u32			cookie;
 	__u32			count;
 };
 
-struct nfsd_stat {
-	__be32			status;
-};
-
 struct nfsd_attrstat {
 	__be32			status;
 	struct svc_fh		fh;
@@ -49,10 +39,8 @@ struct nfsd_statfsres {
 };
 
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
-bool nfssvc_encode_statres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0

