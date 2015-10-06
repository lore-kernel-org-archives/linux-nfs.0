Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19127 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbbJFPF6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 11:05:58 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH rdma-rc] xprtrdma: Don't require LOCAL_DMA_LKEY support for fasterg
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1444124889-8957-1-git-send-email-sagig@mellanox.com>
Date: Tue, 6 Oct 2015 11:05:53 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <56C57483-17AA-47FF-8743-E1522BD8C351@oracle.com>
References: <1444124889-8957-1-git-send-email-sagig@mellanox.com>
To: Sagi Grimberg <sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sagi-


> On Oct 6, 2015, at 5:48 AM, Sagi Grimberg <sagig@mellanox.com> wrote:
> 
> There is no need to require LOCAL_DMA_LKEY support in order to
> use fast registration as the PD allocation makes sure that there
> is a local_dma_lkey.

In other words, all devices now have a local DMA lkey, so the
check is unnecessary.


> This caused a NULL pointer dereference in mlx5 which removed
> the support for LOCAL_DMA_LKEY.

Where was the bad dereference? in mlx5, or in xprtrdma?


> Fixes: bb6c96d72879 ("xprtrdma: Replace global lkey with lkey local to PD")
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> ---
> net/sunrpc/xprtrdma/verbs.c |    7 ++-----
> 1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index eb081ad..7efd9ef 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -543,11 +543,8 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
> 	}
> 
> 	if (memreg == RPCRDMA_FRMR) {
> -		/* Requires both frmr reg and local dma lkey */
> -		if (((devattr->device_cap_flags &
> -		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=
> -		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) ||
> -		      (devattr->max_fast_reg_page_list_len == 0)) {
> +		if (!(devattr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) ||
> +		    (devattr->max_fast_reg_page_list_len == 0)) {
> 			dprintk("RPC:       %s: FRMR registration "
> 				"not supported by HCA\n", __func__);
> 			memreg = RPCRDMA_MTHCAFMR;

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


—
Chuck Lever



