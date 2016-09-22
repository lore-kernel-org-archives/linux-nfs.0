Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37904 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752681AbcIVQPN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 12:15:13 -0400
Date: Thu, 22 Sep 2016 12:15:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Vasily Averin <vvs@virtuozzo.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Scott Mayhew <smayhew@redhat.com>
Subject: Re: [PATCH 1/2] NFSD: notifiers registration cleanup
Message-ID: <20160922161507.GH30401@fieldses.org>
References: <6bce434f-4798-42bf-8d4f-e1f33ceb8ad6@virtuozzo.com>
 <1474464010.32518.3.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1474464010.32518.3.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 21, 2016 at 09:20:10AM -0400, Jeff Layton wrote:
> On Wed, 2016-09-21 at 15:33 +0300, Vasily Averin wrote:
> > By design notifier can be registered once only,
> > however nfsd registers the same inetaddr notifiers per net-namespace.
> > When this happen it corrupts list of notifiers,
> > as result some notifiers can be not called on proper event,
> > traverse on list can be cycled forever,
> > and second unregister can access already freed memory.
> > 
> > fixes: 36684996 ("nfsd: Register callbacks on the inetaddr_chain and inet6addr_chain")
> > > Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> > ---
> >  fs/nfsd/nfssvc.c | 17 +++++++++++++----
> >  1 file changed, 13 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > index 45007ac..7f8914f 100644
> > --- a/fs/nfsd/nfssvc.c
> > +++ b/fs/nfsd/nfssvc.c
> > @@ -366,14 +366,20 @@ static struct notifier_block nfsd_inet6addr_notifier = {
> >  };
> >  #endif
> >  
> > +static atomic_t nfsd_notifier_refcount = ATOMIC_INIT(0);
> > +
> >  static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
> >  {
> > >  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> >  
> > > -	unregister_inetaddr_notifier(&nfsd_inetaddr_notifier);
> > > +	/* check if the notifier still has clients */
> > > +	if (atomic_dec_return(&nfsd_notifier_refcount) == 0) {
> > > +		unregister_inetaddr_notifier(&nfsd_inetaddr_notifier);
> >  #if IS_ENABLED(CONFIG_IPV6)
> > > -	unregister_inet6addr_notifier(&nfsd_inet6addr_notifier);
> > > +		unregister_inet6addr_notifier(&nfsd_inet6addr_notifier);
> >  #endif
> > > +	}
> > +
> > >  	/*
> > >  	 * write_ports can create the server without actually starting
> > >  	 * any threads--if we get shut down before any threads are
> > @@ -488,10 +494,13 @@ int nfsd_create_serv(struct net *net)
> > >  	}
> >  
> > >  	set_max_drc();
> > > -	register_inetaddr_notifier(&nfsd_inetaddr_notifier);
> > > +	/* check if the notifier is already set */
> > > +	if (atomic_inc_return(&nfsd_notifier_refcount) == 1) {
> > > +		register_inetaddr_notifier(&nfsd_inetaddr_notifier);
> >  #if IS_ENABLED(CONFIG_IPV6)
> > > -	register_inet6addr_notifier(&nfsd_inet6addr_notifier);
> > > +		register_inet6addr_notifier(&nfsd_inet6addr_notifier);
> >  #endif
> > > +	}
> > > >  	do_gettimeofday(&nn->nfssvc_boot);		/* record boot time */
> > >  	return 0;
> >  }
> 
> Good catch. I'm not very fond of the refcounting this here but it
> should
> serve the purpose and I don't have anything better to suggest. FWIW, I
> think the nfsd_mutex is held during all of these operations so we
> probably don't need atomics for the refcount.

Inclined to apply with a note like:

	/* Only used under nfsd_mutex, so this atomic may be overkill: */
	static atomic_t nfsd_notifier_refcount = ATOMIC_INIT(0);
	...

--b.
> 
> --
> Jeff Layton <jlayton@redhat.com>
