From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 10 - Remove check on number of threads waiting on user-space.
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004Bc-Sz@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-00072e-S5
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-0002W4-2T
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
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


Currently we are counting the number of threads already asleep and returning an
immediate NFS4ERR_DELAY (==JUKEBOX) error if more than half are already asleep.

This patch removes that logic, so instead we only return NFS4ERR_DELAY if an
upcall times out (if it takes more than a second to return).

With the thread counting there is the risk that even when all the relevant
subsystems are responsive, the client may still see occasional NFS4ERR_DELAY
returns just because, by coincidence, several upcalls were initiated at the
same time.  I expect clients will delay several seconds before retrying after
NFS4ERR_DELAY, so this will be quite noticeable to users.  Sporadic long delays
like this are likely to lead users to suspect a problem somewhere, when in fact
there is none.

The current scheme ensures that we can still process requests not depending on
upcalls, even when all threads would otherwise be tied up waiting on upcalls.
However, this is not something that should happen under normal circumstances;
if a server spends a significant portion of its time with all threads waiting
for upcalls, this a sign that something is seriously wrong.

In such a circumstance (e.g., an ldap server dies), we can, at least, bound the
waiting time to a second without the need for counting threads.

In short, removing the thread-counting will allow us to behave predictably when
things are working, while still allowing some progress when they don't.

It would be a worthwhile project to measure the amount of time threads spend
waiting for upcalls (or for reads, for that matter); if a significant portion
of the time they spend handling requests is spent sleeping, then there's an
opportunity to improve nfsd performance: if we can break the one-to-one mapping
between requests and threads, then we can lower the number of threads required
to keep the nfs server busy.

However, both the currently available options for doing this are problematic:
returning JUKEBOX/DELAY errors at random times will lead to unpredictable
performance, and saving a copy of the request to be processed from scratch
again later is wasteful and makes it difficult to provide correct semantics,
especially in the NFSv4 case.

So for now I believe waits with short timeouts are the best option.


From: "J. Bruce Fields" <bfields@fieldses.org>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4idmap.c |   27 ++-------------------------
 1 files changed, 2 insertions(+), 25 deletions(-)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-05-18 11:18:30.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2004-05-18 11:18:55.000000000 +1000
@@ -454,30 +454,6 @@ do_idmap_lookup(struct ent *(*lookup_fn)
 	return cache_check(detail, &(*item)->h, &mdr->req);
 }
 
-static int threads_waiting = 0;
-
-static inline int
-idmap_lookup_wait(struct idmap_defer_req *mdr, struct svc_rqst *rqstp,
-		struct ent *item))
-{
-	DEFINE_WAIT(wait);
-
-	prepare_to_wait(&mdr->waitq, &wait, TASK_INTERRUPTIBLE);
-	/* XXX: Does it matter that threads_waiting isn't per-server? */
-	/* Note: BKL prevents races with nfsd_svc and other lookups */
-	lock_kernel();
-	if (!test_bit(CACHE_VALID, &item->h.flags)) {
-		if (2 * threads_waiting > rqstp->rq_server->sv_nrthreads)
-			goto out;
-		threads_waiting++;
-		schedule_timeout(1 * HZ);
-		threads_waiting--;
-	}
-out:
-	unlock_kernel();
-	finish_wait(&mdr->waitq, &wait);
-}
-
 static inline int
 do_idmap_lookup_nowait(struct ent *(*lookup_fn)(struct ent *, int),
 			struct ent *key, struct cache_detail *detail,
@@ -521,7 +497,8 @@ idmap_lookup(struct svc_rqst *rqstp,
 	mdr->req.defer = idmap_defer;
 	ret = do_idmap_lookup(lookup_fn, key, detail, item, mdr);
 	if (ret == -EAGAIN) {
-		idmap_wait(mdr, rqstp, *item);
+		wait_event_interruptible_timeout(mdr->waitq,
+			test_bit(CACHE_VALID, &(*item)->h.flags), 1 * HZ);
 		ret = do_idmap_lookup_nowait(lookup_fn, key, detail, item);
 	}
 	put_mdr(mdr);


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
