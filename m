From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 097/112] NLM: Introduce an arguments structure for
	nlmclnt_init()
Date: Fri, 25 Jan 2008 11:37:59 -0500
Message-ID: <20080125163758.31887.93467.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14348 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754841AbYAYQ7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:54 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlnt019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:52 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: pass 5 arguments to nlmclnt_init() in a structure similar to the
new nfs_client_initdata structure.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c        |   22 ++++++++--------------
 fs/nfs/client.c            |   17 ++++++++++-------
 include/linux/lockd/bind.h |   19 ++++++++++++++-----
 3 files changed, 32 insertions(+), 26 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 9a8f4f4..0b45fd3 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -43,31 +43,25 @@ static LIST_HEAD(nlm_blocked);
 
 /**
  * nlmclnt_init - Set up per-NFS mount point lockd data structures
- * @server_name: server's hostname
- * @server_address: server's network address
- * @server_addrlen: length of server's address
- * @protocol: transport protocol lockd should use
- * @nfs_version: NFS protocol version for this mount point
+ * @nlm_init: pointer to arguments structure
  *
  * Returns pointer to an appropriate nlm_host struct,
  * or an ERR_PTR value.
  */
-struct nlm_host *nlmclnt_init(const char *server_name,
-			      const struct sockaddr *server_address,
-			      size_t server_addrlen,
-			      unsigned short protocol, u32 nfs_version)
+struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 {
 	struct nlm_host *host;
-	u32 nlm_version = (nfs_version == 2) ? 1 : 4;
+	u32 nlm_version = (nlm_init->nfs_version == 2) ? 1 : 4;
 	int status;
 
-	status = lockd_up(protocol);
+	status = lockd_up(nlm_init->protocol);
 	if (status < 0)
 		return ERR_PTR(status);
 
-	host = nlmclnt_lookup_host((struct sockaddr_in *)server_address,
-				   protocol, nlm_version,
-				   server_name, strlen(server_name));
+	host = nlmclnt_lookup_host((struct sockaddr_in *)nlm_init->address,
+				   nlm_init->protocol, nlm_version,
+				   nlm_init->hostname,
+				   strlen(nlm_init->hostname));
 	if (host == NULL) {
 		lockd_down();
 		return ERR_PTR(-ENOLCK);
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0b3ce86..7a15832 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -468,18 +468,21 @@ static int nfs_start_lockd(struct nfs_server *server)
 {
 	struct nlm_host *host;
 	struct nfs_client *clp = server->nfs_client;
-	u32 nfs_version = clp->rpc_ops->version;
-	unsigned short protocol = server->flags & NFS_MOUNT_TCP ?
-						IPPROTO_TCP : IPPROTO_UDP;
+	struct nlmclnt_initdata nlm_init = {
+		.hostname	= clp->cl_hostname,
+		.address	= (struct sockaddr *)&clp->cl_addr,
+		.addrlen	= clp->cl_addrlen,
+		.protocol	= server->flags & NFS_MOUNT_TCP ?
+						IPPROTO_TCP : IPPROTO_UDP,
+		.nfs_version	= clp->rpc_ops->version,
+	};
 
-	if (nfs_version > 3)
+	if (nlm_init.nfs_version > 3)
 		return 0;
 	if (server->flags & NFS_MOUNT_NONLM)
 		return 0;
 
-	host = nlmclnt_init(clp->cl_hostname,
-			    (struct sockaddr *)&clp->cl_addr,
-			    clp->cl_addrlen, protocol, nfs_version);
+	host = nlmclnt_init(&nlm_init);
 	if (IS_ERR(host))
 		return PTR_ERR(host);
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 7336807..3d25bcd 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -33,13 +33,22 @@ struct nlmsvc_binding {
 extern struct nlmsvc_binding *	nlmsvc_ops;
 
 /*
+ * Similar to nfs_client_initdata, but without the NFS-specific
+ * rpc_ops field.
+ */
+struct nlmclnt_initdata {
+	const char		*hostname;
+	const struct sockaddr	*address;
+	size_t			addrlen;
+	unsigned short		protocol;
+	u32			nfs_version;
+};
+
+/*
  * Functions exported by the lockd module
  */
-extern struct nlm_host *nlmclnt_init(const char *server_name,
-					const struct sockaddr *server_address,
-					size_t server_addrlen,
-					unsigned short protocol,
-					u32 nfs_version);
+
+extern struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init);
 extern void	nlmclnt_done(struct nlm_host *host);
 
 extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
