From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/5] nfs41: fix wrong error on callback decode hdr
 overflow
Date: Mon, 11 Jan 2010 18:08:39 -0500
Message-ID: <1263251319.2663.6.camel@localhost>
References: <1262802213-2267-1-git-send-email-andros@netapp.com>
	 <1262802213-2267-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32679 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647Ab0AKXJL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jan 2010 18:09:11 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0BN99he023647
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jan 2010 15:09:10 -0800 (PST)
In-Reply-To: <1262802213-2267-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-06 at 13:23 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> decode_op_hdr returns NFS4ERR_RESOURCE on decode buffer overflow which is
> correct for v4.0. Will fix the return for v4.1 along with all the other
> NFS4ERR_RESOURCE overflow errors in a later patch.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback_xdr.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 8e1a251..e24487d 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -605,17 +605,15 @@ static __be32 process_op(uint32_t minorversion, int nop,
>  		struct xdr_stream *xdr_out, void *resp)
>  {
>  	struct callback_op *op = &callback_ops[0];
> -	unsigned int op_nr = OP_CB_ILLEGAL;
> +	unsigned int op_nr;

This will cause us to return a random op number in the case where the
buffer overflows.

> 	__be32 status;
>  	long maxlen;
>  	__be32 res;
>  
>  	dprintk("%s: start\n", __func__);
>  	status = decode_op_hdr(xdr_in, &op_nr);
> -	if (unlikely(status)) {
> -		status = htonl(NFS4ERR_OP_ILLEGAL);
> +	if (unlikely(status))
>  		goto out;
> -	}
>  
>  	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
>  		__func__, minorversion, nop, op_nr);

The correct thing to do would appear to be rather to set
NFS4ERR_RESOURCE in the CB_COMPOUND return value, and simply not to
return an op here at all.

Trond
