From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG] kNFSd may get a freeing inode.
Date: Wed, 18 Sep 2002 21:30:58 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020918.213058.45151863.taka@valinux.co.jp>
References: <15752.7496.463707.865953@notabene.cse.unsw.edu.au>
	<20020918.160913.73658160.taka@valinux.co.jp>
	<15752.22931.241819.210428@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: viro@math.psu.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17re6y-0006Lz-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 05:39:21 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15752.22931.241819.210428@notabene.cse.unsw.edu.au>
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

> So how about if find_inode{,_fast} checks the inode that it finds
> and, if it is FREEING, it drops the spinlock and waits on some
> waitqueue.  destroy_inode calls wake_up on that waitqueue.
> When find_inode is then woken up, it tries the lookup again.

Mmmmm... I can see what you would like to do, but it looks
little bit complex to me.

How do you think of my idea? 

1. If find_inode() finds a valid inode, iget() will return it.

2. If find_inode() finds nothing, iget() will call get_new_inode()
   to make a new inode.

3. If find_inode() finds a I_FREEING inode, iget() will return NULL.
   I guess this case will only happen on NFS. So kNFSd has to accept
   NULL inode.

4. If find_inode() finds both of a I_FREEING inode and a valid inode,
   iget() will return the valid inode.


neilb> --- ./fs/fs-writeback.c	2002/09/18 10:37:04	1.1
neilb> +++ ./fs/fs-writeback.c	2002/09/18 10:37:47
neilb> @@ -87,7 +87,8 @@ void __mark_inode_dirty(struct inode *in
neilb>  		 * Only add valid (hashed) inode to the superblock's
neilb>  		 * dirty list.  Add blockdev inodes as well.
neilb>  		 */
neilb> -		if (list_empty(&inode->i_hash) && !S_ISBLK(inode->i_mode))
neilb> +		if ((list_empty(&inode->i_hash) || (inode->i_state & I_FREEING))
neilb> +		    && !S_ISBLK(inode->i_mode))
neilb>  			goto out;
neilb>  
neilb>  		/*

I think it should be like this:

if ((list_empty(&inode->i_hash) || (inode->i_state & (I_FREEING|I_CLEAN)))
                                                               ^^^^^^^^^^

Following patch is just a sample which may not work.
And find_inode() and iget5_locked also should be fixed.


--- inode.c.ORG	Wed Sep 18 15:58:03 2030
+++ inode.c	Wed Sep 18 21:10:41 2030
@@ -479,18 +479,24 @@ static struct inode * find_inode_fast(st
 {
 	struct list_head *tmp;
 	struct inode * inode;
+	struct inode * freeing_inode = NULL;
 
 	tmp = head;
 	for (;;) {
 		tmp = tmp->next;
-		inode = NULL;
-		if (tmp == head)
+		if (tmp == head) {
+			inode = freeing_inode;
 			break;
+		}
 		inode = list_entry(tmp, struct inode, i_hash);
 		if (inode->i_ino != ino)
 			continue;
 		if (inode->i_sb != sb)
 			continue;
+		if (inode->i_state & (I_FREEING|I_CLEAR)) {
+			freeing_inode = inode;
+			continue;
+		}
 		break;
 	}
 	return inode;
@@ -604,6 +610,11 @@ static struct inode * get_new_inode_fast
 		spin_lock(&inode_lock);
 		/* We released the lock, so.. */
 		old = find_inode_fast(sb, head, ino);
+		if (old && old->i_state & (I_FREEING|I_CLEAR)) {
+			spin_unlock(&inode_lock);
+			destroy_inode(inode);
+			return NULL;
+		}
 		if (!old) {
 			inode->i_ino = ino;
 			inodes_stat.nr_inodes++;
@@ -737,6 +748,10 @@ struct inode *iget_locked(struct super_b
 	spin_lock(&inode_lock);
 	inode = find_inode_fast(sb, head, ino);
 	if (inode) {
+		if (inode->i_state & (I_FREEING|I_CLEAR)) {
+			spin_unlock(&inode_lock);
+			return NULL;
+		}
 		__iget(inode);
 		spin_unlock(&inode_lock);
 		wait_on_inode(inode);
@@ -793,7 +808,6 @@ void generic_delete_inode(struct inode *
 {
 	struct super_operations *op = inode->i_sb->s_op;
 
-	list_del_init(&inode->i_hash);
 	list_del_init(&inode->i_list);
 	inode->i_state|=I_FREEING;
 	inodes_stat.nr_inodes--;
@@ -812,6 +826,7 @@ void generic_delete_inode(struct inode *
 		delete(inode);
 	} else
 		clear_inode(inode);
+	list_del_init(&inode->i_hash);
 	if (inode->i_state != I_CLEAR)
 		BUG();
 	destroy_inode(inode);



-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
