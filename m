Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60988 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752456AbdKNAqg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Nov 2017 19:46:36 -0500
Date: Mon, 13 Nov 2017 19:46:36 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Vasily Averin <vvs@virtuozzo.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: fix "list_add double add" caused by legacy signal
 interface
Message-ID: <20171114004636.GC18192@fieldses.org>
References: <20171109154444.GG8773@fieldses.org>
 <75f4472c-b9e2-6353-3af0-c4939ecfca41@virtuozzo.com>
 <1510573758.4536.8.camel@kernel.org>
 <48cdbeb3-b364-17c1-aaf9-948525e33f38@virtuozzo.com>
 <1510603577.4887.4.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1510603577.4887.4.camel@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 13, 2017 at 03:06:17PM -0500, Jeff Layton wrote:
> On Mon, 2017-11-13 at 17:57 +0300, Vasily Averin wrote:
> > On 2017-11-13 14:49, Jeff Layton wrote:
> > > On Mon, 2017-11-13 at 07:25 +0300, Vasily Averin wrote:
> > > > --- a/fs/nfs_common/grace.c
> > > > +++ b/fs/nfs_common/grace.c
> > > > @@ -30,7 +30,11 @@ locks_start_grace(struct net *net, struct lock_manager *lm)
> > > >  	struct list_head *grace_list = net_generic(net, grace_net_id);
> > > >  
> > > >  	spin_lock(&grace_lock);
> > > > -	list_add(&lm->list, grace_list);
> > > > +	if (list_empty(&lm->list))
> > > > +		list_add(&lm->list, grace_list);
> > > > +	else
> > > > +		WARN(1, "double list_add attempt detected in net %x %s\n",
> > > > +		     net->ns.inum, (net == &init_net) ? "(init_net)" : "");
> > > >  	spin_unlock(&grace_lock);
> > > >  }
> > > 
> > > I'm not sure that warning really means much.
> > > 
> > > It's not _really_ a bug to request that a new grace period start while
> > > it's already in one. In general, it's ok to request a new grace period
> > > while it's currently enforcing one. That should just have the effect of
> > > extending the existing grace period.
> > 
> > "double list_add" can happen in init_net when legacy signal in lockd was used.
> > It should not happen during usual extending of existing grace period,
> > because restart_grace() calls locks_end_grace() before set_grace_period()
> > but it can race with start of lockd_up_net() in init_net.
> > I'm agree: we do not have any bugs in this scenario, all should work correctly.
> > 
> > However I would like to keep WARN to properly detect lost locks_end_grace()/
> > cancel_delayed_work().
> > 
> > If you worry about real false positive and do not worry about abstract
> > future troubles in init_net, I can move WARN under (net != &init_net) check.
> > 
> > However I would like to keep this warning here.
> > 
> > On the other hand if you disagree and still believe that WARN is not required here
> > I'm ready to agree with your original patch version.
> 
> Fair enough. I don't feel strongly about it. I just have been doing some
> investigation lately into clustered grace period management, so it's a
> little on my mind. [1]
> 
> For now though, you're certainly correct that we'll never attempt to set
> the grace period while we're already in it. If we ever want to do more
> complex grace period handling in the kernel, we may need to drop that
> WARN, however.

OK, applied with a minor changelog update.

Vasily, if you see anything missing from nfsd-next at this point, let me
know:

	git://linux-nfs.org/~bfields/linux.git nfsd-next

--b.
