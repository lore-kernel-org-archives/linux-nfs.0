Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e4.ny.us.ibm.com ([32.97.182.144]:38646 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754386Ab2BOWI7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:08:59 -0500
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 15 Feb 2012 17:08:58 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 41B9138C8063
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 17:05:25 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1FM5ON6200038
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 17:05:24 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1FM5Okf006398
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 17:05:24 -0500
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q1FM5OwN006387
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 17:05:24 -0500
Date: Wed, 15 Feb 2012 16:05:23 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/13] SUNRPC: Use KERN_DEFAULT for debugging printk's
Message-ID: <20120215220523.GA24995@us.ibm.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
 <20120215213508.3254.64687.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120215213508.3254.64687.stgit@ellison.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most of the dprintk() callers are using __func__. Not sure if adding
that to the dprintk itself is a good idea. In any case, it will have to
be a separate patchset though.

Regards, Malahal.

Chuck Lever [chuck.lever@oracle.com] wrote:
> Our dprintk() debugging facility doesn't specify any verbosity level
> for it's printk() calls, but it should.
> 
> The default verbosity for printk's is KERN_DEFAULT.  You might argue
> that these are debugging printk's and thus the verbosity should be
> KERN_DEBUG.  That would mean that to see NFS and SUNRPC debugging
> output an admin would also have to boost the syslog verbosity, which
> would be insufferably noisy.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/debug.h |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
> index c2786f2..e0927c2 100644
> --- a/include/linux/sunrpc/debug.h
> +++ b/include/linux/sunrpc/debug.h
> @@ -51,7 +51,11 @@ extern unsigned int		nlm_debug;
>  #undef ifdebug
>  #ifdef RPC_DEBUG			
>  # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
> -# define dfprintk(fac, args...)	do { ifdebug(fac) printk(args); } while(0)
> +# define dfprintk(fac, args...)	\
> +	do { \
> +		ifdebug(fac) \
> +			printk(KERN_DEFAULT args); \
> +	} while (0)
>  # define RPC_IFDEBUG(x)		x
>  #else
>  # define ifdebug(fac)		if (0)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

