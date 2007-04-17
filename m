From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 2] knfsd: Use a spinlock to protect
	sk_info_authunix
Date: Tue, 17 Apr 2007 12:01:41 +1000
Message-ID: <1070417020141.28483@suse.de>
References: <20070417115242.28047.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: stable@kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Greg Banks <gnb@melbourne.sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdd14-0006nK-Gk
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 19:01:58 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hdd16-00027R-9R
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 19:02:01 -0700
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


sk_info_authunix is not being protected properly so the object that
it points to can be cache_put twice, leading to corruption.

We borrow svsk->sk_defer_lock to provide the protection.  We should probably
rename that lock to have a more generic name - later.

Thanks to Gabriel for reporting this.

Cc: Greg Banks <gnb@melbourne.sgi.com>
Cc: Gabriel Barazer <gabriel@oxeva.fr>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff .prev/net/sunrpc/svcauth_unix.c ./net/sunrpc/svcauth_unix.c
--- .prev/net/sunrpc/svcauth_unix.c	2007-04-17 11:42:14.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2007-04-17 11:42:21.000000000 +1000
@@ -383,7 +383,10 @@ void svcauth_unix_purge(void)
 static inline struct ip_map *
 ip_map_cached_get(struct svc_rqst *rqstp)
 {
-	struct ip_map *ipm = rqstp->rq_sock->sk_info_authunix;
+	struct ip_map *ipm;
+	struct svc_sock *svsk = rqstp->rq_sock;
+	spin_lock_bh(&svsk->sk_defer_lock);
+	ipm = svsk->sk_info_authunix;
 	if (ipm != NULL) {
 		if (!cache_valid(&ipm->h)) {
 			/*
@@ -391,12 +394,14 @@ ip_map_cached_get(struct svc_rqst *rqstp
 			 * remembered, e.g. by a second mount from the
 			 * same IP address.
 			 */
-			rqstp->rq_sock->sk_info_authunix = NULL;
+			svsk->sk_info_authunix = NULL;
+			spin_unlock_bh(&svsk->sk_defer_lock);
 			cache_put(&ipm->h, &ip_map_cache);
 			return NULL;
 		}
 		cache_get(&ipm->h);
 	}
+	spin_unlock_bh(&svsk->sk_defer_lock);
 	return ipm;
 }
 
@@ -405,9 +410,15 @@ ip_map_cached_put(struct svc_rqst *rqstp
 {
 	struct svc_sock *svsk = rqstp->rq_sock;
 
-	if (svsk->sk_sock->type == SOCK_STREAM && svsk->sk_info_authunix == NULL)
-		svsk->sk_info_authunix = ipm;	/* newly cached, keep the reference */
-	else
+	spin_lock_bh(&svsk->sk_defer_lock);
+	if (svsk->sk_sock->type == SOCK_STREAM &&
+	    svsk->sk_info_authunix == NULL) {
+		/* newly cached, keep the reference */
+		svsk->sk_info_authunix = ipm;
+		ipm = NULL;
+	}
+	spin_unlock_bh(&svsk->sk_defer_lock);
+	if (ipm)
 		cache_put(&ipm->h, &ip_map_cache);
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
