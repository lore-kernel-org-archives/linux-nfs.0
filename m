From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 11 of 17 - Create files: /proc/net/rpc/$CACHENAME/channel for communicating cache updates with kernel
Date: Fri, 11 Oct 2002 15:27:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKx-0003bj-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLU-0003iF-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:21 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Fri, 11 Oct 2002 15:28:00 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: linux-kernel@vger.kernel.org
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

Normally I don't send nfsd patches to linux-kernel (feeling
that nfs@lists.sourceforge.net is sufficient).
However this set are more interesting so I thought they should get wider 
distribution.  

However linux-kernel will only be seeing 11-17 of 17.  The rest are 
at http://www.cse.unsw.edu.au/~neilb/patches/linux-devel/ and
hopefully will appear in 2.5.X soon....

What I am doing here is changing the export table in knfsd (which
says who is allowed to access which filesystems and with what
options) into a number of caches using a fairly general caching
infrastructure.

The old exports table was considered to be authoritative and
if an entry didn't exist, it was assumed that no access was given.

The new caches allow for a cache-miss to be propagated to user-space,
and for user-space to fill in the missing information.
The mechanism for this communication is the reason that I am
sending these patches to linux-kernel.
It is described briefly in rpc-cache.txt (see below).

This patch provides the core code for handling communication.
Subsequent patches provide more support routines and
actually integrate this code with the various caches that
knfsd is now using.

There is currently no user-space tools for making use of this
interface.  However 'cat' and 'echo' are enough to do some simple
testing.

Current nfs-utils continue to work.  I expect to be extending them
to make use of the new caches sometime this year.

### Comments for ChangeSet

Each cache gets it's own 'channel' at
  /proc/net/rpc/$CACHENAME/channel

Reads from the file will return all pending requests, one at a time.
select will block when at end of file.
writes will pass full lines in to be processed.



 ----------- Diffstat output ------------
 ./Documentation/rpc-cache.txt  |   49 ++++++
 ./include/linux/sunrpc/cache.h |    7 
 ./include/linux/sunrpc/stats.h |    2 
 ./net/sunrpc/cache.c           |  296 +++++++++++++++++++++++++++++++++++++++++
 ./net/sunrpc/stats.c           |    2 
 5 files changed, 355 insertions(+), 1 deletion(-)

--- ./Documentation/rpc-cache.txt	2002/10/11 02:00:12	1.3
+++ ./Documentation/rpc-cache.txt	2002/10/11 02:39:11	1.4
@@ -90,3 +90,52 @@ item does become valid, the deferred cop
 revisited (->revisit).  It is expected that this method will
 reschedule the request for processing.
 
+
+Populating a cache
+------------------
+
+Each cache has a name, and when the cache is registered, a directory
+with that name is created in /proc/net/rpc
+
+This directory contains a file called 'channel' which is a channel
+for communicating between kernel and user for populating the cache.
+This directory may later contain other files of interacting
+with the cache.
+
+The 'channel' works a bit like a datagram socket. Each 'write' is
+passed as a whole to the cache for parsing and interpretation.
+Each cache can treat the write requests differently, but it is
+expected that a message written will contain:
+  - a key
+  - an expiry time
+  - a content.
+with the intention that an item in the cache with the give key
+should be create or updated to have the given content, and the
+expiry time should be set on that item.
+
+Reading from a channel is a bit more interesting.  When a cache
+lookup fail, or when it suceeds but finds an entry that may soon
+expiry, a request is lodged for that cache item to be updated by
+user-space.  These requests appear in the channel file.
+
+Successive reads will return successive requests.
+If there are no more requests to return, read will return EOF, but a
+select or poll for read will block waiting for another request to be
+added.
+
+Thus a user-space helper is likely to:
+  open the channel.
+    select for readable
+    read a request
+    write a response
+  loop.
+
+If it dies and needs to be restarted, any requests that have not be
+answered will still appear in the file and will be read by the new
+instance of the helper.
+
+Each cache should define a "cache_parse" method which takes a message
+written from user-space and processes it.  It should return an error
+(which propagates back to the write syscall) or 0.
+
+
--- ./include/linux/sunrpc/cache.h	2002/10/11 02:00:11	1.3
+++ ./include/linux/sunrpc/cache.h	2002/10/11 02:39:10	1.4
@@ -15,6 +15,7 @@
 
 #include <linux/slab.h>
 #include <asm/atomic.h>
