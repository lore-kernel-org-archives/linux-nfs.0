From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 4 - A couple of possible incorrect calls to dput....
Date: Fri, 11 Oct 2002 10:00:20 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znE4-0007cd-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znEH-0000RA-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:00:33 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:00:24 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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


### Comments for ChangeSet

Thanks to Hirokazu Takahashi <taka@valinux.co.jp>

 ----------- Diffstat output ------------
 ./fs/exportfs/expfs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

--- ./fs/exportfs/expfs.c	2002/10/10 23:07:32	1.1
+++ ./fs/exportfs/expfs.c	2002/10/10 23:07:34	1.2
@@ -183,12 +183,12 @@ find_exported_dentry(struct super_block 
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
@@ -254,6 +254,7 @@ find_exported_dentry(struct super_block 
 		return result;
 	/* one last try of the aliases.. */
 	spin_lock(&dcache_lock);
+	toput = NULL;
 	head = &result->d_inode->i_dentry;
 	list_for_each(le, head) {
 		struct dentry *dentry = list_entry(le, struct dentry, d_alias);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
