Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:50073 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab1FMUcx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 16:32:53 -0400
Received: by pzk9 with SMTP id 9so2297122pzk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2011 13:32:53 -0700 (PDT)
Message-ID: <4DF673F2.4020707@gmail.com>
Date: Mon, 13 Jun 2011 16:32:50 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: andros@netapp.com
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Bakeathon 1/2] NFSv4.1: allow zero fh array in filelayout
 decode layout
References: <1307995906-4177-1-git-send-email-andros@netapp.com>
In-Reply-To: <1307995906-4177-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-13 16:11, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> cc:stable@kernel.org [2.6.39]
> ---
>  fs/nfs/nfs4filelayout.c |   13 ++++++++-----
>  1 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 2cfeaeb..3a8bd92 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -551,13 +551,16 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
>  		__func__, nfl_util, fl->num_fh, fl->first_stripe_index,
>  		fl->pattern_offset);
>  
> -	if (!fl->num_fh)
> +	if (fl->num_fh < 0 || fl->num_fh >

num_fh is unsigned so checking for < 0 is not really needed.

Benny

> +	    max(NFS4_PNFS_MAX_STRIPE_CNT, NFS4_PNFS_MAX_MULTI_CNT))
>  		goto out_err;
>  
> -	fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
> -			       gfp_flags);
> -	if (!fl->fh_array)
> -		goto out_err;
> +	if (fl->num_fh > 0) {
> +		fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
> +				       gfp_flags);
> +		if (!fl->fh_array)
> +			goto out_err;
> +	}
>  
>  	for (i = 0; i < fl->num_fh; i++) {
>  		/* Do we want to use a mempool here? */
