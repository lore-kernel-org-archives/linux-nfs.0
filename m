Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:50456 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750915Ab2BOSRz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 13:17:55 -0500
Message-ID: <4F3BF6D3.8060301@opengridcomputing.com>
Date: Wed, 15 Feb 2012 12:17:55 -0600
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Marc Aurele La France <tsi@ualberta.ca>
CC: linux-nfs@vger.kernel.org
Subject: Re: RFC:  NFS/RDMA, IPoIB MTU and [rw]size
References: <alpine.WNT.2.00.1201121214340.2732@cluij.aict.ualberta.ca>
In-Reply-To: <alpine.WNT.2.00.1201121214340.2732@cluij.aict.ualberta.ca>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Marc,

This looks correct to me. I assume these are v3 mounts?

BTW, the when you say you're running NFS/TCP are you running TCP over IPoIB?

Thanks,
Tom


On 1/12/12 1:17 PM, Marc Aurele La France wrote:
> Greetings.
>
> I am currently in the process of moving a cluster I administer from
> NFS/TCP to NFS/RDMA, and am running into a number of issues I'd like some
> assistance with.  Googling these doesn't help.
>
> For background on what caused me to move to NFS/TCP in the first place,
> please see the thread that starts at http://lkml.org/lkml/2010/8/23/204
>
> The main reason I'm moving away from NFS/TCP is that something happened in
> the later kernels that reduces its resilience.  Specifically, the client
> now permanently loses contact with the server whenever the latter fails to
> allocate an RPC sk_buff due to memory fragmentation.  Restarting the
> server's nfsd's fixes this problem, at least temporarily.
>
> I haven't nailed down when this started happening (somewhere since
> 2.6.38), nor am I inclined to do so.  This new experience (for me) with
> NFS/TCP has conclusively shown me that it is much more responsive with
> smaller IPoIB MTU's.  Thus I will instead be reducing that MTU from its
> connected mode maximum of 65520, perhaps all the way down to datagram
> mode's 2044, to completely factor out memory fragmentation effects.  More
> on that below.
>
> In moving to NFS/RDMA and reducing the IPoIB MTU, I have seen the
> following behaviours.
>
> -- 
>
> 1) Random client-side BUG()'outs.  In fact, these never finish producing a
> complete stack trace.  I've tracked this down to duplicate replies being
> encountered by rpcrdma_reply_handler() in net/sunrpc/xprtrdma/rpc_rdma.c.
> Frankly I don't see why rpcrdma_reply_handler() should BUG() out in that
> case given TCP's behaviour in similar situations, documented requirements
> for the use of BUG() & friends in the first place, and the fact that
> rpcrdma_reply_handler() essentially "ignores" replies for which it cannot
> find a corresponding request.
>
> For the past few days now, I've been running the following on some of my
> nodes with no ill effects.  And yes, I do see the log message this
> produces.  This changes rpcrdma_reply_handler() to treat duplicate replies
> in much the same way it treats replies for which it cannot find a request.
>
> diff -adNpru linux-3.1.6/net/sunrpc/xprtrdma/rpc_rdma.c 
> devel-3.1.6/net/sunrpc/xprtrdma/rpc_rdma.c
> --- linux-3.1.6/net/sunrpc/xprtrdma/rpc_rdma.c    2011-12-21 
> 14:00:46.000000000 -0700
> +++ devel-3.1.6/net/sunrpc/xprtrdma/rpc_rdma.c    2011-12-29 
> 07:25:59.000000000 -0700
> @@ -776,7 +776,13 @@ repost:
>          "                   RPC request 0x%p xid 0x%08x\n",
>              __func__, rep, req, rqst, headerp->rm_xid);
>
> -    BUG_ON(!req || req->rl_reply);
> +    /* req cannot be NULL here */
> +    if (req->rl_reply) {
> +        spin_unlock(&xprt->transport_lock);
> +        printk(KERN_NOTICE "RPC: %s: duplicate replies to request 0x%p: "
> +            "0x%p and 0x%p\n", __func__, req, req->rl_reply, rep);
> +        goto repost;
> +    }
>
>      /* from here on, the reply is no longer an orphan */
>      req->rl_reply = rep;
>
> This would also apply, modulo patch fuzz, all the way back to 2.6.24.
>
> -- 
>
> 2) Still client-side, I'm seeing a lot of these sequences ...
>
> rpcrdma: connection to 10.0.6.1:20049 on mthca0, memreg 6 slots 32 ird 4
> rpcrdma: connection to 10.0.6.1:20049 closed (-103)
>
> 103 is ECONNABORTED.  memreg 6 is RPCRDMA_ALLPHYSICAL, so I'm assuming my
> Mellanox adapters don't support the default RPCRDMA_FRMR (memreg 5).  I've
> traced these aborted connections to IB_CM_DREP_RECEIVED events being
> received by cma_ib_handler() in drivers/infiniband/core/cma.c, but can go
> no further given my limited understanding of what this code is supposed to
> do.  I am guessing though, that these would presumably disappear when
> switching back to datagram mode (cm == connected mode).  These messages
> don't appear to affect anything (the client simply reconnects and I've
> seen no data corruption), but it would still be nice to know what's going
> on here.
>
> -- 
>
> 3) isn't related to NFS/RDMA per se, but to my attempts at reducing the
> IPoIB MTU.  Whenever I do so on the fly across the cluster, some but not
> all, IPoIB traffic simply times out.  Even, in some cases, TCP connections
> accept()'ed after the MTU reduction.  Oddly, neither NFS/TCP nor NFS/RDMA
> seem affected, but other things (MPI apps, torque, etc.) are, whether
> started before or after the change.  So, something, somewhere, remembers
> the previous (larger) MTU (opensm?).  It seems that the only way to clear
> this "memory" is to reboot the entire cluster, something I'd rather avoid
> if possible.
>
> -- 
>
> 4) Lastly, I would like to ask for a better understanding of the
> relationship, if any, between NFS/RDMA and the IPoIB MTU, and between
> NFS/RDMA and [rw]size NFS mount parameters.  What effect do these have on
> NFS/RDMA?  For [rw]size, I have found that specifying less than a page 
> (4K) results in data corruption.
>
> -- 
>
> Please CC me on any comments/flames about any of the above as I am not
> subscribed to this list.
>
> Thanks.
>
> Marc.
>
> +----------------------------------+----------------------------------+
> |  Marc Aurele La France           |  work:   1-780-492-9310          |
> |  Academic Information and        |  fax:    1-780-492-1729          |
> |    Communications Technologies   |  email:  tsi@ualberta.ca         |
> |  352 General Services Building   +----------------------------------+
> |  University of Alberta           |                                  |
> |  Edmonton, Alberta               |    Standard disclaimers apply    |
> |  T6G 2H1                         |                                  |
> |  CANADA                          |                                  |
> +----------------------------------+----------------------------------+
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

