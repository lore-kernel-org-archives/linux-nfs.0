Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40020 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473Ab0I1N4n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 09:56:43 -0400
Date: Tue, 28 Sep 2010 09:56:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/8] sunrpc: Factor out rpc_xprt freeing
Message-ID: <20100928135634.GE24465@fieldses.org>
References: <4CA06C7A.5060307@parallels.com>
 <4CA06CA0.6060606@parallels.com>
 <02506D5E-BD8D-40AC-822F-00BBC14792E9@oracle.com>
 <4CA1C71D.70109@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA1C71D.70109@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 28, 2010 at 02:44:45PM +0400, Pavel Emelyanov wrote:
> On 09/27/2010 11:40 PM, Chuck Lever wrote:
> > 
> > On Sep 27, 2010, at 6:06 AM, Pavel Emelyanov wrote:
> > 
> >>
> >> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >> ---
> >> net/sunrpc/xprtsock.c |   20 ++++++++++++--------
> >> 1 files changed, 12 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> >> index b6309db..98d4b7b 100644
> >> --- a/net/sunrpc/xprtsock.c
> >> +++ b/net/sunrpc/xprtsock.c
> >> @@ -759,6 +759,8 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
> >> 		xs_tcp_shutdown(xprt);
> >> }
> >>
> >> +static void xs_free_xprt(struct rpc_xprt *xprt);
> > 
> > Style nit: we usually like forward declarations at the top of source files.
> 
> OK.
> 
> > Do you need to fix up xprtrdma too?  (eg. xprt_rdma_destroy)  It looks like it has 
> > similar logic around freeing xprts. 
> 
> Indeed. Bruce, which way would you prefer - should I re-send the whole set or
> can apply this change incrementally?

I haven't pushed it out yet, so just do whichever you prefer.

--b.

> 
> > Even though it doesn't use sockets, do we need to be concerned about net namespaces
> > for RDMA transports?
> 
> I believe we should, since at least its initialization goes to the rdma_resolve_addr
> which in turn resolves the address using IP-level routing. But I wanted to finish with
> the tcp/udp transports first.
> 
> Thanks,
> Pavel
