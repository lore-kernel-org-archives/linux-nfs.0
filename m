From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [BUG] kNFSd may get a freeing inode.
Date: Wed, 18 Sep 2002 16:29:28 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15752.7496.463707.865953@notabene.cse.unsw.edu.au>
References: <20020917.170156.35804958.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rYLL-00023E-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 23:29:47 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <viro@math.psu.edu>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 18 Sep 2002 16:29:32 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>, Alexander Viro <viro@math.psu.edu>
In-Reply-To: message from Hirokazu Takahashi on Tuesday September 17
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

On Tuesday September 17, taka@valinux.co.jp wrote:
> Hello,
> 
> This is a big problem.
> 
> kNFSd might get inode which is just freeing.
> We know inodes under freeing(I_FREEING) are not on the inode-hash.
....
> What is the best way to avoid this situation?
> We shold keep freeing inodes the hash?

I think you are right.
If knfsd (or a filesystem's ->get_dentry) calls iget just as
iput_final is being called, the iget will fail to find the inode (it
is dropped from the hash before unlocking inode_lock) and so will call
->read_inode, possibly before generic_delete_inode has called
->delete_inode, and so will get an apparently valid inode just before
that inode actually gets destroyed.

The only solution I can see is, as you say, keeping it on the hash
table a bit longer.

Al,  can you see any problem with this patch which should, I think,
close the race?

NeilBrown


--- fs/inode.c.~1.1~	2002-09-18 16:21:51.000000000 +1000
+++ fs/inode.c	2002-09-18 16:16:29.000000000 +1000
@@ -787,37 +787,37 @@
 	spin_lock(&inode_lock);
 	list_del_init(&inode->i_hash);
 	spin_unlock(&inode_lock);
 }
 
 void generic_delete_inode(struct inode *inode)
 {
 	struct super_operations *op = inode->i_sb->s_op;
 
-	list_del_init(&inode->i_hash);
 	list_del_init(&inode->i_list);
 	inode->i_state|=I_FREEING;
 	inodes_stat.nr_inodes--;
 	spin_unlock(&inode_lock);
 
 	if (inode->i_data.nrpages)
 		truncate_inode_pages(&inode->i_data, 0);
 
 	security_ops->inode_delete(inode);
 
 	if (op && op->delete_inode) {
 		void (*delete)(struct inode *) = op->delete_inode;
 		if (!is_bad_inode(inode))
 			DQUOT_INIT(inode);
 		/* s_op->delete_inode internally recalls clear_inode() */
 		delete(inode);
 	} else
 		clear_inode(inode);
+	list_del_init(&inode->i_hash);
 	if (inode->i_state != I_CLEAR)
 		BUG();
 	destroy_inode(inode);
 }
 EXPORT_SYMBOL(generic_delete_inode);
 
 static void generic_forget_inode(struct inode *inode)
 {
 	struct super_block *sb = inode->i_sb;


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
