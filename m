From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] lockd: Support non-AF_INET addresses in nlm_lookup_host()
Date: Fri, 03 Oct 2008 12:50:14 -0400
Message-ID: <20081003165014.10198.45113.stgit@ingres.1015granger.net>
References: <20081003162856.10198.20451.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40656 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025AbYJCQwJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 12:52:09 -0400
In-Reply-To: <20081003162856.10198.20451.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use struct sockaddr * and length in nlm_lookup_host_info to all callers
to pass in either AF_INET or AF_INET6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   37 ++++++++++++++++++++-----------------
 1 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 1630588..0a0ceb8 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -43,12 +43,13 @@ static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
 
 struct nlm_lookup_host_info {
 	const int		peer;		/* search for server|client */
-	const struct sockaddr_in *sin;		/* address to search for */
+	const struct sockaddr	*sap;		/* address to search for */
+	const size_t		salen;		/* it's length */
 	const unsigned short	protocol;	/* transport to search for*/
 	const u32		version;	/* NLM version to search for */
 	const char		*hostname;	/* remote's hostname */
 	const size_t		hostname_len;	/* it's length */
-	const struct sockaddr_in *src_sin;	/* our address (optional) */
+	const struct sockaddr	*src_sap;	/* our address (optional) */
 	const size_t		src_len;	/* it's length */
 };
 
@@ -154,9 +155,9 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	 * different NLM rpc_clients into one single nlm_host object.
 	 * This would allow us to have one nlm_host per address.
 	 */
-	chain = &nlm_hosts[nlm_hash_address((struct sockaddr *)ni->sin)];
+	chain = &nlm_hosts[nlm_hash_address(ni->sap)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
-		if (!nlm_cmp_addr(nlm_addr(host), (struct sockaddr *)ni->sin))
+		if (!nlm_cmp_addr(nlm_addr(host), ni->sap))
 			continue;
 
 		/* See if we have an NSM handle for this client */
@@ -169,8 +170,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 			continue;
 		if (host->h_server != ni->peer)
 			continue;
-		if (!nlm_cmp_addr(nlm_srcaddr(host),
-					(struct sockaddr *)ni->src_sin))
+		if (!nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
 			continue;
 
 		/* Move to head of hash chain. */
@@ -191,8 +191,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		atomic_inc(&nsm->sm_count);
 	else {
 		host = NULL;
-		nsm = nsm_find((struct sockaddr *)ni->sin,
-				sizeof(struct sockaddr_in),
+		nsm = nsm_find(ni->sap, ni->salen,
 				ni->hostname, ni->hostname_len, 1);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
@@ -208,10 +207,10 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		goto out;
 	}
 	host->h_name	   = nsm->sm_name;
-	memcpy(nlm_addr(host), ni->sin, sizeof(struct sockaddr_in));
-	host->h_addrlen = sizeof(struct sockaddr_in);
+	memcpy(nlm_addr(host), ni->sap, ni->salen);
+	host->h_addrlen = ni->salen;
 	nlm_clear_port(nlm_addr(host));
-	memcpy(nlm_srcaddr(host), ni->src_sin, sizeof(struct sockaddr_in));
+	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
 	host->h_version    = ni->version;
 	host->h_proto      = ni->protocol;
 	host->h_rpcclnt    = NULL;
@@ -276,17 +275,19 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr_in *sin,
 				     const char *hostname,
 				     unsigned int hostname_len)
 {
-	const struct sockaddr_in source = {
-		.sin_family	= AF_UNSPEC,
+	const struct sockaddr source = {
+		.sa_family	= AF_UNSPEC,
 	};
 	struct nlm_lookup_host_info ni = {
 		.peer		= NLM_SERVER,
-		.sin		= sin,
+		.sap		= (struct sockaddr *)sin,
+		.salen		= sizeof(*sin),
 		.protocol	= proto,
 		.version	= version,
 		.hostname	= hostname,
 		.hostname_len	= hostname_len,
-		.src_sin	= &source,
+		.src_sap	= &source,
+		.src_len	= sizeof(source),
 	};
 
 	dprintk("lockd: %s(host='%s', vers=%u, proto=%s)\n", __func__,
@@ -309,12 +310,14 @@ nlmsvc_lookup_host(struct svc_rqst *rqstp,
 	};
 	struct nlm_lookup_host_info ni = {
 		.peer		= NLM_CLIENT,
-		.sin		= svc_addr_in(rqstp),
+		.sap		= svc_addr(rqstp),
+		.salen		= rqstp->rq_addrlen,
 		.protocol	= rqstp->rq_prot,
 		.version	= rqstp->rq_vers,
 		.hostname	= hostname,
 		.hostname_len	= hostname_len,
-		.src_sin	= &source,
+		.src_sap	= (struct sockaddr *)&source,
+		.src_len	= sizeof(source),
 	};
 
 	dprintk("lockd: %s(host='%*s', vers=%u, proto=%s)\n", __func__,

