From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] NFS: Remove unused XDR decoder functions
Date: Sat, 13 Jun 2009 19:26:31 -0400
Message-ID: <20090613232630.3225.73556.stgit@isabey.1015granger.net>
References: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:48448 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482AbZFMX0j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:39 -0400
In-Reply-To: <20090613232149.3225.92143.stgit-r85ClMMopbrwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Remove xdr_decode_fhstatus() and xdr_decode_fhstatus3(), now
that they are unused.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |   29 -----------------------------
 1 files changed, 0 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 618d815..38ef9ea 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -238,18 +238,6 @@ static int mnt_enc_dirpath(struct rpc_rqst *req, __be32 *p,
 	return encode_mntdirpath(&xdr, dirpath);
 }
 
-static int xdr_decode_fhstatus(struct rpc_rqst *req, __be32 *p,
-			       struct mnt_fhstatus *res)
-{
-	struct nfs_fh *fh = res->fh;
-
-	if ((res->status = ntohl(*p++)) == 0) {
-		fh->size = NFS2_FHSIZE;
-		memcpy(fh->data, p, NFS2_FHSIZE);
-	}
-	return 0;
-}
-
 /*
  * RFC 1094: "A non-zero status indicates some sort of error.  In this
  * case, the status is a UNIX error number."  This can be problematic
@@ -409,23 +397,6 @@ static int mnt_dec_mountres3(struct rpc_rqst *req, __be32 *p,
 	return decode_auth_flavors(&xdr, res);
 }
 
-static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
-				struct mnt_fhstatus *res)
-{
-	struct nfs_fh *fh = res->fh;
-	unsigned size;
-
-	if ((res->status = ntohl(*p++)) == 0) {
-		size = ntohl(*p++);
-		if (size <= NFS3_FHSIZE && size != 0) {
-			fh->size = size;
-			memcpy(fh->data, p, size);
-		} else
-			res->status = -EBADHANDLE;
-	}
-	return 0;
-}
-
 static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,

