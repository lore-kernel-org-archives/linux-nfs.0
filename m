From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 12 of 17 - Provide generic code for making an upcall.
Date: Fri, 11 Oct 2002 15:27:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKy-0003bo-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLV-0003iH-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:21 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Fri, 11 Oct 2002 15:28:04 +1000
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


### Comments for ChangeSet

This code enhances 'cache_check' to try to initiate
an up-call if the cache entry is not up-to-date, and also
defines add_word and add_hex for formating up-call
requests.  See rpc-cache.txt for more detail.


 ----------- Diffstat output ------------
 ./Documentation/rpc-cache.txt  |   30 ++++++
 ./include/linux/sunrpc/cache.h |   11 +-
 ./net/sunrpc/cache.c           |  200 ++++++++++++++++++++++++++++++++++++++---
 3 files changed, 227 insertions(+), 14 deletions(-)

--- ./Documentation/rpc-cache.txt	2002/10/11 02:39:11	1.4
+++ ./Documentation/rpc-cache.txt	2002/10/11 03:04:46	1.5
@@ -138,4 +138,34 @@ Each cache should define a "cache_parse"
 written from user-space and processes it.  It should return an error
 (which propagates back to the write syscall) or 0.
 
+Each cache should also define a "cache_request" method which
+takes a cache item and encodes a request into the buffer
+provided.
 
+
+Note: If a cache has no active readers on the channel, and has had not
+active readers for more than 60 seconds, further requests will not be
+added to the channel but instead all looks that do not find a valid
+entry will fail.  This is partly for backward compatability: The
+previous nfs exports table was deemed to be authoritative and a
+failed lookup meant a definate 'no'.
+
+request/response format
+-----------------------
+
+While each cache is free to use it's own format for requests
+and responses over channel, the following is recommended are
+appropriate and support routines are available to help:
+Each request or response record should be printable ASCII
+with precisely one newline character which should be at the end.
+Fields within the record should be separated by spaces, normally one.
+If spaces, newlines, or nul characters are needed in a field they
+much be quotes.  two mechanisms are available:
+1/ If a field begins '\x' then it must contain an even number of
+   hex digits, and pairs of these digits provide the bytes in the
+   field.
+2/ otherwise a \ in the field must be followed by 3 octal digits
+   which give the code for a byte.  Other characters are treated
+   as them selves.  At the very least, space, newlines nul, and
+   '\' must be quoted in this way.
+   
--- ./include/linux/sunrpc/cache.h	2002/10/11 02:39:10	1.4
+++ ./include/linux/sunrpc/cache.h	2002/10/11 03:04:45	1.5
@@ -72,9 +72,9 @@ struct cache_detail {
 	void			(*cache_put)(struct cache_head *,
 					     struct cache_detail*);
 
-	/* request and update functions for interaction with userspace
-	 * will go here
-	 */
+	void			(*cache_request)(struct cache_detail *cd,
+						 struct cache_head *h,
+						 char **bpp, int *blen);
 	int			(*cache_parse)(struct cache_detail *,
 					       char *buf, int len);
 
@@ -90,6 +90,8 @@ struct cache_detail {
 	/* fields for communication over channel */
 	struct list_head	queue;
 	struct proc_dir_entry	*proc_ent;
+	atomic_t		readers;		/* how many time is /chennel open */
+	time_t			last_close;		/* it no readers, when did last close */
 };
 
 
@@ -269,4 +271,7 @@ extern int cache_unregister(struct cache
 extern struct cache_detail *cache_find(char *name);
 extern void cache_drop(struct cache_detail *detail);
 
+extern void add_word(char **bpp, int *lp, char *str);
+extern void add_hex(char **bpp, int *lp, char *buf, int blen);
+
 #endif /*  _LINUX_SUNRPC_CACHE_H_ */
--- ./net/sunrpc/cache.c	2002/10/11 02:39:10	1.4
+++ ./net/sunrpc/cache.c	2002/10/11 03:04:46	1.5
@@ -40,6 +40,7 @@ void cache_init(struct cache_head *h)
 }
 
 
+static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
 /*
  * This is the generic cache management routine for all
  * the authentication caches.
@@ -55,6 +56,7 @@ int cache_check(struct cache_detail *det
 		    struct cache_head *h, struct cache_req *rqstp)
 {
 	int rv;
+	long refresh_age, age;
 
 	/* First decide return status as best we can */
 	if (!test_bit(CACHE_VALID, &h->flags) ||
@@ -69,31 +71,54 @@ int cache_check(struct cache_detail *det
 		else rv = 0;
 	}
 
-	/* up-call processing goes here later */
-	/* if cache_pending, initiate upcall if none pending.
-	 * if upcall cannot be initiated, change to CACHE_NEGATIVE
-	 */
-	if (rv == CACHE_PENDING) rv = CACHE_NEGATIVE;
+	/* now see if we want to start an upcall */
+	refresh_age = (h->expiry_time - h->last_refresh);
+	age = CURRENT_TIME - h->last_refresh;
 
-	if (rv == CACHE_PENDING)
-		cache_defer_req(rqstp, h);
+	if (rqstp == NULL) {
+		if (rv == -EAGAIN)
+			rv = -ENOENT;
+	} else if (rv == -EAGAIN || age > refresh_age/2) {
+		dprintk("Want update, refage=%ld, age=%ld\n", refresh_age, age);
+		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
+			switch (cache_make_upcall(detail, h)) {
+			case -EINVAL:
+				clear_bit(CACHE_PENDING, &h->flags);
+				if (rv == -EAGAIN) {
+					set_bit(CACHE_NEGATIVE, &h->flags);
+					cache_fresh(detail, h, CURRENT_TIME+CACHE_NEW_EXPIRY);
+					rv = -ENOENT;
+				}
+				break;
+
+			case -EAGAIN:
+				clear_bit(CACHE_PENDING, &h->flags);
+				cache_revisit_request(h);
+				break;
+			}
+		}
+	}
 
-	if (rv == -EAGAIN /* && cannot do upcall */)
-		rv = -ENOENT;
+	if (rv == -EAGAIN)
+		cache_defer_req(rqstp, h);
 
 	if (rv && h)
 		detail->cache_put(h, detail);
 	return rv;
 }
 
