From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/16] lockd: Adjust nlmclnt_lookup_host() signature to
	accomodate non-AF_INET
Date: Mon, 30 Jun 2008 18:59:58 -0400
Message-ID: <20080630225957.25407.71453.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51683 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764179AbYF3XAV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:21 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass a struct sockaddr * and a length to nlmclnt_lookup_host() to
accomodate non-AF_INET family addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c         |    5 ++---
 fs/lockd/host.c             |   34 ++++++++++++++++++++++++----------
 include/linux/lockd/lockd.h |    9 +++++----
 3 files changed, 31 insertions(+), 17 deletions(-)


diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 237224a..9eaf306 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -58,10 +58,9 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	if (status < 0)
 		return ERR_PTR(status);
 
-	host = nlmclnt_lookup_host((struct sockaddr_in *)nlm_init->address,
+	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
 				   nlm_init->protocol, nlm_version,
-				   nlm_init->hostname,
-				   strlen(nlm_init->hostname));
+				   nlm_init->hostname);
 	if (host == NULL) {
 		lockd_down();
 		return ERR_PTR(-ENOLCK);
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 5a8114d..3c7916d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -265,29 +265,43 @@ nlm_destroy_host(struct nlm_host *host)
 	kfree(host);
 }
 
-/*
- * Find an NLM server handle in the cache. If there is none, create it.
+/**
+ * nlmclnt_lookup_host - Find an NLM host handle matching a remote server
+ * @sap: network address of server
+ * @salen: length of server address
+ * @protocol: transport protocol to use
+ * @version: NLM protocol version
+ * @hostname: '\0'-terminated hostname of server
+ *
+ * Returns an nlm_host structure that matches the passed-in
+ * [server address, transport protocol, NLM version, server hostname].
+ * If one doesn't already exist in the host cache, a new handle is
+ * created and returned.
  */
-struct nlm_host *nlmclnt_lookup_host(const struct sockaddr_in *sin,
-				     int proto, u32 version,
-				     const char *hostname,
-				     unsigned int hostname_len)
+struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
+				     const size_t salen,
+				     const unsigned short protocol,
+				     const u32 version, const char *hostname)
 {
 	const struct sockaddr source = {
 		.sa_family	= AF_UNSPEC,
 	};
 	struct nlm_lookup_host_info ni = {
 		.server		= NLM_SERVER,
-		.sap		= (struct sockaddr *)sin,
-		.salen		= sizeof(*sin),
-		.protocol	= proto,
+		.sap		= sap,
+		.salen		= salen,
+		.protocol	= protocol,
 		.version	= version,
 		.hostname	= hostname,
-		.hostname_len	= hostname_len,
+		.hostname_len	= strlen(hostname),
 		.src_sap	= &source,
 		.src_len	= sizeof(source),
 	};
 
+	dprintk("lockd: nlmclnt_lookup_host(host='%s', vers=%u, proto=%s)\n",
+			(hostname ? hostname : "<none>"), version,
+			(protocol == IPPROTO_UDP ? "udp" : "tcp"));
+
 	return nlm_lookup_host(&ni);
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 6af3b05..6e8909d 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -214,10 +214,11 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
 /*
  * Host cache
  */
-struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr_in *sin,
-					int proto, u32 version,
-					const char *hostname,
-					unsigned int hostname_len);
+struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
+					const size_t salen,
+					const unsigned short protocol,
+					const u32 version,
+					const char *hostname);
 struct nlm_host  *nlmsvc_lookup_host(struct svc_rqst *, const char *,
 					unsigned int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);

