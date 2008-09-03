From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] lockd: Use sockaddr_storage for h_saddr field
Date: Wed, 03 Sep 2008 14:35:46 -0400
Message-ID: <20080903183546.16867.90601.stgit@ingres.1015granger.net>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56699 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbYICSg1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 14:36:27 -0400
In-Reply-To: <20080903183411.16867.33715.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To store larger addresses in the nlm_host structure, make h_saddr a
sockaddr_storage.  And let's call it something more self-explanatory:
"saddr" could easily be mistaken for "server address".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   12 ++++++------
 fs/lockd/svcsubs.c          |    2 +-
 include/linux/lockd/lockd.h |   14 ++++++++++++--
 3 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 8c7022e..3ce2702 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -129,7 +129,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 			continue;
 		if (host->h_server != server)
 			continue;
-		if (!nlm_cmp_addr(&host->h_saddr, ssin))
+		if (!nlm_cmp_addr(nlm_srcaddr_in(host), ssin))
 			continue;
 
 		/* Move to head of hash chain. */
@@ -168,7 +168,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	memcpy(nlm_addr(host), sin, sizeof(*sin));
 	host->h_addrlen = sizeof(*sin);
 	nlm_clear_port(nlm_addr(host));
-	host->h_saddr	   = *ssin;
+	memcpy(nlm_srcaddr(host), ssin, sizeof(*ssin));
 	host->h_version    = version;
 	host->h_proto      = proto;
 	host->h_rpcclnt    = NULL;
@@ -192,8 +192,8 @@ static struct nlm_host *nlm_lookup_host(int server,
 
 	nlm_display_address((struct sockaddr *)&host->h_addr,
 				host->h_addrbuf, sizeof(host->h_addrbuf));
-	nlm_display_address((struct sockaddr *)&host->h_saddr,
-				host->h_saddrbuf, sizeof(host->h_saddrbuf));
+	nlm_display_address((struct sockaddr *)&host->h_srcaddr,
+				host->h_srcaddrbuf, sizeof(host->h_srcaddrbuf));
 
 	dprintk("lockd: nlm_lookup_host created host %s\n",
 			host->h_name);
@@ -267,7 +267,7 @@ nlm_bind_host(struct nlm_host *host)
 	struct rpc_clnt	*clnt;
 
 	dprintk("lockd: nlm_bind_host %s (%s), my addr=%s\n",
-			host->h_name, host->h_addrbuf, host->h_saddrbuf);
+			host->h_name, host->h_addrbuf, host->h_srcaddrbuf);
 
 	/* Lock host handle */
 	mutex_lock(&host->h_mutex);
@@ -294,7 +294,7 @@ nlm_bind_host(struct nlm_host *host)
 			.protocol	= host->h_proto,
 			.address	= nlm_addr(host),
 			.addrsize	= host->h_addrlen,
-			.saddress	= (struct sockaddr *)&host->h_saddr,
+			.saddress	= nlm_srcaddr(host),
 			.timeout	= &timeparms,
 			.servername	= host->h_name,
 			.program	= &nlm_program,
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 198b4e5..d3d1330 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -418,7 +418,7 @@ EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_sb);
 static int
 nlmsvc_match_ip(void *datap, struct nlm_host *host)
 {
-	return nlm_cmp_addr(&host->h_saddr, datap);
+	return nlm_cmp_addr(nlm_srcaddr_in(host), datap);
 }
 
 /**
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 41d7a8e..964e6c9 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -40,7 +40,7 @@ struct nlm_host {
 	struct hlist_node	h_hash;		/* doubly linked list */
 	struct sockaddr_storage	h_addr;		/* peer address */
 	size_t			h_addrlen;
-	struct sockaddr_in	h_saddr;	/* our address (optional) */
+	struct sockaddr_storage	h_srcaddr;	/* our address (optional) */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char *			h_name;		/* remote hostname */
 	u32			h_version;	/* interface version */
@@ -64,7 +64,7 @@ struct nlm_host {
 	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
 
 	char			h_addrbuf[48],	/* address eyecatchers */
-				h_saddrbuf[48];
+				h_srcaddrbuf[48];
 };
 
 struct nsm_handle {
@@ -90,6 +90,16 @@ static inline struct sockaddr *nlm_addr(const struct nlm_host *host)
 	return (struct sockaddr *)&host->h_addr;
 }
 
+static inline struct sockaddr_in *nlm_srcaddr_in(const struct nlm_host *host)
+{
+	return (struct sockaddr_in *)&host->h_srcaddr;
+}
+
+static inline struct sockaddr *nlm_srcaddr(const struct nlm_host *host)
+{
+	return (struct sockaddr *)&host->h_srcaddr;
+}
+
 /*
  * Map an fl_owner_t into a unique 32-bit "pid"
  */

