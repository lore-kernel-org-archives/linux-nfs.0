Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46076 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753388AbaAIP5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jan 2014 10:57:35 -0500
Date: Thu, 9 Jan 2014 10:57:32 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix a memory leak for tcp NFSv4.1 backchannel
Message-ID: <20140109155732.GA14308@fieldses.org>
References: <52CA7862.1020203@gmail.com>
 <20140106184926.GC31764@fieldses.org>
 <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com>
 <20140106225346.GB3342@fieldses.org>
 <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 06:28:38PM -0500, Trond Myklebust wrote:
> 
> On Jan 6, 2014, at 17:53, Dr Fields James Bruce <bfields@fieldses.org>
> wrote:
> 
> > On Mon, Jan 06, 2014 at 05:40:03PM -0500, Trond Myklebust wrote:
> >> 
> >> On Jan 6, 2014, at 13:49, J. Bruce Fields <bfields@fieldses.org>
> >> wrote:
> >> 
> >>> On Mon, Jan 06, 2014 at 05:33:22PM +0800, Kinglong Mee wrote:
> >>>> xs_setup_bc_tcp may return an existing xprt with non-NULL
> >>>> servername.  xprt_create_transport should not kstrdup servername
> >>>> for it.  Otherwise, those memory for servername will be leaked.
> >>> 
> >>> OK.  Applying to my tree if Trond has no objection.
> >> 
> >> Actually. Why do we go through all this code at all if
> >> xs_setup_bc_tcp() returns args->bc_xprt->xpt_bc_xprt? I’m assuming
> >> that is the only case where xprt->servername != NULL, right?
> >> 
> >> For instance, won’t calling INIT_WORK() be a source of problems?
> > 
> > Huh.  Looking at the history....  There used to be a
> > 
> > 	if (test_and_set_bit(XPRT_INITIALIZED, &xprt->state)) /* ->setup
> > 	returned a pre-initialized xprt: */ return xprt;
> > 
> > here, but it got removed by 21de0a955f3af29fa1100d96f66e6adade89e77a
> > "SUNRPC: Clean up the slot table allocation", which looks otherwise
> > unrelated.  Was that just some kind of rebasing mistake, or was
> > there a reason for that?
> 
> I probably misunderstood that bc_xprt sends a fully initialized struct
> rpc_xprt.
> 
> The obvious question if that is the case, is why we are calling
> xprt_create_transport() at all? If .bc_xprt->xpt_bc_xprt contains a
> fully initialized struct rpc_xprt, then just have rpc_create() do the
> honors.  Better yet, create a svc_create_backchannel_client() helper
> that calls rpc_new_client() with the correct parameters.

Yes, that sounds great.  Looking at rpc_create, it could be that
everything there outside the rpc_new_client call is useless.

--b.

> I really
> don’t like those rpc_create_args hacks that introduce fields that are
> completely private to nfsd.
