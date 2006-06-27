From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 14] knfsd: Improve the test for
	cross-device-rename in nfsd
Date: Tue, 27 Jun 2006 17:19:39 +1000
Message-ID: <1060627071939.26600@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Al Viro <viro@ftp.linux.org.uk>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rV-0006Ed-LY
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:53 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rU-00078G-CH
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:53 -0700
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


Just testing the i_sb isn't really enough, at least
the vfsmnt must be the same.  Thanks Al.

Cc: Al Viro <viro@ftp.linux.org.uk>

### Diffstat output
 ./fs/nfsd/vfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2006-06-27 12:15:18.000000000 +1000
+++ ./fs/nfsd/vfs.c	2006-06-27 12:15:21.000000000 +1000
@@ -1556,7 +1556,7 @@ nfsd_rename(struct svc_rqst *rqstp, stru
 	tdir = tdentry->d_inode;
 
 	err = (rqstp->rq_vers == 2) ? nfserr_acces : nfserr_xdev;
-	if (fdir->i_sb != tdir->i_sb)
+	if (ffhp->fh_export != tfhp->fh_export)
 		goto out;
 
 	err = nfserr_perm;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
