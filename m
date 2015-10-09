Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34787 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932144AbbJIVj3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 17:39:29 -0400
Received: by qkdo1 with SMTP id o1so29297991qkd.1
        for <linux-nfs@vger.kernel.org>; Fri, 09 Oct 2015 14:39:27 -0700 (PDT)
Date: Fri, 9 Oct 2015 17:39:23 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: use a multithreaded workqueue for nfsd4_callbacks
Message-ID: <20151009173923.1ca297a4@synchrony.poochiereds.net>
In-Reply-To: <20151009212459.GF8188@fieldses.org>
References: <1443875882-12089-1-git-send-email-jeff.layton@primarydata.com>
	<20151009212459.GF8188@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 9 Oct 2015 17:24:59 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Oct 03, 2015 at 08:38:02AM -0400, Jeff Layton wrote:
> > I don't see any need to order callbacks with respect to one another.
> 
> I thought the code in nfsd4_process_cb_update really depended on this.
> The locking it has is against nfsd threads, it probably assumes it's
> only run from a cb thread and that it's the only one running at a time.
> 
> But I haven't reviewed it lately.
> 
> --b.
> 

Yikes -- ok. That's not at all obvious. That should prob be documented
if so.

Yeah, ok...I guess you could end up with multiple threads racing to
tear down the cb_client and xprt and create a new one, and it looks
like the cl_cb_client and cl_cred pointers could get clobbered by new
ones in that case.

Shouldn't be too hard to fix protecting those pointers with the
cl_lock. That said, I prob won't be able to spend time on it right now.
You can go ahead and drop that patch and I'll resend if/when I get
around to fixing that.

Thanks for having a look...

> > Also, these are generally not involved in memory reclaim, so I don't see
> > the need for a rescuer thread here either.
> > 
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4callback.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index e7f50c4081d6..7dabbb436290 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -1017,7 +1017,7 @@ static const struct rpc_call_ops nfsd4_cb_ops = {
> >  
> >  int nfsd4_create_callback_queue(void)
> >  {
> > -	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
> > +	callback_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd4_callbacks");
> >  	if (!callback_wq)
> >  		return -ENOMEM;
> >  	return 0;
> > -- 
> > 2.4.3


-- 
Jeff Layton <jlayton@poochiereds.net>
