Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24032 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbJFQf6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 12:35:58 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH rdma-rc] xprtrdma: Don't require LOCAL_DMA_LKEY support for fasterg
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5613F684.3020904@dev.mellanox.co.il>
Date: Tue, 6 Oct 2015 12:35:52 -0400
Cc: Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <99F91046-F9B1-4EBC-ADFD-AE00A3E72B64@oracle.com>
References: <1444124889-8957-1-git-send-email-sagig@mellanox.com> <56C57483-17AA-47FF-8743-E1522BD8C351@oracle.com> <5613F684.3020904@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 6, 2015, at 12:27 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
>> On 10/6/2015 6:05 PM, Chuck Lever wrote:
>> Hi Sagi-
>> 
>> 
>>> On Oct 6, 2015, at 5:48 AM, Sagi Grimberg <sagig@mellanox.com> wrote:
>>> 
>>> There is no need to require LOCAL_DMA_LKEY support in order to
>>> use fast registration as the PD allocation makes sure that there
>>> is a local_dma_lkey.
>> 
>> In other words, all devices now have a local DMA lkey, so the
>> check is unnecessary.
> 
> Right.
> 
>> 
>> 
>>> This caused a NULL pointer dereference in mlx5 which removed
>>> the support for LOCAL_DMA_LKEY.
>> 
>> Where was the bad dereference? in mlx5, or in xprtrdma?
> 
> xprtrdma, ia->ri_ops wasn't assigned correctly.
> 
> Now that I look at it, one error path in rpcrdma_ia_open misses
> an rc assignment. That needs to be fixed too, should it be in the same
> patch?

Go for it.


> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 7efd9ef..81e8d31 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -554,6 +554,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
>                if (!ia->ri_device->alloc_fmr) {
>                        dprintk("RPC:       %s: MTHCAFMR registration "
>                                "not supported by HCA\n", __func__);
> +                       rc = -EINVAL;
>                        goto out3;
>                }
>        }
> --
> 
> the incorrect requirement + missing rc caused the NULL deref of
> ia->ri_ops.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
