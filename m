Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45080 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbbAZXdx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jan 2015 18:33:53 -0500
Message-ID: <54C6CEDD.40808@oracle.com>
Date: Mon, 26 Jan 2015 15:33:49 -0800
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: Adjust rpciod workqueue parameters
References: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond,

workqueue WQ_UNBOUND flag is also needed. Some customer hit a problem, RT thread caused rpciod starvation. It is easy to reproduce it with running a cpu intensive workload with lower nice value than rpciod workqueue on the cpu the network interrupt is received.

I've also tested iozone and fio test with WQ_UNBOUND|WQ_SYSFS flag on for NFS/RDMA, NFS/IPoIB. The results are better than BOUND.

Thanks,
Shirley

On 01/24/2015 04:18 PM, Trond Myklebust wrote:
> Increase the concurrency level for rpciod threads to allow for allocations
> etc that happen in the RPCSEC_GSS layer. Also note that the NFSv4 byte range
> locks may now need to allocate memory from inside rpciod.
> 
> Add the WQ_HIGHPRI flag to improve latency guarantees while we're at it.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/sched.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index d20f2329eea3..4f65ec28d2b4 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -1069,7 +1069,8 @@ static int rpciod_start(void)
>  	 * Create the rpciod thread and wait for it to start.
>  	 */
>  	dprintk("RPC:       creating workqueue rpciod\n");
> -	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 1);
> +	/* Note: highpri because network receive is latency sensitive */
> +	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
>  	rpciod_workqueue = wq;
>  	return rpciod_workqueue != NULL;
>  }
> 
