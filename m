From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 14] knfsd: nfsd: fix misplaced fh_unlock() in
	nfsd_link()
Date: Tue, 27 Jun 2006 17:20:17 +1000
Message-ID: <1060627072017.26685@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7s0-0006Mf-6J
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:24 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rz-0006yg-T5
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:24 -0700
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


From: David M. Richter <richterd@citi.umich.edu>

In the event that lookup_one_len() fails in nfsd_link(), fh_unlock() is
skipped and locks are held overlong.

Patch was tested on 2.6.17-rc2 by causing lookup_one_len() to fail and
verifying that fh_unlock() gets called appropriately.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./fs/nfsd/vfs.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2006-06-27 12:15:21.000000000 +1000
+++ ./fs/nfsd/vfs.c	2006-06-27 14:44:27.000000000 +1000
@@ -1520,14 +1520,15 @@ nfsd_link(struct svc_rqst *rqstp, struct
 			err = nfserrno(err);
 	}
 
-	fh_unlock(ffhp);
 	dput(dnew);
+out_unlock:
+	fh_unlock(ffhp);
 out:
 	return err;
 
 out_nfserr:
 	err = nfserrno(err);
-	goto out;
+	goto out_unlock;
 }
 
 /*

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
