From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NLM: NLM protocol version numbers are u32
Date: Fri, 14 Mar 2008 14:18:37 -0400
Message-ID: <20080314181837.29948.11430.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:30761 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbYCNSS5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:18:57 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: RPC protocol version numbers are u32.  Make sure we use an
appropriate type for NLM version numbers when calling nlm_lookup_host().

Eliminates a harmless mixed sign comparison in nlm_host_lookup().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   20 +++++++++++---------
 include/linux/lockd/lockd.h |    6 ++++--
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index f1ef49f..f23750d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -42,11 +42,12 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 /*
  * Common host lookup routine for server & client
  */
-static struct nlm_host *
-nlm_lookup_host(int server, const struct sockaddr_in *sin,
-		int proto, int version, const char *hostname,
-		unsigned int hostname_len,
-		const struct sockaddr_in *ssin)
+static struct nlm_host *nlm_lookup_host(int server,
+					const struct sockaddr_in *sin,
+					int proto, u32 version,
+					const char *hostname,
+					unsigned int hostname_len,
+					const struct sockaddr_in *ssin)
 {
 	struct hlist_head *chain;
 	struct hlist_node *pos;
@@ -55,7 +56,7 @@ nlm_lookup_host(int server, const struct sockaddr_in *sin,
 	int		hash;
 
 	dprintk("lockd: nlm_lookup_host("NIPQUAD_FMT"->"NIPQUAD_FMT
-			", p=%d, v=%d, my role=%s, name=%.*s)\n",
+			", p=%d, v=%u, my role=%s, name=%.*s)\n",
 			NIPQUAD(ssin->sin_addr.s_addr),
 			NIPQUAD(sin->sin_addr.s_addr), proto, version,
 			server? "server" : "client",
@@ -175,9 +176,10 @@ nlm_destroy_host(struct nlm_host *host)
 /*
  * Find an NLM server handle in the cache. If there is none, create it.
  */
-struct nlm_host *
-nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
-			const char *hostname, unsigned int hostname_len)
+struct nlm_host *nlmclnt_lookup_host(const struct sockaddr_in *sin,
+				     int proto, u32 version,
+				     const char *hostname,
+				     unsigned int hostname_len)
 {
 	struct sockaddr_in ssin = {0};
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 4babb2a..d155950 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -173,8 +173,10 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
 /*
  * Host cache
  */
-struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr_in *, int, int,
-					const char *, unsigned int);
+struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr_in *sin,
+					int proto, u32 version,
+					const char *hostname,
+					unsigned int hostname_len);
 struct nlm_host  *nlmsvc_lookup_host(struct svc_rqst *, const char *,
 					unsigned int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);

