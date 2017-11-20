Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752978AbdKTV2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Nov 2017 16:28:20 -0500
Date: Mon, 20 Nov 2017 16:28:19 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix a deadlock in nfs v4.1 client initialization
Message-ID: <20171120212819.3yxutvgmigxc7at5@tonberry.usersys.redhat.com>
References: <20171107142927.9468-1-smayhew@redhat.com>
 <1510068613.3576.0.camel@primarydata.com>
 <20171107182625.xe7o7xvtn3lk4mor@tonberry.usersys.redhat.com>
 <1510079407.7834.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1510079407.7834.4.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 07 Nov 2017, Trond Myklebust wrote:

> On Tue, 2017-11-07 at 13:26 -0500, Scott Mayhew wrote:
> > On Tue, 07 Nov 2017, Trond Myklebust wrote:
> > 
> > > On Tue, 2017-11-07 at 09:29 -0500, Scott Mayhew wrote:
> > > > The following deadlock can occur between a process waiting for a
> > > > client
> > > > to initialize in while walking the client list and another
> > > > process
> > > > waiting for the nfs_clid_init_mutex so it can initialize that
> > > > client:
> > > > 
> > > > Process 1                               Process 2
> > > > ---------                               ---------
> > > > spin_lock(&nn->nfs_client_lock);
> > > > list_add_tail(&CLIENTA->cl_share_link,
> > > >         &nn->nfs_client_list);
> > > > spin_unlock(&nn->nfs_client_lock);
> > > >                                         spin_lock(&nn-
> > > > > nfs_client_lock);
> > > > 
> > > >                                         list_add_tail(&CLIENTB-
> > > > > cl_share_link,
> > > > 
> > > >                                                 &nn-
> > > > > nfs_client_list);
> > > > 
> > > >                                         spin_unlock(&nn-
> > > > > nfs_client_lock);
> > > > 
> > > >                                         mutex_lock(&nfs_clid_init
> > > > _mut
> > > > ex);
> > > >                                         nfs41_walk_client_list(cl
> > > > p,
> > > > result, cred);
> > > >                                         nfs_wait_client_init_comp
> > > > lete
> > > > (CLIENTA);
> > > > (waiting for nfs_clid_init_mutex)
> > > > 
> > > > Make sure nfs_match_client() only evaluates clients that have
> > > > completed
> > > > initialization in order to prevent that deadlock.
> > > > 
> > > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > > ---
> > > >  fs/nfs/client.c | 9 +++++++++
> > > >  1 file changed, 9 insertions(+)
> > > > 
> > > > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > > > index 22880ef..8b093994 100644
> > > > --- a/fs/nfs/client.c
> > > > +++ b/fs/nfs/client.c
> > > > @@ -291,12 +291,21 @@ static struct nfs_client
> > > > *nfs_match_client(const struct nfs_client_initdata *dat
> > > >  	const struct sockaddr *sap = data->addr;
> > > >  	struct nfs_net *nn = net_generic(data->net, nfs_net_id);
> > > >  
> > > > +again:
> > > >  	list_for_each_entry(clp, &nn->nfs_client_list,
> > > > cl_share_link) {
> > > >  	        const struct sockaddr *clap = (struct sockaddr
> > > > *)&clp->cl_addr;
> > > >  		/* Don't match clients that failed to initialise
> > > > properly */
> > > >  		if (clp->cl_cons_state < 0)
> > > >  			continue;
> > > >  
> > > > +		if (clp->cl_minorversion > 0 &&
> > > > +				clp->cl_cons_state >
> > > > NFS_CS_READY) {
> > > > +			spin_unlock(&nn->nfs_client_lock);
> > > > +			nfs_wait_client_init_complete(clp);
> > > > +			spin_lock(&nn->nfs_client_lock);
> > > > +			goto again;
> > > > +		}
> > > > +
> > > >  		/* Different NFS versions cannot share the same
> > > > nfs_client */
> > > >  		if (clp->rpc_ops != data->nfs_mod->rpc_ops)
> > > >  			continue;
> > > 
> > > Why the test for clp->cl_minorversion? What's so minor version
> > > specific
> > > about any of this?
> > 
> > The deadlock doesn't occur with v4.0 clients because those are being
> > marked NFS_CS_READY in nfs4_client_client(), before the trunking
> > detection
> 
> Sure, but the root cause you are asserting is that the nfs_client has
> not finished initialising. What is minorversion-specific (or even
> NFSv4-specific) about that?

It's NFSv4-specific because one of the processes involved in the
deadlock (the one waiting on the nfs_client_active_wq while holding the 
nfs_clid_init_mutex) is performing trunking detection, which is
NFSv4-specific.

Anyways, this patch is no good because it breaks when issuing mounts
against multiple IPs of a multi-homed NFS server.  I don't have a
reference on the the client I'm waiting on, so if the process doing
trunking detection with that client finds and uses an existing client,
then the client I'm waiting on goes away (and even if I had a reference
on it, if the process doing trunking detection finds and uses an
existing client, there's nothing that would mark the client that I'm
waiting for ready).

I have another approach that fixes the issue.  It's kinda ugly but I'm
going to post it anyway because I don't really have any other ideas.

Also I forgot to include the reproducer info, so here it is:

1 nfs client, 2 nfs servers

on nfs servers:
    # for i in $(seq 1 25) ; do mkdir /exports/dir$i ; done
    # echo "/exports *(rw,no_root_squash)" >> /etc/exports
    # exportfs -ar

on nfs client:
    # for i in $(seq 1 25) ; do mkdir -p /mnt/test$i ; done

    # hosts=(server1 server2)
    # for i in $(seq 1 25) ; do
        hostnum=$(($i % 2))
        mount.nfs ${hosts[$hostnum]}:/exports/dir$i /mnt/test$i -o vers=4,minorversion=1 &
      done

-Scott

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
