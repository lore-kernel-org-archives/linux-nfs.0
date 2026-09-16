Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3089C53ECF3
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576169; cv=none; b=uBqmrynUx7t3ZM8DVO9v5tJy7P3XKS5bijZPWfC+7ohHrz4EF94pIwxdhnexjsfIMmCcmqx6egAD/yvA58oZQOAGrg8s7P8oZ0YfJIu6Ta7MGquLWnOY0OIqB7DB9NwXw2Q4//Yj4OUAG4EjbtMfeSQTwjwNAKomJxgdr7J7CLo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576169; c=relaxed/simple;
	bh=jL9cfiSYOQMmpb/B7lEbUxe8nE03FSryqxVV2vSzMtI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=E0cDklVTGMPQjYxg+yKZ2ZewxtewkyGa1zO6IwBffcZiVY+MuUjGNU2NaPZ87lO5m03txz/br5K+gk3i2EDzlWS76lGzS6nVbdAaHrejGrA0YGMT9JKO/HfVvaDFj8v4u27ioojaacrCEf7UKE4Yoz/aKutu5k8Y51+5a+bQIRY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nozl9FCq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nozl9FCq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3E971F0089A;
	Wed, 16 Sep 2026 16:29:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576164;
	bh=gnecho+5o6fYrTTfzBFxrdMvFDPSvUGjUyhwqhTWqvo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nozl9FCqQjhbLGXgJMWNwyuZ6cbl06BzGd4gAj1f73lH+4KPk5TshAZA/HngrBSGA
	 LCLRKSp1s54PoHkmTUsrycbTld/qhNBlfrHrjuFEnT7AeAbKEhvvi+mvmvtwGE57em
	 JLpvO/troO5hGSS+g25EN+zJbWsxDop1p2R6zg9eLe2Px3gjrPIz9xndRJHQP6j9is
	 wdlMhfdRRyBXTcNu5l4O9oQ8h9tHlHZ895csDeLycnZWHpwBbis3Do7hWKvOmgM0HR
	 tCAd5zz9UqsbhArtK5skQexEVmzGjepERcbDO2YbOC802Njcy5ABqkWqEmHJIMtTZh
	 hqJE3B+UpWE2w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 20/27] NFSD: Use xdrgen XDR functions for NFSv2 SYMLINK procedure
Date: Wed, 16 Sep 2026 12:28:51 -0400
Message-ID: <20260916162859.2051-23-cel@kernel.org>
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

A SYMLINK request's target pathname can extend from the head of the
receive buffer into its page data; the decoder reassembles it from a
head segment and a page via svc_fill_symlink_pathname(). Represent
the pathname in place rather than materializing it inline: the
"pages" directive expresses it as a struct xdr_buf and decodes it
with svcxdr_decode_opaque_payload(), which subsegments the source
stream instead of pulling the string inline through the bounded xdr
scratch buffer.

Annotate the to member of symlinkargs with "pragma pages" and
replace the NFSPROC_SYMLINK entry in nfsd_procedures2 with the
generated nfs_svc_decode_symlinkargs and nfs_svc_encode_nfsstat. A
wrapper structure bridges the generated symlinkargs type and the
svc_fh and iattr representations the NFSD VFS layer still uses.
nfsd_proc_symlink() copies the pathname out of the xdr_buf with
read_bytes_from_xdr_buf(), so a target that lands in the receive
buffer's tail, or straddles its pages and tail, is handled the same
way as one in the head.

The pc_argzero field is now set to zero for the NFSv2 SYMLINK
procedure. The generated decoder initializes every argument in the
argp->xdrgen field, making the early defensive memset unnecessary.

The hand-coded nfsd_proc_symlink() accepts a target of any length
from the decoder and answers one longer than NFS_MAXPATHLEN with
NFSERR_NAMETOOLONG. The generated decoder enforces the path typedef's
bound itself, so such a request now fails decoding and nfsd_dispatch()
returns RPC GARBAGE_ARGS instead. The Linux NFS client sends targets
up to PAGE_SIZE on an NFSv2 mount, and in that case it reports EIO to
the application rather than ENAMETOOLONG.

nfssvc_decode_symlinkargs() no longer has any callers, so it is
removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x    |   1 +
 fs/nfsd/nfs2xdr_gen.c              |   8 ++-
 fs/nfsd/nfs2xdr_gen.h              |   2 +-
 fs/nfsd/nfsproc.c                  | 102 ++++++++++++++++++++---------
 fs/nfsd/nfsxdr.c                   |  20 ------
 fs/nfsd/xdr.h                      |  11 ----
 include/linux/sunrpc/xdrgen/nfs2.h |   4 +-
 7 files changed, 81 insertions(+), 67 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
index b2ed52bd1631..932968c24d99 100644
--- a/Documentation/sunrpc/xdr/nfs2.x
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -178,6 +178,7 @@ struct symlinkargs {
 	path		to;
 	sattr		attributes;
 };
