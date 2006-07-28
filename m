From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 4] knfsd: Correctly handle error condition from
	lockd_up
Date: Fri, 28 Jul 2006 15:10:03 +1000
Message-ID: <1060728051003.570@suse.de>
References: <20060728150606.29533.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6Kcc-0003tP-Hv
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:50 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6Kcb-0000FV-Q7
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:50 -0700
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


If lockd_up fails - what should we expect?  Do we have to later call lockd_down?

Well the nfs client thinks "no", the nfs server thinks "yes".
lockd thinks "yes".

The only answer that really makes sense is "no" !!

So:
  Make lockd_up only increment  nlmsvc_users on success.
  Make nfsd handle errors from lockd_up properly.
  Make sure lockd_up(0) never fails when lockd is running
    so that the 'reclaimer' call to lockd_up doesn't need to
    be error checked.

Cc: "J. Bruce Fields" <bfields@fieldses.org>

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/clntlock.c |    2 +-
 ./fs/lockd/svc.c      |   12 +++++-------
 ./fs/nfsd/nfssvc.c    |   16 ++++++++++------
 3 files changed, 16 insertions(+), 14 deletions(-)

diff .prev/fs/lockd/clntlock.c ./fs/lockd/clntlock.c
--- .prev/fs/lockd/clntlock.c	2006-07-28 14:53:28.000000000 +1000
+++ ./fs/lockd/clntlock.c	2006-07-28 15:01:38.000000000 +1000
@@ -202,7 +202,7 @@ reclaimer(void *ptr)
 	/* This one ensures that our parent doesn't terminate while the
 	 * reclaim is in progress */
 	lock_kernel();
-	lockd_up(0);
+	lockd_up(0); /* note: this cannot fail as lockd is already running */
 
 	nlmclnt_prepare_reclaim(host);
 	/* First, reclaim all locks that have been marked. */

diff .prev/fs/lockd/svc.c ./fs/lockd/svc.c
--- .prev/fs/lockd/svc.c	2006-07-28 15:01:30.000000000 +1000
+++ ./fs/lockd/svc.c	2006-07-28 15:01:38.000000000 +1000
@@ -254,15 +254,11 @@ lockd_up(int proto) /* Maybe add a 'fami
 
 	mutex_lock(&nlmsvc_mutex);
 	/*
-	 * Unconditionally increment the user count ... this is
-	 * the number of clients who _want_ a lockd process.
-	 */
-	nlmsvc_users++; 
-	/*
 	 * Check whether we're already up and running.
 	 */
 	if (nlmsvc_pid) {
-		error = make_socks(nlmsvc_serv, proto);
+		if (proto)
+			error = make_socks(nlmsvc_serv, proto);
 		goto out;
 	}
 
@@ -270,7 +266,7 @@ lockd_up(int proto) /* Maybe add a 'fami
 	 * Sanity check: if there's no pid,
 	 * we should be the first user ...
 	 */
-	if (nlmsvc_users > 1)
+	if (nlmsvc_users)
 		printk(KERN_WARNING
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
@@ -302,6 +298,8 @@ lockd_up(int proto) /* Maybe add a 'fami
 destroy_and_out:
 	svc_destroy(serv);
 out:
+	if (!error)
+		nlmsvc_users++;
 	mutex_unlock(&nlmsvc_mutex);
 	return error;
 }

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-07-28 14:53:28.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-07-28 15:01:38.000000000 +1000
@@ -221,18 +221,22 @@ static int nfsd_init_socks(int port)
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
-	if (error < 0)
-		return error;
 	error = lockd_up(IPPROTO_UDP);
+	if (error >= 0) {
+		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
+		if (error < 0)
+			lockd_down();
+	}
 	if (error < 0)
 		return error;
 
 #ifdef CONFIG_NFSD_TCP
-	error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
-	if (error < 0)
-		return error;
 	error = lockd_up(IPPROTO_TCP);
+	if (error >= 0) {
+		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
+		if (error < 0)
+			lockd_down();
+	}
 	if (error < 0)
 		return error;
 #endif

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
