From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] SQUASHME: nfs41: get rid of READ64 in
 callback_xdr.c
Date: Wed, 17 Jun 2009 11:06:33 -0700
Message-ID: <1245261993.5354.18.camel@heimdal.trondhjem.org>
References: <1245259327-9403-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27627 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbZFQSKT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 14:10:19 -0400
In-Reply-To: <1245259327-9403-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-06-17 at 20:22 +0300, Benny Halevy wrote:
> This was only used later on by the pnfs code.
> 
> Fixes Trond's review comment from 2009-06-15:
> Re: [pnfs] [RFC 31/39] nfs41: cb_sequence xdr implementation
> http://linux-nfs.org/pipermail/pnfs/2009-June/007846.html
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/callback_xdr.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 28242a0..e5a2dac 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -27,11 +27,6 @@
>  
>  #define NFSDBG_FACILITY NFSDBG_CALLBACK
>  
> -#define READ64(x)         do {			\
> -	(x) = (u64)ntohl(*p++) << 32;		\
> -	(x) |= ntohl(*p++);			\
> -} while (0)
> -
>  typedef __be32 (*callback_process_op_t)(void *, void *);
>  typedef __be32 (*callback_decode_arg_t)(struct svc_rqst *, struct xdr_stream *, void *);
>  typedef __be32 (*callback_encode_res_t)(struct svc_rqst *, struct xdr_stream *, void *);

All 3 patches acked...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
