From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 049/112] NFS: Clean up the nfs_client initialisation
Date: Fri, 25 Jan 2008 11:37:39 -0500
Message-ID: <20080125163738.31887.81648.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754841AbYAYRAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:07 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlo9019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:02 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   51 +++++++++++++++++++++++++++++++--------------------
 1 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b5f9b9..d7f6d50 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -93,22 +93,26 @@ struct rpc_program		nfsacl_program = {
 };
 #endif  /* CONFIG_NFS_V3_ACL */
 
+struct nfs_client_initdata {
+	const char *hostname;
+	const struct sockaddr_in *addr;
+	int version;
+};
+
 /*
  * Allocate a shared client record
  *
  * Since these are allocated/deallocated very rarely, we don't
  * bother putting them in a slab cache...
  */
-static struct nfs_client *nfs_alloc_client(const char *hostname,
-					   const struct sockaddr_in *addr,
-					   int nfsversion)
+static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp;
 
 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
 		goto error_0;
 
-	if (nfsversion == 4) {
+	if (cl_init->version == 4) {
 		if (nfs_callback_up() < 0)
 			goto error_2;
 		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
@@ -117,11 +121,11 @@ static struct nfs_client *nfs_alloc_client(const char *hostname,
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	clp->cl_nfsversion = nfsversion;
-	memcpy(&clp->cl_addr, addr, sizeof(clp->cl_addr));
+	clp->cl_nfsversion = cl_init->version;
+	memcpy(&clp->cl_addr, cl_init->addr, sizeof(clp->cl_addr));
 
-	if (hostname) {
-		clp->cl_hostname = kstrdup(hostname, GFP_KERNEL);
+	if (cl_init->hostname) {
+		clp->cl_hostname = kstrdup(cl_init->hostname, GFP_KERNEL);
 		if (!clp->cl_hostname)
 			goto error_3;
 	}
@@ -256,22 +260,20 @@ struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversio
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-static struct nfs_client *nfs_get_client(const char *hostname,
-					 const struct sockaddr_in *addr,
-					 int nfsversion)
+static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
 	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%d)\n",
-		hostname ?: "", NIPQUAD(addr->sin_addr),
-		addr->sin_port, nfsversion);
+		cl_init->hostname ?: "", NIPQUAD(cl_init->addr->sin_addr),
+		cl_init->addr->sin_port, cl_init->version);
 
 	/* see if the client already exists */
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client(addr, nfsversion, 1);
+		clp = __nfs_find_client(cl_init->addr, cl_init->version, 1);
 		if (clp)
 			goto found_client;
 		if (new)
@@ -279,7 +281,7 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 
 		spin_unlock(&nfs_client_lock);
 
-		new = nfs_alloc_client(hostname, addr, nfsversion);
+		new = nfs_alloc_client(cl_init);
 	} while (new);
 
 	return ERR_PTR(-ENOMEM);
@@ -540,19 +542,23 @@ error:
 static int nfs_init_server(struct nfs_server *server,
 			   const struct nfs_parsed_mount_data *data)
 {
+	struct nfs_client_initdata cl_init = {
+		.hostname = data->nfs_server.hostname,
+		.addr = &data->nfs_server.address,
+		.version = 2,
+	};
 	struct nfs_client *clp;
-	int error, nfsvers = 2;
+	int error;
 
 	dprintk("--> nfs_init_server()\n");
 
 #ifdef CONFIG_NFS_V3
 	if (data->flags & NFS_MOUNT_VER3)
-		nfsvers = 3;
+		cl_init.version = 3;
 #endif
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(data->nfs_server.hostname,
-				&data->nfs_server.address, nfsvers);
+	clp = nfs_get_client(&cl_init);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
@@ -889,13 +895,18 @@ static int nfs4_set_client(struct nfs_server *server,
 		rpc_authflavor_t authflavour,
 		int proto, int timeo, int retrans)
 {
+	struct nfs_client_initdata cl_init = {
+		.hostname = hostname,
+		.addr = addr,
+		.version = 4,
+	};
 	struct nfs_client *clp;
 	int error;
 
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(hostname, addr, 4);
+	clp = nfs_get_client(&cl_init);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;
