From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 10 - Fix race conditions in idmapper
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004BN-QV@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSR-00073J-1u
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:51 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSQ-00030Q-EX
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:50 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:40 +1000
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


Also fix leaks on error; split up code a bit to make it
easier to verify correctness.

From: "J. Bruce Fields" <bfields@fieldses.org>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4idmap.c |  102 +++++++++++++++++++++++++++++++-------------------
 1 files changed, 65 insertions(+), 37 deletions(-)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2004-05-18 11:17:53.000000000 +1000
@@ -409,13 +409,19 @@ struct idmap_defer_req {
        atomic_t			count;
 };
 
-static void
+static inline void
 put_mdr(struct idmap_defer_req *mdr)
 {
 	if (atomic_dec_and_test(&mdr->count))
 		kfree(mdr);
 }
 
+static inline void
+get_mdr(struct idmap_defer_req *mdr)
+{
+	atomic_inc(&mdr->count);
+}
+
 static void
 idmap_revisit(struct cache_deferred_req *dreq, int toomany)
 {
@@ -433,31 +439,68 @@ idmap_defer(struct cache_req *req)
 		container_of(req, struct idmap_defer_req, req);
 
 	mdr->deferred_req.revisit = idmap_revisit;
+	get_mdr(mdr);
 	return (&mdr->deferred_req);
 }
 
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
 static int threads_waiting = 0;
 
 static inline int
-idmap_lookup_wait(struct idmap_defer_req *mdr, wait_queue_t waitq, struct
-		svc_rqst *rqstp) {
-	int ret = -ETIMEDOUT;
+idmap_lookup_wait(struct idmap_defer_req *mdr, struct svc_rqst *rqstp,
+		struct ent *item))
+{
+	DEFINE_WAIT(wait);
 
-	set_task_state(current, TASK_INTERRUPTIBLE);
-	lock_kernel();
+	prepare_to_wait(&mdr->waitq, &wait, TASK_INTERRUPTIBLE);
 	/* XXX: Does it matter that threads_waiting isn't per-server? */
 	/* Note: BKL prevents races with nfsd_svc and other lookups */
-	if (2 * threads_waiting > rqstp->rq_server->sv_nrthreads)
-		goto out;
-	threads_waiting++;
-	schedule_timeout(10 * HZ);
-	threads_waiting--;
-	ret = 0;
+	lock_kernel();
+	if (!test_bit(CACHE_VALID, &item->h.flags)) {
+		if (2 * threads_waiting > rqstp->rq_server->sv_nrthreads)
+			goto out;
+		threads_waiting++;
+		schedule_timeout(10 * HZ);
+		threads_waiting--;
+	}
 out:
 	unlock_kernel();
-	remove_wait_queue(&mdr->waitq, &waitq);
-	set_task_state(current, TASK_RUNNING);
-	put_mdr(mdr);
+	finish_wait(&mdr->waitq, &wait);
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
 
@@ -467,36 +510,21 @@ idmap_lookup(struct svc_rqst *rqstp,
 		struct cache_detail *detail, struct ent **item)
 {
 	struct idmap_defer_req *mdr;
-	DECLARE_WAITQUEUE(waitq, current);
 	int ret;
 
-	*item = lookup_fn(key, 0);
-	if (!*item)
-		return -ENOMEM;
 	mdr = kmalloc(sizeof(*mdr), GFP_KERNEL);
+	if (!mdr)
+		return -ENOMEM;
 	memset(mdr, 0, sizeof(*mdr));
+	atomic_set(&mdr->count, 1);
 	init_waitqueue_head(&mdr->waitq);
-	add_wait_queue(&mdr->waitq, &waitq);
-	atomic_set(&mdr->count, 2);
 	mdr->req.defer = idmap_defer;
-	ret = cache_check(detail, &(*item)->h, &mdr->req);
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
+		idmap_wait(mdr, rqstp, *item);
+		ret = do_idmap_lookup_nowait(lookup_fn, key, detail, item);
 	}
-out:
+	put_mdr(mdr);
 	return ret;
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
