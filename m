From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 4] fix setattr-on-symlink error return
Date: Fri, 14 Oct 2005 12:23:07 +1000
Message-ID: <1051014022307.11542@cse.unsw.edu.au>
References: <20051014122041.11376.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQFE5-0006RZ-8B
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:17 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EQFE1-0004YK-Mn
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:16 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



This is a somewhat cosmetic fix to keep the SpecFS validation test
from complaining.
SpecFS want's to try chmod on symlinks, and ext3 and reiser (at least)
return ENOTSUPP.
Probably both sides are being silly, but it is easiest to simply make
it a non-issue and filter out chmod requests on symlinks at the nfsd level.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./fs/nfsd/vfs.c	2005-10-14 12:02:07.000000000 +1000
@@ -254,12 +254,19 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 
 	/* Get inode */
 	err = fh_verify(rqstp, fhp, ftype, accmode);
-	if (err || !iap->ia_valid)
+	if (err)
 		goto out;
 
 	dentry = fhp->fh_dentry;
 	inode = dentry->d_inode;
 
+	/* Ignore any mode updates on symlinks */
+	if (S_ISLNK(inode->i_mode))
+		iap->ia_valid &= ~ATTR_MODE;
+
+	if (!iap->ia_valid)
+		goto out;
+
 	/* NFSv2 does not differentiate between "set-[ac]time-to-now"
 	 * which only requires access, and "set-[ac]time-to-X" which
 	 * requires ownership.


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
