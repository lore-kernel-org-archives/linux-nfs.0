From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 7 - Make sure sunrpc/cache doesn't confuse writers with readers.
Date: Tue, 05 Aug 2003 13:59:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19jsyn-0000mm-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jsyw-0001hB-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 20:59:30 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 5 Aug 2003 13:59:24 +1000
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

7 patches for kNFSd in 2.6.0-test2 - all over the place.

### Comments for ChangeSet

When a sunrpc/cache channel is not open for reading, the
cache doesn't bother making and waiting for up-calls.

However it doesn't currently distingish between open-for-read/write
and open-for-write, so an op-for-write will look like a reader
and will cause inappropriate waiting.

This patch checks if a file is open-for-read and will only register
a file as a reader if it really is one.

 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |   69 +++++++++++++++++++++++++++------------------------
 1 files changed, 37 insertions(+), 32 deletions(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-08-04 11:07:23.000000000 +1000
+++ ./net/sunrpc/cache.c	2003-08-04 11:07:23.000000000 +1000
@@ -738,19 +738,22 @@ cache_ioctl(struct inode *ino, struct fi
 static int
 cache_open(struct inode *inode, struct file *filp)
 {
-	struct cache_reader *rp;
-	struct cache_detail *cd = PDE(inode)->data;
+	struct cache_reader *rp = NULL;
 
-	rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-	if (!rp)
-		return -ENOMEM;
-	rp->page = NULL;
-	rp->offset = 0;
-	rp->q.reader = 1;
-	atomic_inc(&cd->readers);
-	spin_lock(&queue_lock);
-	list_add(&rp->q.list, &cd->queue);
-	spin_unlock(&queue_lock);
+	if (filp->f_mode & FMODE_READ) {
+		struct cache_detail *cd = PDE(inode)->data;
+
+		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
+		if (!rp)
+			return -ENOMEM;
+		rp->page = NULL;
+		rp->offset = 0;
+		rp->q.reader = 1;
+		atomic_inc(&cd->readers);
+		spin_lock(&queue_lock);
+		list_add(&rp->q.list, &cd->queue);
+		spin_unlock(&queue_lock);
+	}
 	filp->private_data = rp;
 	return 0;
 }
@@ -761,29 +764,31 @@ cache_release(struct inode *inode, struc
 	struct cache_reader *rp = filp->private_data;
 	struct cache_detail *cd = PDE(inode)->data;
 
-	spin_lock(&queue_lock);
-	if (rp->offset) {
-		struct cache_queue *cq;
-		for (cq= &rp->q; &cq->list != &cd->queue;
-		     cq = list_entry(cq->list.next, struct cache_queue, list))
-			if (!cq->reader) {
-				container_of(cq, struct cache_request, q)
-					->readers--;
-				break;
-			}
-		rp->offset = 0;
-	}
-	list_del(&rp->q.list);
-	spin_unlock(&queue_lock);
+	if (rp) {
+		spin_lock(&queue_lock);
+		if (rp->offset) {
+			struct cache_queue *cq;
+			for (cq= &rp->q; &cq->list != &cd->queue;
+			     cq = list_entry(cq->list.next, struct cache_queue, list))
+				if (!cq->reader) {
+					container_of(cq, struct cache_request, q)
+						->readers--;
+					break;
+				}
+			rp->offset = 0;
+		}
+		list_del(&rp->q.list);
+		spin_unlock(&queue_lock);
 
-	if (rp->page)
-		kfree(rp->page);
+		if (rp->page)
+			kfree(rp->page);
 
-	filp->private_data = NULL;
-	kfree(rp);
+		filp->private_data = NULL;
+		kfree(rp);
 
-	cd->last_close = get_seconds();
-	atomic_dec(&cd->readers);
+		cd->last_close = get_seconds();
+		atomic_dec(&cd->readers);
+	}
 	return 0;
 }
 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
