From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] [FIX] exportfs dput() problems.
Date: Tue, 17 Sep 2002 17:01:40 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020917.170140.51696587.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rDQf-0002hp-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 01:09:54 -0700
Received: from localhost (gw1.valinux.co.jp [202.221.173.98])
	by sv1.valinux.co.jp (Postfix) with ESMTP id 2AA8470020
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 17:09:52 +0900 (JST)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hello,

There are bugs in fs/exportfs/expfs.c to be fixed.

1) dput() might be called twice against the same dentry as local
   variable "toput" in find_exported_dentry() is not cleared when
   dput() is called so that following code may misunderstand that
   it's still alive.

2) Some dentries might not be released in case of ENOENT error.


Thank you,
Hirokazu Takahashi.


--- linux.ORG/fs/exportfs/expfs.c	Mon Sep 16 11:49:15 2030
+++ linux/fs/exportfs/expfs.c	Tue Sep 17 15:54:23 2030
@@ -100,6 +100,7 @@ find_exported_dentry(struct super_block 
 		spin_unlock(&dcache_lock);
 		if (toput)
 			dput(toput);
+		toput = NULL;
 	}			
 
 	/* It's a directory, or we are required to confirm the file's
@@ -183,12 +184,12 @@ find_exported_dentry(struct super_block 
 			err = CALL(nops,get_name)(ppd, nbuf, pd);
 			if (err) {
 				dput(ppd);
+				dput(pd);
 				if (err == -ENOENT)
 					/* some race between get_parent and
 					 * get_name?  just try again
 					 */
 					continue;
-				dput(pd);
 				break;
 			}
 			dprintk("find_exported_dentry: found name: %s\n", nbuf);


-------------------------------------------------------
Sponsored by: AMD - Your access to the experts on Hammer Technology! 
Open Source & Linux Developers, register now for the AMD Developer 
Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
