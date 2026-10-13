Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 355314F3EA5
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895777; cv=none; b=iTCAtUzbnvsb4EFBFWLpbsgfV1lWlG0G5ro8LuXjBxq8Y2njxUG4R21Yrid5+48K2moPc6X8Pq1Xqwl5gwua4BOJD8sbD4qXpdRLCn+z/tyn9PdA4kSccpevFG2On3zDxC9gN38TPAuCizpX+3ecfnPmd3p56W37fgbQd90krTo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895777; c=relaxed/simple;
	bh=Xs9NZ9jeQX6u2RGwRv6XAO6eASwpaA6JnxfJoJNsr/k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fYf7GXHlJ77KcBQ0ty7bkknZNyAukPI3lraqCoc6K0wMtO4hPxofgI0DbUXL71PxZw7Kk/gjUTewC/oi4AkEh4E0OQK/d8ZqoJxBLvcEvvpnJQBswpm3ja90OlCRPC0vw2aPougWU+z3FA/vefFubLaVQcET69V/O1LvzGBAH8I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jkz+BYWv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jkz+BYWv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6F2B01F000FF;
	Tue, 13 Oct 2026 12:49:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895776;
	bh=p/hb8bovzUyDcvPG2+A0Cj1PMYZHeKm+C0az5DLBzes=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Jkz+BYWvkLjzxJneU3IHjO2Cd84Uf7CwxjIi5M0HN8HNL5WLcqNLAkX3ZY6eLhRA8
	 3eezc166v6jIrOppreGv35M1vwGeHTZwPQWslU2WV8G0DN2eyqrtmHVx43WUzTfDXV
	 jkv2Zb+6PjvFGISbUGtJDybjttwebO+prwAMtyrC77GbHRhfEUaxGy/mZRzyAuTfNK
	 umo9gxaXAgWkgrXenWJaEFotn9nHhCPIjxBYetyiN06OlycWBoyPoxFIPxOk5GNDzK
	 S1uuBeISoiiQj1trfQN0pCrwog850PnsXewXa0jfOw5U8gjtO1KhyKSzGbUbzmTHSd
	 uBLALRyTP1s9w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 12/34] NFSD: Use xdrgen XDR functions for NFSv3 READLINK procedure
Date: Tue, 13 Oct 2026 08:49:26 -0400
Message-ID: <20261013124933.316765-3-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124933.316765-1-cel@kernel.org>
References: <20261013124933.316765-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the hand-written NFSv3 READLINK codec pair with the
xdrgen-generated functions. The NFSPROC3_READLINK entry in the
nfsd_procedures3 array now dispatches nfs_svc_decode_READLINK3args
and nfs_svc_encode_READLINK3res. A wrapper structure bridges the
generated xdrgen fhandle type and the legacy svc_fh representation
the NFSD VFS layer still uses.

The link target does not reside at the data pointer of the
READLINK3resok data member: nfsd_readlink() deposits it directly
in a page of the Reply buffer, so the generic encoder that copies
an opaque from the member's data pointer cannot encode it. Mark
the data member with the "pragma pages" directive so the generated
encoder calls svcxdr_encode_opaque_payload(), which encodes the
length prefix and inserts the payload page into the stream by
reference. The page anchor that the result structure carried
duplicated rq_res.pages -- svc_process() points rq_res.pages at
the first Reply page before dispatch, and the READLINK3args
argument decoder consumes no pages -- so the helper locates the
payload through the Reply buffer itself, and the wrapper collapses
to the generated READLINK3res type.

