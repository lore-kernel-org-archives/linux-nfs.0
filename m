From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] - kNFSd -  Fix the sunrpc cache/reader management properly.
Date: Wed, 06 Aug 2003 16:49:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19kI7G-0000xq-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kI7N-0002Kl-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Aug 2003 23:49:54 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Wed, 6 Aug 2003 16:49:46 +1000
To: Linus Torvalds <torvalds@osdl.org>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

A recent patch changed the rpc/*/channel files to behave
differently depending on whether they were open for read or not.

This hadn't been tested thoroughly.  The cache_reader structure
that was now only allocated when opening for read, had a field that
was iused when writing.

This patch removes that field and takes a different approach to solving
the issue it addressed.
And it has been tested a bit better.


 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-08-05 14:00:43.000000000 +1000
+++ ./net/sunrpc/cache.c	2003-08-06 14:38:10.000000000 +1000
@@ -557,7 +557,6 @@ struct cache_request {
 struct cache_reader {
 	struct cache_queue	q;
 	int			offset;	/* if non-0, we have a refcnt on next request */
-	char			*page;
 };
 
 static ssize_t
@@ -644,7 +643,7 @@ cache_write(struct file *filp, const cha
 	    loff_t *ppos)
 {
 	int err;
-	struct cache_reader *rp = filp->private_data;
+	char *page;
 	struct cache_detail *cd = PDE(filp->f_dentry->d_inode)->data;
 
 	if (ppos != &filp->f_pos)
@@ -657,26 +656,26 @@ cache_write(struct file *filp, const cha
 
 	down(&queue_io_sem);
 
-	if (rp->page == NULL) {
-		rp->page = kmalloc(PAGE_SIZE, GFP_KERNEL);
-		if (rp->page == NULL) {
-			up(&queue_io_sem);
-			return -ENOMEM;
-		}
+	page = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (page == NULL) {
+		up(&queue_io_sem);
+		return -ENOMEM;
 	}
 
-	if (copy_from_user(rp->page, buf, count)) {
+	if (copy_from_user(page, buf, count)) {
 		up(&queue_io_sem);
+		kfree(page);
 		return -EFAULT;
 	}
 	if (count < PAGE_SIZE)
-		rp->page[count] = '\0';
+		page[count] = '\0';
 	if (cd->cache_parse)
-		err = cd->cache_parse(cd, rp->page, count);
+		err = cd->cache_parse(cd, page, count);
 	else
 		err = -EINVAL;
 
 	up(&queue_io_sem);
+	kfree(page);
 	return err ? err : count;
 }
 
@@ -694,6 +693,10 @@ cache_poll(struct file *filp, poll_table
 
 	/* alway allow write */
 	mask = POLL_OUT | POLLWRNORM;
+
+	if (!rp)
+		return mask;
+
 	spin_lock(&queue_lock);
 
 	for (cq= &rp->q; &cq->list != &cd->queue;
@@ -715,8 +718,9 @@ cache_ioctl(struct inode *ino, struct fi
 	struct cache_queue *cq;
 	struct cache_detail *cd = PDE(ino)->data;
 
-	if (cmd != FIONREAD)
+	if (cmd != FIONREAD || !rp)
 		return -EINVAL;
+
 	spin_lock(&queue_lock);
 
 	/* only find the length remaining in current request,
@@ -746,7 +750,6 @@ cache_open(struct inode *inode, struct f
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
 		if (!rp)
 			return -ENOMEM;
-		rp->page = NULL;
 		rp->offset = 0;
 		rp->q.reader = 1;
 		atomic_inc(&cd->readers);
@@ -780,9 +783,6 @@ cache_release(struct inode *inode, struc
 		list_del(&rp->q.list);
 		spin_unlock(&queue_lock);
 
-		if (rp->page)
-			kfree(rp->page);
-
 		filp->private_data = NULL;
 		kfree(rp);
 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
