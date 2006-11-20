From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] fs/lockd/host.c: make 2 functions static
Date: Mon, 20 Nov 2006 03:24:20 +0100
Message-ID: <20061120022420.GP31879@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GlyqN-0005TL-JB
	for nfs@lists.sourceforge.net; Sun, 19 Nov 2006 18:25:11 -0800
Received: from emailhub.stusta.mhn.de ([141.84.69.5]
	helo=mailout.stusta.mhn.de)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GlyqO-0002bZ-Ca
	for nfs@lists.sourceforge.net; Sun, 19 Nov 2006 18:25:12 -0800
To: neilb@cse.unsw.edu.au, trond.myklebust@fys.uio.no
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patch makes the following needlessly global functions static:
- nlm_lookup_host()
- nsm_find()

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 fs/lockd/host.c             |   53 +++++++++++++++++++-----------------
 include/linux/lockd/lockd.h |    2 -
 2 files changed, 28 insertions(+), 27 deletions(-)

--- linux-2.6.19-rc5-mm2/include/linux/lockd/lockd.h.old	2006-11-20 02:01:44.000000000 +0100
+++ linux-2.6.19-rc5-mm2/include/linux/lockd/lockd.h	2006-11-20 01:55:53.000000000 +0100
@@ -164,14 +164,12 @@
  */
 struct nlm_host * nlmclnt_lookup_host(const struct sockaddr_in *, int, int, const char *, int);
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *, const char *, int);
-struct nlm_host * nlm_lookup_host(int server, const struct sockaddr_in *, int, int, const char *, int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
 extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *, int, u32);
-struct nsm_handle *nsm_find(const struct sockaddr_in *, const char *, int);
 void		  nsm_release(struct nsm_handle *);
 
 
--- linux-2.6.19-rc5-mm2/fs/lockd/host.c.old	2006-11-20 01:56:05.000000000 +0100
+++ linux-2.6.19-rc5-mm2/fs/lockd/host.c	2006-11-20 01:58:26.000000000 +0100
@@ -36,34 +36,14 @@
 static void			nlm_gc_hosts(void);
 static struct nsm_handle *	__nsm_find(const struct sockaddr_in *,
 					const char *, int, int);
-
-/*
- * Find an NLM server handle in the cache. If there is none, create it.
- */
-struct nlm_host *
-nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
-			const char *hostname, int hostname_len)
-{
-	return nlm_lookup_host(0, sin, proto, version,
-			       hostname, hostname_len);
-}
-
-/*
- * Find an NLM client handle in the cache. If there is none, create it.
- */
-struct nlm_host *
-nlmsvc_lookup_host(struct svc_rqst *rqstp,
-			const char *hostname, int hostname_len)
-{
-	return nlm_lookup_host(1, &rqstp->rq_addr,
-			       rqstp->rq_prot, rqstp->rq_vers,
-			       hostname, hostname_len);
-}
+static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
+					 const char *hostname,
+					 int hostname_len);
 
 /*
  * Common host lookup routine for server & client
  */
-struct nlm_host *
+static struct nlm_host *
 nlm_lookup_host(int server, const struct sockaddr_in *sin,
 					int proto, int version,
 					const char *hostname,
@@ -195,6 +175,29 @@
 }
 
 /*
+ * Find an NLM server handle in the cache. If there is none, create it.
+ */
+struct nlm_host *
+nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
+			const char *hostname, int hostname_len)
+{
+	return nlm_lookup_host(0, sin, proto, version,
+			       hostname, hostname_len);
+}
+
+/*
+ * Find an NLM client handle in the cache. If there is none, create it.
+ */
+struct nlm_host *
+nlmsvc_lookup_host(struct svc_rqst *rqstp,
+			const char *hostname, int hostname_len)
+{
+	return nlm_lookup_host(1, &rqstp->rq_addr,
+			       rqstp->rq_prot, rqstp->rq_vers,
+			       hostname, hostname_len);
+}
+
+/*
  * Create the NLM RPC client for an NLM peer
  */
 struct rpc_clnt *
@@ -495,7 +498,7 @@
 	return nsm;
 }
 
-struct nsm_handle *
+static struct nsm_handle *
 nsm_find(const struct sockaddr_in *sin, const char *hostname, int hostname_len)
 {
 	return __nsm_find(sin, hostname, hostname_len, 1);


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
