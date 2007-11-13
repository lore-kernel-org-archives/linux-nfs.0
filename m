From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/25] NFS: Change nfs_get_client() to take (sockaddr
	*, len)
Date: Tue, 13 Nov 2007 13:32:19 -0500
Message-ID: <20071113183219.5087.82892.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Ye-0000VL-HO
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:20 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Yk-0006fx-A7
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:26 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Adjust arguments and callers of nfs_get_client() to pass a
"struct sockaddr *" and length instead of "struct sockaddr_in *" to support
non-IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7b45ed0..f03a742 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -288,21 +288,21 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr,
  * - creates a new record if one doesn't yet exist
  */
 static struct nfs_client *nfs_get_client(const char *hostname,
-					 const struct sockaddr_in *addr,
+					 const struct sockaddr *addr,
+					 size_t addrlen,
 					 unsigned int nfsversion)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
-	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%u)\n",
-		hostname ?: "", NIPQUAD(addr->sin_addr),
-		addr->sin_port, nfsversion);
+	dprintk("--> nfs_get_client(%s,v%u)\n",
+		hostname ?: "", nfsversion);
 
 	/* see if the client already exists */
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client((struct sockaddr *)addr, nfsversion, 1);
+		clp = __nfs_find_client(addr, nfsversion, 1);
 		if (clp)
 			goto found_client;
 		if (new)
@@ -310,9 +310,7 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 
 		spin_unlock(&nfs_client_lock);
 
-		new = nfs_alloc_client(hostname,
-				       (const struct sockaddr *)addr,
-				       sizeof(*addr), nfsversion);
+		new = nfs_alloc_client(hostname, addr, addrlen, nfsversion);
 	} while (new);
 
 	return ERR_PTR(-ENOMEM);
@@ -588,7 +586,9 @@ static int nfs_init_server(struct nfs_server *server,
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(data->nfs_server.hostname,
-				&data->nfs_server.address, nfsvers);
+				(struct sockaddr *)&data->nfs_server.address,
+				sizeof(data->nfs_server.address),
+				nfsvers);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
@@ -925,7 +925,8 @@ static int nfs4_set_client(struct nfs_server *server,
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(hostname, addr, 4);
+	clp = nfs_get_client(hostname, (struct sockaddr *)addr,
+				sizeof(*addr), 4);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
