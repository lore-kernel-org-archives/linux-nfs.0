From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NLM: Fix GRANT callback address comparison when IPv6 is
	enabled
Date: Fri, 06 Mar 2009 14:08:54 -0500
Message-ID: <20090306190854.17892.74414.stgit@ingres.1015granger.net>
References: <20090306190613.17892.26458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:61586 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860AbZCFTJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2009 14:09:24 -0500
In-Reply-To: <20090306190613.17892.26458.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS mount command may pass an AF_INET server address to lockd.  If
lockd happens to be using a PF_INET6 listener, the nlm_cmp_addr() in
nlmclnt_grant() will fail to match requests from that host because they
will all have a mapped IPv4 AF_INET6 address.

Adopt the same solution used in nfs_sockaddr_match_ipaddr() for NFSv4
callbacks: if either address is AF_INET, map it to an AF_INET6 address
before doing the comparison.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 1f3b0fc..aedc47a 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -139,6 +139,55 @@ int nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout)
 	return 0;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static const struct in6_addr *nlmclnt_map_v4addr(const struct sockaddr *sap,
+						 struct in6_addr *addr_mapped)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+
+	switch (sap->sa_family) {
+	case AF_INET6:
+		return &((const struct sockaddr_in6 *)sap)->sin6_addr;
+	case AF_INET:
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, addr_mapped);
+		return addr_mapped;
+	}
+
+	return NULL;
+}
+
+/*
+ * If lockd is using a PF_INET6 listener, all incoming requests appear
+ * to come from AF_INET6 remotes.  The address of AF_INET remotes are
+ * mapped to AF_INET6 automatically by the network layer.  In case the
+ * user passed an AF_INET server address at mount time, ensure both
+ * addresses are AF_INET6 before comparing them.
+ */
+static int nlmclnt_cmp_addr(const struct nlm_host *host,
+			    const struct sockaddr *sap)
+{
+	const struct in6_addr *addr1;
+	const struct in6_addr *addr2;
+	struct in6_addr addr1_mapped;
+	struct in6_addr addr2_mapped;
+
+	addr1 = nlmclnt_map_v4addr(nlm_addr(host), &addr1_mapped);
+	if (likely(addr1 != NULL)) {
+		addr2 = nlmclnt_map_v4addr(sap, &addr2_mapped);
+		if (likely(addr2 != NULL))
+			return ipv6_addr_equal(addr1, addr2);
+	}
+
+	return 0;
+}
+#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+static int nlmclnt_cmp_addr(const struct nlm_host *host,
+			    const struct sockaddr *sap)
+{
+	return nlm_cmp_addr(nlm_addr(host), sap);
+}
+#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+
 /*
  * The server lockd has called us back to tell us the lock was granted
  */
@@ -166,7 +215,7 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlm_cmp_addr(nlm_addr(block->b_host), addr))
+		if (!nlmclnt_cmp_addr(block->b_host, addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;

