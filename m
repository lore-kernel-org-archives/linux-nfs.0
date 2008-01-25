From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 095/112] NFS: Invoke nlmclnt_init during NFS mount
	processing
Date: Fri, 25 Jan 2008 11:37:58 -0500
Message-ID: <20080125163757.31887.4328.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755045AbYAYQ7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:50 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdtG010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:50 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Cache an appropriate nlm_host structure in the NFS client's mount point
metadata for later use.

Note that there is no need to set NFS_MOUNT_NONLM in the error case -- if
nfs_start_lockd() returns a non-zero value, its callers ensure that the
mount request fails outright.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |   32 +++++++++++++++++++-------------
 include/linux/nfs_fs_sb.h |    2 ++
 2 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 18fcb05..0b3ce86 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -458,7 +458,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 static void nfs_destroy_server(struct nfs_server *server)
 {
 	if (!(server->flags & NFS_MOUNT_NONLM))
-		lockd_down();	/* release rpc.lockd */
+		nlmclnt_done(server->nlm_host);
 }
 
 /*
@@ -466,20 +466,26 @@ static void nfs_destroy_server(struct nfs_server *server)
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
+	host = nlmclnt_init(clp->cl_hostname,
+			    (struct sockaddr *)&clp->cl_addr,
+			    clp->cl_addrlen, protocol, nfs_version);
+	if (IS_ERR(host))
+		return PTR_ERR(host);
+
+	server->nlm_host = host;
+	server->destroy = nfs_destroy_server;
+	return 0;
 }
 
 /*
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b5ba5f7..3423c67 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -8,6 +8,7 @@
 #include <asm/atomic.h>
 
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
