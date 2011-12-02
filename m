Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40107 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756852Ab1LBQEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Dec 2011 11:04:14 -0500
Date: Fri, 2 Dec 2011 11:04:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] svcrpc: avoid memory-corruption on pool shutdown
Message-ID: <20111202160411.GB14393@fieldses.org>
References: <20111130233925.GA354@fieldses.org>
 <20111130234009.GB354@fieldses.org>
 <20111201072024.5b3d0324@tlielax.poochiereds.net>
 <20111201224640.GB8091@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111201224640.GB8091@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 05:46:40PM -0500, J. Bruce Fields wrote:
> On Thu, Dec 01, 2011 at 07:20:24AM -0500, Jeff Layton wrote:
> > On Wed, 30 Nov 2011 18:40:09 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >  void svc_close_all(struct svc_serv *serv)
> > >  {
> > > +	struct svc_pool *pool;
> > > +	struct svc_xprt *xprt;
> > > +	struct svc_xprt *tmp;
> > > +	int i;
> > > +
> > >  	svc_close_list(&serv->sv_tempsocks);
> > >  	svc_close_list(&serv->sv_permsocks);
> > > +
> > > +	for (i = 0; i < serv->sv_nrpools; i++) {
> > > +		pool = &serv->sv_pools[i];
> > > +
> > > +		spin_lock_bh(&pool->sp_lock);
> > > +		while (!list_empty(&pool->sp_sockets)) {
> > > +			xprt = list_first_entry(&pool->sp_sockets, struct svc_xprt, xpt_ready);
> > > +			list_del_init(&xprt->xpt_ready);
> > > +		}
> > > +		spin_unlock_bh(&pool->sp_lock);
> > > +	}
> > > +	/*
> > > +	 * At this point the sp_sockets lists will stay empty, since
> > > +	 * svc_enqueue will not add new entries without taking the
> > > +	 * sp_lock and checking XPT_BUSY.
> > > +	 */
> > > +	list_for_each_entry_safe(xprt, tmp, &serv->sv_tempsocks, xpt_list)
> > > +		svc_delete_xprt(xprt);
> > > +	list_for_each_entry_safe(xprt, tmp, &serv->sv_permsocks, xpt_list)
> > > +		svc_delete_xprt(xprt);
> > > +
> > 
> > I'm always a little suspicious when I see walking and manipulating a
> > list outside of any locking.
> 
> With good reason.

(Though on the other hand you might also want to be suspicious of code
that took locks around these list traversals, as you'd have to wonder
what would gaurantee the lists would stay empty once the lock was
dropped.)

> So, anyway: my inclination for now is to update this patch with a few
> comments but leave it otherwise the same.

 	del_timer_sync(&serv->sv_temptimer);
-
+	/*
+	 * The set of xprts (contained in the sv_tempsocks and
+	 * sv_permsocks lists) is now constant, since it is modified
+	 * only by accepting new sockets (done by service threads in
+	 * svc_recv) or aging old ones (done by sv_temptimer), or
+	 * configuration changes (excluded by whatever locking the
+	 * caller is using--nfsd_mutex in the case of nfsd).  So it's
+	 * safe to traverse those lists and shut everything down:
+	 */
 	svc_close_all(serv);

--b.
