From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 11] knfsd: Fixed handling of lockd fail when
	adding nfsd socket.
Date: Thu, 24 Aug 2006 16:36:54 +1000
Message-ID: <1060824063654.4969@suse.de>
References: <20060824162917.3600.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GG8ph-00030r-Tr
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:53 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GG8pi-0007bR-0x
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:54 -0700
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


Arrgg.. 
We cannot 'lockd_up' before 'svc_addsock' as we don't know
the protocol yet....
So switch it around again and save the name of the
created sockets so that it can be closed if lock_up fails.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c     |   12 ++++++------
 ./net/sunrpc/svcsock.c |    3 +++
 2 files changed, 9 insertions(+), 6 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-08-24 16:24:47.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-08-24 16:24:56.000000000 +1000
@@ -523,11 +523,11 @@ static ssize_t write_ports(struct file *
 		err = nfsd_create_serv();
 		if (!err) {
 			int proto = 0;
-			err = lockd_up(proto);
-			if (!err) {
-				err = svc_addsock(nfsd_serv, fd, buf, &proto);
-				if (err)
-					lockd_down();
+			err = svc_addsock(nfsd_serv, fd, buf, &proto);
+			if (err >= 0) {
+				err = lockd_up(proto);
+				if (err < 0)
+					svc_sock_names(buf+strlen(buf)+1, nfsd_serv, buf);
 			}
 			/* Decrease the count, but don't shutdown the
 			 * the service
@@ -536,7 +536,7 @@ static ssize_t write_ports(struct file *
 			nfsd_serv->sv_nrthreads--;
 			unlock_kernel();
 		}
-		return err;
+		return err < 0 ? err : 0;
 	}
 	if (buf[0] == '-') {
 		char *toclose = kstrdup(buf+1, GFP_KERNEL);

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-08-24 16:24:21.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-08-24 16:24:56.000000000 +1000
@@ -492,6 +492,9 @@ svc_sock_names(char *buf, struct svc_ser
 	}
 	spin_unlock(&serv->sv_lock);
 	if (closesk)
+		/* Should unregister with portmap, but you cannot
+		 * unregister just one protocol...
+		 */
 		svc_delete_socket(closesk);
 	else if (toclose)
 		return -ENOENT;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
