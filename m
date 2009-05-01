From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] NFS: Update MNT and MNT3 reply decoding functions
Date: Fri, 01 May 2009 12:37:14 -0400
Message-ID: <20090501163714.25681.48417.stgit@ingres.1015granger.net>
References: <20090501163507.25681.14463.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:25430 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760999AbZEAQh2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2009 12:37:28 -0400
In-Reply-To: <20090501163507.25681.14463.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Solder xdr_stream-based XDR decoding functions into the in-kernel mountd
client that are more careful about checking data types and watching for
buffer overflows.  The new MNT3 decoder includes support for auth-flavor
list decoding.

The "_sz" macro for MNT3 replies was missing the size of the file handle.
I've added this back, and included the size of the auth flavor array.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h   |    2 ++
 fs/nfs/mount_clnt.c |   61 ++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfs/nfsroot.c    |    2 ++
 fs/nfs/super.c      |    2 ++
 4 files changed, 54 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b13b456..82a78c8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -83,6 +83,8 @@ struct nfs_mount_request {
 	unsigned short		protocol;
 	struct nfs_fh		*fh;
 	int			noresvport;
+	unsigned int		*auth_flav_len;
+	rpc_authflavor_t	*auth_flavs;
 };
 
 extern int nfs_mount(struct nfs_mount_request *info);
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index bb2bcd9..2975d00 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -40,6 +40,9 @@
  * XDR argument and result sizes
  */
 #define MNT_enc_dirpath_sz	encode_dirpath_sz
+#define MNT_dec_mountres_sz	(MNT_status_sz + MNT_fhandle_sz)
+#define MNT_dec_mountres3_sz	(MNT_status_sz + MNT_fhandle_sz + \
+				 MNT_authflav3_sz)
 
 /*
  * Defined by RFC 1094, section A.5
@@ -159,8 +162,10 @@ struct mnt_fhstatus {
  */
 int nfs_mount(struct nfs_mount_request *info)
 {
-	struct mnt_fhstatus	result = {
-		.fh		= info->fh
+	struct mountres	result = {
+		.fh		= info->fh,
+		.auth_count	= info->auth_flav_len,
+		.auth_flavors	= info->auth_flavs,
 	};
 	struct rpc_message msg	= {
 		.rpc_argp	= info->dirpath,
@@ -199,7 +204,7 @@ int nfs_mount(struct nfs_mount_request *info)
 
 	if (status < 0)
 		goto out_call_err;
-	if (result.status != 0)
+	if (result.errno != 0)
 		goto out_mnt_err;
 
 	dprintk("NFS: MNT request succeeded\n");
@@ -214,12 +219,12 @@ out_clnt_err:
 	goto out;
 
 out_call_err:
-	dprintk("NFS: failed to start MNT request, status=%d\n", status);
+	dprintk("NFS: MNT request failed, status=%d\n", status);
 	goto out;
 
 out_mnt_err:
-	dprintk("NFS: MNT server returned result %d\n", result.status);
-	status = nfs_stat_to_errno(result.status);
+	dprintk("NFS: MNT server returned result %d\n", result.errno);
+	status = result.errno;
 	goto out;
 }
 
@@ -310,6 +315,20 @@ static int decode_fhandle(struct xdr_stream *xdr, struct mountres *res)
 	return 0;
 }
 
+static int mnt_dec_mountres(struct rpc_rqst *req, __be32 *p,
+			    struct mountres *res)
+{
+	struct xdr_stream xdr;
+	int status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+
+	status = decode_status(&xdr, res);
+	if (unlikely(status != 0 || res->errno != 0))
+		return status;
+	return decode_fhandle(&xdr, res);
+}
+
 static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
 {
 	unsigned int i;
@@ -390,6 +409,25 @@ static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
 	return 0;
 }
 
+static int mnt_dec_mountres3(struct rpc_rqst *req, __be32 *p,
+			     struct mountres *res)
+{
+	struct xdr_stream xdr;
+	int status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+
+	status = decode_fhs_status(&xdr, res);
+	if (unlikely(status != 0 || res->errno != 0))
+		return status;
+	status = decode_fhandle3(&xdr, res);
+	if (unlikely(status != 0)) {
+		res->errno = -EBADHANDLE;
+		return 0;
+	}
+	return decode_auth_flavors(&xdr, res);
+}
+
 static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 				struct mnt_fhstatus *res)
 {
@@ -407,16 +445,13 @@ static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-#define MNT_fhstatus_sz		(1 + 8)
-#define MNT_fhstatus3_sz	(1 + 16)
-
 static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
 		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
-		.p_decode	= (kxdrproc_t) xdr_decode_fhstatus,
+		.p_decode	= (kxdrproc_t)mnt_dec_mountres,
 		.p_arglen	= MNT_enc_dirpath_sz,
-		.p_replen	= MNT_fhstatus_sz,
+		.p_replen	= MNT_dec_mountres_sz,
 		.p_statidx	= MOUNTPROC_MNT,
 		.p_name		= "MOUNT",
 	},
@@ -426,9 +461,9 @@ static struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
 		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
-		.p_decode	= (kxdrproc_t) xdr_decode_fhstatus3,
+		.p_decode	= (kxdrproc_t)mnt_dec_mountres3,
 		.p_arglen	= MNT_enc_dirpath_sz,
-		.p_replen	= MNT_fhstatus3_sz,
+		.p_replen	= MNT_dec_mountres3_sz,
 		.p_statidx	= MOUNTPROC3_MNT,
 		.p_name		= "MOUNT",
 	},
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 0388c25..9087178 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -490,6 +490,7 @@ static int __init root_nfs_get_handle(void)
 {
 	struct nfs_fh fh;
 	struct sockaddr_in sin;
+	unsigned int auth_flav_len = 0;
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)&sin,
 		.salen		= sizeof(sin),
@@ -499,6 +500,7 @@ static int __init root_nfs_get_handle(void)
 		.protocol	= (nfs_data.flags & NFS_MOUNT_TCP) ?
 					XPRT_TRANSPORT_TCP : XPRT_TRANSPORT_UDP,
 		.fh		= &fh,
+		.auth_flav_len	= &auth_flav_len,
 	};
 	int status;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7a81cb6..a32e9e5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1375,6 +1375,7 @@ out_security_failure:
 static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			 struct nfs_fh *root_fh)
 {
+	unsigned int auth_flavor_len = 0;
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)
 						&args->mount_server.address,
@@ -1382,6 +1383,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
 		.noresvport	= args->flags & NFS_MOUNT_NORESVPORT,
+		.auth_flav_len	= &auth_flavor_len,
 	};
 	int status;
 

