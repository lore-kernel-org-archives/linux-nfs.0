From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 11] knfsd: Fix a botched comment from the last
	patchset
Date: Thu, 24 Aug 2006 16:36:39 +1000
Message-ID: <1060824063639.4925@suse.de>
References: <20060824162917.3600.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GG8pV-0002z9-Ll
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:41 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GG8pU-0007YF-O8
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:42 -0700
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



Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-08-24 16:23:37.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-08-24 16:23:37.000000000 +1000
@@ -49,7 +49,7 @@
  *	svc_pool->sp_lock protects most of the fields of that pool.
  * 	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
  *	when both need to be taken (rare), svc_serv->sv_lock is first.
- *	BKL protects svc_serv->sv_nrthread, svc_pool->sp_nrthread
+ *	BKL protects svc_serv->sv_nrthread.
  *	svc_sock->sk_defer_lock protects the svc_sock->sk_deferred list
  *	svc_sock->sk_flags.SK_BUSY prevents a svc_sock being enqueued multiply.
  *

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
