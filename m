From: NeilBrown <neilb@suse.de>
Subject: [PATCH 015 of 19] knfsd: make nlmclnt_next_cookie SMP safe
Date: Fri, 1 Sep 2006 14:39:27 +1000
Message-ID: <1060901043927.27629@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0oZ-0005up-Bv
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:35 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0oZ-0004WE-Gj
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:36 -0700
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


From: Olaf Kirch <okir@suse.de>

  The way we incremented the NLM cookie in nlmclnt_next_cookie
  was not thread safe. This patch changes the counter to an
  atomic_t

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/clntproc.c         |   10 +++++-----
 ./include/linux/lockd/lockd.h |    1 +
 2 files changed, 6 insertions(+), 5 deletions(-)

diff .prev/fs/lockd/clntproc.c ./fs/lockd/clntproc.c
--- .prev/fs/lockd/clntproc.c	2006-09-01 12:11:03.000000000 +1000
+++ ./fs/lockd/clntproc.c	2006-09-01 12:17:03.000000000 +1000
@@ -36,14 +36,14 @@ static const struct rpc_call_ops nlmclnt
 /*
  * Cookie counter for NLM requests
  */
-static u32	nlm_cookie = 0x1234;
+static atomic_t	nlm_cookie = ATOMIC_INIT(0x1234);
 
-static inline void nlmclnt_next_cookie(struct nlm_cookie *c)
+void nlmclnt_next_cookie(struct nlm_cookie *c)
 {
-	memcpy(c->data, &nlm_cookie, 4);
-	memset(c->data+4, 0, 4);
+	u32	cookie = atomic_inc_return(&nlm_cookie);
+
+	memcpy(c->data, &cookie, 4);
 	c->len=4;
-	nlm_cookie++;
 }
 
 static struct nlm_lockowner *nlm_get_lockowner(struct nlm_lockowner *lockowner)

diff .prev/include/linux/lockd/lockd.h ./include/linux/lockd/lockd.h
--- .prev/include/linux/lockd/lockd.h	2006-09-01 12:16:06.000000000 +1000
+++ ./include/linux/lockd/lockd.h	2006-09-01 12:17:03.000000000 +1000
@@ -157,6 +157,7 @@ int		  nlmclnt_block(struct nlm_wait *bl
 u32		  nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *);
 void		  nlmclnt_recovery(struct nlm_host *);
 int		  nlmclnt_reclaim(struct nlm_host *, struct file_lock *);
+void		  nlmclnt_next_cookie(struct nlm_cookie *);
 
 /*
  * Host cache

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
