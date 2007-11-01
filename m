From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] NLM: Fix sign of length of NLM variable length
	strings
Date: Thu, 01 Nov 2007 16:56:53 -0400
Message-ID: <20071101205653.5503.91811.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh7k-0007pC-1Q
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:44 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh7p-00023s-IG
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:49 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

According to The Open Group's NLM specification, NLM callers are variable
length strings.  XDR variable length strings use an unsigned 32 bit length.
And internally, negative string lengths are not meaningful for the Linux
NLM implementation.

Clean up: Make nlm_lock.len and nlm_reboot.len unsigned integers.  This
makes the sign of NLM string lengths consistent with the sign of xdr_netobj
lengths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
