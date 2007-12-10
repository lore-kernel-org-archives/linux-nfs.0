From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/27] NFS: Change nfs_find_client() to take "struct sockaddr
	*"
Date: Mon, 10 Dec 2007 14:58:44 -0500
Message-ID: <20071210195844.2823.48536.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:36459 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbXLJUD2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:03:28 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjust arguments and callers of nfs_find_client() to pass a
"struct sockaddr *" instead of "struct sockaddr_in *" to support non-IPv4
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/callback.c      |    3 +--
 fs/nfs/callback_proc.c |    4 ++--
 fs/nfs/client.c        |    4 ++--
 fs/nfs/internal.h      |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bbf67f1..9b6bbf1 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -164,12 +164,11 @@ void nfs_callback_down(void)
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *addr = svc_addr_in(rqstp);
 	struct nfs_client *clp;
 	char buf[RPC_MAX_ADDRBUFLEN];
 
 	/* Don't talk to strangers */
-	clp = nfs_find_client(addr, 4);
+	clp = nfs_find_client(svc_addr(rqstp), 4);
 	if (clp == NULL)
 		return SVC_DROP;
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa9586d..e89a900 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -25,7 +25,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
+	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
@@ -68,7 +68,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
+	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e904e5f..48fbacd 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -266,13 +266,13 @@ found:
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *nfs_find_client(const struct sockaddr_in *addr,
+struct nfs_client *nfs_find_client(const struct sockaddr *addr,
 				   unsigned int nfsversion)
 {
 	struct nfs_client *clp;
 
 	spin_lock(&nfs_client_lock);
-	clp = __nfs_find_client((struct sockaddr *)addr, nfsversion, 0);
+	clp = __nfs_find_client(addr, nfsversion, 0);
 	spin_unlock(&nfs_client_lock);
 	if (clp != NULL && clp->cl_cons_state != NFS_CS_READY) {
 		nfs_put_client(clp);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c065dc3..8b96364 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -61,7 +61,7 @@ extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs_find_client(
-					const struct sockaddr_in *,
+					const struct sockaddr *,
 					unsigned int);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,

