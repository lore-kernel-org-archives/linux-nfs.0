Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2on0097.outbound.protection.outlook.com ([65.55.169.97]:52236
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756438AbbIYQ3t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 12:29:49 -0400
Subject: Re: [PATCH v2 15/26] IB/srp: Split srp_map_sg
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
 <1443116118-10730-16-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <56057320.4010905@sandisk.com>
Date: Fri, 25 Sep 2015 09:15:28 -0700
MIME-Version: 1.0
In-Reply-To: <1443116118-10730-16-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/24/2015 10:35 AM, Sagi Grimberg wrote:
> This is a perparation patch for the new registration API
             ^ preparation ?

> conversion. It splits srp_map_sg per registration strategy
> (srp_map_sg[fmr|fr|dma]. On its own it adds some code duplication,
> but it makes the API switch easier to comprehend.
>
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> ---
>   drivers/infiniband/ulp/srp/ib_srp.c | 156 ++++++++++++++++++++++++------------
>   1 file changed, 105 insertions(+), 51 deletions(-)
>
> diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
> index f8b9c18da03d..74748d1075fc 100644
> --- a/drivers/infiniband/ulp/srp/ib_srp.c
> +++ b/drivers/infiniband/ulp/srp/ib_srp.c
> @@ -1286,6 +1286,17 @@ static int srp_map_finish_fmr(struct srp_map_state *state,
>   	if (WARN_ON_ONCE(state->fmr.next >= state->fmr.end))
>   		return -ENOMEM;
>
> +	WARN_ON_ONCE(!dev->use_fmr);
> +
> +	if (state->npages == 0)
> +		return 0;
> +
> +	if (state->npages == 1 && target->global_mr) {
> +		srp_map_desc(state, state->base_dma_addr, state->dma_len,
> +			     target->global_mr->rkey);
> +		return 0;
> +	}
> +

The above is not correct. The npages and dma_len variables have to be 
reset before returning. How about changing the "return 0" statement into 
"goto reset_state" and adding a "reset_state" label ?

>   	fmr = ib_fmr_pool_map_phys(ch->fmr_pool, state->pages,
>   				   state->npages, io_addr);
>   	if (IS_ERR(fmr))
> @@ -1297,6 +1308,9 @@ static int srp_map_finish_fmr(struct srp_map_state *state,
>   	srp_map_desc(state, state->base_dma_addr & ~dev->mr_page_mask,
>   		     state->dma_len, fmr->fmr->rkey);
>
> +	state->npages = 0;
> +	state->dma_len = 0;
> +
>   	return 0;
>   }
>
> @@ -1309,10 +1323,23 @@ static int srp_map_finish_fr(struct srp_map_state *state,
>   	struct ib_fast_reg_wr wr;
>   	struct srp_fr_desc *desc;
>   	u32 rkey;
> +	int err;
> +
>
>   	if (WARN_ON_ONCE(state->fr.next >= state->fr.end))
>   		return -ENOMEM;
>
> +	WARN_ON_ONCE(!dev->use_fast_reg);
> +
> +	if (state->npages == 0)
> +		return 0;
> +
> +	if (state->npages == 1 && target->global_mr) {
> +		srp_map_desc(state, state->base_dma_addr, state->dma_len,
> +			     target->global_mr->rkey);
> +		return 0;
> +	}
> +

Same comment here. npages and dma_len have to be reset before returning.

Bart.