+pragma pages symlinkargs to;
 
 struct readdirargs {
 	fhandle		dir;
diff --git a/fs/nfsd/nfs2xdr_gen.c b/fs/nfsd/nfs2xdr_gen.c
index 3c2f78c802a6..0ddfd9bc4a99 100644
--- a/fs/nfsd/nfs2xdr_gen.c
+++ b/fs/nfsd/nfs2xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x
-// XDR specification modification time: Tue Sep  8 11:26:00 2026
+// XDR specification modification time: Tue Sep  8 11:26:14 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -322,7 +322,7 @@ xdrgen_decode_symlinkargs(struct xdr_stream *xdr, struct symlinkargs *ptr)
 {
 	if (!xdrgen_decode_diropargs(xdr, &ptr->from))
 		return false;
-	if (!xdrgen_decode_path(xdr, &ptr->to))
+	if (!svcxdr_decode_opaque_payload(xdr, &ptr->to, NFS_MAXPATHLEN))
 		return false;
 	if (!xdrgen_decode_sattr(xdr, &ptr->attributes))
 		return false;
@@ -851,7 +851,9 @@ xdrgen_encode_symlinkargs(struct xdr_stream *xdr, const struct symlinkargs *valu
 {
 	if (!xdrgen_encode_diropargs(xdr, &value->from))
 		return false;
-	if (!xdrgen_encode_path(xdr, value->to))
+	if (value->to.len > NFS_MAXPATHLEN)
+		return false;
+	if (!svcxdr_encode_opaque_payload(xdr, value->to.len))
 		return false;
 	if (!xdrgen_encode_sattr(xdr, &value->attributes))
 		return false;
diff --git a/fs/nfsd/nfs2xdr_gen.h b/fs/nfsd/nfs2xdr_gen.h
index 8f7d17e8e483..c3641ba63bb3 100644
--- a/fs/nfsd/nfs2xdr_gen.h
+++ b/fs/nfsd/nfs2xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:26:00 2026 */
+/* XDR specification modification time: Tue Sep  8 11:26:14 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DECL_H
 #define _LINUX_XDRGEN_NFS2_DECL_H
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index c74893060857..830d90d0ef9e 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -101,6 +101,14 @@ struct linkargs_wrapper {
 
 static_assert(offsetof(struct linkargs_wrapper, xdrgen) == 0);
 
+struct symlinkargs_wrapper {
+	struct symlinkargs	xdrgen;
+	struct svc_fh		ffh;
+	struct iattr		iattrs;
+};
+
+static_assert(offsetof(struct symlinkargs_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -953,38 +961,72 @@ static __be32 nfsd_proc_link(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static __be32
-nfsd_proc_symlink(struct svc_rqst *rqstp)
+static char *nfsd_symlink_target(const struct xdr_buf *to)
 {
-	struct nfsd_symlinkargs *argp = rqstp->rq_argp;
-	struct nfsd_stat *resp = rqstp->rq_resp;
-	struct nfsd_attrs attrs = {
-		.na_iattr	= &argp->attrs,
-	};
-	struct svc_fh	newfh;
+	char *result;
 
-	if (argp->tlen > NFS_MAXPATHLEN) {
-		resp->status = nfserr_nametoolong;
+	result = kmalloc(to->len + 1, GFP_KERNEL);
+	if (!result)
+		return ERR_PTR(-ESERVERFAULT);
+	/* The target can span the receive buffer's head, pages, and tail */
+	if (read_bytes_from_xdr_buf(to, 0, result, to->len)) {
+		kfree(result);
+		return ERR_PTR(-ESERVERFAULT);
+	}
+	result[to->len] = '\0';
+
+	/* The VFS rejects a pathname that contains a NUL byte */
+	if (strlen(result) != to->len) {
+		kfree(result);
+		return ERR_PTR(-EINVAL);
+	}
+	return result;
+}
+
+/**
+ * nfsd_proc_symlink - SYMLINK: Create a symbolic link
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   nfsstat NFSPROC_SYMLINK(symlinkargs) = 13;
+ */
+static __be32 nfsd_proc_symlink(struct svc_rqst *rqstp)
+{
+	struct symlinkargs_wrapper *argp = rqstp->rq_argp;
+	struct diropargs *from = &argp->xdrgen.from;
+	struct xdr_buf *to = &argp->xdrgen.to;
+	nfsstat *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->ffh;
+	struct nfsd_attrs nattrs = {
+		.na_iattr	= &argp->iattrs,
+	};
+	struct svc_fh newfh;
+	char *tname;
+
+	nfsd_fhandle_to_svc_fh(fhp, &from->dir);
+	if (!nfsd_sattr_to_iattr(rqstp, &argp->iattrs, &argp->xdrgen.attributes)) {
+		*resp = nfserr_io;
 		goto out;
 	}
 
-	argp->tname = svc_fill_symlink_pathname(rqstp, &argp->first,
-						page_address(rqstp->rq_arg.pages[0]),
-						argp->tlen);
-	if (IS_ERR(argp->tname)) {
-		resp->status = nfserrno(PTR_ERR(argp->tname));
+	tname = nfsd_symlink_target(to);
+	if (IS_ERR(tname)) {
+		*resp = nfserrno(PTR_ERR(tname));
 		goto out;
 	}
 
 	fh_init(&newfh, NFS_FHSIZE);
-	resp->status = nfsd_symlink(rqstp, &argp->ffh, argp->fname, argp->flen,
-				    argp->tname, &attrs, &newfh);
+	*resp = nfsd_symlink(rqstp, fhp, (char *)from->name.data, from->name.len,
+			     tname, &nattrs, &newfh);
+	kfree(tname);
+	*resp = nfsd_map_status(*resp);
 
-	kfree(argp->tname);
-	fh_put(&argp->ffh);
 	fh_put(&newfh);
 out:
-	resp->status = nfsd_map_status(resp->status);
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1250,15 +1292,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "LINK",
 	},
 	[NFSPROC_SYMLINK] = {
-		.pc_func = nfsd_proc_symlink,
-		.pc_decode = nfssvc_decode_symlinkargs,
-		.pc_encode = nfssvc_encode_statres,
-		.pc_argsize = sizeof(struct nfsd_symlinkargs),
-		.pc_argzero = sizeof(struct nfsd_symlinkargs),
-		.pc_ressize = sizeof(struct nfsd_stat),
-		.pc_cachetype = RC_REPLSTAT,
-		.pc_xdrressize = ST,
-		.pc_name = "SYMLINK",
+		.pc_func	= nfsd_proc_symlink,
+		.pc_decode	= nfs_svc_decode_symlinkargs,
+		.pc_encode	= nfs_svc_encode_nfsstat,
+		.pc_argsize	= sizeof(struct symlinkargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(nfsstat),
+		.pc_cachetype	= RC_REPLSTAT,
+		.pc_xdrressize	= NFS2_nfsstat_sz,
+		.pc_name	= "SYMLINK",
 	},
 	[NFSPROC_MKDIR] = {
 		.pc_func = nfsd_proc_mkdir,
@@ -1318,7 +1360,7 @@ union nfsd_xdrstore {
 	struct createargs_wrapper	createargs;
 	struct renameargs_wrapper	renameargs;
 	struct linkargs_wrapper		linkargs;
-	struct nfsd_symlinkargs	symlink;
+	struct symlinkargs_wrapper	symlinkargs;
 	struct nfsd_readdirargs	readdir;
 	struct attrstat_wrapper		attrstat;
 	struct diropres_wrapper		diropres;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index ddbdf10b9982..eb87ee218f12 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -321,26 +321,6 @@ nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_decode_sattr(rqstp, xdr, &args->attrs);
 }
 
-bool
-nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_symlinkargs *args = rqstp->rq_argp;
-	struct kvec *head = rqstp->rq_arg.head;
-
-	if (!svcxdr_decode_diropargs(xdr, &args->ffh, &args->fname, &args->flen))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->tlen) < 0)
-		return false;
-	if (args->tlen == 0)
-		return false;
-
-	args->first.iov_len = head->iov_len - xdr_stream_pos(xdr);
-	args->first.iov_base = xdr_inline_decode(xdr, args->tlen);
-	if (!args->first.iov_base)
-		return false;
-	return svcxdr_decode_sattr(rqstp, xdr, &args->attrs);
-}
-
 bool
 nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 2cc1581788d8..eeea28caf19d 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -21,16 +21,6 @@ struct nfsd_createargs {
 	struct iattr		attrs;
 };
 
-struct nfsd_symlinkargs {
-	struct svc_fh		ffh;
-	char *			fname;
-	unsigned int		flen;
-	char *			tname;
-	unsigned int		tlen;
-	struct iattr		attrs;
-	struct kvec		first;
-};
-
 struct nfsd_readdirargs {
 	struct svc_fh		fh;
 	__u32			cookie;
@@ -74,7 +64,6 @@ struct nfsd_statfsres {
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfssvc_encode_statres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs2.h b/include/linux/sunrpc/xdrgen/nfs2.h
index 7a469ac4b772..8f7b79983e3e 100644
--- a/include/linux/sunrpc/xdrgen/nfs2.h
+++ b/include/linux/sunrpc/xdrgen/nfs2.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:26:00 2026 */
+/* XDR specification modification time: Tue Sep  8 11:26:14 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DEF_H
 #define _LINUX_XDRGEN_NFS2_DEF_H
@@ -172,7 +172,7 @@ struct linkargs {
 
 struct symlinkargs {
 	struct diropargs from;
-	path to;
+	struct xdr_buf to;
 	struct sattr attributes;
 };
 
-- 
2.55.0

