From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 001 of 3] knfsd: Add some missing newlines in printks
Date: Thu, 06 Jul 2006 15:16:07 +1000
Message-ID: <1152162966.18333.361.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyMEa-0007ih-4f
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 22:17:04 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyMEY-0007Fb-5y
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 22:17:04 -0700
To: Neil Brown <neilb@suse.de>
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

knfsd: Add some missing newlines in printks.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/export.c       |    2 +-
 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4proc.c     |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

Index: linus-git/fs/nfsd/export.c
===================================================================
--- linus-git.orig/fs/nfsd/export.c	2006-07-05 15:54:31.471525922 +1000
+++ linus-git/fs/nfsd/export.c	2006-07-06 12:17:25.500087628 +1000
@@ -370,7 +370,7 @@ static int check_export(struct inode *in
 	 */
 	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
 	    !(flags & NFSEXP_FSID)) {
-		dprintk("exp_export: export of non-dev fs without fsid");
+		dprintk("exp_export: export of non-dev fs without fsid\n");
 		return -EINVAL;
 	}
 	if (!inode->i_sb->s_export_op) {
Index: linus-git/fs/nfsd/nfs4callback.c
===================================================================
--- linus-git.orig/fs/nfsd/nfs4callback.c	2006-07-05 15:54:31.474455230 +1000
+++ linus-git/fs/nfsd/nfs4callback.c	2006-07-06 12:17:25.500087628 +1000
@@ -131,7 +131,7 @@ xdr_error:                              
 #define READ_BUF(nbytes)  do { \
 	p = xdr_inline_decode(xdr, nbytes); \
 	if (!p) { \
-		dprintk("NFSD: %s: reply buffer overflowed in line %d.", \
+		dprintk("NFSD: %s: reply buffer overflowed in line %d.\n", \
 			__FUNCTION__, __LINE__); \
 		return -EIO; \
 	} \
Index: linus-git/fs/nfsd/nfs4proc.c
===================================================================
--- linus-git.orig/fs/nfsd/nfs4proc.c	2006-07-05 15:54:31.476408102 +1000
+++ linus-git/fs/nfsd/nfs4proc.c	2006-07-06 12:17:25.501064063 +1000
@@ -600,7 +600,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 			&setattr->sa_stateid, CHECK_FH | WR_STATE, NULL);
 		nfs4_unlock_state();
 		if (status) {
-			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!");
+			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
 		}
 	}


Greg
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
