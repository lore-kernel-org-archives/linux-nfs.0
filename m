Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47217 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757394Ab0JZALv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 20:11:51 -0400
Date: Mon, 25 Oct 2010 20:11:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Message-ID: <20101026001145.GG13523@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
 <1287969693-12340-1-git-send-email-bfields@redhat.com>
 <20101025124357.63b966bb@notabene>
 <20101025202155.GD13523@fieldses.org>
 <20101026095836.61bf6a38@notabene>
 <20101025230331.GF13523@fieldses.org>
 <20101026105447.264b690e@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101026105447.264b690e@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 10:54:47AM +1100, Neil Brown wrote:
> On Mon, 25 Oct 2010 19:03:35 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Oct 26, 2010 at 09:58:36AM +1100, Neil Brown wrote:
> > > On Mon, 25 Oct 2010 16:21:56 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Mon, Oct 25, 2010 at 12:43:57PM +1100, Neil Brown wrote:
> > > > > On Sun, 24 Oct 2010 21:21:30 -0400
> > > > > "J. Bruce Fields" <bfields@redhat.com> wrote:
> > > > > 
> > > > > > Once an xprt has been deleted, there's no reason to allow it to be
> > > > > > enqueued--at worst, that might cause the xprt to be re-added to some
> > > > > > global list, resulting in later corruption.
> > > > > > 
> > > > > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > > > 
> > > > > Yep, this makes svc_close_xprt() behave the same way as svc_recv() which
> > > > > calls svc_delete_xprt but does not clear XPT_BUSY.  The other branches in
> > > > > svc_recv call svc_xprt_received, but the XPT_CLOSE branch doesn't
> > > > > 
> > > > > Reviewed-by: NeilBrown <neilb@suse.de>
> > > > 
> > > > Also, of course:
> > > > 
> > > > > >  	svc_xprt_get(xprt);
> > > > > >  	svc_delete_xprt(xprt);
> > > > > > -	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> > > > > >  	svc_xprt_put(xprt);
> > > > 
> > > > The get/put is pointless: the only reason I can see for doing that of
> > > > course was to be able to safely clear the bit afterwards.
> > > >
> > > 
> > > Agreed.
> > > 
> > > I like patches that get rid of code!!
> > 
> > Unfortunately, I'm stuck on just one more point: is svc_close_all()
> > really safe?  It assumes it doesn't need any locking to speak of any
> > more because the server threads are gone--but the xprt's themselves
> > could still be producing events, right?  (So data could be arriving that
> > results in calls to svc_xprt_enqueue, for example?)
> > 
> > If that's right, I'm not sure what to do there....
> > 
> > --b.
> 
> Yes, svc_close_all is racy w.r.t. svc_xprt_enqueue.
> I guess we've never lost that race?
> 
> The race happens if the test_and_set(XPT_BUSY) in svc_xprt_enqueue happens
> before the test_bit(XPT_BUSY) in svc_close_all, but the list_add_tail at the
> end of svc_xprt_enqueue happens before (or during!) the list_del_init in
> svc_close_all.
> 
> We cannot really lock against this race as svc_xprt_enqueue holds the pool
> lock, and svc_close_all doesn't know which pool to lock (as xprt->pool isn't
> set until after XPT_BUSY is set).
> 
> Maybe we just need to lock all pools in that case??
> 
> So svc_close_all becomes something like:
> 
> 
> void svc_close_all(struct list_head *xprt_list)
> {
> 	struct svc_xprt *xprt;
> 	struct svc_xprt *tmp;
> 	struct svc_pool *pool;
> 
> 	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
> 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
> 		if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
> 			/* Waiting to be processed, but no threads left,
> 			 * So just remove it from the waiting list.  First
> 			 * we need to ensure svc_xprt_enqueue isn't still
> 			 * queuing the xprt to some pool.
> 			 */
> 			for_each_pool(pool, xprt->xpt_server) {
> 				spin_lock(&pool->sp_lock);
> 				spin_unlock(&pool->sp_lock);
> 			}
> 			list_del_init(&xprt->xpt_ready);
> 		}
> 		svc_delete_xprt(xprt);
> 	}
> }
> 
> 
> Note that once we always set XPT_BUSY and it stays set.  So we call
> svc_delete_xprt instread of svc_close_xprt.
> 
> Maybe we don't actually need to list_del_init - both the pool and the xprt
> will soon be freed and if there is linkage between them, who cares??
> In that case we wouldn't need to for_each_pool after all ???

Yeah, that's what I'm thinking now: if svc_xprt_enqueue is the only
thing that could still be running, then at worst it adds the xprt back
to sp_sockets or something, which we'll delete soon.

And yes I think we can just remove svc_close_all()'s attempts to handle
the situation--if its list_del_init(&xprt->xpt_ready) executes
simultaneously with svc_xprt_enqueue()'s list_add_tail()--well, maybe we
don't care what the results are, but if nothing else we could end up
with a spurious lists corruption warning.

So, delete more code, I think....

--b.
