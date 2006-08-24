From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 11] knfsd: Protect update to sn_nrthreads with
	lock_kernel
Date: Thu, 24 Aug 2006 16:36:50 +1000
Message-ID: <1060824063650.4949@suse.de>
References: <20060824162917.3600.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GG8pd-00030R-Um
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:49 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GG8pd-0002kx-3i
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:50 -0700
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
 ./fs/nfsd/nfsctl.c |    2 ++
 1 file changed, 2 insertions(+)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-08-24 16:24:21.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-08-24 16:24:47.000000000 +1000
@@ -532,7 +532,9 @@ static ssize_t write_ports(struct file *
 			/* Decrease the count, but don't shutdown the
 			 * the service
 			 */
+			lock_kernel();
 			nfsd_serv->sv_nrthreads--;
+			unlock_kernel();
 		}
 		return err;
 	}

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
