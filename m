From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 1 of 10 - idmap bugfixes and cleanup
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001Qe-9u@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCE-0007hD-8r
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:10 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCD-00021a-Ke
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:09 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:05 +1000
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


From: "J. Bruce Fields" <bfields@fieldses.org>

Fix race conditions and leaks on error; split up code a bit to make it
easier to verify correctness.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4idmap.c |  100 ++++++++++++++++++++++++++++++++------------------
 1 files changed, 65 insertions(+), 35 deletions(-)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-04-06 10:57:05.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2004-04-08 10:50:09.000000000 +1000
@@ -412,8 +412,12 @@ struct idmap_defer_req {
 static void
 put_mdr(struct idmap_defer_req *mdr)
 {
+	wait_queue_head_t	*waitq = &mdr->waitq;
+
 	if (atomic_dec_and_test(&mdr->count))
 		kfree(mdr);
+	else
+		wake_up(waitq);
 }
 
 static void
@@ -422,7 +426,6 @@ idmap_revisit(struct cache_deferred_req 
 	struct idmap_defer_req *mdr =
 		container_of(dreq, struct idmap_defer_req, deferred_req);
 
-	wake_up(&mdr->waitq);
 	put_mdr(mdr);
 }
 
@@ -438,65 +441,92 @@ idmap_defer(struct cache_req *req)
 
 static int threads_waiting = 0;
 
-static inline int
-idmap_lookup_wait(struct idmap_defer_req *mdr, wait_queue_t waitq, struct
-		svc_rqst *rqstp) {
-	int ret = -ETIMEDOUT;
+static inline void
+idmap_wait(struct idmap_defer_req *mdr, struct svc_rqst *rqstp) {
 
-	set_task_state(current, TASK_INTERRUPTIBLE);
+	/* Note: BKL prevents races with nfsd_svc and other lookups */
 	lock_kernel();
 	/* XXX: Does it matter that threads_waiting isn't per-server? */
-	/* Note: BKL prevents races with nfsd_svc and other lookups */
 	if (2 * threads_waiting > rqstp->rq_server->sv_nrthreads)
 		goto out;
 	threads_waiting++;
 	schedule_timeout(10 * HZ);
 	threads_waiting--;
-	ret = 0;
 out:
 	unlock_kernel();
-	remove_wait_queue(&mdr->waitq, &waitq);
-	set_task_state(current, TASK_RUNNING);
 	put_mdr(mdr);
+}
+
+static inline int
+do_idmap_lookup(struct ent *(*lookup_fn)(struct ent *, int), struct ent *key,
+		struct cache_detail *detail, struct ent **item,
+		struct idmap_defer_req *mdr)
+{
+	*item = lookup_fn(key, 0);
+	if (!*item)
+		return -ENOMEM;
+	return cache_check(detail, &(*item)->h, &mdr->req);
+}
+
+static inline int
+do_idmap_lookup_nowait(struct ent *(*lookup_fn)(struct ent *, int),
+			struct ent *key, struct cache_detail *detail,
+			struct ent **item)
+{
+	int ret = -ENOMEM;
+
+	*item = lookup_fn(key, 0);
+	if (!*item)
+		goto out_err;
+	ret = -ETIMEDOUT;
+	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
+			|| (*item)->h.expiry_time < get_seconds()
+			|| detail->flush_time > (*item)->h.last_refresh)
+		goto out_put;
+	ret = -ENOENT;
+	if (test_bit(CACHE_NEGATIVE, &(*item)->h.flags))
+		goto out_put;
+	return 0;
+out_put:
+	ent_put(&(*item)->h, detail);
+out_err:
+	*item = NULL;
 	return ret;
 }
 
+static inline void
+init_mdr(struct idmap_defer_req *mdr, wait_queue_t *waitq)
+{
+
+	memset(mdr, 0, sizeof(*mdr));
+	init_waitqueue_head(&mdr->waitq);
+	add_wait_queue(&mdr->waitq, waitq);
+	atomic_set(&mdr->count, 2);
+	mdr->req.defer = idmap_defer;
+}
+
 static int
 idmap_lookup(struct svc_rqst *rqstp,
 		struct ent *(*lookup_fn)(struct ent *, int), struct ent *key,
 		struct cache_detail *detail, struct ent **item)
 {
-	struct idmap_defer_req *mdr;
 	DECLARE_WAITQUEUE(waitq, current);
+	struct idmap_defer_req *mdr;
 	int ret;
 
-	*item = lookup_fn(key, 0);
-	if (!*item)
-		return -ENOMEM;
 	mdr = kmalloc(sizeof(*mdr), GFP_KERNEL);
-	memset(mdr, 0, sizeof(*mdr));
-	init_waitqueue_head(&mdr->waitq);
-	add_wait_queue(&mdr->waitq, &waitq);
-	atomic_set(&mdr->count, 2);
-	mdr->req.defer = idmap_defer;
-	ret = cache_check(detail, &(*item)->h, &mdr->req);
+	if (!mdr)
+		return -ENOMEM;
+	init_mdr(mdr, &waitq);
+	set_task_state(current, TASK_INTERRUPTIBLE);
+	ret = do_idmap_lookup(lookup_fn, key, detail, item, mdr);
 	if (ret == -EAGAIN) {
-		ret = idmap_lookup_wait(mdr, waitq, rqstp);
-		if (ret)
-			goto out;
-		/* Try again, but don't wait. */
-		*item = lookup_fn(key, 0);
-		ret = -ENOMEM;
-		if (!*item)
-			goto out;
-		ret = -ETIMEDOUT;
-		if (!test_bit(CACHE_VALID, &(*item)->h.flags)) {
-			ent_put(&(*item)->h, detail);
-			goto out;
-		}
-		ret = cache_check(detail, &(*item)->h, NULL);
+		idmap_wait(mdr, rqstp);
+		ret = do_idmap_lookup_nowait(lookup_fn, key, detail, item);
+	} else {
+		put_mdr(mdr);
+		put_mdr(mdr);
 	}
-out:
 	return ret;
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
