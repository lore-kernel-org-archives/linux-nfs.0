From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/25] NFS: Change __nfs_find_client() to take "struct
	sockaddr *"
Date: Tue, 13 Nov 2007 13:32:04 -0500
Message-ID: <20071113183203.5087.77372.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Adjust the arguments and callers of __nfs_find_client() to pass a "struct
sockaddr *" instead of a "struct sockaddr_in *" so that non-IPv4 addresses
can be passed into __nfs_find_client().

A subsequent patch adds support for IPv6 addresses to __nfs_find_client().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c1ee3d3..8eff0b2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -209,10 +209,11 @@ void nfs_put_client(struct nfs_client *clp)
  * Find a client by address
  * - caller must hold nfs_client_lock
  */
-static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr,
+static struct nfs_client *__nfs_find_client(const struct sockaddr *addr,
 					    unsigned int nfsversion,
 					    int match_port)
 {
+	struct sockaddr_in *ap = (struct sockaddr_in *)addr;
 	struct nfs_client *clp;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
@@ -226,10 +227,13 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr,
 		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
-		if (clap->sin_addr.s_addr != addr->sin_addr.s_addr)
+		if (((struct sockaddr *)clap)->sa_family != addr->sa_family)
 			continue;
 
-		if (!match_port || clap->sin_port == addr->sin_port)
+		if (clap->sin_addr.s_addr != ap->sin_addr.s_addr)
+			continue;
+
+		if (!match_port || clap->sin_port == ap->sin_port)
 			goto found;
 	}
 
@@ -250,7 +254,7 @@ struct nfs_client *nfs_find_client(const struct sockaddr_in *addr,
 	struct nfs_client *clp;
 
 	spin_lock(&nfs_client_lock);
-	clp = __nfs_find_client(addr, nfsversion, 0);
+	clp = __nfs_find_client((struct sockaddr *)addr, nfsversion, 0);
 	spin_unlock(&nfs_client_lock);
 	if (clp != NULL && clp->cl_cons_state != NFS_CS_READY) {
 		nfs_put_client(clp);
@@ -278,7 +282,7 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client(addr, nfsversion, 1);
+		clp = __nfs_find_client((struct sockaddr *)addr, nfsversion, 1);
 		if (clp)
 			goto found_client;
 		if (new)

