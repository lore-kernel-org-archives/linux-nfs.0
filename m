From: Greg Banks <gnb@sgi.com>
Subject: [patch 14/14] sunrpc: Improve the usefulness of debug printks in the sunrpc cache code.
Date: Thu, 08 Jan 2009 19:25:24 +1100
Message-ID: <20090108082605.391890000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:45000 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753371AbZAHI0N (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |  116 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 100 insertions(+), 16 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -109,6 +109,8 @@ static int cache_fresh_locked(struct cac
 {
 	h->expiry_time = expiry;
 	h->last_refresh = get_seconds();
+	dprintk("%s: refreshing entry %p, expiry %ld refreshed %ld\n",
+		__func__, h, h->expiry_time, h->last_refresh);
 	return !test_and_set_bit(CACHE_VALID, &h->flags);
 }
 
@@ -194,35 +196,57 @@ int cache_check(struct cache_detail *cd,
 {
 	int rv;
 	long refresh_age, age;
+	long now = get_seconds();
+
+	dprintk("%s: cache %s entry %p\n",
+		__func__, cd->name, h);
 
 	/* First decide return status as best we can */
 	if (!test_bit(CACHE_VALID, &h->flags) ||
-	    h->expiry_time < get_seconds())
+	    h->expiry_time < now) {
+		dprintk("%s: entry %p invalid, flags %lu expiry %ld now %ld\n",
+			__func__, h, h->flags, h->expiry_time, now);
 		rv = -EAGAIN;
-	else if (cd->flush_time > h->last_refresh)
+	} else if (cd->flush_time > h->last_refresh) {
+		dprintk("%s: entry %p flushed: last_refresh %ld before flush_time %ld\n",
+			__func__, h, h->last_refresh, cd->flush_time);
 		rv = -EAGAIN;
-	else {
+	} else {
 		/* entry is valid */
-		if (test_bit(CACHE_NEGATIVE, &h->flags))
+		if (test_bit(CACHE_NEGATIVE, &h->flags)) {
+			dprintk("%s: entry %p negative\n",
+				__func__, h);
 			rv = -ENOENT;
+		}
 		else rv = 0;
 	}
 
 	/* now see if we want to start an upcall */
 	refresh_age = (h->expiry_time - h->last_refresh);
-	age = get_seconds() - h->last_refresh;
+	age = now - h->last_refresh;
+	dprintk("%s: entry %p now=%ld expiry=%ld last_refresh=%ld refage=%ld age=%ld\n",
+		__func__, h, now, h->expiry_time, h->last_refresh, refresh_age, age);
 
 	if (rqstp == NULL) {
-		if (rv == -EAGAIN)
+		if (rv == -EAGAIN) {
+			dprintk("%s: entry %p, needs upcall but cannot defer, returning -ENOENT\n",
+				__func__, h);
 			rv = -ENOENT;
+		}
 	} else if (rv == -EAGAIN || age > refresh_age/2) {
-		dprintk("RPC:       Want update, refage=%ld, age=%ld\n",
-				refresh_age, age);
+		dprintk("%s: entry %p needs upcall\n",
+		        __func__, h);
 		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
+			dprintk("%s: entry %p initiating upcall\n",
+				__func__, h);
 			switch (cache_make_upcall(cd, h)) {
 			case -EINVAL:
+				dprintk("%s: entry %p cache_make_upcall returned -EINVAL\n",
+					__func__, h);
 				clear_bit(CACHE_PENDING, &h->flags);
 				if (rv == -EAGAIN) {
+					dprintk("%s: entry %p going NEGATIVE\n",
+						__func__, h);
 					set_bit(CACHE_NEGATIVE, &h->flags);
 					cache_fresh_unlocked(h, cd,
 					     cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY));
@@ -231,6 +255,8 @@ int cache_check(struct cache_detail *cd,
 				break;
 
 			case -EAGAIN:
+				dprintk("%s: entry %p cache_make_upcall returned -EAGAIN\n",
+					__func__, h);
 				clear_bit(CACHE_PENDING, &h->flags);
 				cache_revisit_request(h);
 				break;
@@ -244,6 +270,9 @@ int cache_check(struct cache_detail *cd,
 
 	if (rv)
 		cache_put(h, cd);
+
+	dprintk("%s: entry %p, returning %d\n",
+		__func__, h, rv);
 	return rv;
 }
 EXPORT_SYMBOL(cache_check);
@@ -559,10 +588,15 @@ static int cache_defer_req(struct cache_
 	struct cache_deferred_req *dreq;
 	int hash = DFR_HASH(h);
 
+	dprintk("%s: deferring entry %p\n",
+		__func__, h);
+
 	if (cache_defer_cnt >= DFR_MAX) {
 		/* too much in the cache, randomly drop this one,
 		 * or continue and drop the oldest below
 		 */
+		dprintk("%s: entry %p, too many deferrals, dropping new\n",
+			__func__, h);
 		if (net_random()&1)
 			return -ETIMEDOUT;
 	}
@@ -585,6 +619,8 @@ static int cache_defer_req(struct cache_
 	if (++cache_defer_cnt > DFR_MAX) {
 		dreq = list_entry(cache_defer_list.prev,
 				  struct cache_deferred_req, recent);
+		dprintk("%s: entry %p, too many deferrals, dropping old %p\n",
+			__func__, h, dreq);
 		list_del(&dreq->recent);
 		list_del(&dreq->hash);
 		cache_defer_cnt--;
@@ -610,6 +646,9 @@ static void cache_revisit_request(struct
 	struct list_head *lp;
 	int hash = DFR_HASH(h);
 
+	dprintk("%s: revisiting entry %p\n",
+		__func__, h);
+
 	INIT_LIST_HEAD(&pending);
 	spin_lock(&cache_defer_lock);
 
@@ -693,6 +732,9 @@ cache_read(struct file *filp, char __use
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
 	int err;
 
+	dprintk("%s: cache %s pid %d(%s) reading %zd bytes\n",
+		__func__, cd->name, task_pid_nr(current), current->comm, count);
+
 	if (count == 0)
 		return 0;
 
@@ -704,17 +746,24 @@ cache_read(struct file *filp, char __use
 	}
 	spin_unlock(&cd->queue_lock);
 
-	if (rq == NULL)
+	if (rq == NULL) {
+		dprintk("%s: cache %s no queued requests\n",
+			__func__, cd->name);
 		return 0; /* no queued requests */
+	}
 
 	err = -EAGAIN;	/* gnb:TODO...this used to cause a loop, wtf */
 	if (!test_bit(CACHE_PENDING, &rq->item->flags))
 		goto error;
 
-	/* gnb:TODO whine to dmesg; stat */
+	/* gnb:TODO stat */
 	err = -EFAULT;
-	if (count < rq->len)
+	if (count < rq->len) {
+		dprintk("%s: cache %s short read, message length %d"
+		        " dropping request %p entry %p\n",
+			__func__, cd->name, rq->len, rq, rq->item);
 		goto error; /* We make no pretence at handling short reads */
+	}
 	count = rq->len;
 
 	err = -EFAULT;
@@ -735,6 +784,7 @@ error:
 	/* need to release rq */
 	cache_request_put(rq, cd);
 
+	dprintk("%s: returning %d\n", __func__, err);
 	return err;
 }
 
@@ -747,27 +797,38 @@ cache_write(struct file *filp, const cha
 	char *tmp;
 	int tmp_size = PAGE_SIZE;
 
+	dprintk("%s: cache %s pid %d(%s) writing %zd bytes\n",
+		__func__, cd->name, task_pid_nr(current), current->comm, count);
+
 	if (count == 0)
 		return 0;
+	err = -EINVAL;
 	if (count >= tmp_size)
-		return -EINVAL;
+		goto out2;
 
+	err = -ENOMEM;
 	tmp = kmalloc(tmp_size, GFP_KERNEL);
 	if (!tmp)
-		return -ENOMEM;
+		goto out2;
 
 	err = -EFAULT;
 	if (copy_from_user(tmp, buf, count))
 		goto out;
 
 	tmp[count] = '\0';
+	dprintk("%s: cache %s parsing update text \"%.*s\"\n",
+		__func__, cd->name, (int)count, tmp);
 	err = -EINVAL;
 	if (cd->cache_parse)
 		err = cd->cache_parse(cd, tmp, count);
 
 out:
 	kfree(tmp);
-	return err ? err : count;
+out2:
+	if (!err)
+		err = count;
+	dprintk("%s: returning %d\n", __func__, err);
+	return err;
 }
 
 static unsigned int
@@ -776,6 +837,9 @@ cache_poll(struct file *filp, poll_table
 	unsigned int mask = 0;
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
 
+	dprintk("%s: cache %s pid %d(%s) polling on filp %p\n",
+		__func__, cd->name, task_pid_nr(current), current->comm, filp);
+
 	poll_wait(filp, &cd->queue_wait, wait);
 
 	if (filp->f_mode & FMODE_WRITE)
@@ -799,6 +863,9 @@ cache_ioctl(struct inode *ino, struct fi
 	struct cache_request *rq;
 	struct cache_detail *cd = PDE(ino)->data;
 
+	dprintk("%s: cache %s, cmd=%u\n",
+		__func__, cd->name, cmd);
+
 	if (cmd != FIONREAD)
 		return -EINVAL;
 	if (!(filp->f_mode & FMODE_READ))
@@ -811,6 +878,8 @@ cache_ioctl(struct inode *ino, struct fi
 	if (!list_empty(&cd->to_read)) {
 		rq = container_of(cd->to_read.next, struct cache_request, list);
 		len = rq->len;
+		dprintk("%s: cache %s, request %p is length %d\n",
+			__func__, cd->name, rq, rq->len);
 	}
 
 	spin_unlock(&cd->queue_lock);
@@ -870,6 +939,9 @@ static void cache_remove_queued(struct c
 {
 	struct cache_request *rq;
 
+	dprintk("%s: trying to remove entry %p\n",
+		__func__, h);
+
 	/* find and de-queue */
 	spin_lock(&cd->queue_lock);
 
@@ -882,8 +954,11 @@ static void cache_remove_queued(struct c
 	spin_unlock(&cd->queue_lock);
 
 	/* if found, destroy */
-	if (rq)
+	if (rq) {
+		dprintk("%s: dropping reference on entry %p\n",
+			__func__, h);
 		cache_request_put(rq, cd);
+	}
 }
 
 /*
@@ -992,6 +1067,9 @@ static int cache_make_upcall(struct cach
 	if (!rq)
 		return -EAGAIN;
 
+	dprintk("%s: entry %p, request %p\n",
+		__func__, h, rq);
+
 	bp = rq->buf;
 	len = rq->len;
 	cd->cache_request(cd, h, &bp, &len);
@@ -1001,6 +1079,10 @@ static int cache_make_upcall(struct cach
 		return -EAGAIN;
 	}
 	rq->len -= len;
+
+	dprintk("%s: cache %s, entry %p, queueing request %p text \"%.*s\"\n",
+		__func__, cd->name, h, rq, rq->len, rq->buf);
+
 	spin_lock(&cd->queue_lock);
 	list_add_tail(&rq->list, &cd->to_read);
 	spin_unlock(&cd->queue_lock);

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
