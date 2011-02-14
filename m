From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs-utils: calculate stripe device size during process
 phase
Date: Mon, 14 Feb 2011 15:45:12 -0500
Message-ID: <4D599458.8040004@panasas.com>
References: <20110214193233.GA3555@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5922 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab1BNUpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 15:45:14 -0500
In-Reply-To: <20110214193233.GA3555-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged.  Thanks!

Benny

On 2011-02-14 14:32, Jim Rees wrote:
> If a device has stripe device components, the total size will be wrong.
> Calculate the stripe device size earlier, during the process phase, so that
> later devices will have the correct size.
> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/blkmapd/device-process.c |    3 ++-
>  utils/blkmapd/dm-device.c      |    2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index b709b48..9a78457 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -318,7 +318,8 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
>  			}
>  		}
>  		/* Truncate size to a stripe unit boundary */
> -		vol->bv_size = vol->bv_vols[0]->bv_size & ~(chunksize - 1);
> +		vol->bv_size = vol->bv_vols[0]->bv_size * vol->bv_vol_n;
> +		vol->bv_size &= ~(chunksize - 1);
>  		break;
>  	case BLOCK_VOLUME_CONCAT:
>  		BLK_READBUF(p, end, 4);
> diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
> index 2e87db8..c4fe4e9 100644
> --- a/utils/blkmapd/dm-device.c
> +++ b/utils/blkmapd/dm-device.c
> @@ -418,7 +418,7 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  			stripe_size = stripe_unit * node->bv_vol_n;
>  			nstripes = node->bv_size * node->bv_vol_n / stripe_size;
>  			/* Make sure total size is a multiple of stripe size */
> -			size = node->bv_size * node->bv_vol_n;
> +			size = node->bv_size;
>  			if (size % stripe_size != 0) {
>  				/* XXX Should this be an error? */
>  				BL_LOG_WARNING(
