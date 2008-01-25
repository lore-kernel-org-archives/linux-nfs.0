From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 051/112] NFS: Remove the redundant nfs_client->cl_nfsversion
Date: Fri, 25 Jan 2008 11:37:40 -0500
Message-ID: <20080125163739.31887.98347.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755712AbYAYRAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:19 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH04Hk010310
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:16 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can get the same information from the rpc_ops structure instead.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |   41 ++++++++++++++++++-----------------------
 fs/nfs/namespace.c        |    2 +-
 fs/nfs/super.c            |    2 +-
 include/linux/nfs_fs_sb.h |    1 -
 4 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ff778ec..3b21731 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -96,7 +96,7 @@ struct rpc_program		nfsacl_program = {
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr_in *addr;
-	int version;
+	const struct nfs_rpc_ops *rpc_ops;
 };
 
 /*
@@ -112,7 +112,9 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
 		goto error_0;
 
-	if (cl_init->version == 4) {
+	clp->rpc_ops = cl_init->rpc_ops;
+
+	if (cl_init->rpc_ops->version == 4) {
 		if (nfs_callback_up() < 0)
 			goto error_2;
 		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
@@ -121,7 +123,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	clp->cl_nfsversion = cl_init->version;
 	memcpy(&clp->cl_addr, cl_init->addr, sizeof(clp->cl_addr));
 
 	if (cl_init->hostname) {
@@ -170,7 +171,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
  */
 static void nfs_free_client(struct nfs_client *clp)
 {
-	dprintk("--> nfs_free_client(%d)\n", clp->cl_nfsversion);
+	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
 
 	nfs4_shutdown_client(clp);
 
@@ -222,7 +223,7 @@ struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversio
 			continue;
 
 		/* Different NFS versions cannot share the same nfs_client */
-		if (clp->cl_nfsversion != nfsversion)
+		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
 		/* Match only the IP address, not the port number */
@@ -251,7 +252,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		/* Different NFS versions cannot share the same nfs_client */
-		if (clp->cl_nfsversion != data->version)
+		if (clp->rpc_ops != data->rpc_ops)
 			continue;
 
 		/* Match the full socket address */
@@ -273,9 +274,9 @@ static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_in
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
-	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%d)\n",
+	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%u)\n",
 		cl_init->hostname ?: "", NIPQUAD(cl_init->addr->sin_addr),
-		cl_init->addr->sin_port, cl_init->version);
+		cl_init->addr->sin_port, cl_init->rpc_ops->version);
 
 	/* see if the client already exists */
 	do {
@@ -430,7 +431,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 {
 	int error = 0;
 
-	if (server->nfs_client->cl_nfsversion > 3)
+	if (server->nfs_client->rpc_ops->version > 3)
 		goto out;
 	if (server->flags & NFS_MOUNT_NONLM)
 		goto out;
@@ -450,7 +451,7 @@ out:
 #ifdef CONFIG_NFS_V3_ACL
 static void nfs_init_server_aclclient(struct nfs_server *server)
 {
-	if (server->nfs_client->cl_nfsversion != 3)
+	if (server->nfs_client->rpc_ops->version != 3)
 		goto out_noacl;
 	if (server->flags & NFS_MOUNT_NOACL)
 		goto out_noacl;
@@ -521,12 +522,6 @@ static int nfs_init_client(struct nfs_client *clp,
 		return 0;
 	}
 
-	/* Check NFS protocol revision and initialize RPC op vector */
-	clp->rpc_ops = &nfs_v2_clientops;
-#ifdef CONFIG_NFS_V3
-	if (clp->cl_nfsversion == 3)
-		clp->rpc_ops = &nfs_v3_clientops;
-#endif
 	/*
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
@@ -553,7 +548,7 @@ static int nfs_init_server(struct nfs_server *server,
 	struct nfs_client_initdata cl_init = {
 		.hostname = data->nfs_server.hostname,
 		.addr = &data->nfs_server.address,
-		.version = 2,
+		.rpc_ops = &nfs_v2_clientops,
 	};
 	struct nfs_client *clp;
 	int error;
@@ -562,7 +557,7 @@ static int nfs_init_server(struct nfs_server *server,
 
 #ifdef CONFIG_NFS_V3
 	if (data->flags & NFS_MOUNT_VER3)
-		cl_init.version = 3;
+		cl_init.rpc_ops = &nfs_v3_clientops;
 #endif
 
 	/* Allocate or find a client reference we can use */
@@ -906,7 +901,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
 		.addr = addr,
-		.version = 4,
+		.rpc_ops = &nfs_v4_clientops,
 	};
 	struct nfs_client *clp;
 	int error;
@@ -1284,8 +1279,8 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 	/* display one transport per line on subsequent lines */
 	clp = list_entry(v, struct nfs_client, cl_share_link);
 
-	seq_printf(m, "v%d %02x%02x%02x%02x %4hx %3d %s\n",
-		   clp->cl_nfsversion,
+	seq_printf(m, "v%u %02x%02x%02x%02x %4hx %3d %s\n",
+		   clp->rpc_ops->version,
 		   NIPQUAD(clp->cl_addr.sin_addr),
 		   ntohs(clp->cl_addr.sin_port),
 		   atomic_read(&clp->cl_count),
@@ -1363,8 +1358,8 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		 (unsigned long long) server->fsid.major,
 		 (unsigned long long) server->fsid.minor);
 
-	seq_printf(m, "v%d %02x%02x%02x%02x %4hx %-7s %-17s\n",
-		   clp->cl_nfsversion,
+	seq_printf(m, "v%u %02x%02x%02x%02x %4hx %-7s %-17s\n",
+		   clp->rpc_ops->version,
 		   NIPQUAD(clp->cl_addr.sin_addr),
 		   ntohs(clp->cl_addr.sin_port),
 		   dev,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index acfc56f..be4ce1c 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -188,7 +188,7 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 {
 #ifdef CONFIG_NFS_V4
 	struct vfsmount *mnt = NULL;
-	switch (server->nfs_client->cl_nfsversion) {
+	switch (server->nfs_client->rpc_ops->version) {
 		case 2:
 		case 3:
 			mnt = vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a3492d6..5608e6a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -529,7 +529,7 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 	seq_printf(m, ",namelen=%d", nfss->namelen);
 
 #ifdef CONFIG_NFS_V4
-	if (nfss->nfs_client->cl_nfsversion == 4) {
+	if (nfss->nfs_client->rpc_ops->version == 4) {
 		seq_printf(m, "\n\tnfsv4:\t");
 		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
 		seq_printf(m, ",bm1=0x%x", nfss->attr_bitmask[1]);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 9f949b5..97b3257 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -17,7 +17,6 @@ struct nfs_client {
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
-	int			cl_nfsversion;	/* NFS protocol version */
 	unsigned long		cl_res_state;	/* NFS resources state */
 #define NFS_CS_CALLBACK		1		/* - callback started */
 #define NFS_CS_IDMAP		2		/* - idmap started */
