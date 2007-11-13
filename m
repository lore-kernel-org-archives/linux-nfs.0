From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/25] NFS: Change nfs_find_client() to take "struct sockaddr
	*"
Date: Tue, 13 Nov 2007 13:32:14 -0500
Message-ID: <20071113183214.5087.34512.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Adjust arguments and callers of nfs_find_client() to pass a
"struct sockaddr *" instead of "struct sockaddr_in *" to support non-IPv4
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
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
index 00082cf..019d939 100644
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
index 67a5a53..7b45ed0 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -268,13 +268,13 @@ found:
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
index 3d5e587..ef40539 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -64,7 +64,7 @@ extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs_find_client(
-					const struct sockaddr_in *,
+					const struct sockaddr *,
 					unsigned int);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,

