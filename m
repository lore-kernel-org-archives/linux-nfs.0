Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65060 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863Ab1ISReD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2011 13:34:03 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] Check validity of cl_rpcclient in nfs_server_list_show
Date: Mon, 19 Sep 2011 10:33:58 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B35626A@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <20110919153429.GA16725@us.ibm.com>
References: <1315965305-23757-1-git-send-email-malahal@us.ibm.com> <20110919153429.GA16725@us.ibm.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Malahal Naineni" <malahal@us.ibm.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Malahal Naineni [mailto:malahal@us.ibm.com]
> Sent: Monday, September 19, 2011 11:34 AM
> To: linux-nfs@vger.kernel.org
> Cc: Myklebust, Trond
> Subject: Re: [PATCH] Check validity of cl_rpcclient in
nfs_server_list_show
> 
> Any comments on the patch below? It is very easy to reproduce the bug
(at
> least on SLES11 SP1).

Shouldn't we just skip all nfs_client structures that don't have
cl_cons_state set to NFS_CS_READY? I see no reason to display their
properties even if they have got far enough as to create an rpc client.

Cheers
  Trond


> Thanks, Malahal.
> 
> Malahal Naineni [malahal@us.ibm.com] wrote:
> > As soon as the nfs_client gets created, its cl_rpcclient is set to
> > ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
> > for the validity of cl_rpcclient before using it.
> >
> > Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> > ---
> >  fs/nfs/client.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c index
5833fbb..ff79e72
> > 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -1867,6 +1867,10 @@ static int nfs_server_list_show(struct
seq_file
> *m, void *v)
> >  	/* display one transport per line on subsequent lines */
> >  	clp = list_entry(v, struct nfs_client, cl_share_link);
> >
> > +	/* Check if the rpc client is initialized */
> > +	if (IS_ERR(clp->cl_rpcclient))
> > +		return 0;
> > +
> >  	seq_printf(m, "v%u %s %s %3d %s\n",
> >  		   clp->rpc_ops->version,
> >  		   rpc_peeraddr2str(clp->cl_rpcclient,
> RPC_DISPLAY_HEX_ADDR),
> > --
> > 1.7.0.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > in the body of a message to majordomo@vger.kernel.org More
> majordomo
> > info at  http://vger.kernel.org/majordomo-info.html

