Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:14359 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752941AbdHKUC5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Aug 2017 16:02:57 -0400
Subject: Re: [PATCH v1 0/5] Clean up XDR encoding of RPC/RDMA xprt hdrs
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-nfs@vger.kernel.org>
References: <20170810164425.23774.91430.stgit@manet.1015granger.net>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <4359ffc0-6e29-925b-e6f9-5ec4794fefc2@Netapp.com>
Date: Fri, 11 Aug 2017 16:02:49 -0400
MIME-Version: 1.0
In-Reply-To: <20170810164425.23774.91430.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/10/2017 12:47 PM, Chuck Lever wrote:
> Hi Anna-
> 
> These patches harden xprtrdma's send_request code path, particu-
> larly XDR encoding of outgoing transport headers. This is the flip
> side of the series I sent last week. Again, I didn't copy
> linux-rdma on this series since it is strictly XDR-related.
> 
> Please have a look at these and let me know if they are not
> acceptable for v4.14.

Thanks!  They look good to me!

> 
> ---
> 
> Chuck Lever (5):
>       xprtrdma: Clean up rpcrdma_marshal_req() synopsis
>       xprtrdma: Remove rpclen from rpcrdma_marshal_req
>       xprtrdma: Set up an xdr_stream in rpcrdma_marshal_req()
>       xprtrdma: Harden chunk list encoding against send buffer overflow
>       xprtrdma: Clean up rpcrdma_bc_marshal_reply()
> 
> 
>  net/sunrpc/xprtrdma/backchannel.c |   31 ++--
>  net/sunrpc/xprtrdma/rpc_rdma.c    |  280 +++++++++++++++++++++++--------------
>  net/sunrpc/xprtrdma/transport.c   |    3 
>  net/sunrpc/xprtrdma/xprt_rdma.h   |    4 -
>  4 files changed, 199 insertions(+), 119 deletions(-)
> 
> --
> Chuck Lever
> 
