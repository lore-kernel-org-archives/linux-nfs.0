Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10299 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932757Ab2AMULk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:40 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 40/44] NFS: Export functions from client.c
Date: Fri, 13 Jan 2012 15:10:49 -0500
Message-Id: <1326485453-1350-41-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I am about to move over nfs v4-only code from client.c to nfs4/client.c.
These functions will be needed by that code, so they cannot be declared
static.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c |   34 +++++++++++++++++++++-------------
 fs/nfs/nfs.h    |   11 +++++++++++
 2 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 56da3b6..8e053a4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -402,8 +402,8 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
  * Test if two socket addresses represent the same actual socket,
  * by comparing (only) relevant fields, excluding the port number.
  */
-static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
-				     const struct sockaddr *sa2)
+int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
+			      const struct sockaddr *sa2)
 {
 	if (sa1->sa_family != sa2->sa_family)
 		return 0;
@@ -416,6 +416,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_sockaddr_match_ipaddr);
 
 /*
  * Test if two socket addresses represent the same actual socket,
@@ -498,7 +499,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-static struct nfs_client *
+struct nfs_client *
 nfs_get_client(const struct nfs_client_initdata *cl_init,
 	       const struct rpc_timeout *timeparms,
 	       const char *ip_addr,
@@ -571,6 +572,7 @@ found_client:
 	dprintk("--> nfs_get_client() = %p [share]\n", clp);
 	return clp;
 }
+EXPORT_SYMBOL_GPL(nfs_get_client);
 
 /*
  * Mark a server as ready or failed
@@ -580,6 +582,7 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 	clp->cl_cons_state = state;
 	wake_up_all(&nfs_client_active_wq);
 }
+EXPORT_SYMBOL_GPL(nfs_mark_client_ready);
 
 /*
  * With sessions, the client is not marked ready until after a
@@ -600,8 +603,8 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 /*
  * Initialise the timeout values for a connection
  */
-static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
-				    unsigned int timeo, unsigned int retrans)
+void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
+			     unsigned int timeo, unsigned int retrans)
 {
 	to->to_initval = timeo * HZ / 10;
 	to->to_retries = retrans;
@@ -637,14 +640,15 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 		BUG();
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_init_timeout_values);
 
 /*
  * Create an RPC client handle
  */
-static int nfs_create_rpc_client(struct nfs_client *clp,
-				 const struct rpc_timeout *timeparms,
-				 rpc_authflavor_t flavor,
-				 int discrtry, int noresvport)
+int nfs_create_rpc_client(struct nfs_client *clp,
+			  const struct rpc_timeout *timeparms,
+			  rpc_authflavor_t flavor,
+			  int discrtry, int noresvport)
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
@@ -677,6 +681,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 	clp->cl_rpcclient = clnt;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
 
 /*
  * Version 2 or 3 client destruction
@@ -730,7 +735,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 /*
  * Create a general RPC client
  */
-static int nfs_init_server_rpcclient(struct nfs_server *server,
+int nfs_init_server_rpcclient(struct nfs_server *server,
 		const struct rpc_timeout *timeo,
 		rpc_authflavor_t pseudoflavour)
 {
@@ -762,6 +767,7 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_init_server_rpcclient);
 
 /*
  * Initialise an NFS2 or NFS3 client
@@ -947,7 +953,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 /*
  * Probe filesystem information, including the FSID on v2/v3
  */
-static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fattr *fattr)
+int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fattr *fattr)
 {
 	struct nfs_fsinfo fsinfo;
 	struct nfs_client *clp = server->nfs_client;
@@ -987,11 +993,12 @@ out_error:
 	dprintk("nfs_probe_fsinfo: error = %d\n", -error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_probe_fsinfo);
 
 /*
  * Copy useful information when duplicating a server record
  */
-static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
+void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
 {
 	target->flags = source->flags;
 	target->rsize = source->rsize;
@@ -1003,8 +1010,9 @@ static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_serve
 	target->caps = source->caps;
 	target->options = source->options;
 }
+EXPORT_SYMBOL_GPL(nfs_server_copy_userdata);
 
-static void nfs_server_insert_lists(struct nfs_server *server)
+void nfs_server_insert_lists(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
 
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 5f2d632..464c64a 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -68,6 +68,17 @@ struct nfs_server *do_nfs_clone_server(struct nfs_server *, struct nfs_server *,
 				       struct nfs_fh *, struct nfs_fattr *);
 struct list_head *nfs_client_list_start(void);
 void nfs_client_list_end(void);
+int nfs_sockaddr_match_ipaddr(const struct sockaddr *, const struct sockaddr *);
+int nfs_create_rpc_client(struct nfs_client *, const struct rpc_timeout *,
+			  rpc_authflavor_t, int, int);
+struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
+				  const struct rpc_timeout *, const char *,
+				  rpc_authflavor_t, int);
+int nfs_probe_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
+void nfs_server_insert_lists(struct nfs_server *);
+void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
+int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *, rpc_authflavor_t);
+void nfs_server_copy_userdata(struct nfs_server *, struct nfs_server *);
 
 /* Exported in dir.c */
 int nfs_lookup_revalidate(struct dentry *, struct nameidata *);
-- 
1.7.8.3

