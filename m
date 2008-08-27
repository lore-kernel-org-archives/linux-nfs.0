From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] lockd: address-family independent printable addresses
Date: Wed, 27 Aug 2008 16:57:23 -0400
Message-ID: <20080827205722.17837.33918.stgit@manray.1015granger.net>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:46875 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbYH0VEL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 17:04:11 -0400
In-Reply-To: <20080827204852.17837.38361.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Knowing which source address is used for communicating with remote NLM
services can be helpful for debugging configuration problems on hosts
with multiple addresses.

Keep the dprintk debugging here, but adapt it so it displays AF_INET6
addresses properly.  There are also a couple of dprintk clean-ups as
well.

At some point we will aggregate the helpers that display presentation
format addresses into a single set of shared helpers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   78 ++++++++++++++++++++++++++++++++++---------
 include/linux/lockd/lockd.h |    4 ++
 2 files changed, 65 insertions(+), 17 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index cb26e3d..e5dcfa5 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -11,12 +11,14 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/sm_inter.h>
 #include <linux/mutex.h>
 
+#include <net/ipv6.h>
 
 #define NLMDBG_FACILITY		NLMDBG_HOSTCACHE
 #define NLM_HOST_NRHASH		32
@@ -38,6 +40,32 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 					 const char *hostname,
 					 unsigned int hostname_len);
 
+static void nlm_display_address(const struct sockaddr *sap,
+				char *buf, const size_t len)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+
+	switch (sap->sa_family) {
+	case AF_UNSPEC:
+		snprintf(buf, len, "unspecified");
+		break;
+	case AF_INET:
+		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+		break;
+	case AF_INET6:
+		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
+			snprintf(buf, len, NIPQUAD_FMT,
+				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
+		else
+			snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
+		break;
+	default:
+		snprintf(buf, len, "unsupported address family");
+		break;
+	}
+}
+
 /*
  * Common host lookup routine for server & client
  */
@@ -54,14 +82,10 @@ static struct nlm_host *nlm_lookup_host(int server,
 	struct nsm_handle *nsm = NULL;
 	int		hash;
 
-	dprintk("lockd: nlm_lookup_host("NIPQUAD_FMT"->"NIPQUAD_FMT
-			", p=%d, v=%u, my role=%s, name=%.*s)\n",
-			NIPQUAD(ssin->sin_addr.s_addr),
-			NIPQUAD(sin->sin_addr.s_addr), proto, version,
-			server? "server" : "client",
-			hostname_len,
-			hostname? hostname : "<none>");
-
+	dprintk("lockd: nlm_lookup_host(proto=%d, vers=%u,"
+			" my role is %s, hostname=%.*s)\n",
+			proto, version, server ? "server" : "client",
+			hostname_len, hostname ? hostname : "<none>");
 
 	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
 
@@ -101,6 +125,8 @@ static struct nlm_host *nlm_lookup_host(int server,
 		hlist_add_head(&host->h_hash, chain);
 
 		nlm_get_host(host);
+		dprintk("lockd: nlm_lookup_host found host %s (%s)\n",
+				host->h_name, host->h_addrbuf);
 		goto out;
 	}
 
@@ -113,13 +139,17 @@ static struct nlm_host *nlm_lookup_host(int server,
 	else {
 		host = NULL;
 		nsm = nsm_find(sin, hostname, hostname_len);
-		if (!nsm)
+		if (!nsm) {
+			dprintk("lockd: nlm_lookup_host failed; "
+				"no nsm handle\n");
 			goto out;
+		}
 	}
 
 	host = kzalloc(sizeof(*host), GFP_KERNEL);
 	if (!host) {
 		nsm_release(nsm);
+		dprintk("lockd: nlm_lookup_host failed; no memory\n");
 		goto out;
 	}
 	host->h_name	   = nsm->sm_name;
@@ -146,6 +176,15 @@ static struct nlm_host *nlm_lookup_host(int server,
 	INIT_LIST_HEAD(&host->h_reclaim);
 
 	nrhosts++;
+
+	nlm_display_address((struct sockaddr *)&host->h_addr,
+				host->h_addrbuf, sizeof(host->h_addrbuf));
+	nlm_display_address((struct sockaddr *)&host->h_saddr,
+				host->h_saddrbuf, sizeof(host->h_saddrbuf));
+
+	dprintk("lockd: nlm_lookup_host created host %s\n",
+			host->h_name);
+
 out:
 	mutex_unlock(&nlm_host_mutex);
 	return host;
@@ -210,9 +249,8 @@ nlm_bind_host(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
 
-	dprintk("lockd: nlm_bind_host("NIPQUAD_FMT"->"NIPQUAD_FMT")\n",
-			NIPQUAD(host->h_saddr.sin_addr),
-			NIPQUAD(host->h_addr.sin_addr));
+	dprintk("lockd: nlm_bind_host %s (%s), my addr=%s\n",
+			host->h_name, host->h_addrbuf, host->h_saddrbuf);
 
 	/* Lock host handle */
 	mutex_lock(&host->h_mutex);
@@ -224,7 +262,7 @@ nlm_bind_host(struct nlm_host *host)
 		if (time_after_eq(jiffies, host->h_nextrebind)) {
 			rpc_force_rebind(clnt);
 			host->h_nextrebind = jiffies + NLM_HOST_REBIND;
-			dprintk("lockd: next rebind in %ld jiffies\n",
+			dprintk("lockd: next rebind in %lu jiffies\n",
 					host->h_nextrebind - jiffies);
 		}
 	} else {
@@ -327,12 +365,16 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
-	dprintk("lockd: nlm_host_rebooted(%s, %u.%u.%u.%u)\n",
-			hostname, NIPQUAD(sin->sin_addr));
-
 	/* Find the NSM handle for this peer */
-	if (!(nsm = __nsm_find(sin, hostname, hostname_len, 0)))
+	nsm = __nsm_find(sin, hostname, hostname_len, 0);
+	if (nsm == NULL) {
+		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
+				hostname_len, hostname);
 		return;
+	}
+
+	dprintk("lockd: nlm_host_rebooted(%.*s, %s)\n",
+			hostname_len, hostname, nsm->sm_addrbuf);
 
 	/* When reclaiming locks on this peer, make sure that
 	 * we set up a new notification */
@@ -516,6 +558,8 @@ retry:
 	nsm->sm_name = (char *) (nsm + 1);
 	memcpy(nsm->sm_name, hostname, hostname_len);
 	nsm->sm_name[hostname_len] = '\0';
+	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
+				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
 	atomic_set(&nsm->sm_count, 1);
 	goto retry;
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index dbb87ab..0691efb 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -61,6 +61,9 @@ struct nlm_host {
 	struct list_head	h_granted;	/* Locks in GRANTED state */
 	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
 	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
+
+	char			h_addrbuf[48],	/* address eyecatchers */
+				h_saddrbuf[48];
 };
 
 struct nsm_handle {
@@ -70,6 +73,7 @@ struct nsm_handle {
 	struct sockaddr_in	sm_addr;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
+	char			sm_addrbuf[48];	/* address eyecatcher */
 };
 
 /*

