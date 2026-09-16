Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BD1D530DE2
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576153; cv=none; b=rU28prDBN/fGMpUYHUaq7u77CBq7yL239W8+LNhtacRRMwhBEmxuHc8woZMcwln2F1Sbte6PlRihCxXqeu5RElabzTypWSF9z7XKhOAZ/8mJ2Rl6jYpvRJYG0bybCm6VqpnTw91CraqxHyAgshkHj0GBLQgRUEEK+1VyZZG4gcs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576153; c=relaxed/simple;
	bh=Fn8/47pqZW3rDzGWM+IOyDU05/3KmkfZRS5ni01GPyo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fts3UHOuPVFTVZZnXMEMonrSDvdzg6RiVMWEfy0qbKyBN5Q5KDNLM7Q+FncrRFgWdT0p8VlMYrfxsTG98NERMMd0Ua2cbT8cr0NKPnmDW3IBTN54Y0h3hEMySwaR0+h+snygb3/1qs1iwQ29IRY6dyGP2sm0RfKKJ3l3tUfgTlM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DQuixl2L; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DQuixl2L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED5171F0089B;
	Wed, 16 Sep 2026 16:29:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576150;
	bh=rs6aagke/ItkB9nu3ogA+SgjLeCCksrdOkAKu3T3f+o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DQuixl2LIo0uR8hhLW8AMD3RO3Q9TbWfAyjWMnDo+kpquHTz3CzbARlNx+2rZ/4eL
	 uE6GQ7+P/iiqQuYdylTlHECMuBP/JrIM/XPVAVNw7GaiwfnT4sxspR5O1/nILi01yA
	 KkSuVipKdn5GcHqwH2Y6yeLRVh1WwPRknGrdSMRVBe+2o5jZBeMsJmtk/2OAyQ8+WJ
	 5AuqK8HEyqPVpTUf5IpEwZN0RKh7q47PpZ8kaU5zBd/kh/LzkV0HoDpVYf9QFp0vcl
	 3+BU2hvDxHKgD7AJosj6xHpKQOLFNhlAW3gcOnp6R+xCjBhPMEKmukQNofIEEvWuKX
	 3IBa7fctVM1+A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 11/27] NFSD: Use xdrgen XDR functions for NFSv2 READLINK procedure
Date: Wed, 16 Sep 2026 12:28:42 -0400
Message-ID: <20260916162859.2051-14-cel@kernel.org>
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

Replace the hand-written NFSv2 READLINK codec pair with the
xdrgen-generated functions. The NFSPROC_READLINK entry in the
nfsd_procedures2 array now dispatches nfs_svc_decode_fhandle and
nfs_svc_encode_readlinkres. A wrapper structure bridges the
generated xdrgen fhandle type and the legacy svc_fh representation
the NFSD VFS layer still uses.

The link target does not reside at the data pointer of the
readlinkres union arm: nfsd_readlink() deposits it directly in a
page of the Reply buffer, so the generic encoder that copies an
opaque from the member's data pointer cannot encode it. Mark the
arm with the "pragma pages" directive so the generated encoder
calls svcxdr_encode_opaque_payload(), which encodes the length
prefix and inserts the payload page into the stream by reference.
The page anchor that the result structure carried duplicated
rq_res.pages -- svc_process() points rq_res.pages at the first
Reply page before dispatch, and the fhandle argument decoder
consumes no pages -- so the helper locates the payload through the
Reply buffer itself, and the wrapper collapses to the generated
readlinkres type.

The pc_argzero field is now set to zero for the NFSv2 READLINK
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs2.x    |  1 +
 fs/nfsd/nfs2xdr_gen.c              |  6 ++--
 fs/nfsd/nfs2xdr_gen.h              |  2 +-
 fs/nfsd/nfsproc.c                  | 58 +++++++++++++++++-------------
 fs/nfsd/nfsxdr.c                   | 22 ------------
 fs/nfsd/xdr.h                      |  7 ----
 include/linux/sunrpc/xdrgen/nfs2.h |  2 +-
 7 files changed, 41 insertions(+), 57 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs2.x b/Documentation/sunrpc/xdr/nfs2.x
index abec81cecbae..771acc4baa17 100644
--- a/Documentation/sunrpc/xdr/nfs2.x
+++ b/Documentation/sunrpc/xdr/nfs2.x
@@ -127,6 +127,7 @@ union readlinkres switch (nfsstat status) {
 	default:
 		void;
 };
