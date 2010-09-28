Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27511 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755182Ab0I1N7q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 09:59:46 -0400
Subject: Re: [PATCH 1/8] sunrpc: Factor out rpc_xprt freeing
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <4CA1C71D.70109@parallels.com>
References: <4CA06C7A.5060307@parallels.com>
	 <4CA06CA0.6060606@parallels.com>
	 <02506D5E-BD8D-40AC-822F-00BBC14792E9@oracle.com>
	 <4CA1C71D.70109@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 28 Sep 2010 09:59:44 -0400
Message-ID: <1285682384.9185.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-28 at 14:44 +0400, Pavel Emelyanov wrote:
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
> 
> > Even though it doesn't use sockets, do we need to be concerned about net namespaces
> > for RDMA transports?
> 
> I believe we should, since at least its initialization goes to the rdma_resolve_addr
> which in turn resolves the address using IP-level routing. But I wanted to finish with
> the tcp/udp transports first.

If you are redoing the patch, then could you please just get rid of the
above forward declaration for xs_free_xprt, and instead just move the
function itself further up the file?

Cheers
  Trond