+#include <linux/proc_fs.h>
 
 /*
  * Each cache requires:
@@ -74,6 +75,8 @@ struct cache_detail {
 	/* request and update functions for interaction with userspace
 	 * will go here
 	 */
+	int			(*cache_parse)(struct cache_detail *,
+					       char *buf, int len);
 
 	/* fields below this comment are for internal use
 	 * and should not be touched by cache owners
@@ -83,6 +86,10 @@ struct cache_detail {
 	struct list_head	others;
 	time_t			nextcheck;
 	int			entries;
+
+	/* fields for communication over channel */
+	struct list_head	queue;
+	struct proc_dir_entry	*proc_ent;
 };
 
 
--- ./include/linux/sunrpc/stats.h	2002/10/11 02:22:32	1.1
+++ ./include/linux/sunrpc/stats.h	2002/10/11 02:39:10	1.2
@@ -57,6 +57,8 @@ int			svc_proc_read(char *, char **, off
 					int *, void *);
 void			svc_proc_zero(struct svc_program *);
 
+extern struct proc_dir_entry	*proc_net_rpc;
+
 #else
 
 static inline void svc_proc_unregister(const char *p) {}
--- ./net/sunrpc/cache.c	2002/10/11 02:00:12	1.3
+++ ./net/sunrpc/cache.c	2002/10/11 02:39:10	1.4
@@ -18,9 +18,14 @@
 #include <linux/sched.h>
 #include <linux/kmod.h>
 #include <linux/list.h>
+#include <linux/module.h>
 #include <asm/uaccess.h>
+#include <linux/poll.h>
+#include <linux/proc_fs.h>
+#include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
+#include <linux/sunrpc/stats.h>
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
@@ -128,9 +133,25 @@ static spinlock_t cache_list_lock = SPIN
 static struct cache_detail *current_detail;
 static int current_index;
 
+struct file_operations cache_file_operations;
+
 void cache_register(struct cache_detail *cd)
 {
+	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
+	if (cd->proc_ent) {
+		struct proc_dir_entry *p;
+		cd->proc_ent->owner = THIS_MODULE;
+		
+		p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
+				      cd->proc_ent);
+		if (p) {
+			p->proc_fops = &cache_file_operations;
+			p->owner = THIS_MODULE;
+			p->data = cd;
+		}
+	}
 	rwlock_init(&cd->hash_lock);
+	INIT_LIST_HEAD(&cd->queue);
 	spin_lock(&cache_list_lock);
 	cd->nextcheck = 0;
 	cd->entries = 0;
@@ -153,6 +174,10 @@ int cache_unregister(struct cache_detail
 	list_del_init(&cd->others);
 	write_unlock(&cd->hash_lock);
 	spin_unlock(&cache_list_lock);
+	if (cd->proc_ent) {
+		cd->proc_ent = NULL;
+		remove_proc_entry(cd->name, proc_net_rpc);
+	}
 	return 0;
 }
 
@@ -390,3 +415,274 @@ void cache_revisit_request(struct cache_
 		dreq->revisit(dreq, 0);
 	}
 }
