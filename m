From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG] kNFSd may get a freeing inode.
Date: Fri, 20 Sep 2002 20:05:08 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020920.200508.68137471.taka@valinux.co.jp>
References: <20020918.160913.73658160.taka@valinux.co.jp>
	<15752.22931.241819.210428@notabene.cse.unsw.edu.au>
	<20020920.005300.74726524.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: viro@math.psu.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sLjG-0000ej-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 04:13:47 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <20020920.005300.74726524.taka@valinux.co.jp>
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

I've checked with printk that nfsd will sleep when it find a
freeing inode. It worked good as we expected.

taka> I was thinking about your code and I've changed my mind that
taka> your aproach isn't bad.
taka> 
taka> > Brief description of patch:
taka> > 
taka> >  leaf about-to-be-delete inodes in hash table until 
taka> > filesystem has signed off on them, then remove from table and
taka> > wake_up_inode.
taka> >  If a FREEING inode is found on hash table, sleep on
taka> > the inodes wait_queue (which usefully is separate from the inode and
taka> > won't be freed when the inode goes) and then try again.


--- linux/fs/inode.c.ORG	Wed Sep 18 15:58:03 2030
+++ linux/fs/inode.c	Fri Sep 20 20:00:16 2030
@@ -444,6 +444,8 @@ int shrink_icache_memory(int priority, i
 	return 0;
 }
 
+static void __wait_on_freeing_inode(struct inode *inode);
+
 /*
  * Called with the inode lock held.
  * NOTE: we are not increasing the inode-refcount, you must call __iget()
@@ -454,7 +456,7 @@ static struct inode * find_inode(struct 
 {
 	struct list_head *tmp;
 	struct inode * inode;
-
+retry:
 	tmp = head;
 	for (;;) {
 		tmp = tmp->next;
@@ -466,6 +468,17 @@ static struct inode * find_inode(struct 
 			continue;
 		if (!test(inode, data))
 			continue;
+		/* 
+		 * Keep freeing inodes on the hash or nfsd might try to
+		 * read them from disk and put them on the hash as nfsd
+		 * can call iget() directly at any time.
+		 * If it's a freeing inode, nfsd has to wait until it's
+		 * freed completely and try to search again.
+		 */ 
+		if (inode->i_state & (I_FREEING|I_CLEAR)) {
+			__wait_on_freeing_inode(inode);
+			goto retry;
+		}
 		break;
 	}
 	return inode;
@@ -479,7 +492,7 @@ static struct inode * find_inode_fast(st
 {
 	struct list_head *tmp;
 	struct inode * inode;
-
+retry:
 	tmp = head;
 	for (;;) {
 		tmp = tmp->next;
@@ -491,6 +504,17 @@ static struct inode * find_inode_fast(st
 			continue;
 		if (inode->i_sb != sb)
 			continue;
+		/* 
+		 * Keep freeing inodes on the hash or nfsd might try to
+		 * read them from disk and put them on the hash as nfsd
+		 * can call iget() directly at any time.
+		 * If it's a freeing inode, nfsd has to wait until it's
+		 * freed completely and try to search again.
+		 */ 
+		if (inode->i_state & (I_FREEING|I_CLEAR)) {
+			__wait_on_freeing_inode(inode);
+			goto retry;
+		}
 		break;
 	}
 	return inode;
@@ -793,7 +817,6 @@ void generic_delete_inode(struct inode *
 {
 	struct super_operations *op = inode->i_sb->s_op;
 
-	list_del_init(&inode->i_hash);
 	list_del_init(&inode->i_list);
 	inode->i_state|=I_FREEING;
 	inodes_stat.nr_inodes--;
@@ -812,6 +835,10 @@ void generic_delete_inode(struct inode *
 		delete(inode);
 	} else
 		clear_inode(inode);
+	spin_lock(&inode_lock);
+	list_del_init(&inode->i_hash);
+	spin_unlock(&inode_lock);
+	wake_up_inode(inode);
 	if (inode->i_state != I_CLEAR)
 		BUG();
 	destroy_inode(inode);
@@ -1050,6 +1077,21 @@ void wake_up_inode(struct inode *inode)
 	if (waitqueue_active(wq))
 		wake_up_all(wq);
 }
+
+static void __wait_on_freeing_inode(struct inode *inode)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	wait_queue_head_t *wq = i_waitq_head(inode);
+
+	add_wait_queue(wq, &wait);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	spin_unlock(&inode_lock);
+	schedule();
+	remove_wait_queue(wq, &wait);
+	current->state = TASK_RUNNING;
+	spin_lock(&inode_lock);
+}
+
 
 /*
  * Initialize the waitqueues and inode hash table.
--- linux/fs/fs-writeback.c.ORG	Fri Sep 20 17:49:36 2030
+++ linux/fs/fs-writeback.c	Fri Sep 20 17:53:48 2030
@@ -87,7 +87,7 @@ void __mark_inode_dirty(struct inode *in
 		 * Only add valid (hashed) inode to the superblock's
 		 * dirty list.  Add blockdev inodes as well.
 		 */
-		if (list_empty(&inode->i_hash) && !S_ISBLK(inode->i_mode))
+		if ((list_empty(&inode->i_hash) || inode->i_state & (I_FREEING|I_CLEAR)) && !S_ISBLK(inode->i_mode))
 			goto out;
 
 		/*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
