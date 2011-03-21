Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37922 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288Ab1CUWSJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2011 18:18:09 -0400
Date: Tue, 22 Mar 2011 09:17:57 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
Message-ID: <20110322091757.7bf56d80@notabene.brown>
In-Reply-To: <1300741320.13307.50.camel@lade.trondhjem.org>
References: <20110216171555.6642c630@notabene.brown>
	<1300405987.4621.10.camel@lade.trondhjem.org>
	<20110318120417.435551da@notabene.brown>
	<1300412966.9671.9.camel@lade.trondhjem.org>
	<20110318131214.0e2c840a@notabene.brown>
	<1300415108.13476.6.camel@lade.trondhjem.org>
	<20110318145232.7bbb4216@notabene.brown>
	<1300741320.13307.50.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 21 Mar 2011 17:02:00 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> On Fri, 2011-03-18 at 14:52 +1100, NeilBrown wrote:
> > On Thu, 17 Mar 2011 22:25:08 -0400 Trond Myklebust
> > <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Fri, 2011-03-18 at 13:12 +1100, NeilBrown wrote:
> > > > On Thu, 17 Mar 2011 21:49:26 -0400 Trond Myklebust
> > > > <Trond.Myklebust@netapp.com> wrote:
> > > > 
> > > > > However we could adopt the Solaris convention of always starting
> > > > > writebacks with a FILE_SYNC, and then falling back to UNSTABLE for the
> > > > > second rpc call and all subsequent calls...
> > > > > 
> > > > 
> > > > That approach certainly has merit.
> > > > 
> > > > However, as we know from the wbc info whether the write is small and sync -
> > > > which is the only case where I think a STABLE write is needed - I cannot see
> > > > why you don't want to just use that information to guide the choice of
> > > > 'stable' or not ???
> > > 
> > > By far the most common case we would want to optimise for is the sync at
> > > close() or fsync() when you have written a small file (<= wsize). If we
> > > can't optimise for that case, then the optimisation isn't worth doing at
> > > all.
> > 
> > Fair point.  I hadn't thought of that.
> > 
> > > 
> > > The point is that in that particular case, the wbc doesn't help you at
> > > all since the limits are set at 0 and LLONG_MAX (see nfs_wb_all(),
> > > write_inode_now(),...)
> > > 
> > 
> > I would be trivial to use min(wbc->range_end, i_size_read(inode)) as the
> > upper bound when assessing the size of the range to compare with 'wsize'.
> > 
> > However that wouldn't address the case of a small append to a large file
> > which would also be good to optimise.
> > 
> > If you can detect the 'first' RPC reliably at the same time that you still
> > have access to the wbc information, then:
> > 
> >  if this is the first request in a writeback, and the difference beween
> >   the address of this page, and min(wbc->range_end, i_size_read(inode))
> >   is less than wsize, then make it a STABLE write
> > 
> > might be a heuristic that catches most interesting cases.
> > It might be a bit complex though.
> > 
> > I think we should in general err on the size of not using a STABLE write
> > when it might be useful rather than using a STABLE write when it is not
> > necessary as, while there a costs each way, I think the cost of incorrectly
> > using STABLE would be higher.
> 
> How about something like the following (as of yet untested) patch?

Looks good.

I tried it out and it works as expected on large writes (uses UNSTABLE),
O_SYNC writes (uses FILE_SYNC) and small writes (uses FILE_SYNC).
All these were simple open/write/close.  I didn't watch what happens if we
wait for writeback, but I don't expect it to be any different.

I must admit that I found the terminology a bit confusing for 
FLUSH_COND_STABLE.
What is means is "if this turns out to be part of a larger request, then clear
FLUSH_STABLE" - which sounds a bit more like "FLUSH_COND_UNSTABLE" - i.e. if
a condition is met, then make it unstable.
But I don't think that change would help at all.

How about changing the test in nfs_write_rpcsetup to
	if (how & (FLUSH_STABLE|FLUSH_CONDSTABLE)) {
		data->args.stable = NFS_DATA_SYNC;
		if (!nfs_need_commit(NFS_I(inode)))
			data->args.stable = NFS_FILE_SYNC;
	}

and then just set either FLUSH_STABLE or FLUSH_COND_STABLE - never both -
and when you test FLUSH_COND_STABLE and then some other condition, just
clear FLUSH_COND_STABLE.

I would find that quite a bit more readable.

i.e. the following - in which I also enhanced a comment slightly.

Thanks,
NeilBrown

commit 8283f834711942d808a5a9056893c46f59ad4770
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Mar 21 17:02:00 2011 -0400

    NFS: Use stable writes when not doing a bulk flush
    
    If we're only doing a single write, and there are no other unstable
    writes being queued up, we might want to just flip to using a stable
    write RPC call.
    
    Reviewed-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 23e7944..fd85618 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -223,6 +223,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_count = 0;
 	desc->pg_bsize = bsize;
 	desc->pg_base = 0;
+	desc->pg_moreio = 0;
 	desc->pg_inode = inode;
 	desc->pg_doio = doio;
 	desc->pg_ioflags = io_flags;
@@ -335,9 +336,11 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			   struct nfs_page *req)
 {
 	while (!nfs_pageio_do_add_request(desc, req)) {
+		desc->pg_moreio = 1;
 		nfs_pageio_doio(desc);
 		if (desc->pg_error < 0)
 			return 0;
+		desc->pg_moreio = 0;
 	}
 	return 1;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 47a3ad6..4d686ee 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -179,8 +179,8 @@ static int wb_priority(struct writeback_control *wbc)
 	if (wbc->for_reclaim)
 		return FLUSH_HIGHPRI | FLUSH_STABLE;
 	if (wbc->for_kupdate || wbc->for_background)
-		return FLUSH_LOWPRI;
-	return 0;
+		return FLUSH_LOWPRI | FLUSH_COND_STABLE;
+	return FLUSH_COND_STABLE;
 }
 
 /*
@@ -863,7 +863,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->args.context = get_nfs_open_context(req->wb_context);
 	data->args.lock_context = req->wb_lock_context;
 	data->args.stable  = NFS_UNSTABLE;
-	if (how & FLUSH_STABLE) {
+	if (how & (FLUSH_STABLE | FLUSH_COND_STABLE)) {
 		data->args.stable = NFS_DATA_SYNC;
 		if (!nfs_need_commit(NFS_I(inode)))
 			data->args.stable = NFS_FILE_SYNC;
@@ -912,6 +912,12 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 
 	nfs_list_remove_request(req);
 
+	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
+	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit ||
+	     desc->pg_count > wsize))
+		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
+
+
 	nbytes = desc->pg_count;
 	do {
 		size_t len = min(nbytes, wsize);
@@ -1002,6 +1008,10 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 	if ((!lseg) && list_is_singular(&data->pages))
 		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
 
+	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
+	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
+		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
+
 	/* Set up the argument struct */
 	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, desc->pg_count, 0, lseg, desc->pg_ioflags);
 out:
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f88522b..cb2add4 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -33,6 +33,8 @@
 #define FLUSH_STABLE		4	/* commit to stable storage */
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
+#define FLUSH_COND_STABLE	32	/* conditional stable write - only stable
+					 * if everything fits in one RPC */
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 90907ad..92d54c8 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -57,6 +57,7 @@ struct nfs_pageio_descriptor {
 	size_t			pg_count;
 	size_t			pg_bsize;
 	unsigned int		pg_base;
+	char			pg_moreio;
 
 	struct inode		*pg_inode;
 	int			(*pg_doio)(struct nfs_pageio_descriptor *);

