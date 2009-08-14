From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/6] sunrpc: add routine for comparing addresses
Date: Fri, 14 Aug 2009 12:57:54 -0400
Message-ID: <1250269079-14629-2-git-send-email-jlayton@redhat.com>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org, chuck.lever@oracle.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

lockd needs these sort of routines, as does the NFSv4 callback code.

Move lockd's routines into common code and rename them so that they can
be used by others.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/clntlock.c         |    2 +-
 fs/lockd/host.c             |    4 +-
 fs/lockd/mon.c              |    2 +-
 fs/lockd/svcsubs.c          |    2 +-
 include/linux/lockd/lockd.h |   43 --------------------------------------
 include/linux/sunrpc/clnt.h |   48 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 53 insertions(+), 48 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 1f3b0fc..fc9032d 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -166,7 +166,7 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlm_cmp_addr(nlm_addr(block->b_host), addr))
+		if (!rpc_cmp_addr(nlm_addr(block->b_host), addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 7cb076a..4600c20 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -111,7 +111,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	 */
 	chain = &nlm_hosts[nlm_hash_address(ni->sap)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
-		if (!nlm_cmp_addr(nlm_addr(host), ni->sap))
+		if (!rpc_cmp_addr(nlm_addr(host), ni->sap))
 			continue;
 
 		/* See if we have an NSM handle for this client */
@@ -125,7 +125,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		if (host->h_server != ni->server)
 			continue;
 		if (ni->server &&
-		    !nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
+		    !rpc_cmp_addr(nlm_srcaddr(host), ni->src_sap))
 			continue;
 
 		/* Move to head of hash chain. */
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 30c9331..f956651 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -209,7 +209,7 @@ static struct nsm_handle *nsm_lookup_addr(const struct sockaddr *sap)
 	struct nsm_handle *nsm;
 
 	list_for_each_entry(nsm, &nsm_handles, sm_link)
-		if (nlm_cmp_addr(nsm_addr(nsm), sap))
+		if (rpc_cmp_addr(nsm_addr(nsm), sap))
 			return nsm;
 	return NULL;
 }
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 9e4d6aa..ad478da 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -417,7 +417,7 @@ EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_sb);
 static int
 nlmsvc_match_ip(void *datap, struct nlm_host *host)
 {
-	return nlm_cmp_addr(nlm_srcaddr(host), datap);
+	return rpc_cmp_addr(nlm_srcaddr(host), datap);
 }
 
 /**
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index c325b18..e7a251a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -338,49 +338,6 @@ static inline int nlm_privileged_requester(const struct svc_rqst *rqstp)
 	}
 }
 
-static inline int __nlm_cmp_addr4(const struct sockaddr *sap1,
-				  const struct sockaddr *sap2)
-{
-	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
-	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
-}
-
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
-				  const struct sockaddr *sap2)
-{
-	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
-	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
-	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
-}
-#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
-static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
-				  const struct sockaddr *sap2)
-{
-	return 0;
-}
-#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
-
-/*
- * Compare two host addresses
- *
- * Return TRUE if the addresses are the same; otherwise FALSE.
- */
-static inline int nlm_cmp_addr(const struct sockaddr *sap1,
-			       const struct sockaddr *sap2)
-{
-	if (sap1->sa_family == sap2->sa_family) {
-		switch (sap1->sa_family) {
-		case AF_INET:
-			return __nlm_cmp_addr4(sap1, sap2);
-		case AF_INET6:
-			return __nlm_cmp_addr6(sap1, sap2);
-		}
-	}
-	return 0;
-}
-
 /*
  * Compare two NLM locks.
  * When the second lock is of type F_UNLCK, this acts like a wildcard.
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index ab3f6e9..b17df36 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -22,6 +22,7 @@
 #include <linux/sunrpc/timer.h>
 #include <asm/signal.h>
 #include <linux/path.h>
+#include <net/ipv6.h>
 
 struct rpc_inode;
 
@@ -188,5 +189,52 @@ static inline void rpc_set_port(struct sockaddr *sap,
 #define IPV6_SCOPE_DELIMITER		'%'
 #define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
 
+static inline bool __rpc_cmp_addr4(const struct sockaddr *sap1,
+				   const struct sockaddr *sap2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
+
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
+				   const struct sockaddr *sap2)
+{
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
+	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
+}
+#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
+				   const struct sockaddr *sap2)
+{
+	return false;
+}
+#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+
+/**
+ * rpc_cmp_addr - compare the address portion of two sockaddrs.
+ * @sap1: first sockaddr
+ * @sap2: second sockaddr
+ *
+ * Just compares the family and address portion. Ignores port, scope, etc.
+ * Returns true if the addrs are equal, false if they aren't.
+ */
+static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
+				const struct sockaddr *sap2)
+{
+	if (sap1->sa_family == sap2->sa_family) {
+		switch (sap1->sa_family) {
+		case AF_INET:
+			return __rpc_cmp_addr4(sap1, sap2);
+		case AF_INET6:
+			return __rpc_cmp_addr6(sap1, sap2);
+		}
+	}
+	return false;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
-- 
1.6.0.6
