From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/16] lockd: Adjust nlmsvc_lookup_host() to accomodate
	non-AF_INET
Date: Mon, 30 Jun 2008 19:00:06 -0400
Message-ID: <20080630230005.25407.79595.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51768 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763695AbYF3XA3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:29 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up nlmsvc_lookup_host() to pass non-AF_INET source addresses to
nlm_lookup_host().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   51 +++++++++++++++++++++++++++++++++++--------
 include/linux/lockd/lockd.h |    5 +++-
 2 files changed, 44 insertions(+), 12 deletions(-)


diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 3c7916d..73e234a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -305,29 +305,60 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
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
+ * Manufacture a specific source address in case the local system
+ * services clients from multiple IP addresses.  The family of the
+ * address in rq_daddr is guaranteed to be the same as the family of
+ * the address in rq_addr, so it's safe to use the same family and
+ * length for our manufactured source address.
  */
-struct nlm_host *
-nlmsvc_lookup_host(struct svc_rqst *rqstp,
-			const char *hostname, unsigned int hostname_len)
+struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
+				    const char *hostname,
+				    const size_t hostname_len)
 {
-	const struct sockaddr_in source = {
-		.sin_family	= AF_INET,
-		.sin_addr	= rqstp->rq_daddr.addr,
+	const struct sockaddr *sap = svc_addr(rqstp);
+	struct sockaddr_storage source = {
+		.ss_family	= sap->sa_family,
 	};
+	struct sockaddr_in *sin = (struct sockaddr_in *)&source;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&source;
 	struct nlm_lookup_host_info ni = {
 		.server		= NLM_CLIENT,
-		.sap		= svc_addr(rqstp),
+		.sap		= sap,
 		.salen		= rqstp->rq_addrlen,
 		.protocol	= rqstp->rq_prot,
 		.version	= rqstp->rq_vers,
 		.hostname	= hostname,
 		.hostname_len	= hostname_len,
 		.src_sap	= (struct sockaddr *)&source,
-		.src_len	= sizeof(source),
+		.src_len	= rqstp->rq_addrlen,
 	};
 
+	dprintk("lockd: %s(host='%.*s', vers=%u, proto=%s)\n", __func__,
+			hostname_len, hostname, rqstp->rq_vers,
+			(rqstp->rq_prot == IPPROTO_UDP ? "udp" : "tcp"));
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		sin->sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
+		break;
+	case AF_INET6:
+		ipv6_addr_copy(&sin6->sin6_addr, &rqstp->rq_daddr.addr6);
+		break;
+	default:
+		return NULL;
+	}
+
 	return nlm_lookup_host(&ni);
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 6e8909d..e327914 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -219,8 +219,9 @@ struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
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

