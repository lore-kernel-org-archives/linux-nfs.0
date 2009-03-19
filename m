From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/23] lockd: Start PF_INET6 listener only if IPv6 support is
	available
Date: Wed, 18 Mar 2009 20:47:59 -0400
Message-ID: <20090319004758.32404.30626.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:35024 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898AbZCSAsk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:48:40 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apparently a lot of people need to disable IPv6 completely on their
distributor-built systems, which have CONFIG_IPV6_MODULE enabled at
build time.

They do this by blacklisting the ipv6.ko module.  This causes the
creation of the lockd service listener to fail if CONFIG_IPV6_MODULE
is set, but the module cannot be loaded.

Now that the kernel's PF_INET6 RPC listeners are completely separate
from PF_INET listeners, we can always start PF_INET.  Then lockd can
try to start PF_INET6, but it isn't required to be available.

Note this has the added benefit that NLM callbacks from AF_INET6
servers will never come from AF_INET remotes.  We no longer have to
worry about matching mapped IPv4 addresses to AF_INET when comparing
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c |   51 +--------------------------------------------------
 fs/lockd/svc.c      |   30 +++++++++++++++++++++---------
 2 files changed, 22 insertions(+), 59 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index aedc47a..1f3b0fc 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -139,55 +139,6 @@ int nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout)
 	return 0;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static const struct in6_addr *nlmclnt_map_v4addr(const struct sockaddr *sap,
-						 struct in6_addr *addr_mapped)
-{
-	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
-
-	switch (sap->sa_family) {
-	case AF_INET6:
-		return &((const struct sockaddr_in6 *)sap)->sin6_addr;
-	case AF_INET:
-		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, addr_mapped);
-		return addr_mapped;
-	}
-
-	return NULL;
-}
-
-/*
- * If lockd is using a PF_INET6 listener, all incoming requests appear
- * to come from AF_INET6 remotes.  The address of AF_INET remotes are
- * mapped to AF_INET6 automatically by the network layer.  In case the
- * user passed an AF_INET server address at mount time, ensure both
- * addresses are AF_INET6 before comparing them.
- */
-static int nlmclnt_cmp_addr(const struct nlm_host *host,
-			    const struct sockaddr *sap)
-{
-	const struct in6_addr *addr1;
-	const struct in6_addr *addr2;
-	struct in6_addr addr1_mapped;
-	struct in6_addr addr2_mapped;
-
-	addr1 = nlmclnt_map_v4addr(nlm_addr(host), &addr1_mapped);
-	if (likely(addr1 != NULL)) {
-		addr2 = nlmclnt_map_v4addr(sap, &addr2_mapped);
-		if (likely(addr2 != NULL))
-			return ipv6_addr_equal(addr1, addr2);
-	}
-
-	return 0;
-}
-#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
-static int nlmclnt_cmp_addr(const struct nlm_host *host,
-			    const struct sockaddr *sap)
-{
-	return nlm_cmp_addr(nlm_addr(host), sap);
-}
-#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
-
 /*
  * The server lockd has called us back to tell us the lock was granted
  */
@@ -215,7 +166,7 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlmclnt_cmp_addr(block->b_host, addr))
+		if (!nlm_cmp_addr(nlm_addr(block->b_host), addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 566932b..abf8388 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -193,20 +193,30 @@ lockd(void *vrqstp)
 	return 0;
 }
 
-static int create_lockd_listener(struct svc_serv *serv, char *name,
-				 unsigned short port)
+static int create_lockd_listener(struct svc_serv *serv, const char *name,
+				 const int family, const unsigned short port)
 {
 	struct svc_xprt *xprt;
 
-	xprt = svc_find_xprt(serv, name, 0, 0);
+	xprt = svc_find_xprt(serv, name, family, 0);
 	if (xprt == NULL)
-		return svc_create_xprt(serv, name, PF_INET,
-					port, SVC_SOCK_DEFAULTS);
-
+		return svc_create_xprt(serv, name, family, port,
+						SVC_SOCK_DEFAULTS);
 	svc_xprt_put(xprt);
 	return 0;
 }
 
+static int create_lockd_family(struct svc_serv *serv, const int family)
+{
+	int err;
+
+	err = create_lockd_listener(serv, "udp", family, nlm_udpport);
+	if (err < 0)
+		return err;
+
+	return create_lockd_listener(serv, "tcp", family, nlm_tcpport);
+}
+
 /*
  * Ensure there are active UDP and TCP listeners for lockd.
  *
@@ -222,13 +232,15 @@ static int make_socks(struct svc_serv *serv)
 	static int warned;
 	int err;
 
-	err = create_lockd_listener(serv, "udp", nlm_udpport);
+	err = create_lockd_family(serv, PF_INET);
 	if (err < 0)
 		goto out_err;
 
-	err = create_lockd_listener(serv, "tcp", nlm_tcpport);
-	if (err < 0)
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	err = create_lockd_family(serv, PF_INET6);
+	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_err;
+#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
 
 	warned = 0;
 	return 0;

