Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40422 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932812Ab0KPWYy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 17:24:54 -0500
Date: Wed, 17 Nov 2010 09:24:46 +1100
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 0/2] sunrpc: fix two server-side race problems.
Message-ID: <20101117092446.475cd4a6@notabene.brown>
In-Reply-To: <20101116150450.GC23781@fieldses.org>
References: <20101115002634.19121.7027.stgit@notabene.brown>
	<20101116170720.6dc36154@notabene.brown>
	<20101116150450.GC23781@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 16 Nov 2010 10:04:50 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Nov 16, 2010 at 05:07:20PM +1100, Neil Brown wrote:
> > On Mon, 15 Nov 2010 11:27:01 +1100
> > NeilBrown <neilb@suse.de> wrote:
> > 
> > > 
> > > Hi Bruce,
> > >  I found these while trying to diagnose why a customer hit the
> > >  	BUG_ON(xprt->xpt_pool != NULL);
> > >  in svc_xprt_enqueue (in a 2.6.27 based kernel).  I don't think either
> > >  of these actually explain the problem, but they seem to be bugs
> > >  none-the-less.
> > > 
> > 
> > And I think I have now found the bug that caused the BUG_ON.
> 
> Ah-hah!  Cool bug.  (By the way, what made you think it's what this
> customer hit?)

The first two I found while just looking for ways that BUG_ON could have
occurred, and both turned out to be actually impossible in the customers
config.  Once required a different arch and the other required manipulating
open sockets  through the nfsfs interface, which wasn't happening.

This one I found by looking more closely at the crash dump.  The BUG_ON was
in svc_xprt_enqueue called from svc_xprt_received called from svc_recv.  And
it was the svc_xprt_received that is call on a newly accepted socket.  Given
this was a new socket there are going to be limited options for racing with
anything.  And given that I found something that *could* happen in that
limite scenario, I figure it probably did happen.


> 
> > The xprt has been freed and reused for something else so xpt_pool and other
> > things are garbage.
> > 
> > If you could review and apply this patch I would appreciate it.
> 
> Certainly looks sensible to me.
> 
> Do you think that anything we did recently made this more likely?  Or
> have we never seen this before because the window for this race is so
> small?

No, I don't think we changed anything.  This customer seems to be beating on
nfsd very hard - big server and lots of clients - trying to make sure it is
stable.  So they have probably pushed it harder and longer than anyone else.
We need more people doing that!!!


> 
> (I'm just wondering whether to aim for 2.6.38, or for 2.6.37 and stable.
> Though I'm sort of inclined to the latter if it's a crash that someone's
> really hit, even if it's not a regression.)

I would go for 2.6.37 and -stable for purely selfish reasons.
If you put a "Cc: stable@kernel.org" tag on it, then it will automatically
get pulled into the stable trees (with suitable review of course) and then it
will be automatically pulled into the SLES kernel (and probably RHEL too) so
it will get into our update stream without me having to do anything :-)


But I agree there is no rush with the other two.
The one which removes the BUG_ON may not be strictly necessary.  It requires
the CPU to do out-of-order writes, and it was suggested to me that because
the two memory locations are likely to be in the same cache line,
out-of-order writes aren't actually possible.
The other requires explicit closing of connections via the nfsdfs which
hardly ever happens at all, so the chance of a race with it is almost
non-existent.

Thanks,
NeilBrown



> 
> --b.
> 
> > 
> > While exploring I noticed something that I thought was odd.
> > In svc_rdma_transport.c, handle_connect_req calls rdma_create_xprt which will
> > return an xprt with XPT_BUSY set.
> > But I cannot see that XPT_BUSY is ever cleared.
> > There is a comment saying that svc_xprt_received() cannot be called for some
> > reason, but as far as I can see the reason is invalid, and svc_xprt_received
> > is exactly what should be called to clear XPT_BUSY.
> > But I don't really know this code so might be missing something important.
> > 
> > Thanks,
> > NeilBrown
> > 
> > From 0edb33a19f415a783d89839efbdf7c572a797043 Mon Sep 17 00:00:00 2001
> > From: NeilBrown <neilb@suse.de>
> > Date: Tue, 16 Nov 2010 16:55:19 +1100
> > Subject: [PATCH] sunrpc: close another server-size race.
> > 
> > When an xprt is created, it has a refcount of 1, and XPT_BUSY
> > is set.
> > The refcount is *not* owned by the thread that created the xprt
> > (as is clear from the fact that creators never put the reference).
> > Rather, it is owned by the absence of XPT_DEAD.  Once XPT_DEAD is set,
> > (And XPT_BUSY is clear) that initial reference is dropped and the xprt
> > can be freed.
> > 
> > So when a creator clears XPT_BUSY it is dropping its only reference and
> > so must not touch the xprt again.
> > 
> > However svc_recv, after calling ->xpo_accept (and so getting an XPT_BUSY
> > reference on a new xprt), calls svc_xprt_recieved.  This clears
> > XPT_BUSY and then svc_xprt_enqueue - this last without owning a reference.
> > This is dangerous and has been seen to leave svc_xprt_enqueue working
> > with an xprt containing garbage.
> > 
> > So we need to hold an extra counted reference over that call to
> > svc_xprt_received.
> > 
> > For safety, any time we clear XPT_BUSY and then use the xprt again, we
> > first get a reference, and the put it again afterwards.
> > 
> > Note that svc_close_all does not need this extra protection as there are
> > no threads running, and the final free can only be called asynchronously
> > from such a thread.
> > 
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > 
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index ec9d8ef..fa249ca 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -213,6 +213,7 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> >  	spin_lock(&svc_xprt_class_lock);
> >  	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
> >  		struct svc_xprt *newxprt;
> > +		unsigned short newport;
> >  
> >  		if (strcmp(xprt_name, xcl->xcl_name))
> >  			continue;
> > @@ -231,8 +232,9 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
> >  		spin_lock_bh(&serv->sv_lock);
> >  		list_add(&newxprt->xpt_list, &serv->sv_permsocks);
> >  		spin_unlock_bh(&serv->sv_lock);
> > +		newport = svc_xprt_local_port(newxprt);
> >  		clear_bit(XPT_BUSY, &newxprt->xpt_flags);
> > -		return svc_xprt_local_port(newxprt);
> > +		return newport;
> >  	}
> >   err:
> >  	spin_unlock(&svc_xprt_class_lock);
> > @@ -420,8 +422,13 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
> >  void svc_xprt_received(struct svc_xprt *xprt)
> >  {
> >  	BUG_ON(!test_bit(XPT_BUSY, &xprt->xpt_flags));
> > +	/* As soon as we clear busy, the xprt could be closed and
> > +	 * 'put', so we need a reference to call svc_xprt_enqueue with
> > +	 */
> > +	svc_xprt_get(xprt);
> >  	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> >  	svc_xprt_enqueue(xprt);
> > +	svc_xprt_put(xprt);
> >  }
> >  EXPORT_SYMBOL_GPL(svc_xprt_received);
> >  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

