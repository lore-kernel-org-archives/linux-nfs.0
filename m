From: Olaf Kirch <okir@suse.de>
Subject: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 12:46:11 +0200
Message-ID: <20050711104611.GK27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Schroeder <mls@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drvni-0003HE-Oe
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:46:14 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drvni-00056e-HW
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:46:15 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id E32481D769
	for <nfs@lists.sourceforge.net>; Mon, 11 Jul 2005 12:46:11 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

With recent kernels, we were seeing frequent corruption of files on NFSv2
immediately after creation, often containing pieces of of frequently
written files such as .viminfo and the like.

The problem turns out to be caused by rename. The applications
encountering this problem were all rewriting files by first creating a
temporary copy, and finally renaming it, replacing the original file.

When doing a rename on a NFSv2 mount on top of an existing file, the
inode of the overwritten file would remain, with all caches intact. If
a new file created subsequently ended up with the same inode number, it
would pick up the stale cache.

The fix is to decrement i_nlink of the overwritten inode, like we
do for unlink, rmdir etc already.

Signed-off-by: okir@suse.de


Index: linux-2.6.11/fs/nfs/dir.c
===================================================================
--- linux-2.6.11.orig/fs/nfs/dir.c
+++ linux-2.6.11/fs/nfs/dir.c
@@ -1429,8 +1429,15 @@ go_ahead:
 		shrink_dcache_parent(old_dentry);
 	}
 
-	if (new_inode)
+	/* d_delete will currently not do a dentry_iput
+	 * because new_dentry->d_count is at least 2 when
+	 * we get here. As a matter of caution
+	 * let's grab a reference to the inode anyway.
+	 */
+	if (new_inode && igrab(new_inode)) {
+		nfs_begin_data_update(new_inode);
 		d_delete(new_dentry);
+	}
 
 	nfs_begin_data_update(old_dir);
 	nfs_begin_data_update(new_dir);
@@ -1440,6 +1447,17 @@ go_ahead:
 	nfs_end_data_update(old_inode);
 	nfs_end_data_update(new_dir);
 	nfs_end_data_update(old_dir);
+
+	if (new_inode) {
+		/* If this was the last reference to the inode make
+		 * sure the VFS zaps it and all associated caches.
+		 */
+		if (error == 0)
+			new_inode->i_nlink--;
+		nfs_end_data_update(new_inode);  
+		iput(new_inode);
+	}
+
 out:
 	if (rehash)
 		d_rehash(rehash);

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
