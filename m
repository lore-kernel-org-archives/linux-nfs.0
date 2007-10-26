From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 25/27] NFS: Make cl_nfsversion an unsigned integer,
	like nrvers
Date: Fri, 26 Oct 2007 13:32:50 -0400
Message-ID: <20071026173250.31475.47700.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT3L-0007La-Vg
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:09 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT3R-0006ll-Be
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:05 -0700
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

NFS version numbers are unsigned.  Clean up a little bit of confusion by
changing the cl_nfsversion field in the nfs_client struct to match nrvers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |   22 +++++++++++++---------
 fs/nfs/internal.h         |    4 +++-
 include/linux/nfs_fs_sb.h |    2 +-
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4081197..101f30e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -101,7 +101,7 @@ struct rpc_program		nfsacl_program = {
  */
 static struct nfs_client *nfs_alloc_client(const char *hostname,
 					   const struct sockaddr_in *addr,
-					   int nfsversion)
+					   unsigned int nfsversion)
 {
 	struct nfs_client *clp;
 
@@ -166,7 +166,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
  */
 static void nfs_free_client(struct nfs_client *clp)
 {
-	dprintk("--> nfs_free_client(%d)\n", clp->cl_nfsversion);
+	dprintk("--> nfs_free_client(%u)\n", clp->cl_nfsversion);
 
 	nfs4_shutdown_client(clp);
 
@@ -207,7 +207,9 @@ void nfs_put_client(struct nfs_client *clp)
  * Find a client by address
  * - caller must hold nfs_client_lock
  */
-static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr, int nfsversion, int match_port)
+static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr,
+					    unsigned int nfsversion,
+					    int match_port)
 {
 	struct nfs_client *clp;
 
@@ -238,7 +240,8 @@ found:
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversion)
+struct nfs_client *nfs_find_client(const struct sockaddr_in *addr,
+				   unsigned int nfsversion)
 {
 	struct nfs_client *clp;
 
@@ -258,12 +261,12 @@ struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversio
  */
 static struct nfs_client *nfs_get_client(const char *hostname,
 					 const struct sockaddr_in *addr,
-					 int nfsversion)
+					 unsigned int nfsversion)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
-	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%d)\n",
+	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%u)\n",
 		hostname ?: "", NIPQUAD(addr->sin_addr),
 		addr->sin_port, nfsversion);
 
@@ -544,7 +547,8 @@ static int nfs_init_server(struct nfs_server *server,
 			   const struct nfs_parsed_mount_data *data)
 {
 	struct nfs_client *clp;
-	int error, nfsvers = 2;
+	unsigned nfsvers = 2;
+	int error;
 
 	dprintk("--> nfs_init_server()\n");
 
@@ -1262,7 +1266,7 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 	/* display one transport per line on subsequent lines */
 	clp = list_entry(v, struct nfs_client, cl_share_link);
 
-	seq_printf(m, "v%d %02x%02x%02x%02x %4hx %3d %s\n",
+	seq_printf(m, "v%u %02x%02x%02x%02x %4hx %3d %s\n",
 		   clp->cl_nfsversion,
 		   NIPQUAD(clp->cl_addr.sin_addr),
 		   ntohs(clp->cl_addr.sin_port),
@@ -1341,7 +1345,7 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		 (unsigned long long) server->fsid.major,
 		 (unsigned long long) server->fsid.minor);
 
-	seq_printf(m, "v%d %02x%02x%02x%02x %4hx %-7s %-17s\n",
+	seq_printf(m, "v%u %02x%02x%02x%02x %4hx %-7s %-17s\n",
 		   clp->cl_nfsversion,
 		   NIPQUAD(clp->cl_addr.sin_addr),
 		   ntohs(clp->cl_addr.sin_port),
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5f93512..3d5e587 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -63,7 +63,9 @@ struct nfs_parsed_mount_data {
 extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
-extern struct nfs_client *nfs_find_client(const struct sockaddr_in *, int);
+extern struct nfs_client *nfs_find_client(
+					const struct sockaddr_in *,
+					unsigned int);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0cac49b..64638ca 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -14,7 +14,7 @@ struct nfs_client {
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
-	int			cl_nfsversion;	/* NFS protocol version */
+	unsigned int		cl_nfsversion;	/* NFS protocol version */
 	unsigned long		cl_res_state;	/* NFS resources state */
 #define NFS_CS_CALLBACK		1		/* - callback started */
 #define NFS_CS_IDMAP		2		/* - idmap started */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
