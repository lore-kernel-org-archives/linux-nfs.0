From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd in 2.5.14 - Add a kernel_lock in d_splice_alias
Date: Tue, 7 May 2002 14:41:08 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15575.23268.169760.699113@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Viro <viro@math.psu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174wnQ-0004lz-00
	for <nfs@lists.sourceforge.net>; Mon, 06 May 2002 21:41:52 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <viro@math.psu.edu>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Tue, 7 May 2002 14:41:33 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



d_move wants the kernel to be locked, so
d_splice_alias now takes that lock.


 ----------- Diffstat output ------------
 ./fs/dcache.c |    2 ++
 1 files changed, 2 insertions(+)

--- ./fs/dcache.c	2002/05/07 04:30:43	1.1
+++ ./fs/dcache.c	2002/05/07 04:32:21	1.2
@@ -812,6 +812,7 @@
 	struct dentry *new = NULL;
 
 	if (inode && S_ISDIR(inode->i_mode)) {
+		lock_kernel(); /* for d_move */
 		spin_lock(&dcache_lock);
 		if (!list_empty(&inode->i_dentry)) {
 			new = list_entry(inode->i_dentry.next, struct dentry, d_alias);
@@ -827,6 +828,7 @@
 			spin_unlock(&dcache_lock);
 			d_rehash(dentry);
 		}
+		unlock_kernel();
 	} else
 		d_add(dentry, inode);
 	return new;

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
