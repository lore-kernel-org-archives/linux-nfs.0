From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/11] NFS: Fix NFSv4 callback regression
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.65993.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GabLZ-0001Re-1Z
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 10:06:21 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GabLZ-0003uw-Sv
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 10:06:22 -0700
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

The change in semantics for nfs_find_client() introduced by David breaks
the NFSv4 callback channel.

Also, replace another completely broken BUG_ON() in nfs_find_client().
In initialised clients, clp->cl_cons_state == 0, and callers of that
function should in any case never want to see clients that are
uninitialised.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b123f6..5fea638 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -232,11 +232,15 @@ void nfs_put_client(struct nfs_client *c
  * Find a client by address
  * - caller must hold nfs_client_lock
  */
-static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr, int nfsversion)
+static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr, int nfsversion, int match_port)
 {
 	struct nfs_client *clp;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+		/* Don't match clients that failed to initialise properly */
+		if (clp->cl_cons_state < 0)
+			continue;
+
 		/* Different NFS versions cannot share the same nfs_client */
 		if (clp->cl_nfsversion != nfsversion)
 			continue;
@@ -245,7 +249,7 @@ static struct nfs_client *__nfs_find_cli
 			   sizeof(clp->cl_addr.sin_addr)) != 0)
 			continue;
 
-		if (clp->cl_addr.sin_port == addr->sin_port)
+		if (!match_port || clp->cl_addr.sin_port == addr->sin_port)
 			goto found;
 	}
 
@@ -265,11 +269,12 @@ struct nfs_client *nfs_find_client(const
 	struct nfs_client *clp;
 
 	spin_lock(&nfs_client_lock);
-	clp = __nfs_find_client(addr, nfsversion);
+	clp = __nfs_find_client(addr, nfsversion, 0);
 	spin_unlock(&nfs_client_lock);
-
-	BUG_ON(clp && clp->cl_cons_state == 0);
-
+	if (clp != NULL && clp->cl_cons_state != NFS_CS_READY) {
+		nfs_put_client(clp);
+		clp = NULL;
+	}
 	return clp;
 }
 
@@ -292,7 +297,7 @@ static struct nfs_client *nfs_get_client
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client(addr, nfsversion);
+		clp = __nfs_find_client(addr, nfsversion, 1);
 		if (clp)
 			goto found_client;
 		if (new)

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
