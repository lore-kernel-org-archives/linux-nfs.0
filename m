From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/25] NFS: Make nfs_alloc_client() take (sockaddr,
	len) instead of sockaddr_in
Date: Tue, 13 Nov 2007 13:31:58 -0500
Message-ID: <20071113183158.5087.73050.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

To support non-IPv4 addresses, adjust the arguments and callers of
nfs_alloc_client() to pass in a "struct sockaddr *" and length instead of
a "struct sockaddr_in *".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 53bf8ab..c1ee3d3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -100,7 +100,8 @@ struct rpc_program		nfsacl_program = {
  * bother putting them in a slab cache...
  */
 static struct nfs_client *nfs_alloc_client(const char *hostname,
-					   const struct sockaddr_in *addr,
+					   const struct sockaddr *addr,
+					   size_t addrlen,
 					   unsigned int nfsversion)
 {
 	struct nfs_client *clp;
@@ -117,7 +118,7 @@ static struct nfs_client *nfs_alloc_client(const char *hostname,
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	clp->cl_addrlen = sizeof(*addr);	/* for now */
+	clp->cl_addrlen = addrlen;
 	memcpy(&clp->cl_addr, addr, clp->cl_addrlen);
 
 	if (hostname) {
@@ -285,7 +286,9 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 
 		spin_unlock(&nfs_client_lock);
 
-		new = nfs_alloc_client(hostname, addr, nfsversion);
+		new = nfs_alloc_client(hostname,
+				       (const struct sockaddr *)addr,
+				       sizeof(*addr), nfsversion);
 	} while (new);
 
 	return ERR_PTR(-ENOMEM);

