From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/16] lockd: Teach nlm_cmp_addr() to support AF_INET6
	addresses
Date: Mon, 30 Jun 2008 18:59:18 -0400
Message-ID: <20080630225917.25407.55799.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51653 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932436AbYF3XAQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:16 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the nlm_cmp_addr() helper to support AF_INET6 as well as AF_INET
addresses.  New version takes two "struct sockaddr *" arguments instead of
"struct sockaddr_in *" arguments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c         |    3 ++-
 fs/lockd/host.c             |    6 +++---
 fs/lockd/svcsubs.c          |    2 +-
 include/linux/lockd/lockd.h |   38 ++++++++++++++++++++++++++++++++++----
 4 files changed, 40 insertions(+), 9 deletions(-)


diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 0df5587..237224a 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -166,7 +166,8 @@ __be32 nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *lock
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlm_cmp_addr(nlm_addr_in(block->b_host), addr))
+		if (!nlm_cmp_addr(nlm_addr(block->b_host),
+					(struct sockaddr *)addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index c2efbfb..cd3f663 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -114,7 +114,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	 */
 	chain = &nlm_hosts[hash];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
-		if (!nlm_cmp_addr(nlm_addr_in(host), sin))
+		if (!nlm_cmp_addr(nlm_addr(host), (struct sockaddr *)sin))
 			continue;
 
 		/* See if we have an NSM handle for this client */
@@ -127,7 +127,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 			continue;
 		if (host->h_server != server)
 			continue;
-		if (!nlm_cmp_addr(nlm_srcaddr_in(host), ssin))
+		if (!nlm_cmp_addr(nlm_srcaddr(host), (struct sockaddr *)ssin))
 			continue;
 
 		/* Move to head of hash chain. */
@@ -544,7 +544,7 @@ retry:
 			if (strlen(pos->sm_name) != hostname_len
 			 || memcmp(pos->sm_name, hostname, hostname_len))
 				continue;
-		} else if (!nlm_cmp_addr(nsm_addr_in(pos), sin))
+		} else if (!nlm_cmp_addr(nsm_addr(pos), (struct sockaddr *)sin))
 			continue;
 		atomic_inc(&pos->sm_count);
 		kfree(nsm);
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 64ba7df..373ec0c 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -415,7 +415,7 @@ EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_sb);
 static int
 nlmsvc_match_ip(void *datap, struct nlm_host *host)
 {
-	return nlm_cmp_addr(nlm_srcaddr_in(host), datap);
+	return nlm_cmp_addr(nlm_srcaddr(host), datap);
 }
 
 /**
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a1eecf5..6af3b05 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -12,6 +12,8 @@
 #ifdef __KERNEL__
 
 #include <linux/in.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
 #include <linux/fs.h>
 #include <linux/kref.h>
 #include <linux/utsname.h>
@@ -269,13 +271,41 @@ static inline struct inode *nlmsvc_file_inode(struct nlm_file *file)
 	return file->f_file->f_path.dentry->d_inode;
 }
 
+static inline int __nlm_cmp_addr4(const struct sockaddr *sap1,
+				  const struct sockaddr *sap2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+}
+
+static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
+				  const struct sockaddr *sap2)
+{
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
+	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
+}
+
 /*
- * Compare two host addresses (needs modifying for ipv6)
+ * Compare two host addresses
+ *
+ * Return TRUE if the addresses are the same; otherwise FALSE.
  */
-static inline int nlm_cmp_addr(const struct sockaddr_in *sin1,
-			       const struct sockaddr_in *sin2)
+static inline int nlm_cmp_addr(const struct sockaddr *sap1,
+			       const struct sockaddr *sap2)
 {
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+	if (sap1->sa_family != sap2->sa_family)
+		return 0;
+
+	switch (sap1->sa_family) {
+	case AF_INET:
+		return __nlm_cmp_addr4(sap1, sap2);
+	case AF_INET6:
+		return __nlm_cmp_addr6(sap1, sap2);
+	default:
+		return 0;
+	}
 }
 
 /*

