From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG] kNFSd may get a freeing inode.
Date: Fri, 20 Sep 2002 00:53:00 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020920.005300.74726524.taka@valinux.co.jp>
References: <15752.7496.463707.865953@notabene.cse.unsw.edu.au>
	<20020918.160913.73658160.taka@valinux.co.jp>
	<15752.22931.241819.210428@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: viro@math.psu.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17s3kB-0005EF-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 09:01:31 -0700
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

Hi,

I was thinking about your code and I've changed my mind that
your aproach isn't bad.

> Brief description of patch:
> 
>  leaf about-to-be-delete inodes in hash table until 
> filesystem has signed off on them, then remove from table and
> wake_up_inode.
>  If a FREEING inode is found on hash table, sleep on
> the inodes wait_queue (which usefully is separate from the inode and
> won't be freed when the inode goes) and then try again.
.....
	
I refined your patch, how do you think about it?
  (This patch is just sample)

--- inode.c.ORG	Wed Sep 18 15:58:03 2030
+++ inode.c	Fri Sep 20 00:48:31 2030
@@ -444,6 +444,20 @@ int shrink_icache_memory(int priority, i
 	return 0;
 }
 
+void __wait_on_freeing_inode(struct inode *inode)
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
  * Called with the inode lock held.
  * NOTE: we are not increasing the inode-refcount, you must call __iget()
@@ -466,6 +480,10 @@ static struct inode * find_inode(struct 
 			continue;
 		if (!test(inode, data))
 			continue;
+		if (inode->i_state & (I_FREEING|I_CLEAR)) {
+			__wait_on_freeing_inode(inode);
+			goto retry;
+		}
 		break;
 	}
 	return inode;
@@ -479,7 +497,7 @@ static struct inode * find_inode_fast(st
 {
 	struct list_head *tmp;
 	struct inode * inode;
-
+retry:
 	tmp = head;
 	for (;;) {
 		tmp = tmp->next;
@@ -491,6 +509,10 @@ static struct inode * find_inode_fast(st
 			continue;
 		if (inode->i_sb != sb)
 			continue;
+		if (inode->i_state & (I_FREEING|I_CLEAR)) {
+			__wait_on_freeing_inode(inode);
+			goto retry;
+		}
 		break;
 	}
 	return inode;
@@ -793,7 +815,6 @@ void generic_delete_inode(struct inode *
 {
 	struct super_operations *op = inode->i_sb->s_op;
 
-	list_del_init(&inode->i_hash);
 	list_del_init(&inode->i_list);
 	inode->i_state|=I_FREEING;
 	inodes_stat.nr_inodes--;
@@ -812,6 +833,10 @@ void generic_delete_inode(struct inode *
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


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
