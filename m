From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 10/14] SQUASHME: nfs41: sunrpc: Don't skip past the RPC
 call direction
Date: Sun, 14 Jun 2009 10:34:34 -0400
Message-ID: <4A350A7A.7000008@panasas.com>
References: <> <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-10-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-11-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:8589
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755211AbZFNOed (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jun 2009 10:34:33 -0400
In-Reply-To: <1244786060-2200-11-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 12, 2009, 1:54 -0400, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> [squash with: nfs41: Skippast the RPC call direction]
> 
> xs_tcp_read_data() has been modified to include the RPC call direction in the
> XDR buffer.  We need to read the direction during the header verification.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  net/sunrpc/clnt.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index e7fffd2..d5a85a9 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1507,12 +1507,12 @@ rpc_verify_header(struct rpc_task *task)
>  	if ((len -= 3) < 0)
>  		goto out_overflow;
>  
> -	/*
> -	 * Skip the XID and call direction.
> -	 * The underlying transport has read the XID and RPC call direction
> -	 * to determine this is an RPC reply.
> -	 */
> -	p += 2;
> +	p += 1; /* skip XID */
> +	if ((n = ntohl(*p++)) != RPC_REPLY) {
> +		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
> +			task->tk_pid, __func__, n);
> +		goto out_garbage;
> +	}
>  
>  	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
>  		if (--len < 0)

BTW, for bisectability reasons it looks like this patch needs to
be part of the previous patch:
"[PATCH 09/14] SQUASHME: nfs41: sunrpc: Add RPC direction back into the XDR buffer"
Otherwise it introduces a bug that this patch fixes.
(just a nit, not that it matters much if both are to be squashed
into the same patch eventually)

Benny
