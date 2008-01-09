From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NFS: Invoke nlmclnt_init during NFS mount processing
Date: Wed, 09 Jan 2008 12:20:18 -0500
Message-ID: <20080109172018.7067.13528.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:43946 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbYAIRUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 12:20:25 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cache an appropriate nlm_host structure in the NFS client's mount point
metadata for later use.

Note that there is no need to set NFS_MOUNT_NONLM in the error case -- if
nfs_start_lockd() returns a non-zero value, its callers ensure that the
mount request fails outright.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |   31 ++++++++++++++++++-------------
 include/linux/nfs_fs_sb.h |    2 ++
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 33a5678..2d635a3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -439,7 +439,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 static void nfs_destroy_server(struct nfs_server *server)
 {
 	if (!(server->flags & NFS_MOUNT_NONLM))
-		lockd_down();	/* release rpc.lockd */
+		nlmclnt_done(server->nlm_host);
 }
 
 /*
@@ -447,20 +447,25 @@ static void nfs_destroy_server(struct nfs_server *server)
  */
 static int nfs_start_lockd(struct nfs_server *server)
 {
-	int error = 0;
+	struct nlm_host *host;
+	struct nfs_client *clp = server->nfs_client;
+	u32 nfs_version = clp->rpc_ops->version;
+	unsigned short protocol = server->flags & NFS_MOUNT_TCP ?
+						IPPROTO_TCP : IPPROTO_UDP;
 
-	if (server->nfs_client->rpc_ops->version > 3)
-		goto out;
+	if (nfs_version > 3)
+		return 0;
 	if (server->flags & NFS_MOUNT_NONLM)
-		goto out;
-	error = lockd_up((server->flags & NFS_MOUNT_TCP) ?
-			IPPROTO_TCP : IPPROTO_UDP);
-	if (error < 0)
-		server->flags |= NFS_MOUNT_NONLM;
-	else
-		server->destroy = nfs_destroy_server;
-out:
-	return error;
+		return 0;
+
+	host = nlmclnt_init((struct sockaddr *)&clp->cl_addr, clp->cl_addrlen,
+			    clp->cl_hostname, nfs_version, protocol);
+	if (IS_ERR(host))
+		return PTR_ERR(host);
+
+	server->nlm_host = host;
+	server->destroy = nfs_destroy_server;
+	return 0;
 }
 
 /*
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 383abe0..d75cf0a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -5,6 +5,7 @@
 #include <linux/backing-dev.h>
 
 struct nfs_iostats;
+struct nlm_host;
 
 /*
  * The nfs_client identifies our client state to the server.
@@ -80,6 +81,7 @@ struct nfs_server {
 	struct list_head	master_link;	/* link in master servers list */
 	struct rpc_clnt *	client;		/* RPC client handle */
 	struct rpc_clnt *	client_acl;	/* ACL RPC client handle */
+	struct nlm_host		*nlm_host;	/* NLM client handle */
 	struct nfs_iostats *	io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */

