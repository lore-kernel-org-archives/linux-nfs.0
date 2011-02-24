From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs-utils: fix stripe device size calculation for layouts
 not a multiple of stripe unit
Date: Wed, 23 Feb 2011 18:31:14 -0800
Message-ID: <4D65C2F2.5080808@panasas.com>
References: <20110223193016.GA14849@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16013 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160Ab1BXCbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 21:31:11 -0500
In-Reply-To: <20110223193016.GA14849-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me.
Merged at pnfs-nfs-utils-1-2-4-rc5-2011-02-23

Benny

On 2011-02-23 11:30, Jim Rees wrote:
> If a complex layout has a stripe volume in it, and that volume has a size
> that is not a multiple of the stripe unit, the total layout size will be
> wrong because it is based on the truncated stripe volume size.  Fix this by
> using the truncated size for making the mapped device, and the untruncated
> size in the table for subsequent devices to use.
> 
> Also remove the warning for stripe volumes not a multiple of the stripe
> width, since this is legal and apparently common.
> 
> While we're at it, use variable names consistent with the terminology in
> rfc5661 section 13.2.
> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/blkmapd/device-process.c |   10 ++++------
>  utils/blkmapd/dm-device.c      |   21 +++++----------------
>  2 files changed, 9 insertions(+), 22 deletions(-)
> 
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index 9a78457..79e596d 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -295,10 +295,10 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
>  	case BLOCK_VOLUME_STRIPE:
>  		BLK_READBUF(p, end, 8);
>  		READ_SECTOR(vol->param.bv_stripe_unit);
> -		off_t chunksize = vol->param.bv_stripe_unit;
> +		off_t stripe_unit = vol->param.bv_stripe_unit;
>  		/* Check limitations imposed by device-mapper */
> -		if ((chunksize & (chunksize - 1)) != 0
> -		    || chunksize < (off_t) (PAGE_SIZE >> 9))
> +		if ((stripe_unit & (stripe_unit - 1)) != 0
> +		    || stripe_unit < (off_t) (PAGE_SIZE >> 9))
>  			return -EIO;
>  		BLK_READBUF(p, end, 4);
>  		READ32(vol->bv_vol_n);
> @@ -306,7 +306,7 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
>  			return -EIO;
>  		*array_cnt = vol->bv_vol_n;
>  		BL_LOG_INFO("%s: stripe %d nvols=%d unit=%ld\n", __func__, voln,
> -			    vol->bv_vol_n, (long)chunksize);
> +			    vol->bv_vol_n, (long)stripe_unit);
>  		status = set_vol_array(&p, end, vols, voln);
>  		if (status)
>  			return status;
> @@ -317,9 +317,7 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
>  				return -EIO;
>  			}
>  		}
> -		/* Truncate size to a stripe unit boundary */
>  		vol->bv_size = vol->bv_vols[0]->bv_size * vol->bv_vol_n;
> -		vol->bv_size &= ~(chunksize - 1);
>  		break;
>  	case BLOCK_VOLUME_CONCAT:
>  		BLK_READBUF(p, end, 4);
> diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
> index c4fe4e9..0f4f148 100644
> --- a/utils/blkmapd/dm-device.c
> +++ b/utils/blkmapd/dm-device.c
> @@ -369,7 +369,7 @@ static int dm_device_exists(char *dev_name)
>  /* TODO: check the value for DM_DEV_NAME_LEN, DM_TYPE_LEN, DM_PARAMS_LEN */
>  uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  {
> -	uint64_t size, stripe_unit, stripe_size, nstripes, dev = 0;
> +	uint64_t size, stripe_unit, dev = 0;
>  	unsigned int count = dev_count;
>  	int volnum, i, pos;
>  	struct bl_volume *node;
> @@ -414,21 +414,10 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  			if (!table)
>  				goto out;
>  			table->offset = 0;
> -			stripe_unit = node->param.bv_stripe_unit << 9;
> -			stripe_size = stripe_unit * node->bv_vol_n;
> -			nstripes = node->bv_size * node->bv_vol_n / stripe_size;
> -			/* Make sure total size is a multiple of stripe size */
> -			size = node->bv_size;
> -			if (size % stripe_size != 0) {
> -				/* XXX Should this be an error? */
> -				BL_LOG_WARNING(
> -					"%s: %d units of %llu bytes is not a multiple of %lld stripe size\n",
> -					__func__, node->bv_vol_n,
> -					(long long unsigned) node->bv_size,
> -					(long long unsigned) stripe_size);
> -				size = nstripes * stripe_size;
> -			}
> -			table->size = size;
> +			/* Truncate size to a stripe unit boundary */
> +			stripe_unit = node->param.bv_stripe_unit;
> +			table->size =
> +			    node->bv_size - (node->bv_size % stripe_unit);
>  			strcpy(table->target_type, "striped");
>  			sprintf(table->params, "%d %llu %n", node->bv_vol_n,
>  				(long long unsigned) stripe_unit, &pos);
