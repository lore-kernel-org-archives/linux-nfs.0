Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 559A955D89F
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576155; cv=none; b=rCaYiCKXZUCNHaQZb0oVw6Mc2Yu5Mf+VxBqtanyQcyfqTwkdC0tlN4lOQOUHGmsouculKRHt7bUmpjb1O6GcCAVh9gAVqRjRv/zeDrDFqg/tkaeIu3QO4yY24xUvDsvmSGzbzvmbwy5NrvSTPA4i8yMauxAfr7p7s4DGYGKcyzk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576155; c=relaxed/simple;
	bh=Emht96KlzJUuanz+/d7Taqne9nd4PqFWUzggXtaKVKY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=U2TBjtZ22fYG7c6Ct85E9p40T4RMbAo3T9U/nDNrGpY9dvfO70C/SbHmomJ/ZC/pXjF5Fmz+R3LBhp+EqfFq/pYaizIwkcLQ12DUGox/layMViIR+2TFKfJyaFv1H9nw/noNNm3dXjT4mY/lRYGlvNHvyPSVeMsQcTHt2bQ1lGE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fivu4KTU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fivu4KTU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B0BD01F00893;
	Wed, 16 Sep 2026 16:29:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576151;
	bh=rwx401t7aiiVc8w3neMEERWBf83mNvqkqdXfv0V2IOQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fivu4KTUxNpeElVJljtyCaSa9/k0QQlqTkZSU7XvjXKTDa492vIFiioR19IizoYNR
	 5LaQgiUFcKEd1C1swjnv/XLjWeiVUrwcXl8KI7yhZWfQ6L+c1P1Rupn0fw2mzaU7bv
	 dgFfXc3md/+2yBQRXxX/c72JoRuav7b3OkzMDds0X9Bi4FHOYg7hIOfnhklI7YO9/u
	 PLe7MoYc7yk/Dyt7828v4rnD74rFPlyrCGFj7HVQEHcdc8fW1kBDZy/h1+spJfoW6f
	 2hS/UGXR1YGoiQ5blV5wFBG0aOno+ibFOdbw6hl4WocNo+GMB6s5KP0ucB5nWR4mcO
	 2w8g13scJDHXw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 12/27] NFSD: Use xdrgen XDR functions for NFSv2 READ procedure
Date: Wed, 16 Sep 2026 12:28:43 -0400
Message-ID: <20260916162859.2051-15-cel@kernel.org>
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

Replace the hand-written NFSv2 READ codec pair with the
xdrgen-generated functions. The NFSPROC_READ entry in the
nfsd_procedures2 array now dispatches nfs_svc_decode_readargs and
nfs_svc_encode_readres. A wrapper structure bridges the generated
xdrgen readargs type and the legacy svc_fh representation the NFSD
VFS layer still uses.

The file's data does not reside at the data pointer of the
readresok data member: nfsd_read() deposits it directly in the
pages of the Reply buffer, so the generic encoder that copies an
opaque from the member's data pointer cannot encode it. Mark the
member with the "pragma pages" directive so the generated encoder
calls svcxdr_encode_opaque_payload(), which encodes the length
prefix and inserts the payload pages into the stream by reference.
The page anchor that the result structure carried duplicated
rq_res.pages -- svc_process() points rq_res.pages at the first
Reply page before dispatch, and the readargs decoder consumes no
pages -- so the helper locates the payload through the Reply buffer
itself, and the wrapper collapses to the generated readres type.

The pc_argzero field is now set to zero for the NFSv2 READ
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because the generated encoder no longer needs the svc_fh at encode
time, nfsd_proc_read() releases the file handle directly and no
separate ->pc_release callback is needed. This makes it
straightforward to confirm that the file handle is properly
released during every error flow.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x    |  1 +
 fs/nfsd/nfs2xdr_gen.c              |  4 +-
 fs/nfsd/nfs2xdr_gen.h              |  2 +-
 fs/nfsd/nfsproc.c                  | 94 ++++++++++++++++++------------
 fs/nfsd/nfsxdr.c                   | 52 +----------------
 fs/nfsd/xdr.h                      | 17 ------
 include/linux/sunrpc/xdrgen/nfs2.h |  2 +-
 7 files changed, 62 insertions(+), 110 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
index 771acc4baa17..b64b939f11f8 100644
--- a/Documentation/sunrpc/xdr/nfs2.x
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -140,6 +140,7 @@ struct readresok {
 	fattr		attributes;
 	opaque		data<NFS_MAXDATA>;
 };
