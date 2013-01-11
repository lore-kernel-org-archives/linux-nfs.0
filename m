Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49701 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753938Ab3AKRUR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jan 2013 12:20:17 -0500
Date: Fri, 11 Jan 2013 12:20:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [Devel] [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
Message-ID: <20130111172015.GG17909@fieldses.org>
References: <20121206153447.30693.54128.stgit@localhost.localdomain>
 <20121210202842.GB17350@fieldses.org>
 <50C73C60.8060405@parallels.com>
 <50C73F58.1080005@parallels.com>
 <20121211145621.GA3336@fieldses.org>
 <50C74C14.8030807@parallels.com>
 <20121211152036.GB3336@fieldses.org>
 <20121211153527.GC3336@fieldses.org>
 <50F0283A.6040509@parallels.com>
 <20130111170312.GF17909@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130111170312.GF17909@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 11, 2013 at 12:03:12PM -0500, J. Bruce Fields wrote:
> On Fri, Jan 11, 2013 at 06:56:58PM +0400, Stanislav Kinsbursky wrote:
> > 11.12.2012 19:35, J. Bruce Fields пишет:
> > >On Tue, Dec 11, 2012 at 10:20:36AM -0500, J. Bruce Fields wrote:
> > >>On Tue, Dec 11, 2012 at 07:07:00PM +0400, Stanislav Kinsbursky wrote:
> > >>>I don't really understand, how  mountd's root can be wrong. I.e.
> > >>>its' always right as I see it. NFSd kthreads have to swap/use
> > >>>relative path/whatever to communicate with proper mountd.
> > >>>Or I'm missing something?
> > >>
> > >>Ugh, I see the problem: I thought svc_export_request was called at the
> > >>time mountd does the read, but instead its done at the time nfsd does
> > >>the upcall.
> > >>
> > >>I suspect that's wrong, and we really want this done in the context of
> > >>the mountd process when it does the read call.  If d_path is called
> > >>there then we have no problem.
> > >
> > >Right, so I'd be happier if we could modify sunrpc_cache_pipe_upcall to
> > >skip calling cache_request and instead delay that until cache_read().  I
> > >think that should be possible.
> > >
> > 
> > So, Bruce, what we going to do (or what you want me to do) with the rest of NFSd changes?
> > I.e. how I should solve this d_path() problem?
> > I.e. I don't understand what did you mean by "I'd be happier if we could modify sunrpc_cache_pipe_upcall to
> > skip calling cache_request and instead delay that until cache_read()".
> > Could you give me a hint?
> 
> Definitely.  So normally the way these upcalls happen are:
> 
> 	1. the kernel does a cache lookup, finds no matching item, and
> 	   calls sunrpc_cache_pipe_upcall().
> 	2. sunrpc_cache_pipe_upcall() formats the upcall: it allocates a
> 	   struct cache_request crq and fills crq->buf with the upcall
> 	   data by calling the cache's ->cache_request() method.
> 	3. Then rpc.mountd realizes there's data available in
> 	   /proc/net/rpc/nfsd.fh/content, so it does a read on that file.
> 	4. cache_read copies the formatted upcall from crq->buf to
> 	   to userspace.
> 
> So all I'm suggesting is that instead of calling ->cache_request() at
> step 2, we do it at step 4.
> 
> Then cache_request will be called from rpc.mountd's read.  So we'll know
> which container rpc.mountd is in.
> 
> Does that make sense?

The following is untested, ugly, and almost certainly insufficient and
wrong, but maybe it's a starting point:

--b.

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9f84703..f15e4c1 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -744,6 +744,7 @@ struct cache_request {
 	char			* buf;
 	int			len;
 	int			readers;
+	void (*cache_request)(struct cache_detail *, struct cache_head *, char **, int *);
 };
 struct cache_reader {
 	struct cache_queue	q;
@@ -785,10 +786,19 @@ static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
 	spin_unlock(&queue_lock);
 
 	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
+		char *bp;
+		int len = PAGE_SIZE;
+
 		err = -EAGAIN;
 		spin_lock(&queue_lock);
 		list_move(&rp->q.list, &rq->q.list);
 		spin_unlock(&queue_lock);
+
+		bp = rq->buf;
+		rq->cache_request(cd, rq->item, &bp, &len);
+		if (rq->len < 0)
+			goto out;
+		rq->len = PAGE_SIZE - len;
 	} else {
 		if (rp->offset + count > rq->len)
 			count = rq->len - rp->offset;
@@ -1149,8 +1159,6 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 
 	char *buf;
 	struct cache_request *crq;
-	char *bp;
-	int len;
 
 	if (!cache_listeners_exist(detail)) {
 		warn_no_listener(detail);
@@ -1167,19 +1175,10 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 		return -EAGAIN;
 	}
 
-	bp = buf; len = PAGE_SIZE;
-
-	cache_request(detail, h, &bp, &len);
-
-	if (len < 0) {
-		kfree(buf);
-		kfree(crq);
-		return -EAGAIN;
-	}
+	crq->cache_request = cache_request;
 	crq->q.reader = 0;
 	crq->item = cache_get(h);
 	crq->buf = buf;
-	crq->len = PAGE_SIZE - len;
 	crq->readers = 0;
 	spin_lock(&queue_lock);
 	list_add_tail(&crq->q.list, &detail->queue);
