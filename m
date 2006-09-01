From: NeilBrown <neilb@suse.de>
Subject: [PATCH 018 of 19] knfsd: lockd: fix use of h_nextrebind
Date: Fri, 1 Sep 2006 14:39:43 +1000
Message-ID: <1060901043943.27665@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0oq-0005wX-BI
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:52 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0op-0001YU-ID
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:53 -0700
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

  nlmclnt_recovery would try to force a portmap rebind by setting
  host->h_nextrebind to 0. The right thing to do here is to set it
  to the current time.

Signed-off-by: okir@suse.de
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/clntlock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/lockd/clntlock.c ./fs/lockd/clntlock.c
--- .prev/fs/lockd/clntlock.c	2006-08-31 17:02:23.000000000 +1000
+++ ./fs/lockd/clntlock.c	2006-09-01 12:19:55.000000000 +1000
@@ -184,7 +184,7 @@ restart:
 	/* Force a portmap getport - the peer's lockd will
 	 * most likely end up on a different port.
 	 */
-	host->h_nextrebind = 0;
+	host->h_nextrebind = jiffies;
 	nlm_rebind_host(host);
 
 	/* First, reclaim all locks that have been granted. */

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
