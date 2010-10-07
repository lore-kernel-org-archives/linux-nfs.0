Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og103.obsmtp.com ([64.18.0.145]:60369 "HELO
	exprod5og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750919Ab0JGSwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 14:52:42 -0400
Message-ID: <4CAE16FA.9040606@panasas.com>
Date: Thu, 07 Oct 2010 14:52:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] pnfs_submit: move layout segment valid test
References: <1286480230-9418-1-git-send-email-andros@netapp.com>
In-Reply-To: <1286480230-9418-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-07 15:37, andros@netapp.com wrote:
> From: Andy Adamson <andros@rhel6-1.androsmac.org>
> 
> Do not get_lseg for a non-valid lseg.
> Prepare for calling put_lseg outside of inode i_lock.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/pnfs.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6b2a95d..24620cf 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -845,7 +845,8 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
>  	list_for_each_entry(lseg, &lo->segs, fi_list) {
>  		if (is_matching_lseg(lseg, range)) {
>  			ret = lseg;
> -			get_lseg(ret);
> +			if (lseg->valid)
> +				get_lseg(ret);

We shouldn't be hiding this inside pnfs_has_layout
and have different side effects in the different cases.
Since we're called under the lock, pnfs_has_layout
can just return the lseg and never get a reference and its
caller can take it if necessary before releasing the lock.

Also, it doesn't need to be EXPORT_SYMBOL_GPLed as it's
not used outside of the nfs client module.

Benny

>  			break;
>  		}
>  		if (cmp_layout(range, &lseg->range) > 0)
> @@ -889,7 +890,6 @@ pnfs_update_layout(struct inode *ino,
>  	/* Check to see if the layout for the given range already exists */
>  	lseg = pnfs_has_layout(lo, &arg);
>  	if (lseg && !lseg->valid) {
> -		put_lseg_locked(lseg);
>  		/* someone is cleaning the layout */
>  		lseg = NULL;
>  		goto out_unlock;