The pc_argzero field is now set to zero for the NFSv3 READLINK
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_readlink() now fills in the post-op attributes,
the fh_getattr() calls are made in the proc function rather than
in the XDR result encoder, and the reference to the file handle
can be released directly by nfsd3_proc_readlink(). A separate
->pc_release callback is thus no longer needed. This makes it
straightforward to confirm that the file handle is properly
released during every error flow.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |  1 +
 fs/nfsd/nfs3proc.c                 | 79 ++++++++++++++++++++----------
 fs/nfsd/nfs3xdr.c                  | 28 -----------
 fs/nfsd/nfs3xdr_gen.c              |  4 +-
 fs/nfsd/nfs3xdr_gen.h              |  2 +-
 fs/nfsd/xdr3.h                     |  9 +---
 include/linux/sunrpc/xdrgen/nfs3.h |  2 +-
 7 files changed, 60 insertions(+), 65 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index 1ef99ec54103..b50ffb77af54 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -331,6 +331,7 @@ struct READLINK3resok {
 	post_op_attr	symlink_attributes;
 	nfspath3	data;
 };
+pragma pages READLINK3resok data;
 
 struct READLINK3resfail {
 	post_op_attr	symlink_attributes;
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 8f02dcd6404b..3c557124196f 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -78,6 +78,13 @@ struct ACCESS3args_wrapper {
 
 static_assert(offsetof(struct ACCESS3args_wrapper, xdrgen) == 0);
 
+struct READLINK3args_wrapper {
+	struct READLINK3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct READLINK3args_wrapper, xdrgen) == 0);
+
 static int	nfs3_ftypes[] = {
 	0,			/* NF3NON */
 	S_IFREG,		/* NF3REG */
@@ -587,24 +594,44 @@ static __be32 nfsd3_proc_access(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Read a symlink.
+/**
+ * nfsd3_proc_readlink - READLINK: Read from symbolic link
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   READLINK3res NFSPROC3_READLINK(READLINK3args) = 5;
  */
-static __be32
-nfsd3_proc_readlink(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_readlink(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
-	struct nfsd3_readlinkres *resp = rqstp->rq_resp;
+	struct READLINK3args_wrapper *argp = rqstp->rq_argp;
+	struct READLINK3res *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
+	struct page *page;
+	u32 len;
 
-	dprintk("nfsd: READLINK(3) %s\n", SVCFH_fmt(&argp->fh));
+	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.symlink);
 
-	/* Read the symlink. */
-	fh_copy(&resp->fh, &argp->fh);
-	resp->len = NFS3_MAXPATHLEN;
-	resp->pages = rqstp->rq_next_page++;
-	resp->status = nfsd_readlink(rqstp, &resp->fh,
-				     page_address(*resp->pages), &resp->len);
-	resp->status = nfsd3_map_status(resp->status);
+	len = NFS3_MAXPATHLEN;
+	page = *(rqstp->rq_next_page++);
+	resp->status = nfsd_readlink(rqstp, fhp, page_address(page), &len);
+
+	if (resp->status == nfs_ok) {
+		struct READLINK3resok *resok = &resp->u.resok;
+
+		resok->data.len = len;
+		nfsd3_fill_post_op_attr(rqstp, &resok->symlink_attributes, fhp);
+	} else {
+		struct READLINK3resfail *resfail = &resp->u.resfail;
+
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_post_op_attr(rqstp, &resfail->symlink_attributes,
+					fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1330,16 +1357,17 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "ACCESS",
 	},
 	[NFSPROC3_READLINK] = {
-		.pc_func = nfsd3_proc_readlink,
-		.pc_decode = nfs3svc_decode_fhandleargs,
-		.pc_encode = nfs3svc_encode_readlinkres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd_fhandle),
-		.pc_argzero = sizeof(struct nfsd_fhandle),
-		.pc_ressize = sizeof(struct nfsd3_readlinkres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+pAT+1+NFS3_MAXPATHLEN/4,
-		.pc_name = "READLINK",
+		.pc_func	= nfsd3_proc_readlink,
+		.pc_decode	= nfs_svc_decode_READLINK3args,
+		.pc_encode	= nfs_svc_encode_READLINK3res,
+		.pc_argsize	= sizeof(struct READLINK3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct READLINK3res),
+		.pc_cachetype	= RC_NOCACHE,
+		/* _sz omits the payload, which nfs3.x leaves unbounded */
+		.pc_xdrressize	= NFS3_READLINK3res_sz +
+				  XDR_QUADLEN(NFS3_MAXPATHLEN),
+		.pc_name	= "READLINK",
 	},
 	[NFSPROC3_READ] = {
 		.pc_func = nfsd3_proc_read,
@@ -1542,6 +1570,7 @@ union nfsd3_xdrstore {
 	struct LOOKUP3res_wrapper	lookupres;
 	struct ACCESS3args_wrapper	accessargs;
 	struct ACCESS3res		accessres;
+	struct READLINK3args_wrapper	readlinkargs;
 	struct nfsd3_diropargs		diropargs;
 	struct nfsd3_readargs		readargs;
 	struct nfsd3_writeargs		writeargs;
@@ -1551,7 +1580,7 @@ union nfsd3_xdrstore {
 	struct nfsd3_symlinkargs	symlinkargs;
 	struct nfsd3_readdirargs	readdirargs;
 	struct nfsd3_diropres 		diropres;
-	struct nfsd3_readlinkres	readlinkres;
+	struct READLINK3res		readlinkres;
 	struct nfsd3_readres		readres;
 	struct nfsd3_writeres		writeres;
 	struct nfsd3_renameres		renameres;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index f3f723215114..a77b5f7a7e27 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -708,34 +708,6 @@ nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		svcxdr_encode_wcc_data(rqstp, xdr, &resp->fh);
 }
 
-/* READLINK */
-bool
-nfs3svc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_readlinkres *resp = rqstp->rq_resp;
-	struct kvec *head = rqstp->rq_res.head;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->len) < 0)
-			return false;
-		svcxdr_encode_opaque_pages(rqstp, xdr, resp->pages, 0,
-					   resp->len);
-		if (svc_encode_result_payload(rqstp, head->iov_len, resp->len) < 0)
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-	}
-
-	return true;
-}
-
 /* READ */
 bool
 nfs3svc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
index e21ee0053129..bc6fb9829397 100644
--- a/fs/nfsd/nfs3xdr_gen.c
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x
-// XDR specification modification time: Fri Jul 10 23:21:45 2026
+// XDR specification modification time: Tue Jul 14 09:53:56 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -2480,7 +2480,7 @@ xdrgen_encode_READLINK3resok(struct xdr_stream *xdr, const struct READLINK3resok
 {
 	if (!xdrgen_encode_post_op_attr(xdr, &value->symlink_attributes))
 		return false;
-	if (!xdrgen_encode_nfspath3(xdr, value->data))
+	if (!svcxdr_encode_opaque_payload(xdr, value->data.len))
 		return false;
 	return true;
 }
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
index 58499ca28c43..3fefbb797b69 100644
--- a/fs/nfsd/nfs3xdr_gen.h
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Fri Jul 10 23:21:45 2026 */
+/* XDR specification modification time: Tue Jul 14 09:53:56 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DECL_H
 #define _LINUX_XDRGEN_NFS3_DECL_H
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index bb23c444c23d..39a2109a2c66 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -9,6 +9,7 @@
 #define _LINUX_NFSD_XDR3_H
 
 #include <linux/vfs.h>
+#include <linux/sunrpc/xdrgen/nfs3.h>
 
 #include "vfs.h"
 
@@ -134,13 +135,6 @@ struct nfsd3_accessres {
 	struct kstat		stat;
 };
 
-struct nfsd3_readlinkres {
-	__be32			status;
-	struct svc_fh		fh;
-	__u32			len;
-	struct page		**pages;
-};
-
 struct nfsd3_readres {
 	__be32			status;
 	struct svc_fh		fh;
@@ -252,7 +246,6 @@ bool nfs3svc_decode_commitargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 bool nfs3svc_encode_wccstat(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_writeres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_createres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 785ebff351ce..3f8d1ecda7f2 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Fri Jul 10 23:21:45 2026 */
+/* XDR specification modification time: Tue Jul 14 09:53:56 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DEF_H
 #define _LINUX_XDRGEN_NFS3_DEF_H
-- 
2.55.0

