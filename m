Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755024Ab1LAWqn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 17:46:43 -0500
Date: Thu, 1 Dec 2011 17:46:40 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] svcrpc: avoid memory-corruption on pool shutdown
Message-ID: <20111201224640.GB8091@fieldses.org>
References: <20111130233925.GA354@fieldses.org>
 <20111130234009.GB354@fieldses.org>
 <20111201072024.5b3d0324@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111201072024.5b3d0324@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 07:20:24AM -0500, Jeff Layton wrote:
> On Wed, 30 Nov 2011 18:40:09 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >  void svc_close_all(struct svc_serv *serv)
> >  {
> > +	struct svc_pool *pool;
> > +	struct svc_xprt *xprt;
> > +	struct svc_xprt *tmp;
> > +	int i;
> > +
> >  	svc_close_list(&serv->sv_tempsocks);
> >  	svc_close_list(&serv->sv_permsocks);
> > +
> > +	for (i = 0; i < serv->sv_nrpools; i++) {
> > +		pool = &serv->sv_pools[i];
> > +
> > +		spin_lock_bh(&pool->sp_lock);
> > +		while (!list_empty(&pool->sp_sockets)) {
> > +			xprt = list_first_entry(&pool->sp_sockets, struct svc_xprt, xpt_ready);
> > +			list_del_init(&xprt->xpt_ready);
> > +		}
> > +		spin_unlock_bh(&pool->sp_lock);
> > +	}
> > +	/*
> > +	 * At this point the sp_sockets lists will stay empty, since
> > +	 * svc_enqueue will not add new entries without taking the
> > +	 * sp_lock and checking XPT_BUSY.
> > +	 */
> > +	list_for_each_entry_safe(xprt, tmp, &serv->sv_tempsocks, xpt_list)
> > +		svc_delete_xprt(xprt);
> > +	list_for_each_entry_safe(xprt, tmp, &serv->sv_permsocks, xpt_list)
> > +		svc_delete_xprt(xprt);
> > +
> 
> I'm always a little suspicious when I see walking and manipulating a
> list outside of any locking.

With good reason.

> Can you convince me as to why it's safe to do the above?

After entirely too much grepping....

The server keeps its listeners on sv_permsocks, and individual client
connections on sv_tempsocks.

The tempsocks list:
	- has a new xprt added when we accept a new connection.  This is
	  done by a server thread in svc_recv().  (Also
	  svc_check_conn_limits() may decide to remove an old connection
	  at the same time.)
	- has xprts removed by svc_age_temp_xprts, called from
	  sv_temptimer.

But svc_close_all() is called only after all server threads are gone
and after sv_temptimer has been stopped by a del_timer_sync().  So we're
safe from either of the above.

Great!  But:

The more irritating code is the code that's run on server startup and
configuration: svc_sock_update_bufs, nfsd_init_socks, svc_find_xprt,
svc_xprt_names, svc_create_xprt, svc_sock_names, and svc_addsock all
modify or traverse these two lists.  I believe the callers should all be
holding a mutex (normally nfsd_mutex, or nlmsvc_mutex or
nfs_callback_mutex as appropriate).  But not all of them are (e.g.
addfd, addxprt are fishy).

So, anyway: my inclination for now is to update this patch with a few
comments but leave it otherwise the same.

The remaining races look easier to avoid, as they'd only happen if
userspace was doing something odd like trying to give nfsd another
socket to listen on from one process while simultaneously shutting it
down from another.

But server startup and shutdown has always been fuzzy and kinda fragile.
And it will probably need a harder look anyway for containerization.  So
I'll take a harder look at that next....

--b.

> 
> list_for_each_entry_safe just makes it safe to remove "xprt" from the
> list essentially by preloading "tmp". What prevents another task from
> removing "tmp" while you're busy dealing with "xprt"? Or from putting a
> new socket onto the list at that point?
> 
> >  	BUG_ON(!list_empty(&serv->sv_permsocks));
> >  	BUG_ON(!list_empty(&serv->sv_tempsocks));
> > -
> >  }
> >  
> >  /*
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
