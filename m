Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58926 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab1GOR41 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 13:56:27 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH (RESEND) 12/12] lockd: Support binding nlm client to specific address.
Date: Fri, 15 Jul 2011 10:56:08 -0700
Message-Id: <1310752568-21280-13-git-send-email-greearb@candelatech.com>
In-Reply-To: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
References: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This ensures that file locking messages use the proper
source IP address if the file system has been mounted
with a specified source IP address.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 8d4ea83... e8dff8d... M	fs/lockd/clntlock.c
:100644 100644 b7c99bf... 140fccc... M	fs/lockd/host.c
:100644 100644 8b8766a... 39c7667... M	fs/nfs/client.c
:100644 100644 fbc48f8... 822bcc3... M	include/linux/lockd/bind.h
:100644 100644 ff9abff... b69ef3b... M	include/linux/lockd/lockd.h
:100644 100644 db7bcaf... adfe318... M	include/linux/sunrpc/clnt.h
 fs/lockd/clntlock.c         |    3 ++-
 fs/lockd/host.c             |   17 ++++++++++++++++-
 fs/nfs/client.c             |    1 +
 include/linux/lockd/bind.h  |    1 +
 include/linux/lockd/lockd.h |    1 +
 include/linux/sunrpc/clnt.h |    2 ++
 6 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 8d4ea83..e8dff8d 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -60,7 +60,8 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	if (status < 0)
 		return ERR_PTR(status);
 
-	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
+	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->srcaddr,
+				   nlm_init->addrlen,
 				   nlm_init->protocol, nlm_version,
 				   nlm_init->hostname, nlm_init->noresvport);
 	if (host == NULL) {
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index b7c99bf..140fccc 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -48,6 +48,7 @@ static void			nlm_gc_hosts(void);
 struct nlm_lookup_host_info {
 	const int		server;		/* search for server|client */
 	const struct sockaddr	*sap;		/* address to search for */
+	const struct sockaddr   *src_addr;      /* source address */
 	const size_t		salen;		/* it's length */
 	const unsigned short	protocol;	/* transport to search for*/
 	const u32		version;	/* NLM version to search for */
@@ -130,7 +131,12 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	memcpy(nlm_addr(host), ni->sap, ni->salen);
 	host->h_addrlen    = ni->salen;
 	rpc_set_port(nlm_addr(host), 0);
-	host->h_srcaddrlen = 0;
+	if (ni->src_addr && ni->src_addr->sa_family != AF_UNSPEC) {
+		memcpy(nlm_srcaddr(host), ni->src_addr, ni->salen);
+		host->h_srcaddrlen = ni->salen;
+	} else {
+		host->h_srcaddrlen = 0;
+	}
 
 	host->h_rpcclnt    = NULL;
 	host->h_name	   = nsm->sm_name;
@@ -202,6 +208,7 @@ static void nlm_destroy_host_locked(struct nlm_host *host)
  * created and returned.
  */
 struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
+				     const struct sockaddr *srcaddr,
 				     const size_t salen,
 				     const unsigned short protocol,
 				     const u32 version,
@@ -216,6 +223,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.version	= version,
 		.hostname	= hostname,
 		.hostname_len	= strlen(hostname),
+		.src_addr       = srcaddr,
 		.noresvport	= noresvport,
 	};
 	struct hlist_head *chain;
@@ -234,6 +242,13 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		if (!rpc_cmp_addr(nlm_addr(host), sap))
 			continue;
 
+		/* Check for local binding match only if user
+		 * has specified the source-address.
+		 */
+		if (srcaddr && srcaddr->sa_family != AF_UNSPEC &&
+		    !rpc_cmp_addr(nlm_srcaddr(host), srcaddr))
+			continue;
+
 		/* Same address. Share an NSM handle if we already have one */
 		if (nsm == NULL)
 			nsm = host->h_nsmhandle;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b8766a..39c7667 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -705,6 +705,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 	struct nlmclnt_initdata nlm_init = {
 		.hostname	= clp->cl_hostname,
 		.address	= (struct sockaddr *)&clp->cl_addr,
+		.srcaddr        = (struct sockaddr *)&clp->srcaddr,
 		.addrlen	= clp->cl_addrlen,
 		.nfs_version	= clp->rpc_ops->version,
 		.noresvport	= server->flags & NFS_MOUNT_NORESVPORT ?
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index fbc48f8..822bcc3 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -38,6 +38,7 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
 struct nlmclnt_initdata {
 	const char		*hostname;
 	const struct sockaddr	*address;
+	const struct sockaddr   *srcaddr;
 	size_t			addrlen;
 	unsigned short		protocol;
 	u32			nfs_version;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ff9abff..b69ef3b 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -218,6 +218,7 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
  * Host cache
  */
 struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
+					const struct sockaddr *bindaddr,
 					const size_t salen,
 					const unsigned short protocol,
 					const u32 version,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index db7bcaf..adfe318 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -262,6 +262,8 @@ static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
 			return __rpc_cmp_addr4(sap1, sap2);
 		case AF_INET6:
 			return __rpc_cmp_addr6(sap1, sap2);
+		case AF_UNSPEC:
+			return true;
 		}
 	}
 	return false;
-- 
1.7.3.4

