From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/16] lockd: Support non-AF_INET addresses in
	nlm_lookup_host()
Date: Mon, 30 Jun 2008 18:59:50 -0400
Message-ID: <20080630225949.25407.63985.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51654 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528AbYF3XAQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:16 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make nlm_lookup_host() agnostic to address families.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   88 +++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 56 insertions(+), 32 deletions(-)


diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 0e749e6..5a8114d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -37,6 +37,21 @@ static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
 						const size_t hostname_len,
 						const int create);
 
+#define NLM_SERVER	(0)
+#define NLM_CLIENT	(1)
+
+struct nlm_lookup_host_info {
+	const int		server;		/* search for server|client */
+	const struct sockaddr	*sap;		/* address to search for */
+	const size_t		salen;		/* it's length */
+	const unsigned short	protocol;	/* transport to search for*/
+	const u32		version;	/* NLM version to search for */
+	const char		*hostname;	/* remote's hostname */
+	const size_t		hostname_len;	/* it's length */
+	const struct sockaddr	*src_sap;	/* our address (optional) */
+	const size_t		src_len;	/* it's length */
+};
+
 /*
  * Hash function must work well on big- and little-endian platforms
  */
@@ -119,23 +134,13 @@ static void nlm_display_address(const struct sockaddr *sap,
 /*
  * Common host lookup routine for server & client
  */
-static struct nlm_host *nlm_lookup_host(int server,
-					const struct sockaddr_in *sin,
-					int proto, u32 version,
-					const char *hostname,
-					unsigned int hostname_len,
-					const struct sockaddr_in *ssin)
+static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 {
 	struct hlist_head *chain;
 	struct hlist_node *pos;
 	struct nlm_host	*host;
 	struct nsm_handle *nsm = NULL;
 
-	dprintk("lockd: nlm_lookup_host(proto=%d, vers=%u,"
-			" my role is %s, hostname=%.*s)\n",
-			proto, version, server? "server" : "client",
-			hostname_len, hostname? hostname : "<none>");
-
 	mutex_lock(&nlm_host_mutex);
 
 	if (time_after_eq(jiffies, next_gc))
@@ -148,22 +153,22 @@ static struct nlm_host *nlm_lookup_host(int server,
 	 * different NLM rpc_clients into one single nlm_host object.
 	 * This would allow us to have one nlm_host per address.
 	 */
-	chain = &nlm_hosts[nlm_hash_address((struct sockaddr *)sin)];
+	chain = &nlm_hosts[nlm_hash_address(ni->sap)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
-		if (!nlm_cmp_addr(nlm_addr(host), (struct sockaddr *)sin))
+		if (!nlm_cmp_addr(nlm_addr(host), ni->sap))
 			continue;
 
 		/* See if we have an NSM handle for this client */
 		if (!nsm)
 			nsm = host->h_nsmhandle;
 
-		if (host->h_proto != proto)
+		if (host->h_proto != ni->protocol)
 			continue;
-		if (host->h_version != version)
+		if (host->h_version != ni->version)
 			continue;
-		if (host->h_server != server)
+		if (host->h_server != ni->server)
 			continue;
-		if (!nlm_cmp_addr(nlm_srcaddr(host), (struct sockaddr *)ssin))
+		if (!nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
 			continue;
 
 		/* Move to head of hash chain. */
@@ -184,8 +189,8 @@ static struct nlm_host *nlm_lookup_host(int server,
 		atomic_inc(&nsm->sm_count);
 	else {
 		host = NULL;
-		nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
-				hostname, hostname_len, 1);
+		nsm = nsm_find(ni->sap, ni->salen,
+					ni->hostname, ni->hostname_len, 1);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
@@ -200,12 +205,12 @@ static struct nlm_host *nlm_lookup_host(int server,
 		goto out;
 	}
 	host->h_name	   = nsm->sm_name;
-	memcpy(nlm_addr(host), sin, sizeof(*sin));
-	host->h_addrlen = sizeof(*sin);
+	memcpy(nlm_addr(host), ni->sap, ni->salen);
+	host->h_addrlen = ni->salen;
 	nlm_clear_port(nlm_addr(host));
-	memcpy(nlm_srcaddr(host), ssin, sizeof(*ssin));
-	host->h_version    = version;
-	host->h_proto      = proto;
+	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
+	host->h_version    = ni->version;
+	host->h_proto      = ni->protocol;
 	host->h_rpcclnt    = NULL;
 	mutex_init(&host->h_mutex);
 	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
@@ -216,7 +221,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	host->h_state      = 0;			/* pseudo NSM state */
 	host->h_nsmstate   = 0;			/* real NSM state */
 	host->h_nsmhandle  = nsm;
-	host->h_server	   = server;
+	host->h_server	   = ni->server;
 	hlist_add_head(&host->h_hash, chain);
 	INIT_LIST_HEAD(&host->h_lockowners);
 	spin_lock_init(&host->h_lock);
@@ -268,12 +273,22 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr_in *sin,
 				     const char *hostname,
 				     unsigned int hostname_len)
 {
-	const struct sockaddr_in source = {
-		.sin_family	= AF_UNSPEC,
+	const struct sockaddr source = {
+		.sa_family	= AF_UNSPEC,
+	};
+	struct nlm_lookup_host_info ni = {
+		.server		= NLM_SERVER,
+		.sap		= (struct sockaddr *)sin,
+		.salen		= sizeof(*sin),
+		.protocol	= proto,
+		.version	= version,
+		.hostname	= hostname,
+		.hostname_len	= hostname_len,
+		.src_sap	= &source,
+		.src_len	= sizeof(source),
 	};
 
-	return nlm_lookup_host(0, sin, proto, version,
-			       hostname, hostname_len, &source);
+	return nlm_lookup_host(&ni);
 }
 
 /*
@@ -287,10 +302,19 @@ nlmsvc_lookup_host(struct svc_rqst *rqstp,
 		.sin_family	= AF_INET,
 		.sin_addr	= rqstp->rq_daddr.addr,
 	};
+	struct nlm_lookup_host_info ni = {
+		.server		= NLM_CLIENT,
+		.sap		= svc_addr(rqstp),
+		.salen		= rqstp->rq_addrlen,
+		.protocol	= rqstp->rq_prot,
+		.version	= rqstp->rq_vers,
+		.hostname	= hostname,
+		.hostname_len	= hostname_len,
+		.src_sap	= (struct sockaddr *)&source,
+		.src_len	= sizeof(source),
+	};
 
-	return nlm_lookup_host(1, svc_addr_in(rqstp),
-			       rqstp->rq_prot, rqstp->rq_vers,
-			       hostname, hostname_len, &source);
+	return nlm_lookup_host(&ni);
 }
 
 /*

