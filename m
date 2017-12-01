Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44647 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751874AbdLANKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Dec 2017 08:10:52 -0500
Date: Fri, 1 Dec 2017 08:10:51 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfs: fix a deadlock in nfs client initialization
Message-ID: <20171201131051.o2k56cej2iw7zih7@tonberry.usersys.redhat.com>
References: <20171130144647.gwuchptqyiomcojl@tonberry.usersys.redhat.com>
 <20171130222135.3752-1-smayhew@redhat.com>
 <1512095773.27780.3.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1512095773.27780.3.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 01 Dec 2017, Trond Myklebust wrote:

> On Thu, 2017-11-30 at 17:21 -0500, Scott Mayhew wrote:
> > The following deadlock can occur between a process waiting for a
> > client
> > to initialize in while walking the client list during nfsv4 server
> > trunking
> > detection and another process waiting for the nfs_clid_init_mutex so
> > it
> > can initialize that client:
> > 
> > Process 1                               Process 2
> > ---------                               ---------
> > spin_lock(&nn->nfs_client_lock);
> > list_add_tail(&CLIENTA->cl_share_link,
> >         &nn->nfs_client_list);
> > spin_unlock(&nn->nfs_client_lock);
> >                                         spin_lock(&nn-
> > >nfs_client_lock);
> >                                         list_add_tail(&CLIENTB-
> > >cl_share_link,
> >                                                 &nn-
> > >nfs_client_list);
> >                                         spin_unlock(&nn-
> > >nfs_client_lock);
> >                                         mutex_lock(&nfs_clid_init_mut
> > ex);
> >                                         nfs41_walk_client_list(clp,
> > result, cred);
> >                                         nfs_wait_client_init_complete
> > (CLIENTA);
> > (waiting for nfs_clid_init_mutex)
> > 
> > Make sure nfs_match_client() only evaluates clients that have
> > completed
> > initialization in order to prevent that deadlock.
> > 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  fs/nfs/client.c     | 11 +++++++++++
> >  fs/nfs/nfs4client.c |  9 ++++++++-
> >  2 files changed, 19 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 0ac2fb1..7e42380 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -291,12 +291,23 @@ static struct nfs_client
> > *nfs_match_client(const struct nfs_client_initdata *dat
> >  	const struct sockaddr *sap = data->addr;
> >  	struct nfs_net *nn = net_generic(data->net, nfs_net_id);
> >  
> > +again:
> >  	list_for_each_entry(clp, &nn->nfs_client_list,
> > cl_share_link) {
> >  	        const struct sockaddr *clap = (struct sockaddr
> > *)&clp->cl_addr;
> >  		/* Don't match clients that failed to initialise
> > properly */
> >  		if (clp->cl_cons_state < 0)
> >  			continue;
> >  
> > +		/* If a client is still initializing then we need to
> > wait */
> > +		if (clp->cl_cons_state > NFS_CS_READY) {
> > +			spin_unlock(&nn->nfs_client_lock);
> > +			refcount_inc(&clp->cl_count);
> 
> The refcount needs to be bumped before dropping the spinlock above.

Okay.
> 
> > +			nfs_wait_client_init_complete(clp);
> > +			nfs_put_client(clp);
> > +			spin_lock(&nn->nfs_client_lock);
> > +			goto again;
> > +		}
> > +
> >  		/* Different NFS versions cannot share the same
> > nfs_client */
> >  		if (clp->rpc_ops != data->nfs_mod->rpc_ops)
> >  			continue;
> > diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> > index 12bbab0..39dd39c 100644
> > --- a/fs/nfs/nfs4client.c
> > +++ b/fs/nfs/nfs4client.c
> > @@ -411,8 +411,15 @@ struct nfs_client *nfs4_init_client(struct
> > nfs_client *clp,
> >  	if (error < 0)
> >  		goto error;
> >  
> > -	if (clp != old)
> > +	if (clp != old) {
> >  		clp->cl_preserve_clid = true;
> > +		/*
> > +		 * Mark the client as having failed initialization
> > so other
> > +		 * processes walking the nfs_client_list in
> > nfs_match_client()
> > +		 * won't try to use it.
> > +		 */
> > +		nfs_mark_client_ready(clp, -EPERM);
> 
> You can't do this if the client was already marked as NFS_CS_READY, so
> you need at least to move the !nfs4_has_session() condition 4 lines
> above this.

How about if I change it to this:

                if (!nfs_client_init_is_complete(clp))
                        nfs_mark_client_ready(clp, -EPERM);

In my earlier testing I had problems whenever I tried moving that
!nfs4_has_session() condition.  

-Scott
> 
> > +	}
> >  	nfs_put_client(clp);
> >  	clear_bit(NFS_CS_TSM_POSSIBLE, &clp->cl_flags);
> >  	return old;
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
