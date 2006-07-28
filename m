From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 4] knfsd: Check return value of lockd_up in
	write_ports
Date: Fri, 28 Jul 2006 15:09:51 +1000
Message-ID: <1060728050951.453@suse.de>
References: <20060728150606.29533.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6Kcb-0003t6-M2
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:49 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6KcU-0000DI-Bt
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:44 -0700
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


We should be checking the return value of lockd_up when
adding a new socket to nfsd.
So move the lockd_up before the svc_addsock and check
the return value.
The move is because lockd_down is easy, but there is no easy
way to remove a recently added socket.

Cc: "J. Bruce Fields" <bfields@fieldses.org>

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-07-28 11:34:33.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-07-28 12:07:35.000000000 +1000
@@ -454,12 +454,15 @@ static ssize_t write_ports(struct file *
 		err = nfsd_create_serv();
 		if (!err) {
 			int proto = 0;
-			err = svc_addsock(nfsd_serv, fd, buf, &proto);
+			err = lockd_up(proto);
+			if (!err) {
+				err = svc_addsock(nfsd_serv, fd, buf, &proto);
+				if (err)
+					lockd_down();
+			}
 			/* Decrease the count, but don't shutdown the
 			 * the service
 			 */
-			if (err >= 0)
-				lockd_up(proto);
 			nfsd_serv->sv_nrthreads--;
 		}
 		return err;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
