Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:17128 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758AbcCNTAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2016 15:00:00 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [GIT PULL] Please pull NFSoRDMA client changes for 4.6
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <56E33462.6060003@Netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <56E70A29.8040301@Netapp.com>
Date: Mon, 14 Mar 2016 14:59:53 -0400
MIME-Version: 1.0
In-Reply-To: <56E33462.6060003@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ignore this, I just realized I forgot to add my signed-off-by lines.  I'll resend!

Anna

On 03/11/2016 04:10 PM, Anna Schumaker wrote:
> Hi Trond,
> 
> The following changes since commit fc77dbd34c5c99bce46d40a2491937c3bcbd10af:
> 
>   Linux 4.5-rc6 (2016-02-28 08:41:20 -0800)
> 
> are available in the git repository at:
> 
>   git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.6
> 
> for you to fetch changes up to 50340ef97f0ae41211084cbc23a629600918a2dd:
> 
>   xprtrdma: Use new CQ API for RPC-over-RDMA client send CQs (2016-03-11 15:51:16 -0500)
> 
> Thanks,
> Anna
> 
> ----------------------------------------------------------------
> Chuck Lever (11):
>       xprtrdma: Clean up unused RPCRDMA_INLINE_PAD_THRESH macro
>       xprtrdma: Clean up physical_op_map()
>       xprtrdma: Clean up dprintk format string containing a newline
>       xprtrdma: Segment head and tail XDR buffers on page boundaries
>       xprtrdma: Do not wait if ib_post_send() fails
>       rpcrdma: Add RPCRDMA_HDRLEN_ERR
>       xprtrdma: Properly handle RDMA_ERROR replies
>       xprtrdma: Serialize credit accounting again
>       xprtrdma: Use new CQ API for RPC-over-RDMA client receive CQs
>       xprtrdma: Use an anonymous union in struct rpcrdma_mw
>       xprtrdma: Use new CQ API for RPC-over-RDMA client send CQs
> 
>  include/linux/sunrpc/rpc_rdma.h    |  12 ++---
>  include/linux/sunrpc/xprtrdma.h    |   2 -
>  net/sunrpc/xprtrdma/fmr_ops.c      |  28 ++++++------
>  net/sunrpc/xprtrdma/frwr_ops.c     | 143 ++++++++++++++++++++++++++++++++++++++---------------------
>  net/sunrpc/xprtrdma/physical_ops.c |   1 -
>  net/sunrpc/xprtrdma/rpc_rdma.c     | 108 ++++++++++++++++++++++++++++++++-------------
>  net/sunrpc/xprtrdma/verbs.c        | 204 ++++++++++++++++++++++++++-----------------------------------------------------------
>  net/sunrpc/xprtrdma/xprt_rdma.h    |  14 +++---
>  8 files changed, 259 insertions(+), 253 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

