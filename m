From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/27] NFS: Change cb_recallargs to pass "struct sockaddr *"
	instead of sockaddr_in
Date: Mon, 10 Dec 2007 14:58:29 -0500
Message-ID: <20071210195829.2823.44609.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:39761 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755839AbXLJUEq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:04:46 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the addr field in the cb_recallargs struct to a "struct sockaddr *"
to support non-IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/callback.h      |    2 +-
 fs/nfs/callback_proc.c |    2 +-
 fs/nfs/callback_xdr.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index ec0ffd9..bb25d21 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -53,7 +53,7 @@ struct cb_getattrres {
 };
 
 struct cb_recallargs {
-	struct sockaddr_in *addr;
+	struct sockaddr *addr;
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	uint32_t truncate;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 32f0df0..fa9586d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -68,7 +68,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 3eda1bc..c63eb72 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -188,7 +188,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	__be32 *p;
 	__be32 status;
 
-	args->addr = svc_addr_in(rqstp);
+	args->addr = svc_addr(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;

