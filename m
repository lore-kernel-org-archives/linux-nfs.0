Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:33596 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643Ab1JLRRw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Oct 2011 13:17:52 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9CH2RTY014203
	for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2011 13:02:27 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9CHHfGH2326706
	for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2011 13:17:41 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9CHHS0p027197
	for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2011 14:17:28 -0300
Date: Wed, 12 Oct 2011 10:17:27 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Check validity of cl_rpcclient in nfs_server_list_show
Message-ID: <20111012171727.GA18925@us.ibm.com>
References: <1315965305-23757-1-git-send-email-malahal@us.ibm.com>
 <20110919153429.GA16725@us.ibm.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B35626A@SACMVEXC2-PRD.hq.netapp.com>
 <20110921002714.GA31689@us.ibm.com>
 <20110927164335.GA19331@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110927164335.GA19331@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any comments on this patch?

Malahal Naineni [malahal@us.ibm.com] wrote:
> Malahal Naineni [malahal@us.ibm.com] wrote:
> > Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> > > Shouldn't we just skip all nfs_client structures that don't have
> > > cl_cons_state set to NFS_CS_READY? I see no reason to display their
> > > properties even if they have got far enough as to create an rpc client.
> > > 
> > > Cheers
> > >   Trond
> > 
> > Sounds good to me. Here is a tested patch.
> 
> Any comments on this one?
> 
> Thanks, Malahal.
> 
> > 
> > 
> > As soon as the nfs_client gets created, its cl_rpcclient is set to
> > ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
> > if the client is ready before using the cl_rpcclient pointer.
> > 
> > Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> > ---
> >  fs/nfs/client.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 5833fbb..a54c45e 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -1867,6 +1867,10 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
> >  	/* display one transport per line on subsequent lines */
> >  	clp = list_entry(v, struct nfs_client, cl_share_link);
> > 
> > +	/* Check if the client is initialized */
> > +	if (clp->cl_cons_state != NFS_CS_READY)
> > +		return 0;
> > +
> >  	seq_printf(m, "v%u %s %s %3d %s\n",
> >  		   clp->rpc_ops->version,
> >  		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
> > -- 
> > 1.7.0.4
> > 
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
