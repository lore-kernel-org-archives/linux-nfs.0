Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:38313 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752458AbdHHUyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Aug 2017 16:54:21 -0400
Subject: Re: [PATCH v1 0/7] Clean up XDR decoding of RPC/RDMA xprt hdrs
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-nfs@vger.kernel.org>
References: <20170803182623.14672.77636.stgit@manet.1015granger.net>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <e08a4b40-26c4-fb38-d8a9-e1c4497e6b9d@Netapp.com>
Date: Tue, 8 Aug 2017 16:54:15 -0400
MIME-Version: 1.0
In-Reply-To: <20170803182623.14672.77636.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/03/2017 02:29 PM, Chuck Lever wrote:
> Hi Anna-

Hi Chuck,

> 
> These patches harden xprtrdma's reply handler code path, particu-
> larly XDR decoding of incoming transport headers. I didn't copy
> linux-rdma on this series since it is strictly XDR-related.
> 
> Please have a look at these and let me know if they are not
> acceptable for v4.14.

Patches look okay to me.  Thanks!

Anna

> 
> ---
> 
> Chuck Lever (7):
>       xprtrdma: Add xdr_init_decode to rpcrdma_reply_handler()
>       xprtrdma: Harden backchannel call decoding
>       xprtrdma: Refactor rpcrdma_reply_handler()
>       xprtrdma: Replace rpcrdma_count_chunks()
>       xprtrdma: Remove opcode check in Receive completion handler
>       xprtrdma: Remove rpcrdma_rep::rr_len
>       xprtrdma: Clean up XDR decoding in rpcrdma_update_granted_credits()
> 
> 
>  include/linux/sunrpc/xdr.h        |   13 +
>  net/sunrpc/xprtrdma/backchannel.c |   40 +---
>  net/sunrpc/xprtrdma/rpc_rdma.c    |  422 +++++++++++++++++++++++--------------
>  net/sunrpc/xprtrdma/verbs.c       |   21 +-
>  net/sunrpc/xprtrdma/xprt_rdma.h   |   13 +
>  5 files changed, 304 insertions(+), 205 deletions(-)
> 
> --
> Chuck Lever
> 
