Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48021 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757797Ab0KQVQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Nov 2010 16:16:15 -0500
From: andros@netapp.com
To: benny@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] NFS add minorversion to nfs_find_client search
Date: Tue, 16 Nov 2010 22:36:28 -0500
Message-Id: <1289964990-4480-2-git-send-email-andros@netapp.com>
In-Reply-To: <1289964990-4480-1-git-send-email-andros@netapp.com>
References: <1289964990-4480-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

The v4.0 and v4.1 callback threads share a pg_authenticate method.
Minorversions do not share an nfs_client.

Respond with an rpc auth error (SVC_DENIED) if the nfs_client matching the
server address, nfs version, and minorversion is not found.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c      |   19 +++++++++++++------
 fs/nfs/callback.h      |    4 ++--
 fs/nfs/callback_proc.c |    8 ++++----
 fs/nfs/client.c        |   16 +++++++++++-----
 fs/nfs/internal.h      |    2 +-
 5 files changed, 31 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index aeec017..962c5de 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -17,9 +17,7 @@
 #include <linux/freezer.h>
 #include <linux/kthread.h>
 #include <linux/sunrpc/svcauth_gss.h>
-#if defined(CONFIG_NFS_V4_1)
 #include <linux/sunrpc/bc_xprt.h>
-#endif
 
 #include <net/inet_sock.h>
 
@@ -346,19 +344,28 @@ static int check_gss_callback_principal(struct nfs_client *clp,
 	return SVC_OK;
 }
 
+/*
+ * Lookup the nfs_client that corresponds to this backchannel request.
+ *
+ * We only support NFSv4.1 callbacks on the fore channel connection, so
+ * the svc_is_backchannel test indicates which minorversion nfs_client we are
+ * searching for.
+ */
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
 	struct nfs_client *clp;
 	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
+	u32 minorversion = svc_is_backchannel(rqstp) ? 1 : 0;
 	int ret = SVC_OK;
 
 	/* Don't talk to strangers */
-	clp = nfs_find_client(svc_addr(rqstp), 4);
+	clp = nfs_find_client(svc_addr(rqstp), 4, minorversion);
 	if (clp == NULL)
-		return SVC_DROP;
+		return SVC_DENIED;
 
-	dprintk("%s: %s NFSv4 callback!\n", __func__,
-			svc_print_addr(rqstp, buf, sizeof(buf)));
+	dprintk("%s: %s NFSv4 callback! minorversion %d\n", __func__,
+			svc_print_addr(rqstp, buf, sizeof(buf)),
+			clp->cl_minorversion);
 
 	switch (rqstp->rq_authop->flavour) {
 		case RPC_AUTH_NULL:
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b16dd1f..b69bec5 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -177,7 +177,7 @@ static inline void put_session_client(struct nfs4_session *session)
 static inline struct nfs_client *
 find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
 {
-	return cps->session ? cps->session->clp : nfs_find_client(addr, 4);
+	return cps->session ? cps->session->clp : nfs_find_client(addr, 4, 0);
 }
 
 #else /* CONFIG_NFS_V4_1 */
@@ -189,7 +189,7 @@ static inline void nfs_client_return_layouts(struct nfs_client *clp)
 static inline struct nfs_client *
 find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
 {
-	return nfs_find_client(addr, 4);
+	return nfs_find_client(addr, 4, 0);
 }
 
 static inline void put_session_client(struct nfs4_session *session)
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b4c68e9..69d085a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -505,13 +505,13 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
  * Returns NULL if there are no connections with sessions, or if no session
  * matches the one of interest.
  */
- static struct nfs_client *find_client_with_session(
-	const struct sockaddr *addr, u32 nfsversion,
-	struct nfs4_sessionid *sessionid)
+static struct nfs_client *
+find_client_with_session(const struct sockaddr *addr, u32 nfsversion,
+			 struct nfs4_sessionid *sessionid)
 {
 	struct nfs_client *clp;
 
-	clp = nfs_find_client(addr, 4);
+	clp = nfs_find_client(addr, 4, 1);
 	if (clp == NULL)
 		return NULL;
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dbf43e7..ba7712c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -371,7 +371,8 @@ EXPORT_SYMBOL(nfs_sockaddr_cmp);
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
+struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion,
+				   u32 minorversion)
 {
 	struct nfs_client *clp;
 
@@ -385,7 +386,8 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 			continue;
 
 		/* Different NFS versions cannot share the same nfs_client */
-		if (clp->rpc_ops->version != nfsversion)
+		if (clp->rpc_ops->version != nfsversion ||
+		    clp->cl_minorversion != minorversion)
 			continue;
 
 		/* Match only the IP address, not the port number */
@@ -401,13 +403,16 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 }
 
 /*
- * Find a client by IP address and protocol version
- * - returns NULL if no such client
+ * Callback service RPC layer pg_authenticate method.
+ *
+ * Find a client by IP address, protocol version, and minorversion.
+ * Returns NULL if no such client
  */
 struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 {
 	struct sockaddr *sap = (struct sockaddr *)&clp->cl_addr;
 	u32 nfsvers = clp->rpc_ops->version;
+	u32 minorversion = clp->cl_minorversion;
 
 	spin_lock(&nfs_client_lock);
 	list_for_each_entry_continue(clp, &nfs_client_list, cl_share_link) {
@@ -418,7 +423,8 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 			continue;
 
 		/* Different NFS versions cannot share the same nfs_client */
-		if (clp->rpc_ops->version != nfsvers)
+		if (clp->rpc_ops->version != nfsvers ||
+		    clp->cl_minorversion != minorversion)
 			continue;
 
 		/* Match only the IP address, not the port number */
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0a9ea58..d89aded 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -131,7 +131,7 @@ extern void nfs_umount(const struct nfs_mount_request *info);
 extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
-extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32);
+extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32, u32);
 extern struct nfs_client *nfs_find_client_next(struct nfs_client *);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
-- 
1.6.6

