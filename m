Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57939 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab3CKTPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 15:15:50 -0400
Date: Mon, 11 Mar 2013 15:15:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tim Gardner <tim.gardner@canonical.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, Tom Tucker <tom@ogc.us>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH linux-next v2] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
Message-ID: <20130311191545.GA642@fieldses.org>
References: <20130310202838.GL31448@fieldses.org>
 <1363023447-22453-1-git-send-email-tim.gardner@canonical.com>
 <20130311181450.GC30618@fieldses.org>
 <513E27C0.8050108@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <513E27C0.8050108@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 11, 2013 at 12:51:44PM -0600, Tim Gardner wrote:
> On 03/11/2013 12:14 PM, J. Bruce Fields wrote:
> <snip>
> >>
> >> v2 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_req
> >> and pass this request down through rpcrdma_register_external() and
> >> rpcrdma_register_default_external(). This is less overhead then using
> >> kmalloc() and requires no extra error checking as the allocation burden is
> >> shifted to the transport client.
> > 
> > Oh good--so that works, and the req is the right place to put this?  How
> > are you testing this?
> > 
> > (Just want to make it clear: I'm *not* an expert on the rdma code, so my
> > suggestion to put this in the rpcrdma_req was a suggestion for something
> > to look into, not a claim that it's correct.)
> > 
> 
> Just compile tested so far. Incidentally, I've been through the call stack:
> 
> call_transmit
>  xprt_transmit
>   xprt->ops->send_request(task)
>    xprt_rdma_send_request
>     rpcrdma_marshal_req
>      rpcrdma_create_chunks
>       rpcrdma_register_external
>        rpcrdma_register_default_external
> 
> It appears that the context for kmalloc() should be fine unless there is
> a spinlock held around call_transmit() (which seems unlikely).

Right, though I think it shouldn't be GFP_KERNEL--looks like writes
could wait on it.

In any case, the embedding-in-rpcrdma_req solution does look cleaner if
that's correct (e.g. if we can be sure there won't be two simultaneous
users of that array).

--b.