+
+/*
+ * communicate with user-space
+ *
+ * We have a magic /proc file - /proc/sunrpc/cache
+ * On read, you get a full request, or block
+ * On write, an update request is processed
+ * Poll works if anything to read, and always allows write
+ *
+ * Implemented by linked list of requests.  Each open file has 
+ * a ->private that also exists in this list.  New request are added
+ * to the end and may wakeup and preceeding readers.
+ * New readers are added to the head.  If, on read, an item is found with
+ * CACHE_UPCALLING clear, we free it from the list.
+ *
+ */
+
+static spinlock_t queue_lock = SPIN_LOCK_UNLOCKED;
+static DECLARE_MUTEX(queue_io_sem);
+
+struct cache_queue {
+	struct list_head	list;
+	int			reader;	/* if 0, then request */
+};
+struct cache_request {
+	struct cache_queue	q;
+	struct cache_head	*item;
+	char			* buf;
+	int			len;
+	int			readers;
+};
+struct cache_reader {
+	struct cache_queue	q;
+	int			offset;	/* if non-0, we have a refcnt on next request */
+	char			*page;
+};
+
+static ssize_t
+cache_read(struct file *filp, char *buf, size_t count, loff_t *ppos)
+{
+	struct cache_reader *rp = filp->private_data;
+	struct cache_request *rq;
+	struct cache_detail *cd = PDE(filp->f_dentry->d_inode)->data;
+	int err;
+
+	if (ppos != &filp->f_pos)
+		return -ESPIPE;
+
+	if (count == 0)
+		return 0;
+
+	down(&queue_io_sem); /* protect against multiple concurrent
+			      * readers on this file */
+ again:
+	spin_lock(&queue_lock);
+	/* need to find next request */
+	while (rp->q.list.next != &cd->queue &&
+	       list_entry(rp->q.list.next, struct cache_queue, list)
+	       ->reader) {
+		struct list_head *next = rp->q.list.next;
+		list_move(&rp->q.list, next);
+	}
+	if (rp->q.list.next == &cd->queue) {
+		spin_unlock(&queue_lock);
+		up(&queue_io_sem);
+		if (rp->offset)
+			BUG();
+		return 0;
+	}
+	rq = container_of(rp->q.list.next, struct cache_request, q.list);
+	if (rq->q.reader) BUG();
+	if (rp->offset == 0)
+		rq->readers++;
+	spin_unlock(&queue_lock);
+
+	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
+		err = -EAGAIN;
+		spin_lock(&queue_lock);
+		list_move(&rp->q.list, &rq->q.list);
+		spin_unlock(&queue_lock);
+	} else {
+		if (rp->offset + count > rq->len)
+			count = rq->len - rp->offset;
+		err = -EFAULT;
+		if (copy_to_user(buf, rq->buf + rp->offset, count))
+			goto out;
+		rp->offset += count;
+		if (rp->offset >= rq->len) {
+			rp->offset = 0;
+			spin_lock(&queue_lock);
+			list_move(&rp->q.list, &rq->q.list);
+			spin_unlock(&queue_lock);
+		}
+		err = 0;
+	}
+ out:
+	if (rp->offset == 0) {
+		/* need to release rq */
+		spin_lock(&queue_lock);
+		rq->readers--;
+		if (rq->readers == 0 &&
+		    !test_bit(CACHE_PENDING, &rq->item->flags)) {
+			list_del(&rq->q.list);
+			spin_unlock(&queue_lock);
+			cd->cache_put(rq->item, cd);
+			kfree(rq->buf);
+			kfree(rq);
+		} else
+			spin_unlock(&queue_lock);
+	}
+	if (err == -EAGAIN)
+		goto again;
+	up(&queue_io_sem);
+	return err ? err :  count;
+}
+
+static ssize_t
+cache_write(struct file *filp, const char *buf, size_t count,
+	    loff_t *ppos)
+{
+	int err;
+	struct cache_reader *rp = filp->private_data;
+	struct cache_detail *cd = PDE(filp->f_dentry->d_inode)->data;
+
+	if (ppos != &filp->f_pos)
+		return -ESPIPE;
+
+	if (count == 0)
+		return 0;
+	if (count > PAGE_SIZE)
+		return -EINVAL;
+
+	down(&queue_io_sem);
+
+	if (rp->page == NULL) {
+		rp->page = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (rp->page == NULL) {
+			up(&queue_io_sem);
+			return -ENOMEM;
+		}
+	}
+
+	if (copy_from_user(rp->page, buf, count)) {
+		up(&queue_io_sem);
+		return -EFAULT;
+	}
+	if (count < PAGE_SIZE)
+		rp->page[count] = '\0';
+	if (cd->cache_parse)
+		err = cd->cache_parse(cd, rp->page, count);
+	else
+		err = -EINVAL;
+
+	up(&queue_io_sem);
+	return err ? err : count;
+}
+
+static DECLARE_WAIT_QUEUE_HEAD(queue_wait);
+
+static unsigned int
+cache_poll(struct file *filp, poll_table *wait)
+{
+	unsigned int mask;
+	struct cache_reader *rp = filp->private_data;
+	struct cache_queue *cq;
+	struct cache_detail *cd = PDE(filp->f_dentry->d_inode)->data;
+
+	poll_wait(filp, &queue_wait, wait);
+
+	/* alway allow write */
+	mask = POLL_OUT | POLLWRNORM;
+	spin_lock(&queue_lock);
+
+	for (cq= &rp->q; &cq->list != &cd->queue;
+	     cq = list_entry(cq->list.next, struct cache_queue, list))
+		if (!cq->reader) {
+			mask |= POLLIN | POLLRDNORM;
+			break;
+		}
+	spin_unlock(&queue_lock);
+	return mask;
+}
+
+static int
+cache_ioctl(struct inode *ino, struct file *filp,
+	    unsigned int cmd, unsigned long arg)
+{
+	int len = 0;
+	struct cache_reader *rp = filp->private_data;
+	struct cache_queue *cq;
+	struct cache_detail *cd = PDE(ino)->data;
+
+	if (cmd != FIONREAD)
+		return -EINVAL;
+	spin_lock(&queue_lock);
+
+	/* only find the length remaining in current request,
+	 * or the length of the next request
+	 */
+	for (cq= &rp->q; &cq->list != &cd->queue;
+	     cq = list_entry(cq->list.next, struct cache_queue, list))
+		if (!cq->reader) {
+			struct cache_request *cr =
+				container_of(cq, struct cache_request, q);
+			len = cr->len - rp->offset;
+			break;
+		}
+	spin_unlock(&queue_lock);
+
+	return put_user(len, (int *)arg);
+}
+
+static int
+cache_open(struct inode *inode, struct file *filp)
+{
+	struct cache_reader *rp;
+	struct cache_detail *cd = PDE(inode)->data;
+
+	rp = kmalloc(sizeof(*rp), GFP_KERNEL);
+	if (!rp)
+		return -ENOMEM;
+	rp->page = NULL;
+	rp->offset = 0;
+	rp->q.reader = 1;
+	spin_lock(&queue_lock);
+	list_add(&rp->q.list, &cd->queue);
+	spin_unlock(&queue_lock);
+	filp->private_data = rp;
+	return 0;
+}
+
+static int
+cache_release(struct inode *inode, struct file *filp)
+{
+	struct cache_reader *rp = filp->private_data;
+	struct cache_detail *cd = PDE(inode)->data;
+
+	spin_lock(&queue_lock);
+	if (rp->offset) {
+		struct cache_queue *cq;
+		for (cq= &rp->q; &cq->list != &cd->queue;
+		     cq = list_entry(cq->list.next, struct cache_queue, list))
+			if (!cq->reader) {
+				container_of(cq, struct cache_request, q)
+					->readers--;
+				break;
+			}
+		rp->offset = 0;
+	}
+	list_del(&rp->q.list);
+	spin_unlock(&queue_lock);
+
+	if (rp->page)
+		kfree(rp->page);
+
+	filp->private_data = NULL;
+	kfree(rp);
+	return 0;
+}
+
+
+
+struct file_operations cache_file_operations = {
+	.llseek		= no_llseek,
+	.read		= cache_read,
+	.write		= cache_write,
+	.poll		= cache_poll,
+	.ioctl		= cache_ioctl, /* for FIONREAD */
+	.open		= cache_open,
+	.release	= cache_release,
+};
--- ./net/sunrpc/stats.c	2002/10/11 00:51:16	1.2
+++ ./net/sunrpc/stats.c	2002/10/11 02:39:11	1.3
@@ -25,7 +25,7 @@
 
 #define RPCDBG_FACILITY	RPCDBG_MISC
 
-static struct proc_dir_entry	*proc_net_rpc = NULL;
+struct proc_dir_entry	*proc_net_rpc = NULL;
 
 /*
  * Get RPC client stats


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
