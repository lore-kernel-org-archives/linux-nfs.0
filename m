From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [BUG] kNFSd may get a freeing inode.
Date: Wed, 18 Sep 2002 20:46:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15752.22931.241819.210428@notabene.cse.unsw.edu.au>
References: <20020917.170156.35804958.taka@valinux.co.jp>
	<15752.7496.463707.865953@notabene.cse.unsw.edu.au>
	<20020918.160913.73658160.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@math.psu.edu,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rcMI-0006AW-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 03:47:02 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <viro@math.psu.edu>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 18 Sep 2002 20:46:50 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Wednesday September 18
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

On Wednesday September 18, taka@valinux.co.jp wrote:
> > 
> > Al,  can you see any problem with this patch which should, I think,
> > close the race?
> 
> There would be some problems.
> 
> 1) knfsd can get a freeing inode which will be destroyed soon,
>    so that knfsd may access unknown memory.
>    find_inode() should be fixed to not get a freeing inode

I thought of that too.... after I posted :-(

find_inode is always called immediately after inode_lock
is claimed (except for iunique).  So it would be ok for find_inode
to drop the spinlock, wait, and try again.  The logic works for
iunique too - there is no harm in find_inode_fast dropping and
reclaiming inode_lock.

So how about if find_inode{,_fast} checks the inode that it finds
and, if it is FREEING, it drops the spinlock and waits on some
waitqueue.  destroy_inode calls wake_up on that waitqueue.
When find_inode is then woken up, it tries the lookup again.

The patch below (uncompiled) should do something like that.
> 
> 2) Just after calling op->delete_inode(inode) or clear_inode(inode),
>    others can create a new inode which have the same inode-number
>    even if old one is still on the hash.

That's true.. but with the above approach, the attempt to
create the new inode should block until the delete_inode has
completed. 

> 
> 3) Some code assumes inodes on the hash are valid.
>    I found __mark_inode_dirty() assumes this and may move freeing
>    inodes on the dirty-inode-list.
>    __mark_inode_dirty() should check i_state flag instead of i_hash.
> 
> Any others?

Thanks. That patch makes that change.  If search the tree for
i_hash and the only other references are in fs/inode.c and they
all seem safe to me.

NeilBrown

Brief description of patch:

 leaf about-to-be-delete inodes in hash table until 
filesystem has signed off on them, then remove from table and
wake_up_inode.
 If a FREEING inode is found on hash table, sleep on
the inodes wait_queue (which usefully is separate from the inode and
won't be freed when the inode goes) and then try again.

This is against 2.5.35.

--- ./fs/inode.c	2002/09/18 06:16:13	1.1
+++ ./fs/inode.c	2002/09/18 10:43:21
@@ -454,6 +454,9 @@ static struct inode * find_inode(struct 
 {
 	struct list_head *tmp;
 	struct inode * inode;
+	wait_queue_t wt;
+	wait_queue_head_t *wq;
+	wt.task = NULL;
 
 	tmp = head;
 	for (;;) {
@@ -466,7 +469,23 @@ static struct inode * find_inode(struct 
 			continue;
 		if (!test(inode, data))
 			continue;
-		break;
+		if (!(inode->i_state & I_FREEING))
+			break;
+		spin_unlock(&inode_lock);
+		if (!wq.task) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			init_waitqueue_entry(&wt, current);
+			wq= i_waitq_head(inode);
+			add_wait_queue(wq, &wt);
+		} else {
+			schedule();
+			set_current_state(TASK_INTERRUPTIBLE);
+		}
+		spin_lock(&inode_lock);
+	}
+	if (wt.task) {
+		current->state = TASK_RUNNING;
+		remove_wait_queue(wq, &wt);
 	}
 	return inode;
 }
@@ -479,6 +498,9 @@ static struct inode * find_inode_fast(st
 {
 	struct list_head *tmp;
 	struct inode * inode;
+	wait_queue_t wt;
+	wait_queue_head_t *wq;
+	wt.task = NULL;
 
 	tmp = head;
 	for (;;) {
@@ -491,7 +513,23 @@ static struct inode * find_inode_fast(st
 			continue;
 		if (inode->i_sb != sb)
 			continue;
-		break;
+		if (!(inode->i_state & I_FREEING))
+			break;
+		spin_unlock(&inode_lock);
+		if (!wq.task) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			init_waitqueue_entry(&wt, current);
+			wq= i_waitq_head(inode);
+			add_wait_queue(wq, &wt);
+		} else {
+			schedule();
+			set_current_state(TASK_INTERRUPTIBLE);
+		}
+		spin_lock(&inode_lock);
+	}
+	if (wt.task) {
+		current->state = TASK_RUNNING;
+		remove_wait_queue(wq, &wt);
 	}
 	return inode;
 }
@@ -793,7 +831,6 @@ void generic_delete_inode(struct inode *
 {
 	struct super_operations *op = inode->i_sb->s_op;
 
-	list_del_init(&inode->i_hash);
 	list_del_init(&inode->i_list);
 	inode->i_state|=I_FREEING;
 	inodes_stat.nr_inodes--;
@@ -812,6 +849,11 @@ void generic_delete_inode(struct inode *
 		delete(inode);
 	} else
 		clear_inode(inode);
+	spin_lock(&inode_lock);
+	list_del_init(&inode->i_hash);
+	spin_unlock(&inode_lock);
+	wake_up_inode(inode);
+
 	if (inode->i_state != I_CLEAR)
 		BUG();
 	destroy_inode(inode);
--- ./fs/fs-writeback.c	2002/09/18 10:37:04	1.1
+++ ./fs/fs-writeback.c	2002/09/18 10:37:47
@@ -87,7 +87,8 @@ void __mark_inode_dirty(struct inode *in
 		 * Only add valid (hashed) inode to the superblock's
 		 * dirty list.  Add blockdev inodes as well.
 		 */
-		if (list_empty(&inode->i_hash) && !S_ISBLK(inode->i_mode))
+		if ((list_empty(&inode->i_hash) || (inode->i_state & I_FREEING))
+		    && !S_ISBLK(inode->i_mode))
 			goto out;
 
 		/*


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
