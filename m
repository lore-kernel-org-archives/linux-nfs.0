From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/25] NFS: Expand server address storage in
	nfs_client struct
Date: Tue, 13 Nov 2007 13:31:42 -0500
Message-ID: <20071113183142.5087.5236.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Y3-0000NY-Sn
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:44 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Y9-0007wT-84
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:49 -0800
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

Prepare for managing larger addresses in the NFS client by widening the
nfs_client struct's cl_addr field and adding a field to store the address's
length.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/client.c           |   11 +++++++----
 fs/nfs/super.c            |    9 ++++++---
 include/linux/nfs_fs_sb.h |    3 ++-
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5ab1ca1..53bf8ab 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -117,7 +117,8 @@ static struct nfs_client *nfs_alloc_client(const char *hostname,
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	memcpy(&clp->cl_addr, addr, sizeof(clp->cl_addr));
+	clp->cl_addrlen = sizeof(*addr);	/* for now */
+	memcpy(&clp->cl_addr, addr, clp->cl_addrlen);
 
 	if (hostname) {
 		clp->cl_hostname = kstrdup(hostname, GFP_KERNEL);
@@ -214,6 +215,8 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr,
 	struct nfs_client *clp;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+		struct sockaddr_in *clap = (struct sockaddr_in *)&clp->cl_addr;
+
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -222,10 +225,10 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr,
 		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
-		if (clp->cl_addr.sin_addr.s_addr != addr->sin_addr.s_addr)
+		if (clap->sin_addr.s_addr != addr->sin_addr.s_addr)
 			continue;
 
-		if (!match_port || clp->cl_addr.sin_port == addr->sin_port)
+		if (!match_port || clap->sin_port == addr->sin_port)
 			goto found;
 	}
 
@@ -380,7 +383,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 	struct rpc_create_args args = {
 		.protocol	= proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
-		.addrsize	= sizeof(clp->cl_addr),
+		.addrsize	= clp->cl_addrlen,
 		.timeout	= &timeparms,
 		.servername	= clp->cl_hostname,
 		.program	= &nfs_program,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5a742a8..6258a19 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1332,10 +1332,13 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
 	int mntflags = sb_mntdata->mntflags;
 
-	if (memcmp(&old->nfs_client->cl_addr,
-				&server->nfs_client->cl_addr,
-				sizeof(old->nfs_client->cl_addr)) != 0)
+	/* Check family, address, and port */
+	if (old->nfs_client->cl_addrlen != server->nfs_client->cl_addrlen)
 		return 0;
+	if (memcmp(&old->nfs_client->cl_addr, &server->nfs_client->cl_addr,
+		   old->nfs_client->cl_addrlen) != 0)
+		return 0;
+
 	/* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
 	if (old->flags & NFS_MOUNT_UNSHARED)
 		return 0;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index f2a0f20..5e3a43b 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -20,7 +20,8 @@ struct nfs_client {
 #define NFS_CS_IDMAP		2		/* - idmap started */
 #define NFS_CS_RENEWD		3		/* - renewd started */
 
-	struct sockaddr_in	cl_addr;	/* server identifier */
+	struct sockaddr_storage	cl_addr;	/* server identifier */
+	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
 	struct list_head	cl_share_link;	/* link in global client list */
 	struct list_head	cl_superblocks;	/* List of nfs_server structs */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
