Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687Ab1CIAuE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2011 19:50:04 -0500
Date: Tue, 8 Mar 2011 19:49:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: roel <roel.kluin@gmail.com>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: wrong index used in inner loop
Message-ID: <20110309004955.GD15814@fieldses.org>
References: <4D76A06A.4090405@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D76A06A.4090405@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 08, 2011 at 10:32:26PM +0100, roel wrote:
> Index i was already used in the outer loop
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> Not 100% sure this one is needed but it looks suspicious.

Looks bad to me, thanks.

nfsd4_decode_create_session should probably really be broken up a little
bit; if it wasn't so long this would have been more obvious.

I'll see if I can slip this into 2.6.38 with a couple other last-minute
patches....  Otherwise, it'll be in 2.6.39.

--b.

> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 1275b86..615f0a9 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1142,7 +1142,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  
>  	u32 dummy;
>  	char *machine_name;
> -	int i;
> +	int i, j;
>  	int nr_secflavs;
>  
>  	READ_BUF(16);
> @@ -1215,7 +1215,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  			READ_BUF(4);
>  			READ32(dummy);
>  			READ_BUF(dummy * 4);
> -			for (i = 0; i < dummy; ++i)
> +			for (j = 0; j < dummy; ++j)
>  				READ32(dummy);
>  			break;
>  		case RPC_AUTH_GSS:
