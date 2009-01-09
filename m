From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Fri, 9 Jan 2009 16:29:21 -0500
Message-ID: <20090109212921.GC5466@fieldses.org>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44982 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757499AbZAIV3X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2009 16:29:23 -0500
In-Reply-To: <4966B92F.8060008-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2009 at 01:40:47PM +1100, Greg Banks wrote:
> J. Bruce Fields wrote:
> >   Appended below if it's of
> > any use to you to compare.  (Happy to apply either your patch or mine
> > depending which looks better; I haven't tried to compare carefully.)
> >   
> 
> Ok, I'll take a look at yours.

Thanks for doing this, by the way.

> >  static ssize_t
> >  cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
> >  {
> > -	struct cache_reader *rp = filp->private_data;
> > -	struct cache_request *rq;
> > +	struct cache_request *rq = filp->private_data;
> >  	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
> > +	struct list_head *queue = &cd->queue;
> >  	int err;
> >  
> >  	if (count == 0)
> > @@ -711,60 +703,45 @@ cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
> >  	mutex_lock(&queue_io_mutex); /* protect against multiple concurrent
> >  			      * readers on this file */
> >   
> 
> Ah, so you still have a single global lock which is serialising all
> reads and writes to all caches.

Yes, making this per-cd seems sensible (though if the problem is
typically a single cache (auth_unix) then I don't know how significant a
help it is).

> Also, I think you'd want to sample filp->private_data after taking
> queue_io_mutex.

Whoops, yes.

> > +	if (rq == NULL) {
> >  		mutex_unlock(&queue_io_mutex);
> > -		BUG_ON(rp->offset);
> >   
> 
> Good riddance to that BUG_ON().
> > -		return 0;
> > +		return -EAGAIN;
> >  	}
> > -	rq = container_of(rp->q.list.next, struct cache_request, q.list);
> > -	BUG_ON(rq->q.reader);
> > -	if (rp->offset == 0)
> > -		rq->readers++;
> > -	spin_unlock(&queue_lock);
> >  
> > -	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
> > +	if (!test_bit(CACHE_PENDING, &rq->item->flags))
> >  		err = -EAGAIN;
> > -		spin_lock(&queue_lock);
> > -		list_move(&rp->q.list, &rq->q.list);
> > -		spin_unlock(&queue_lock);
> > -	} else {
> > -		if (rp->offset + count > rq->len)
> > -			count = rq->len - rp->offset;
> > +	else {
> > +		if (rq->offset + count > rq->len)
> > +			count = rq->len - rq->offset;
> >  		err = -EFAULT;
> > -		if (copy_to_user(buf, rq->buf + rp->offset, count))
> > +		if (copy_to_user(buf, rq->buf + rq->offset, count))
> >  			goto out;
> >   
> 
> Ok, so you try to keep partial read support but move the offset into the
> upcall request itself.  Interesting idea.
> 
> I think partial reads are Just Too Hard to do properly, i.e. without
> risk of racy message corruption under all combinations of message size
> and userspace behaviour .  In particular I think your code will corrupt
> upcall data if multiple userspace threads race to do partial reads on
> the same struct file (as rpc.mountd is doing at SGI's customer sites).

Yes, but what mountd's doing is just dumb, as far as I can tell; is
there any real reason not to just keep a separate open for each thread?

If we just tell userland to keep a number of opens equal to the number
of concurrent upcalls it wants to handle, and then all of this becomes
very easy.

Forget sharing a single struct file between tasks that do too-small
reads: we should make sure that we don't oops, but that's all.

> For the same reasons I think the FIONREAD support is utterly pointless
> (even though I preserved it).
> 
> But I still don't understand how this 100K message size number for gssd
> can happen?  If that's really necessary then the design equation changes
> considerably.  This seems to be the most significant difference between
> our patches.

So, the somewhat depressing situation with spkm3, which was to be the
public-key-based gss mechanism for nfs: we (citi) implemented it (modulo
this problem and maybe one or two others), but found some problems along
the way that required revising the spec.  I think there might have been
an implementation for one other platform too.  But the ietf seems to
have given up on spkm3, and instead is likely to pursue a new mechanism,
pku2u.  Nobody's implementing that yet.  Consulting my local expert, it
sounds like pku2u will have some more reasonable bound on init-sec-ctx
token sizes.  (Not sure if it'll be under a page, without checking, but
it shouldn't be much more than that, anyway).

So: the immediate pressure for larger upcalls is probably gone.  And
anyway more changes would be required (the ascii-hex encoding and
upcall-downcall matching are very wasteful in this case, etc.), so we'd
likely end up using a different mechanism.

That said, I think it's easy enough to handle just the case of multiple
reads on unshared struct files that it might make sense to keep that
piece.

> A smaller issue is that you keep a single list and use the value of the
> CACHE_PENDING bit to tell the difference between states.  I think this
> could be made to work; however my technique of using two lists makes
> most of the code even simpler at the small cost of having to do two list
> searches in queue_loose().

OK.  When exactly do they get moved between lists?  I'll take a look at
the code.

--b.
