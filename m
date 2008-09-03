From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] lockd: Support AF_INET6 when hashing addresses in
	nlm_lookup_host
Date: Wed, 03 Sep 2008 14:36:08 -0400
Message-ID: <20080903183608.16867.80962.stgit@ingres.1015granger.net>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56600 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbYICSgX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 14:36:23 -0400
In-Reply-To: <20080903183411.16867.33715.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adopt an approach similar to the RPC server's auth cache (from Aurelien
Charbon and Brian Haley).

Note nlm_lookup_host()'s existing IP address hash function has the same
issue with correctness on little-endian systems as the original IPv4 auth
cache hash function, so I've also updated it with a hash function similar
to the new auth cache hash function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   49 +++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index dbf3fe6..1f9d72a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -22,7 +22,6 @@
 
 #define NLMDBG_FACILITY		NLMDBG_HOSTCACHE
 #define NLM_HOST_NRHASH		32
-#define NLM_ADDRHASH(addr)	(ntohl(addr) & (NLM_HOST_NRHASH-1))
 #define NLM_HOST_REBIND		(60 * HZ)
 #define NLM_HOST_EXPIRE		(300 * HZ)
 #define NLM_HOST_COLLECT	(120 * HZ)
@@ -40,6 +39,48 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 					 const char *hostname,
 					 unsigned int hostname_len);
 
+/*
+ * Hash function must work well on big- and little-endian platforms
+ */
+static unsigned int __nlm_hash32(const __be32 n)
+{
+	unsigned int hash = (__force u32)n ^ ((__force u32)n >> 16);
+	return hash ^ (hash >> 8);
+}
+
+static unsigned int __nlm_hash_addr4(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	return __nlm_hash32(sin->sin_addr.s_addr);
+}
+
+static unsigned int __nlm_hash_addr6(const struct sockaddr *sap)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	const struct in6_addr addr = sin6->sin6_addr;
+	return __nlm_hash32(addr.s6_addr32[0]) ^
+	       __nlm_hash32(addr.s6_addr32[1]) ^
+	       __nlm_hash32(addr.s6_addr32[2]) ^
+	       __nlm_hash32(addr.s6_addr32[3]);
+}
+
+static unsigned int nlm_hash_address(const struct sockaddr *sap)
+{
+	unsigned int hash;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		hash = __nlm_hash_addr4(sap);
+		break;
+	case AF_INET6:
+		hash = __nlm_hash_addr6(sap);
+		break;
+	default:
+		hash = 0;
+	}
+	return hash & (NLM_HOST_NRHASH - 1);
+}
+
 static void nlm_clear_port(struct sockaddr *sap)
 {
 	switch (sap->sa_family) {
@@ -92,16 +133,12 @@ static struct nlm_host *nlm_lookup_host(int server,
 	struct hlist_node *pos;
 	struct nlm_host	*host;
 	struct nsm_handle *nsm = NULL;
-	int		hash;
 
 	dprintk("lockd: nlm_lookup_host(proto=%d, vers=%u,"
 			" my role is %s, hostname=%.*s)\n",
 			proto, version, server ? "server" : "client",
 			hostname_len, hostname ? hostname : "<none>");
 
-	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
-
-	/* Lock hash table */
 	mutex_lock(&nlm_host_mutex);
 
 	if (time_after_eq(jiffies, next_gc))
@@ -114,7 +151,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	 * different NLM rpc_clients into one single nlm_host object.
 	 * This would allow us to have one nlm_host per address.
 	 */
-	chain = &nlm_hosts[hash];
+	chain = &nlm_hosts[nlm_hash_address((struct sockaddr *)sin)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
 		if (!nlm_cmp_addr(nlm_addr(host), (struct sockaddr *)sin))
 			continue;

