From: NeilBrown <neilb@suse.de>
Subject: [PATCH 011 of 11] knfsd: knfsd: cache ipmap per TCP socket
Date: Thu, 24 Aug 2006 16:37:27 +1000
Message-ID: <1060824063727.5048@suse.de>
References: <20060824162917.3600.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GG8qF-0003Aa-8n
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:37:27 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GG8qE-0007qw-RG
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:37:27 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Greg Banks <gnb@melbourne.sgi.com>

knfsd: speed up high call-rate workloads by caching the struct ip_map
for the peer on the connected struct svc_sock instead of looking it
up in the ip_map cache hashtable on every call.  This helps workloads
using AUTH_SYS authentication over TCP.

Testing was on a 4 CPU 4 NIC Altix using 4 IRIX clients, each with 16
synthetic client threads simulating an rsync (i.e. recursive directory
listing) workload reading from an i386 RH9 install image (161480
regular files in 10841 directories) on the server.  That tree is small
enough to fill in the server's RAM so no disk traffic was involved.
This setup gives a sustained call rate in excess of 60000 calls/sec
before being CPU-bound on the server.

Profiling showed strcmp(), called from ip_map_match(), was taking 4.8%
of each CPU, and ip_map_lookup() was taking 2.9%.  This patch drops
both contribution into the profile noise.

Note that the above result overstates this value of this patch
for most workloads.  The synthetic clients are all using separate
IP addresses, so there are 64 entries in the ip_map cache hash.
Because the kernel measured contained the bug fixed in commit

commit 1f1e030bf75774b6a283518e1534d598e14147d4

and was running on 64bit little-endian machine, probably all of
those 64 entries were on a single chain, thus increasing the cost
of ip_map_lookup().

With a modern kernel you would need more clients to see the same
amount of performance improvement.  This patch has helped to scale
knfsd to handle a deployment with 2000 NFS clients.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/cache.h   |   11 +++++++++
 ./include/linux/sunrpc/svcauth.h |    1 
 ./include/linux/sunrpc/svcsock.h |    3 ++
 ./net/sunrpc/svcauth_unix.c      |   47 ++++++++++++++++++++++++++++++++++++---
 ./net/sunrpc/svcsock.c           |    2 +
 5 files changed, 61 insertions(+), 3 deletions(-)

diff .prev/include/linux/sunrpc/cache.h ./include/linux/sunrpc/cache.h
--- .prev/include/linux/sunrpc/cache.h	2006-08-24 16:27:18.000000000 +1000
+++ ./include/linux/sunrpc/cache.h	2006-08-24 16:27:18.000000000 +1000
@@ -163,6 +163,17 @@ static inline void cache_put(struct cach
 	kref_put(&h->ref, cd->cache_put);
 }
 
+static inline int cache_valid(struct cache_head *h)
+{
+	/* If an item has been unhashed pending removal when
+	 * the refcount drops to 0, the expiry_time will be
+	 * set to 0.  We don't want to consider such items
+	 * valid in this context even though CACHE_VALID is
+	 * set.
+	 */
+	return (h->expiry_time != 0 && test_bit(CACHE_VALID, &h->flags));
+}
+
 extern int cache_check(struct cache_detail *detail,
 		       struct cache_head *h, struct cache_req *rqstp);
 extern void cache_flush(void);

diff .prev/include/linux/sunrpc/svcauth.h ./include/linux/sunrpc/svcauth.h
--- .prev/include/linux/sunrpc/svcauth.h	2006-08-24 16:27:18.000000000 +1000
+++ ./include/linux/sunrpc/svcauth.h	2006-08-24 16:27:18.000000000 +1000
@@ -126,6 +126,7 @@ extern struct auth_domain *auth_domain_f
 extern struct auth_domain *auth_unix_lookup(struct in_addr addr);
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
+extern void svcauth_unix_info_release(void *);
 
 static inline unsigned long hash_str(char *name, int bits)
 {

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2006-08-24 16:27:18.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2006-08-24 16:27:18.000000000 +1000
@@ -54,6 +54,9 @@ struct svc_sock {
 	int			sk_reclen;	/* length of record */
 	int			sk_tcplen;	/* current read length */
 	time_t			sk_lastrecv;	/* time of last received request */
+
+	/* cache of various info for TCP sockets */
+	void			*sk_info_authunix;
 };
 
 /*

diff .prev/net/sunrpc/svcauth_unix.c ./net/sunrpc/svcauth_unix.c
--- .prev/net/sunrpc/svcauth_unix.c	2006-08-24 16:27:18.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2006-08-24 16:27:18.000000000 +1000
@@ -9,6 +9,7 @@
 #include <linux/seq_file.h>
 #include <linux/hash.h>
 #include <linux/string.h>
+#include <net/sock.h>
 
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
@@ -375,6 +376,44 @@ void svcauth_unix_purge(void)
 	cache_purge(&ip_map_cache);
 }
 
+static inline struct ip_map *
+ip_map_cached_get(struct svc_rqst *rqstp)
+{
+	struct ip_map *ipm = rqstp->rq_sock->sk_info_authunix;
+	if (ipm != NULL) {
+		if (!cache_valid(&ipm->h)) {
+			/*
+			 * The entry has been invalidated since it was
+			 * remembered, e.g. by a second mount from the
+			 * same IP address.
+			 */
+			rqstp->rq_sock->sk_info_authunix = NULL;
+			cache_put(&ipm->h, &ip_map_cache);
+			return NULL;
+		}
+		cache_get(&ipm->h);
+	}
+	return ipm;
+}
+
+static inline void
+ip_map_cached_put(struct svc_rqst *rqstp, struct ip_map *ipm)
+{
+	struct svc_sock *svsk = rqstp->rq_sock;
+
+	if (svsk->sk_sock->type == SOCK_STREAM && svsk->sk_info_authunix == NULL)
+		svsk->sk_info_authunix = ipm;	/* newly cached, keep the reference */
+	else
+		cache_put(&ipm->h, &ip_map_cache);
+}
+
+void
+svcauth_unix_info_release(void *info)
+{
+	struct ip_map *ipm = info;
+	cache_put(&ipm->h, &ip_map_cache);
+}
+
 static int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
@@ -384,8 +423,10 @@ svcauth_unix_set_client(struct svc_rqst 
 	if (rqstp->rq_proc == 0)
 		return SVC_OK;
 
-	ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-			    rqstp->rq_addr.sin_addr);
+	ipm = ip_map_cached_get(rqstp);
+	if (ipm == NULL)
+		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
+				    rqstp->rq_addr.sin_addr);
 
 	if (ipm == NULL)
 		return SVC_DENIED;
@@ -400,7 +441,7 @@ svcauth_unix_set_client(struct svc_rqst 
 		case 0:
 			rqstp->rq_client = &ipm->m_client->h;
 			kref_get(&rqstp->rq_client->ref);
-			cache_put(&ipm->h, &ip_map_cache);
+			ip_map_cached_put(rqstp, ipm);
 			break;
 	}
 	return SVC_OK;

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-08-24 16:25:41.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-08-24 16:27:18.000000000 +1000
@@ -1612,6 +1612,8 @@ svc_delete_socket(struct svc_sock *svsk)
 			sockfd_put(svsk->sk_sock);
 		else
 			sock_release(svsk->sk_sock);
+		if (svsk->sk_info_authunix != NULL)
+			svcauth_unix_info_release(svsk->sk_info_authunix);
 		kfree(svsk);
 	} else {
 		spin_unlock_bh(&serv->sv_lock);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