+pragma pages readresok data;
 
 union readres switch (nfsstat status) {
 	case NFS_OK:
diff --git a/fs/nfsd/nfs2xdr_gen.c b/fs/nfsd/nfs2xdr_gen.c
index e97df0eda0e1..abde6fa8e510 100644
--- a/fs/nfsd/nfs2xdr_gen.c
+++ b/fs/nfsd/nfs2xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x
-// XDR specification modification time: Tue Sep  8 11:25:27 2026
+// XDR specification modification time: Tue Sep  8 11:25:45 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -777,7 +777,7 @@ xdrgen_encode_readresok(struct xdr_stream *xdr, const struct readresok *value)
 		return false;
 	if (value->data.len > NFS_MAXDATA)
 		return false;
-	if (xdr_stream_encode_opaque(xdr, value->data.data, value->data.len) < 0)
+	if (!svcxdr_encode_opaque_payload(xdr, value->data.len))
 		return false;
 	return true;
 }
diff --git a/fs/nfsd/nfs2xdr_gen.h b/fs/nfsd/nfs2xdr_gen.h
index 92d5f9a8f5dd..e8ff072e32e5 100644
--- a/fs/nfsd/nfs2xdr_gen.h
+++ b/fs/nfsd/nfs2xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:25:27 2026 */
+/* XDR specification modification time: Tue Sep  8 11:25:45 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DECL_H
 #define _LINUX_XDRGEN_NFS2_DECL_H
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 7bc89629934b..c7e273e74c54 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -63,6 +63,13 @@ struct diropres_wrapper {
 
 static_assert(offsetof(struct diropres_wrapper, xdrgen) == 0);
 
+struct readargs_wrapper {
+	struct readargs		xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct readargs_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -508,40 +515,52 @@ static __be32 nfsd_proc_readlink(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Read a portion of a file.
- * N.B. After this call resp->fh needs an fh_put
+/**
+ * nfsd_proc_read - READ: Read from file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   readres NFSPROC_READ(readargs) = 6;
  */
