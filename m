Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39752 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109Ab3A3CSI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2013 21:18:08 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tejun Heo <tj@kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 11/14] nfs: idr_destroy() no longer needs
 idr_remove_all()
Date: Wed, 30 Jan 2013 02:18:06 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9183426FE@sacexcmbx05-prd.hq.netapp.com>
References: <1359163872-1949-1-git-send-email-tj@kernel.org>
	 <1359163872-1949-12-git-send-email-tj@kernel.org>
	 <20130129225848.GD6219@fieldses.org>
In-Reply-To: <20130129225848.GD6219@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-29 at 17:58 -0500, J. Bruce Fields wrote:
> On Fri, Jan 25, 2013 at 05:31:09PM -0800, Tejun Heo wrote:
> > idr_destroy() can destroy idr by itself and idr_remove_all() is being
> > deprecated.  Drop reference to idr_remove_all().  Note that the code
> > wasn't completely correct before because idr_remove() on all entries
> > doesn't necessarily release all idr_layers which could lead to memory
> > leak.
> 
> Seems fine, but actually this is client-side so I think you meant the cc
> to be to Trond.

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

No problems whatsoever with removing a comment. :-)

My worry is more about Tejun's comment that we did actually need a call
to idr_remove_all() in the original code. Do we need to queue up a fix
for the 3.8 and existing stable kernels?

Cheers
  Trond

> > Signed-off-by: Tejun Heo <tj@kernel.org>
> > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> > Cc: linux-nfs@vger.kernel.org
> > ---
> > This patch depends on an earlier idr patch and given the trivial
> > nature of the patch, I think it would be best to route these together
> > through -mm.  Please holler if there's any objection.
> > 
> > Thanks.
> > 
> >  fs/nfs/client.c | 1 -
> >  1 file changed, 1 deletion(-)
> > 
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 9f3c664..84d8eae 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -197,7 +197,6 @@ error_0:
> >  EXPORT_SYMBOL_GPL(nfs_alloc_client);
> >  
> >  #if IS_ENABLED(CONFIG_NFS_V4)
> > -/* idr_remove_all is not needed as all id's are removed by nfs_put_client */
> >  void nfs_cleanup_cb_ident_idr(struct net *net)
> >  {
> >  	struct nfs_net *nn = net_generic(net, nfs_net_id);
> > -- 
> > 1.8.1
> > 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
