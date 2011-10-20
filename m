Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42123 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659Ab1JTTDY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 15:03:24 -0400
Date: Thu, 20 Oct 2011 12:03:16 -0700
Subject: Re: [PATCH] Check validity of cl_rpcclient in nfs_server_list_show
Content-Type: text/plain;
	charset="utf-8"
Message-ID: <02cf01cc8f5a$efda6ba5$cc5f630a@hq.netapp.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Malahal Naineni" <malahal@us.ibm.com>
Cc: <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry about that. I'll try to fix it later, but I'm on various planes for most of today so I might not have the ability until tomorrow. 

Malahal Naineni <malahal@us.ibm.com> wrote:

The following patch fixes the panic that we see often. I didn't see it
in the git://git.linux-nfs.org/projects/trondmy/linux-nfs.git git tree
yet as far as I can tell. Any comments on the patch?

Thanks, Malahal.

Malahal Naineni [malahal@us.ibm.com] wrote:
> Any comments on this patch?
> 
> Malahal Naineni [malahal@us.ibm.com] wrote:
> > Malahal Naineni [malahal@us.ibm.com] wrote:
> > > Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> > > > Shouldn't we just skip all nfs_client structures that don't have
> > > > cl_cons_state set to NFS_CS_READY? I see no reason to display their
> > > > properties even if they have got far enough as to create an rpc client.
> > > > 
> > > > Cheers
> > > >   Trond
> > > 
> > > Sounds good to me. Here is a tested patch.
> > 
> > Any comments on this one?
> > 
> > Thanks, Malahal.
> > 
> > > 
> > > 
> > > As soon as the nfs_client gets created, its cl_rpcclient is set to
> > > ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
> > > if the client is ready before using the cl_rpcclient pointer.
> > > 
> > > Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> > > ---
> > >  fs/nfs/client.c |    4 ++++
> > >  1 files changed, 4 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > > index 5833fbb..a54c45e 100644
> > > --- a/fs/nfs/client.c
> > > +++ b/fs/nfs/client.c
> > > @@ -1867,6 +1867,10 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
> > >  	/* display one transport per line on subsequent lines */
> > >  	clp = list_entry(v, struct nfs_client, cl_share_link);
> > > 
> > > +	/* Check if the client is initialized */
> > > +	if (clp->cl_cons_state != NFS_CS_READY)
> > > +		return 0;
> > > +
> > >  	seq_printf(m, "v%u %s %s %3d %s\n",
> > >  		   clp->rpc_ops->version,
> > >  		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
> > > -- 
> > > 1.7.0.4
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

