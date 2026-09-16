Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2BBD59573C
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576173; cv=none; b=Eu9FZRaUtX5OWJq+yezolfo1sJyop9/pHsnI1JpfZSVG8oUZIMa7PLqribwipI8eP24rCQ/eZDKHvv3bgoc5x06CD9fh7luHm6Qzw1Oi6hz5szdtKFiPyQ9RD77bqHtqmfgiatDs0gCk6dltlWsqjDGv1n5aRZ1xXVJc9Et7WHQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576173; c=relaxed/simple;
	bh=mFQ8RVyMEDaFIBnI8ct8mmxfORFtXc6NHVqgP7vn39I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DHTFUZjBqSTaNl2jcie06vsrY32JRyN1miDPx8/qLZWNkJgR6U5oipu2prro1C8Rsvq+M9E/ZHXJv+1Wf5eedFLrDd7WuRj/q4favDk59ySHqL/Il0mHi0nPJImAXbYT2UtPSR9tbEmAuR9AUF8TPnUxnXOJGASVLp/n/eSGk2A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KbBNmNB6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KbBNmNB6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 005671F00898;
	Wed, 16 Sep 2026 16:29:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576167;
	bh=5XANkU+qc05YfOhfm/8M3ESXS3CvxZiTNyevFcmw2k4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KbBNmNB6tikCdoX1NDZaWW5ydAU1jFNB2/rYQty9/esnAnPABivtfIVwgT0u6aGw6
	 1oe3FyiJNijyag37DFDm/kDDMA7UV6/9EgCna6BPHtHHuFuWsqXaybAfg8E04xB4dJ
	 N9OWTHTTMEz0OFp4K7oiz76QPKO3zPIaBy6B+0WYeYO9v6TNGlCv4ss5C3R0gTRoHx
	 dHFVBD05WPYhcwkUrZ4gqKhNOuEvNREutOFMdexnf606CLqaNUCzMUeefwRFhTh2mV
	 0CL8hM8tmclgrRSHCZknWrxWpiAgoXUyNaYIdV+petyQvrgqcef+LuJyMsVuaOgN4L
	 m1HiMHdCwbOhA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 24/27] NFSD: Use xdrgen XDR functions for NFSv2 READDIR arguments
Date: Wed, 16 Sep 2026 12:28:55 -0400
Message-ID: <20260916162859.2051-27-cel@kernel.org>
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

Replace the NFSPROC_READDIR entry's argument decoder in the
nfsd_procedures2 array with the xdrgen-generated
nfs_svc_decode_readdirargs. A wrapper structure bridges the
generated xdrgen readdirargs type and the legacy svc_fh
representation the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 READDIR
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 53 ++++++++++++++++++++++++++++++-----------------
 fs/nfsd/nfsxdr.c  | 15 --------------
 fs/nfsd/xdr.h     |  7 -------
 3 files changed, 34 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 327088a1012c..759bd3fc1254 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -116,6 +116,13 @@ struct statfsres_wrapper {
 
 static_assert(offsetof(struct statfsres_wrapper, xdrgen) == 0);
 
+struct readdirargs_wrapper {
+	struct readdirargs	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct readdirargs_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -1135,28 +1142,35 @@ static void nfsd_init_dirlist_pages(struct svc_rqst *rqstp,
 	xdr_init_encode_pages(xdr, buf);
 }
 
-/*
- * Read a portion of a directory.
+/**
+ * nfsd_proc_readdir - READDIR: Read from directory
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   readdirres NFSPROC_READDIR(readdirargs) = 16;
  */
-static __be32
-nfsd_proc_readdir(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_readdir(struct svc_rqst *rqstp)
 {
-	struct nfsd_readdirargs *argp = rqstp->rq_argp;
+	struct readdirargs_wrapper *argp = rqstp->rq_argp;
 	struct nfsd_readdirres *resp = rqstp->rq_resp;
-	loff_t		offset;
+	loff_t offset = be32_to_cpup((__be32 *)argp->xdrgen.cookie);
+	struct svc_fh *fhp = &argp->fh;
 
-	trace_nfsd_vfs_readdir(rqstp, &argp->fh, argp->count, argp->cookie);
+	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen.dir);
+	trace_nfsd_vfs_readdir(rqstp, fhp, argp->xdrgen.count, offset);
 
-	nfsd_init_dirlist_pages(rqstp, resp, argp->count);
+	nfsd_init_dirlist_pages(rqstp, resp, argp->xdrgen.count);
 
 	resp->common.err = nfs_ok;
 	resp->cookie_offset = 0;
-	offset = argp->cookie;
-	resp->status = nfsd_readdir(rqstp, &argp->fh, &offset,
+	resp->status = nfsd_readdir(rqstp, fhp, &offset,
 				    &resp->common, nfssvc_encode_entry);
 	nfssvc_encode_nfscookie(resp, offset);
 
-	fh_put(&argp->fh);
+	fh_put(fhp);
 	resp->status = nfsd_map_status(resp->status);
 	return rpc_success;
 }
@@ -1385,14 +1399,14 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "RMDIR",
 	},
 	[NFSPROC_READDIR] = {
-		.pc_func = nfsd_proc_readdir,
-		.pc_decode = nfssvc_decode_readdirargs,
-		.pc_encode = nfssvc_encode_readdirres,
-		.pc_argsize = sizeof(struct nfsd_readdirargs),
-		.pc_argzero = sizeof(struct nfsd_readdirargs),
-		.pc_ressize = sizeof(struct nfsd_readdirres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_name = "READDIR",
+		.pc_func	= nfsd_proc_readdir,
+		.pc_decode	= nfs_svc_decode_readdirargs,
+		.pc_encode	= nfssvc_encode_readdirres,
+		.pc_argsize	= sizeof(struct readdirargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct nfsd_readdirres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_name	= "READDIR",
 	},
 	[NFSPROC_STATFS] = {
 		.pc_func	= nfsd_proc_statfs,
@@ -1420,6 +1434,7 @@ union nfsd_xdrstore {
 	struct renameargs_wrapper	renameargs;
 	struct linkargs_wrapper		linkargs;
 	struct symlinkargs_wrapper	symlinkargs;
+	struct readdirargs_wrapper	readdirargs;
 	struct attrstat_wrapper		attrstat;
 	struct diropres_wrapper		diropres;
 	struct readlinkres	readlinkres;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 5da47ba5b465..bc35c2fced79 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -173,21 +173,6 @@ nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_fhandle(xdr, &args->fh);
 }
 
-bool
-nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_readdirargs *args = rqstp->rq_argp;
-
-	if (!svcxdr_decode_fhandle(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->cookie) < 0)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->count) < 0)
-		return false;
-
-	return true;
-}
-
 /*
  * XDR encode functions
  */
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 6537ea17c63a..27976b372cf1 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -8,12 +8,6 @@
 
 #include "vfs.h"
 
-struct nfsd_readdirargs {
-	struct svc_fh		fh;
-	__u32			cookie;
-	__u32			count;
-};
-
 struct nfsd_attrstat {
 	__be32			status;
 	struct svc_fh		fh;
@@ -34,7 +28,6 @@ struct nfsd_readdirres {
 };
 
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.55.0

