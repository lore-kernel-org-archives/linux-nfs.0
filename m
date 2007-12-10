From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/27] NFS: Expand server address storage in nfs_client struct
Date: Mon, 10 Dec 2007 14:58:15 -0500
Message-ID: <20071210195815.2823.77445.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:34026 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbXLJUCh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:02:37 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prepare for managing larger addresses in the NFS client by widening the
nfs_client struct's cl_addr field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c           |    5 +++--
 include/linux/nfs_fs_sb.h |    3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a37f01a..4da1014 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -119,7 +119,8 @@ static struct nfs_client *nfs_alloc_client(const char *hostname,
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	memcpy(&clp->cl_addr, addr, sizeof(clp->cl_addr));
+	memcpy(&clp->cl_addr, addr, sizeof(*addr));
+	clp->cl_addrlen = sizeof(*addr);
 
 	if (hostname) {
 		clp->cl_hostname = kstrdup(hostname, GFP_KERNEL);
@@ -404,7 +405,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 	struct rpc_create_args args = {
 		.protocol	= proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
-		.addrsize	= sizeof(clp->cl_addr),
+		.addrsize	= clp->cl_addrlen,
 		.timeout	= &timeparms,
 		.servername	= clp->cl_hostname,
 		.program	= &nfs_program,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c64773f..383abe0 100644
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