+static void queue_loose(struct cache_detail *detail, struct cache_head *ch);
+
 void cache_fresh(struct cache_detail *detail,
 		 struct cache_head *head, time_t expiry)
 {
 
 	head->expiry_time = expiry;
 	head->last_refresh = CURRENT_TIME;
-	set_bit(CACHE_VALID, &head->flags);
-	clear_bit(CACHE_PENDING, &head->flags);
+	if (!test_and_set_bit(CACHE_VALID, &head->flags))
+		cache_revisit_request(head);
+	if (test_and_clear_bit(CACHE_PENDING, &head->flags))
+		queue_loose(detail, head);
 }
 
 /*
@@ -155,6 +180,8 @@ void cache_register(struct cache_detail 
 	spin_lock(&cache_list_lock);
 	cd->nextcheck = 0;
 	cd->entries = 0;
+	atomic_set(&cd->readers, 0);
+	cd->last_close = CURRENT_TIME;
 	list_add(&cd->others, &cache_list);
 	spin_unlock(&cache_list_lock);
 }
@@ -639,6 +666,7 @@ cache_open(struct inode *inode, struct f
 	rp->page = NULL;
 	rp->offset = 0;
 	rp->q.reader = 1;
+	atomic_inc(&cd->readers);
 	spin_lock(&queue_lock);
 	list_add(&rp->q.list, &cd->queue);
 	spin_unlock(&queue_lock);
@@ -672,6 +700,9 @@ cache_release(struct inode *inode, struc
 
 	filp->private_data = NULL;
 	kfree(rp);
+
+	cd->last_close = CURRENT_TIME;
+	atomic_dec(&cd->readers);
 	return 0;
 }
 
@@ -686,3 +717,150 @@ struct file_operations cache_file_operat
 	.open		= cache_open,
 	.release	= cache_release,
 };
+
+
+static void queue_loose(struct cache_detail *detail, struct cache_head *ch)
+{
+	struct cache_queue *cq;
+	spin_lock(&queue_lock);
+	list_for_each_entry(cq, &detail->queue, list)
+		if (!cq->reader) {
+			struct cache_request *cr = container_of(cq, struct cache_request, q);
+			if (cr->item != ch)
+				continue;
+			if (cr->readers != 0)
+				break;
+			list_del(&cr->q.list);
+			spin_unlock(&queue_lock);
+			detail->cache_put(cr->item, detail);
+			kfree(cr->buf);
+			kfree(cr);
+			return;
+		}
+	spin_unlock(&queue_lock);
+}
+
+/*
+ * Support routines for text-based upcalls.
+ * Fields are separated by spaces.
+ * Fields are either mangled to quote space tab newline slosh with slosh
+ * or a hexified with a leading \x
+ * Record is terminated with newline.
+ *
+ */
+
+void add_word(char **bpp, int *lp, char *str)
+{
+	char *bp = *bpp;
+	int len = *lp;
+	char c;
+
+	if (len < 0) return;
+
+	while ((c=*str++) && len)
+		switch(c) {
+		case ' ':
+		case '\t':
+		case '\n':
+		case '\\':
+			if (len >= 4) {
+				*bp++ = '\\';
+				*bp++ = '0' + ((c & 0300)>>6);
+				*bp++ = '0' + ((c & 0070)>>3);
+				*bp++ = '0' + ((c & 0007)>>0);
+			}
+			len -= 4;
+			break;
+		default:
+			*bp++ = c;
+			len--;
+		}
+	if (c || len <1) len = -1;
+	else {
+		*bp++ = ' ';
+		len--;
+	}
+	*bpp = bp;
+	*lp = len;
+}
+
+void add_hex(char **bpp, int *lp, char *buf, int blen)
+{
+	char *bp = *bpp;
+	int len = *lp;
+
+	if (len < 0) return;
+
+	if (len > 2) {
+		*bp++ = '\\';
+		*bp++ = 'x';
+		len -= 2;
+		while (blen && len >= 2) {
+			unsigned char c = *buf++;
+			*bp++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'0');
+			*bp++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'0');
+			len -= 2;
+			blen--;
+		}
+	}
+	if (blen || len<1) len = -1;
+	else {
+		*bp++ = ' ';
+		len--;
+	}
+	*bpp = bp;
+	*lp = len;
+}
+
+			
+
+/*
+ * register an upcall request to user-space.
+ * Each request is at most one page long.
+ */
+static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h)
+{
+
+	char *buf;
+	struct cache_request *crq;
+	char *bp;
+	int len;
+
+	if (detail->cache_request == NULL)
+		return -EINVAL;
+
+	if (atomic_read(&detail->readers) == 0 &&
+	    detail->last_close < CURRENT_TIME - 60)
+		/* nobody is listening */
+		return -EINVAL;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -EAGAIN;
+
+	crq = kmalloc(sizeof (*crq), GFP_KERNEL);
+	if (!crq) {
+		kfree(buf);
+		return -EAGAIN;
+	}
+
+	bp = buf; len = PAGE_SIZE;
+
+	detail->cache_request(detail, h, &bp, &len);
+
+	if (len < 0) {
+		kfree(buf);
+		kfree(crq);
+		return -EAGAIN;
+	}
+	crq->q.reader = 0;
+	crq->item = cache_get(h);
+	crq->buf = buf;
+	crq->len = PAGE_SIZE - len;
+	crq->readers = 0;
+	spin_lock(&queue_lock);
+	list_add_tail(&crq->q.list, &detail->queue);
+	spin_unlock(&queue_lock);
+	wake_up(&queue_wait);
+	return 0;
+}


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
