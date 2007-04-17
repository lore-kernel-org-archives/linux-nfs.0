From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 2] knfsd: Rename sk_defer_lock to sk_lock
Date: Tue, 17 Apr 2007 12:01:48 +1000
Message-ID: <1070417020148.28498@suse.de>
References: <20070417115242.28047.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdd1A-0006rV-HO
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 19:02:04 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hdd1C-0002Cs-9i
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 19:02:07 -0700
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


Now that sk_defer_lock protects two different things, make the
name more generic.

Also don't bother with disabling _bh as the lock is only
ever taken from process context.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svcsock.h |    3 ++-
 ./net/sunrpc/svcauth_unix.c      |   10 +++++-----
 ./net/sunrpc/svcsock.c           |   13 +++++++------
 3 files changed, 14 insertions(+), 12 deletions(-)

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2007-04-17 11:42:13.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2007-04-17 11:42:26.000000000 +1000
@@ -37,7 +37,8 @@ struct svc_sock {
 
 	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
-	spinlock_t		sk_defer_lock;	/* protects sk_deferred */
+	spinlock_t		sk_lock;	/* protects sk_deferred and
+						 * sk_info_authunix */
 	struct list_head	sk_deferred;	/* deferred requests that need to
 						 * be revisted */
 	struct mutex		sk_mutex;	/* to serialize sending data */

diff .prev/net/sunrpc/svcauth_unix.c ./net/sunrpc/svcauth_unix.c
--- .prev/net/sunrpc/svcauth_unix.c	2007-04-17 11:42:21.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2007-04-17 11:42:26.000000000 +1000
@@ -385,7 +385,7 @@ ip_map_cached_get(struct svc_rqst *rqstp
 {
 	struct ip_map *ipm;
 	struct svc_sock *svsk = rqstp->rq_sock;
-	spin_lock_bh(&svsk->sk_defer_lock);
+	spin_lock(&svsk->sk_lock);
 	ipm = svsk->sk_info_authunix;
 	if (ipm != NULL) {
 		if (!cache_valid(&ipm->h)) {
@@ -395,13 +395,13 @@ ip_map_cached_get(struct svc_rqst *rqstp
 			 * same IP address.
 			 */
 			svsk->sk_info_authunix = NULL;
-			spin_unlock_bh(&svsk->sk_defer_lock);
+			spin_unlock(&svsk->sk_lock);
 			cache_put(&ipm->h, &ip_map_cache);
 			return NULL;
 		}
 		cache_get(&ipm->h);
 	}
-	spin_unlock_bh(&svsk->sk_defer_lock);
+	spin_unlock(&svsk->sk_lock);
 	return ipm;
 }
 
@@ -410,14 +410,14 @@ ip_map_cached_put(struct svc_rqst *rqstp
 {
 	struct svc_sock *svsk = rqstp->rq_sock;
 
-	spin_lock_bh(&svsk->sk_defer_lock);
+	spin_lock(&svsk->sk_lock);
 	if (svsk->sk_sock->type == SOCK_STREAM &&
 	    svsk->sk_info_authunix == NULL) {
 		/* newly cached, keep the reference */
 		svsk->sk_info_authunix = ipm;
 		ipm = NULL;
 	}
-	spin_unlock_bh(&svsk->sk_defer_lock);
+	spin_unlock(&svsk->sk_lock);
 	if (ipm)
 		cache_put(&ipm->h, &ip_map_cache);
 }

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-04-17 11:42:13.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2007-04-17 11:42:26.000000000 +1000
@@ -53,7 +53,8 @@
  * 	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
  *	when both need to be taken (rare), svc_serv->sv_lock is first.
  *	BKL protects svc_serv->sv_nrthread.
- *	svc_sock->sk_defer_lock protects the svc_sock->sk_deferred list
+ *	svc_sock->sk_lock protects the svc_sock->sk_deferred list
+ *             and the ->sk_info_authunix cache.
  *	svc_sock->sk_flags.SK_BUSY prevents a svc_sock being enqueued multiply.
  *
  *	Some flags can be set to certain values at any time
@@ -1625,7 +1626,7 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_server = serv;
 	atomic_set(&svsk->sk_inuse, 1);
 	svsk->sk_lastrecv = get_seconds();
-	spin_lock_init(&svsk->sk_defer_lock);
+	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	INIT_LIST_HEAD(&svsk->sk_ready);
 	mutex_init(&svsk->sk_mutex);
@@ -1849,9 +1850,9 @@ static void svc_revisit(struct cache_def
 	dprintk("revisit queued\n");
 	svsk = dr->svsk;
 	dr->svsk = NULL;
-	spin_lock_bh(&svsk->sk_defer_lock);
+	spin_lock(&svsk->sk_lock);
 	list_add(&dr->handle.recent, &svsk->sk_deferred);
-	spin_unlock_bh(&svsk->sk_defer_lock);
+	spin_unlock(&svsk->sk_lock);
 	set_bit(SK_DEFERRED, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
 	svc_sock_put(svsk);
@@ -1917,7 +1918,7 @@ static struct svc_deferred_req *svc_defe
 
 	if (!test_bit(SK_DEFERRED, &svsk->sk_flags))
 		return NULL;
-	spin_lock_bh(&svsk->sk_defer_lock);
+	spin_lock(&svsk->sk_lock);
 	clear_bit(SK_DEFERRED, &svsk->sk_flags);
 	if (!list_empty(&svsk->sk_deferred)) {
 		dr = list_entry(svsk->sk_deferred.next,
@@ -1926,6 +1927,6 @@ static struct svc_deferred_req *svc_defe
 		list_del_init(&dr->handle.recent);
 		set_bit(SK_DEFERRED, &svsk->sk_flags);
 	}
-	spin_unlock_bh(&svsk->sk_defer_lock);
+	spin_unlock(&svsk->sk_lock);
 	return dr;
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