+pragma pages readlinkres data;
 
 struct readargs {
 	fhandle		file;
diff --git a/fs/nfsd/nfs2xdr_gen.c b/fs/nfsd/nfs2xdr_gen.c
index 59bee2746650..e97df0eda0e1 100644
--- a/fs/nfsd/nfs2xdr_gen.c
+++ b/fs/nfsd/nfs2xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x
-// XDR specification modification time: Tue Sep  8 11:24:48 2026
+// XDR specification modification time: Tue Sep  8 11:25:27 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -745,7 +745,9 @@ xdrgen_encode_readlinkres(struct xdr_stream *xdr, const struct readlinkres *ptr)
 		return false;
 	switch (ptr->status) {
 	case __constant_cpu_to_be32(NFS_OK):
-		if (!xdrgen_encode_path(xdr, ptr->u.data))
+		if (ptr->u.data.len > NFS_MAXPATHLEN)
+			return false;
+		if (!svcxdr_encode_opaque_payload(xdr, ptr->u.data.len))
 			return false;
 		break;
 	default:
diff --git a/fs/nfsd/nfs2xdr_gen.h b/fs/nfsd/nfs2xdr_gen.h
index 150f4215dbe3..92d5f9a8f5dd 100644
--- a/fs/nfsd/nfs2xdr_gen.h
+++ b/fs/nfsd/nfs2xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:24:48 2026 */
+/* XDR specification modification time: Tue Sep  8 11:25:27 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DECL_H
 #define _LINUX_XDRGEN_NFS2_DECL_H
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index ce52939b3ae7..7bc89629934b 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -476,25 +476,35 @@ static __be32 nfsd_proc_lookup(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Read a symlink.
+/**
+ * nfsd_proc_readlink - READLINK: Read symbolic link
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   readlinkres NFSPROC_READLINK(fhandle) = 5;
  */
-static __be32
-nfsd_proc_readlink(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_readlink(struct svc_rqst *rqstp)
 {
-	struct nfsd_fhandle *argp = rqstp->rq_argp;
-	struct nfsd_readlinkres *resp = rqstp->rq_resp;
+	struct fhandle_wrapper *argp = rqstp->rq_argp;
+	struct readlinkres *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
+	struct page *page;
+	u32 len;
 
-	dprintk("nfsd: READLINK %s\n", SVCFH_fmt(&argp->fh));
+	nfsd_fhandle_to_svc_fh(fhp, &argp->xdrgen);
 
-	/* Read the symlink. */
-	resp->len = NFS_MAXPATHLEN;
-	resp->page = *(rqstp->rq_next_page++);
-	resp->status = nfsd_readlink(rqstp, &argp->fh,
-				     page_address(resp->page), &resp->len);
+	len = NFS_MAXPATHLEN;
+	page = *(rqstp->rq_next_page++);
+	resp->status = nfsd_readlink(rqstp, fhp, page_address(page), &len);
+	if (resp->status == nfs_ok)
+		resp->u.data.len = len;
+	else
+		resp->status = nfsd_map_status(resp->status);
 
-	fh_put(&argp->fh);
-	resp->status = nfsd_map_status(resp->status);
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1004,15 +1014,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "LOOKUP",
 	},
 	[NFSPROC_READLINK] = {
-		.pc_func = nfsd_proc_readlink,
-		.pc_decode = nfssvc_decode_fhandleargs,
-		.pc_encode = nfssvc_encode_readlinkres,
-		.pc_argsize = sizeof(struct nfsd_fhandle),
-		.pc_argzero = sizeof(struct nfsd_fhandle),
-		.pc_ressize = sizeof(struct nfsd_readlinkres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+1+NFS_MAXPATHLEN/4,
-		.pc_name = "READLINK",
+		.pc_func	= nfsd_proc_readlink,
+		.pc_decode	= nfs_svc_decode_fhandle,
+		.pc_encode	= nfs_svc_encode_readlinkres,
+		.pc_argsize	= sizeof(struct fhandle_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct readlinkres),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS2_readlinkres_sz,
+		.pc_name	= "READLINK",
 	},
 	[NFSPROC_READ] = {
 		.pc_func = nfsd_proc_read,
@@ -1167,7 +1177,7 @@ union nfsd_xdrstore {
 	struct nfsd_readdirargs	readdir;
 	struct attrstat_wrapper		attrstat;
 	struct diropres_wrapper		diropres;
-	struct nfsd_readlinkres	readlinkres;
+	struct readlinkres	readlinkres;
 	struct nfsd_readres	readres;
 	struct nfsd_readdirres	readdirres;
 	struct nfsd_statfsres	statfsres;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 174e6f5622f9..ed5ec00e8557 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -469,28 +469,6 @@ nfssvc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 	return true;
 }
 
-bool
-nfssvc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd_readlinkres *resp = rqstp->rq_resp;
-	struct kvec *head = rqstp->rq_res.head;
-
-	if (!svcxdr_encode_stat(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (xdr_stream_encode_u32(xdr, resp->len) < 0)
-			return false;
-		svcxdr_encode_opaque_pages(rqstp, xdr, &resp->page, 0,
-					   resp->len);
-		if (svc_encode_result_payload(rqstp, head->iov_len, resp->len) < 0)
-			return false;
-		break;
-	}
-
-	return true;
-}
-
 bool
 nfssvc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 9983fe212f3a..4d06c415a867 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -82,12 +82,6 @@ struct nfsd_diropres  {
 	struct kstat		stat;
 };
 
-struct nfsd_readlinkres {
-	__be32			status;
-	int			len;
-	struct page		*page;
-};
-
 struct nfsd_readres {
 	__be32			status;
 	struct svc_fh		fh;
@@ -127,7 +121,6 @@ bool nfssvc_decode_readdirargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_statres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_diropres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfssvc_encode_readlinkres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_statfsres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/include/linux/sunrpc/xdrgen/nfs2.h b/include/linux/sunrpc/xdrgen/nfs2.h
index 7e3af2ad90a7..fbda12101f87 100644
--- a/include/linux/sunrpc/xdrgen/nfs2.h
+++ b/include/linux/sunrpc/xdrgen/nfs2.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: ../../Documentation/sunrpc/xdr/nfs2.x */
-/* XDR specification modification time: Tue Sep  8 11:24:48 2026 */
+/* XDR specification modification time: Tue Sep  8 11:25:27 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS2_DEF_H
 #define _LINUX_XDRGEN_NFS2_DEF_H
-- 
2.55.0

