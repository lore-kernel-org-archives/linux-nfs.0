From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 4 - Make sure dnotify events happen for NFS read and write.
Date: Fri, 21 Nov 2003 14:27:14 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AN1ww-0008T4-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AN1xi-0003hh-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Nov 2003 19:28:02 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AN1xh-0007pS-Kc
	for nfs@lists.sourceforge.net; Thu, 20 Nov 2003 19:28:01 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 21 Nov 2003 14:27:57 +1100
To: Linus Torvalds <torvalds@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

Based on code from  Terje Malmedal <terje.malmedal@usit.uio.no>

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-11-21 14:10:56.000000000 +1100
+++ ./fs/nfsd/vfs.c	2003-11-21 14:11:09.000000000 +1100
@@ -43,6 +43,7 @@
 #endif /* CONFIG_NFSD_V3 */
 #include <linux/nfsd/nfsfh.h>
 #include <linux/quotaops.h>
+#include <linux/dnotify.h>
 
 #include <asm/uaccess.h>
 
@@ -680,6 +681,7 @@ nfsd_read(struct svc_rqst *rqstp, struct
 		nfsdstats.io_read += err;
 		*count = err;
 		err = 0;
+		dnotify_parent(file.f_dentry, DN_ACCESS);
 	} else 
 		err = nfserrno(err);
 out_close:
@@ -745,9 +747,11 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
 	err = vfs_writev(&file, vec, vlen, &offset);
-	if (err >= 0)
-		nfsdstats.io_write += cnt;
 	set_fs(oldfs);
+	if (err >= 0) {
+		nfsdstats.io_write += cnt;
+		dnotify_parent(file.f_dentry, DN_MODIFY);
+	}
 
 	/* clear setuid/setgid flag after write */
 	if (err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID))) {


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
