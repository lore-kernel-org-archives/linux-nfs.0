From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 067/112] NFS: Expand server address storage in nfs_client
	struct
Date: Fri, 25 Jan 2008 11:37:46 -0500
Message-ID: <20080125163746.31887.98755.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294AbYAYRAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:00 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlo1019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:58 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Prepare for managing larger addresses in the NFS client by widening the
nfs_client struct's cl_addr field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>

(Modified to work with the new parameters for nfs_alloc_client)
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    8 ++++++--
 include/linux/nfs_fs_sb.h |    3 ++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 876162c..44fe7fd 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -98,6 +98,7 @@ struct rpc_program		nfsacl_program = {
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr_in *addr;
+	size_t addrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 };
 
@@ -125,7 +126,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	memcpy(&clp->cl_addr, cl_init->addr, sizeof(clp->cl_addr));
+	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
+	clp->cl_addrlen = cl_init->addrlen;
 
 	if (cl_init->hostname) {
 		clp->cl_hostname = kstrdup(cl_init->hostname, GFP_KERNEL);
@@ -425,7 +427,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 	struct rpc_create_args args = {
 		.protocol	= proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
-		.addrsize	= sizeof(clp->cl_addr),
+		.addrsize	= clp->cl_addrlen,
 		.timeout	= &timeparms,
 		.servername	= clp->cl_hostname,
 		.program	= &nfs_program,
@@ -585,6 +587,7 @@ static int nfs_init_server(struct nfs_server *server,
 	struct nfs_client_initdata cl_init = {
 		.hostname = data->nfs_server.hostname,
 		.addr = &data->nfs_server.address,
+		.addrlen = sizeof(data->nfs_server.address),
 		.rpc_ops = &nfs_v2_clientops,
 	};
 	struct nfs_client *clp;
@@ -938,6 +941,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
 		.addr = addr,
+		.addrlen = sizeof(*addr),
 		.rpc_ops = &nfs_v4_clientops,
 	};
 	struct nfs_client *clp;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0b3dcba..912cfe8 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -21,7 +21,8 @@ struct nfs_client {
 #define NFS_CS_CALLBACK		1		/* - callback started */
 #define NFS_CS_IDMAP		2		/* - idmap started */
 #define NFS_CS_RENEWD		3		/* - renewd started */
-	struct sockaddr_in	cl_addr;	/* server identifier */
+	struct sockaddr_storage	cl_addr;	/* server identifier */
+	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
 	struct list_head	cl_share_link;	/* link in global client list */
 	struct list_head	cl_superblocks;	/* List of nfs_server structs */