-static __be32
-nfsd_proc_read(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_read(struct svc_rqst *rqstp)
 {
-	struct nfsd_readargs *argp = rqstp->rq_argp;
-	struct nfsd_readres *resp = rqstp->rq_resp;
+	struct readargs_wrapper *argp = rqstp->rq_argp;
+	struct readres *resp = rqstp->rq_resp;
+	unsigned long count = argp->xdrgen.count;
+	u32 offset = argp->xdrgen.offset;
+	struct svc_fh *fhp = &argp->fh;
+	struct kstat stat;
 	u32 eof;
 
-	dprintk("nfsd: READ    %s %d bytes at %d\n",
-		SVCFH_fmt(&argp->fh),
-		argp->count, argp->offset);
+	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen.file);
+	count = min_t(u32, count, NFS_MAXDATA);
+	count = min_t(u32, count, rqstp->rq_res.buflen);
 
-	argp->count = min_t(u32, argp->count, NFS_MAXDATA);
-	argp->count = min_t(u32, argp->count, rqstp->rq_res.buflen);
-
-	resp->pages = rqstp->rq_next_page;
-
-	/* Obtain buffer pointer for payload. 19 is 1 word for
-	 * status, 17 words for fattr, and 1 word for the byte count.
+	/*
+	 * 19 is 1 word for status, 17 words for fattr, and 1 word
+	 * for the byte count.
 	 */
-	svc_reserve_auth(rqstp, (19<<2) + argp->count + 4);
+	svc_reserve_auth(rqstp, (19 << 2) + count + 4);
+	resp->status = nfsd_read(rqstp, fhp, offset, &count, &eof);
 
-	resp->count = argp->count;
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = nfsd_read(rqstp, &resp->fh, argp->offset,
-				 &resp->count, &eof);
-	if (resp->status == nfs_ok)
-		resp->status = fh_getattr(&resp->fh, &resp->stat);
-	else if (resp->status == nfserr_jukebox)
+	if (resp->status == nfs_ok) {
+		struct readresok *resok = &resp->u.readresok;
+
+		resok->data.len = count;
+		resp->status = fh_getattr(fhp, &stat);
+		if (resp->status == nfs_ok)
+			nfsd_stat_to_fattr(rqstp, &resok->attributes, &stat,
+					   fhp);
+	}
+	if (resp->status == nfserr_jukebox)
 		set_bit(RQ_DROPME, &rqstp->rq_flags);
-	resp->status = nfsd_map_io_status(resp->status);
+	if (resp->status != nfs_ok)
+		resp->status = nfsd_map_io_status(resp->status);
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1025,16 +1044,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "READLINK",
 	},
 	[NFSPROC_READ] = {
-		.pc_func = nfsd_proc_read,
-		.pc_decode = nfssvc_decode_readargs,
-		.pc_encode = nfssvc_encode_readres,
-		.pc_release = nfssvc_release_readres,
-		.pc_argsize = sizeof(struct nfsd_readargs),
-		.pc_argzero = sizeof(struct nfsd_readargs),
-		.pc_ressize = sizeof(struct nfsd_readres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+AT+1+NFS_MAXDATA/4,
-		.pc_name = "READ",
+		.pc_func	= nfsd_proc_read,
+		.pc_decode	= nfs_svc_decode_readargs,
+		.pc_encode	= nfs_svc_encode_readres,
+		.pc_argsize	= sizeof(struct readargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct readres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS2_readres_sz,
+		.pc_name	= "READ",
 	},
 	[NFSPROC_WRITECACHE] = {
 		.pc_func = nfsd_proc_writecache,
@@ -1168,7 +1186,7 @@ union nfsd_xdrstore {
 	struct fhandle_wrapper		fhandle;
 	struct sattrargs_wrapper	sattrargs;
 	struct diropargs_wrapper	diropargs;
-	struct nfsd_readargs	read;
+	struct readargs_wrapper		readargs;
 	struct nfsd_writeargs	write;
 	struct nfsd_createargs	create;
 	struct nfsd_renameargs	rename;
@@ -1178,7 +1196,7 @@ union nfsd_xdrstore {
 	struct attrstat_wrapper		attrstat;
 	struct diropres_wrapper		diropres;
 	struct readlinkres	readlinkres;
-	struct nfsd_readres	readres;
+	struct readres		readres;
 	struct nfsd_readdirres	readdirres;
 	struct nfsd_statfsres	statfsres;
 };
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index ed5ec00e8557..1b79f9534af6 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -10,6 +10,7 @@
 #include "vfs.h"
 #include "nfserr.h"
 #include "xdr.h"
+#include "nfs2xdr_gen.h"
 #include "auth.h"
 
 /*
@@ -310,25 +311,6 @@ nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return svcxdr_decode_diropargs(xdr, &args->fh, &args->name, &args->len);
 }
 
-bool
-nfssvc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_readargs *args = rqstp->rq_argp;
-	u32 totalcount;
-
-	if (!svcxdr_decode_fhandle(xdr, &args->fh))
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->offset) < 0)
-		return false;
-	if (xdr_stream_decode_u32(xdr, &args->count) < 0)
-		return false;
-	/* totalcount is ignored */
-	if (xdr_stream_decode_u32(xdr, &totalcount) < 0)
-		return false;
-
-	return true;
-}
-
 bool
 nfssvc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -469,31 +451,6 @@ nfssvc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return true;
 }
 
-bool
-nfssvc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_readres *resp = rqstp->rq_resp;
-	struct kvec *head = rqstp->rq_res.head;
-
-	if (!svcxdr_encode_stat(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
-			return false;
-		if (xdr_stream_encode_u32(xdr, resp->count) < 0)
-			return false;
-		svcxdr_encode_opaque_pages(rqstp, xdr, resp->pages,
-					   rqstp->rq_res.page_base,
-					   resp->count);
-		if (svc_encode_result_payload(rqstp, head->iov_len, resp->count) < 0)
-			return false;
-		break;
-	}
-
-	return true;
-}
-
 bool
 nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -645,10 +602,3 @@ void nfssvc_release_diropres(struct svc_rqst *rqstp)
 
 	fh_put(&resp->fh);
 }
-
-void nfssvc_release_readres(struct svc_rqst *rqstp)
-{
-	struct nfsd_readres *resp = rqstp->rq_resp;
-
-	fh_put(&resp->fh);
-}
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 4d06c415a867..9d9150760a0b 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -14,12 +14,6 @@ struct nfsd_diropargs {
 	unsigned int		len;
 };
 
-struct nfsd_readargs {
-	struct svc_fh		fh;
-	__u32			offset;
-	__u32			count;
-};
-
 struct nfsd_writeargs {
 	svc_fh			fh;
 	__u32			offset;
@@ -82,14 +76,6 @@ struct nfsd_diropres  {
 	struct kstat		stat;
 };
 
-struct nfsd_readres {
-	__be32			status;
-	struct svc_fh		fh;
-	unsigned long		count;
-	struct kstat		stat;
-	struct page		**pages;
-};
-
 struct nfsd_readdirres {
 	/* Components of the reply */
 	__be32			status;
@@ -110,7 +96,6 @@ struct nfsd_statfsres {
 
 bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_diropargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_decode_readargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_createargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_decode_renameargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
@@ -121,7 +106,6 @@ bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_statres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
@@ -131,7 +115,6 @@ int nfssvc_encode_entry(void *data, const char *name, int namlen,
 
 void nfssvc_release_attrstat(struct svc_rqst *rqstp);
 void nfssvc_release_diropres(struct svc_rqst *rqstp);
-void nfssvc_release_readres(struct svc_rqst *rqstp);
 
 /* Helper functions for NFSv2 ACL code */
 bool svcxdr_decode_fhandle(struct xdr_stream *xdr, struct svc_fh *fhp);
diff --git a/include/linux/sunrpc/xdrgen/nfs2.h b/include/linux/sunrpc/xdrgen/nfs2.h
index fbda12101f87..eeb8b9ded65f 100644
--- a/include/linux/sunrpc/xdrgen/nfs2.h
+++ b/include/linux/sunrpc/xdrgen/nfs2.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:25:27 2026 */
+/* XDR specification modification time: Tue Sep  8 11:25:45 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DEF_H
 #define _LINUX_XDRGEN_NFS2_DEF_H
-- 
2.55.0

