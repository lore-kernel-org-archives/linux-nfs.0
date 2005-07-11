From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 12:50:45 +0200
Message-ID: <20050711105045.GL27163@suse.de>
References: <20050711104611.GK27163@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="O3RTKUHj+75w1tg5"
Cc: Michael Schroeder <mls@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drvs8-0003Pv-BF
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:50:48 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Drvs8-0004oh-6a
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:50:48 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id DCDA9F0AE
	for <nfs@lists.sourceforge.net>; Mon, 11 Jul 2005 12:50:45 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20050711104611.GK27163@suse.de>
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


--O3RTKUHj+75w1tg5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Sorry, I sent an older version of this patch. Here's the one for
2.6.12.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--O3RTKUHj+75w1tg5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfs-rename-zap-inode

Index: test12/fs/nfs/dir.c
===================================================================
--- test12.orig/fs/nfs/dir.c	2005-07-08 11:45:18.000000000 +0200
+++ test12/fs/nfs/dir.c	2005-07-11 12:49:34.000000000 +0200
@@ -1445,8 +1445,15 @@ go_ahead:
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
@@ -1456,6 +1463,17 @@ go_ahead:
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

--O3RTKUHj+75w1tg5--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
