Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38125 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbbGTRNZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 13:13:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH RFC] svcrdma: Fix possible over population fast_reg_page_list
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1437411614-29722-1-git-send-email-sagig@mellanox.com>
Date: Mon, 20 Jul 2015 13:13:18 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Steve Wise <swise@opengridcomputing.com>
Message-Id: <C3FCF5F9-07D6-4A6D-8114-CB700038797E@oracle.com>
References: <1437411614-29722-1-git-send-email-sagig@mellanox.com>
To: Sagi Grimberg <sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 20, 2015, at 1:00 PM, Sagi Grimberg <sagig@mellanox.com> wrote:

> When accounting the needed_pages, we need to look into
> the page_list->max_page_list_len and not the global
> context xprt->sc_frmr_pg_list_len.
> 
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> ---
> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 2e1348b..b19ffd3 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -244,7 +244,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
> 
> 	ctxt->direction = DMA_FROM_DEVICE;
> 	ctxt->frmr = frmr;
> -	pages_needed = min_t(int, pages_needed, xprt->sc_frmr_pg_list_len);
> +	pages_needed = min_t(int, pages_needed,
> +			     frmr->page_list->max_page_list_len);

This is the last user of sc_frmr_pg_list_len. If Steve thinks this is
a good change, then why not remove it.

The client uses ib_device_attr::max_fast_reg_page_list_len too.
Should it be fixed?


> 	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
> 
> 	frmr->kva = page_address(rqstp->rq_arg.pages[pg_no]);

--
Chuck Lever



