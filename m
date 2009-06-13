From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] NFS: Use xdr_stream-based XDR encoder for MNT's dirpath
	argument
Date: Sat, 13 Jun 2009 19:25:46 -0400
Message-ID: <20090613232546.3225.81025.stgit@isabey.1015granger.net>
References: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:16878 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659AbZFMX0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:35 -0400
In-Reply-To: <20090613232149.3225.92143.stgit-r85ClMMopbrwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Check the length of the supplied dirpath, and see that it fits
properly in the RPC buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |   49 ++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index af45a37..93361af 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -21,6 +21,21 @@
 #endif
 
 /*
+ * Defined by RFC 1094, section A.3; and RFC 1813, section 5.1.4
+ */
+#define MNTPATHLEN		(1024)
+
+/*
+ * XDR data type sizes
+ */
+#define encode_dirpath_sz	(1 + XDR_QUADLEN(MNTPATHLEN))
+
+/*
+ * XDR argument and result sizes
+ */
+#define MNT_enc_dirpath_sz	encode_dirpath_sz
+
+/*
  * Defined by RFC 1094, section A.5
  */
 enum {
@@ -135,6 +150,31 @@ static int xdr_encode_dirpath(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
+{
+	const u32 pathname_len = strlen(pathname);
+	__be32 *p;
+
+	if (unlikely(pathname_len > MNTPATHLEN))
+		return -EIO;
+
+	p = xdr_reserve_space(xdr, sizeof(u32) + pathname_len);
+	if (unlikely(p == NULL))
+		return -EIO;
+	xdr_encode_opaque(p, pathname, pathname_len);
+
+	return 0;
+}
+
+static int mnt_enc_dirpath(struct rpc_rqst *req, __be32 *p,
+			   const char *dirpath)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	return encode_mntdirpath(&xdr, dirpath);
+}
+
 static int xdr_decode_fhstatus(struct rpc_rqst *req, __be32 *p,
 			       struct mnt_fhstatus *res)
 {
@@ -164,16 +204,15 @@ static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-#define MNT_dirpath_sz		(1 + 256)
 #define MNT_fhstatus_sz		(1 + 8)
 #define MNT_fhstatus3_sz	(1 + 16)
 
 static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
-		.p_encode	= (kxdrproc_t) xdr_encode_dirpath,
+		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
 		.p_decode	= (kxdrproc_t) xdr_decode_fhstatus,
-		.p_arglen	= MNT_dirpath_sz,
+		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_fhstatus_sz,
 		.p_statidx	= MOUNTPROC_MNT,
 		.p_name		= "MOUNT",
@@ -183,9 +222,9 @@ static struct rpc_procinfo mnt_procedures[] = {
 static struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
-		.p_encode	= (kxdrproc_t) xdr_encode_dirpath,
+		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
 		.p_decode	= (kxdrproc_t) xdr_decode_fhstatus3,
-		.p_arglen	= MNT_dirpath_sz,
+		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_fhstatus3_sz,
 		.p_statidx	= MOUNTPROC3_MNT,
 		.p_name		= "MOUNT",

