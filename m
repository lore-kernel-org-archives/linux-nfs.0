From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 9] fix incorrect indentation in fh_verify
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-00042u-3A@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uZ-00007Y-Lp
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:47 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uY-0007MF-VQ
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:47 -0700
To: Andrew Morton <akpm@osdl.org>
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



fix incorrect indentation in fh_verify

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsfh.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-09-03 11:56:47.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2004-09-03 11:56:56.000000000 +1000
@@ -190,10 +190,10 @@ fh_verify(struct svc_rqst *rqstp, struct
 			dentry = dget(exp->ex_dentry);
 		else {
 			struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
-				dentry = CALL(nop,decode_fh)(exp->ex_mnt->mnt_sb,
-							     datap, data_left,
-							     fileid_type,
-							     nfsd_acceptable, exp);
+			dentry = CALL(nop,decode_fh)(exp->ex_mnt->mnt_sb,
+						     datap, data_left,
+						     fileid_type,
+						     nfsd_acceptable, exp);
 		}
 		if (dentry == NULL)
 			goto out;


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
