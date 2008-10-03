From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] lockd: Adjust nlmsvc_lookup_host() to accomodate AF_INET6
	addresses
Date: Fri, 03 Oct 2008 12:50:29 -0400
Message-ID: <20081003165029.10198.77023.stgit@ingres.1015granger.net>
References: <20081003162856.10198.20451.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40649 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbYJCQwG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 12:52:06 -0400
In-Reply-To: <20081003162856.10198.20451.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up nlmsvc_lookup_host() to pass AF_INET6 source addresses to
nlm_lookup_host().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   47 +++++++++++++++++++++++++++++++++++--------
 include/linux/lockd/lockd.h |    5 +++--
 2 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 95a91e8..541e157 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -307,16 +307,33 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 	return nlm_lookup_host(&ni);
 }
 
-/*
- * Find an NLM client handle in the cache. If there is none, create it.
+/**
+ * nlmsvc_lookup_host - Find an NLM host handle matching a remote client
+ * @rqstp: incoming NLM request
+ * @hostname: name of client host
+ * @hostname_len: length of client hostname
+ *
+ * Returns an nlm_host structure that matches the [client address,
+ * transport protocol, NLM version, client hostname] of the passed-in
+ * NLM request.  If one doesn't already exist in the host cache, a
+ * new handle is created and returned.
+ *
+ * Before possibly creating a new nlm_host, construct a sockaddr
+ * for a specific source address in case the local system has
+ * multiple network addresses.  The family of the address in
+ * rq_daddr is guaranteed to be the same as the family of the
+ * address in rq_addr, so it's safe to use the same family for
+ * the source address.
  */
-struct nlm_host *
-nlmsvc_lookup_host(struct svc_rqst *rqstp,
-			const char *hostname, unsigned int hostname_len)
+struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
+				    const char *hostname,
+				    const size_t hostname_len)
 {
-	const struct sockaddr_in source = {
+	struct sockaddr_in sin = {
 		.sin_family	= AF_INET,
-		.sin_addr	= rqstp->rq_daddr.addr,
+	};
+	struct sockaddr_in6 sin6 = {
+		.sin6_family	= AF_INET6,
 	};
 	struct nlm_lookup_host_info ni = {
 		.peer		= NLM_CLIENT,
@@ -326,14 +343,26 @@ nlmsvc_lookup_host(struct svc_rqst *rqstp,
 		.version	= rqstp->rq_vers,
 		.hostname	= hostname,
 		.hostname_len	= hostname_len,
-		.src_sap	= (struct sockaddr *)&source,
-		.src_len	= sizeof(source),
+		.src_len	= rqstp->rq_addrlen,
 	};
 
 	dprintk("lockd: %s(host='%*s', vers=%u, proto=%s)\n", __func__,
 			(int)hostname_len, hostname, rqstp->rq_vers,
 			(rqstp->rq_prot == IPPROTO_UDP ? "udp" : "tcp"));
 
+	switch (ni.sap->sa_family) {
+	case AF_INET:
+		sin.sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
+		ni.src_sap = (struct sockaddr *)&sin;
+		break;
+	case AF_INET6:
+		ipv6_addr_copy(&sin6.sin6_addr, &rqstp->rq_daddr.addr6);
+		ni.src_sap = (struct sockaddr *)&sin6;
+		break;
+	default:
+		return NULL;
+	}
+
 	return nlm_lookup_host(&ni);
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 693d57b..2e13c0b 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -220,8 +220,9 @@ struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 					const unsigned short protocol,
 					const u32 version,
 					const char *hostname);
-struct nlm_host  *nlmsvc_lookup_host(struct svc_rqst *, const char *,
-					unsigned int);
+struct nlm_host  *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
+					const char *hostname,
+					const size_t hostname_len);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);

