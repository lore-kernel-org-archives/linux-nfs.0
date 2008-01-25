From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 007/100] NLM: Fix sign of length of NLM variable length strings
Date: Fri, 25 Jan 2008 18:15:47 -0500
Message-ID: <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47314 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762002AbYAYXRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:23 -0500
In-Reply-To: <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

According to The Open Group's NLM specification, NLM callers are variable
length strings.  XDR variable length strings use an unsigned 32 bit length.
And internally, negative string lengths are not meaningful for the Linux
NLM implementation.

Clean up: Make nlm_lock.len and nlm_reboot.len unsigned integers.  This
makes the sign of NLM string lengths consistent with the sign of xdr_netobj
lengths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-By: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c             |   19 +++++++++++--------
 include/linux/lockd/lockd.h |    9 ++++++---
 include/linux/lockd/xdr.h   |    4 ++--
 3 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 572601e..ebec009 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -34,10 +34,10 @@ static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
 static struct nsm_handle *	__nsm_find(const struct sockaddr_in *,
-					const char *, int, int);
+					const char *, unsigned int, int);
 static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 					 const char *hostname,
-					 int hostname_len);
+					 unsigned int hostname_len);
 
 /*
  * Common host lookup routine for server & client
@@ -45,7 +45,8 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 static struct nlm_host *
 nlm_lookup_host(int server, const struct sockaddr_in *sin,
 		int proto, int version, const char *hostname,
-		int hostname_len, const struct sockaddr_in *ssin)
+		unsigned int hostname_len,
+		const struct sockaddr_in *ssin)
 {
 	struct hlist_head *chain;
 	struct hlist_node *pos;
@@ -176,7 +177,7 @@ nlm_destroy_host(struct nlm_host *host)
  */
 struct nlm_host *
 nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
-			const char *hostname, int hostname_len)
+			const char *hostname, unsigned int hostname_len)
 {
 	struct sockaddr_in ssin = {0};
 
@@ -189,7 +190,7 @@ nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
  */
 struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp,
-			const char *hostname, int hostname_len)
+			const char *hostname, unsigned int hostname_len)
 {
 	struct sockaddr_in ssin = {0};
 
@@ -307,7 +308,8 @@ void nlm_release_host(struct nlm_host *host)
  * Release all resources held by that peer.
  */
 void nlm_host_rebooted(const struct sockaddr_in *sin,
-				const char *hostname, int hostname_len,
+				const char *hostname,
+				unsigned int hostname_len,
 				u32 new_state)
 {
 	struct hlist_head *chain;
@@ -449,7 +451,7 @@ static DEFINE_MUTEX(nsm_mutex);
 
 static struct nsm_handle *
 __nsm_find(const struct sockaddr_in *sin,
-		const char *hostname, int hostname_len,
+		const char *hostname, unsigned int hostname_len,
 		int create)
 {
 	struct nsm_handle *nsm = NULL;
@@ -503,7 +505,8 @@ out:
 }
 
 static struct nsm_handle *
-nsm_find(const struct sockaddr_in *sin, const char *hostname, int hostname_len)
+nsm_find(const struct sockaddr_in *sin, const char *hostname,
+	 unsigned int hostname_len)
 {
 	return __nsm_find(sin, hostname, hostname_len, 1);
 }
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index e2d1ce3..4babb2a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -173,14 +173,17 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
 /*
  * Host cache
  */
-struct nlm_host * nlmclnt_lookup_host(const struct sockaddr_in *, int, int, const char *, int);
-struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *, const char *, int);
+struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr_in *, int, int,
+					const char *, unsigned int);
+struct nlm_host  *nlmsvc_lookup_host(struct svc_rqst *, const char *,
+					unsigned int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
-extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *, int, u32);
+extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
+					unsigned int, u32);
 void		  nsm_release(struct nsm_handle *);
 
 
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index 83a1f9f..df18fa0 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -29,7 +29,7 @@ struct svc_rqst;
 /* Lock info passed via NLM */
 struct nlm_lock {
 	char *			caller;
-	int			len; 	/* length of "caller" */
+	unsigned int		len; 	/* length of "caller" */
 	struct nfs_fh		fh;
 	struct xdr_netobj	oh;
 	u32			svid;
@@ -78,7 +78,7 @@ struct nlm_res {
  */
 struct nlm_reboot {
 	char *		mon;
-	int		len;
+	unsigned int	len;
 	u32		state;
 	__be32		addr;
 	__be32		vers;
-- 
1.5.4.rc2.60.gb2e62

