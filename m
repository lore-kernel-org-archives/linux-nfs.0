From: Greg KH <gregkh@suse.de>
Subject: [patch 01/33] knfsd: Use a spinlock to protect sk_info_authunix
Date: Thu, 26 Apr 2007 09:54:58 -0700
Message-ID: <20070426165458.GB1898@kroah.com>
References: <20070426165111.393445007@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	Gabriel Barazer <gabriel@oxeva.fr>, nfs@lists.sourceforge.net,
	Greg Banks <gnb@melbourne.sgi.com>, Neil Brown <neilb@suse.de>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754862AbXDZQ6J@vger.kernel.org>
In-Reply-To: <20070426165445.GA1898@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: NeilBrown <neilb@suse.de>

sk_info_authunix is not being protected properly so the object that
it points to can be cache_put twice, leading to corruption.

We borrow svsk->sk_defer_lock to provide the protection.  We should probably
rename that lock to have a more generic name - later.

Thanks to Gabriel for reporting this.

Cc: Greg Banks <gnb@melbourne.sgi.com>
Cc: Gabriel Barazer <gabriel@oxeva.fr>
Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/sunrpc/svcauth_unix.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
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
 

-- 
