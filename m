Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53338 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755951AbdKGS00 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 13:26:26 -0500
Date: Tue, 7 Nov 2017 13:26:25 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix a deadlock in nfs v4.1 client initialization
Message-ID: <20171107182625.xe7o7xvtn3lk4mor@tonberry.usersys.redhat.com>
References: <20171107142927.9468-1-smayhew@redhat.com>
 <1510068613.3576.0.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1510068613.3576.0.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 07 Nov 2017, Trond Myklebust wrote:

> On Tue, 2017-11-07 at 09:29 -0500, Scott Mayhew wrote:
> > The following deadlock can occur between a process waiting for a
> > client
> > to initialize in while walking the client list and another process
> > waiting for the nfs_clid_init_mutex so it can initialize that client:
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
> >  fs/nfs/client.c | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 22880ef..8b093994 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -291,12 +291,21 @@ static struct nfs_client
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
> > +		if (clp->cl_minorversion > 0 &&
> > +				clp->cl_cons_state > NFS_CS_READY) {
> > +			spin_unlock(&nn->nfs_client_lock);
> > +			nfs_wait_client_init_complete(clp);
> > +			spin_lock(&nn->nfs_client_lock);
> > +			goto again;
> > +		}
> > +
> >  		/* Different NFS versions cannot share the same
> > nfs_client */
> >  		if (clp->rpc_ops != data->nfs_mod->rpc_ops)
> >  			continue;
> 
> Why the test for clp->cl_minorversion? What's so minor version specific
> about any of this?

The deadlock doesn't occur with v4.0 clients because those are being
marked NFS_CS_READY in nfs4_client_client(), before the trunking
detection

        if (!nfs4_has_session(clp))
                nfs_mark_client_ready(clp, NFS_CS_READY);

        error = nfs4_discover_server_trunking(clp, &old);

Now that I think about it, that seems wrong because nfs4_match_client()
could be comparing cl_clientid and cl_owner_id values that haven't been
established yet... in fact when I run my reproducer against two ip
addresses on the same server I wind up with multiple clients with the
same cl_clientid and cl_owner_id  

crash> list -H 0xffff9fc2b6327118 -o nfs_client.cl_share_link -s nfs_client.cl_clientid,cl_owner_id
ffff9fc2b352c800
  cl_clientid = 0xb81ff359309120bb
  cl_owner_id = 0xffff9fc2ae9644c0 "Linux NFSv4.0 fedora26.smayhew.test"
ffff9fc2aded7400
  cl_clientid = 0xb81ff359309120bb
  cl_owner_id = 0xffff9fc2b0584f80 "Linux NFSv4.0 fedora26.smayhew.test"

I'll poke around a bit more.

-Scott
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
