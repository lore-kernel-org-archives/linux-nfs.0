Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbaHMOyT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 10:54:19 -0400
Message-ID: <53EB7C17.8050402@RedHat.com>
Date: Wed, 13 Aug 2014 10:54:15 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] blkmapd: dump useful device information to syslog
References: <1407396409-5036-1-git-send-email-hch@lst.de> <1407396409-5036-3-git-send-email-hch@lst.de>
In-Reply-To: <1407396409-5036-3-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/07/2014 03:26 AM, Christoph Hellwig wrote:
> Dump some information about used devices to syslog so that an admin
> can troubleshoot failing blocklayout mounts.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
Committed... after fixing a couple format warnings... 

steved.

> ---
>  utils/blkmapd/device-discovery.c | 6 +++++-
>  utils/blkmapd/device-process.c   | 2 ++
>  utils/blkmapd/dm-device.c        | 4 ++++
>  3 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index bcfb060..b52afe2 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -148,7 +148,11 @@ void bl_add_disk(char *filepath)
>  
>  	dev = sb.st_rdev;
>  	serial = bldev_read_serial(fd, filepath);
> -	if (dm_is_dm_major(major(dev)))
> +	if (!serial) {
> +		BL_LOG_ERR("%s: no serial found for %s\n",
> +				 __func__, filepath);
> +		ap_state = BL_PATH_STATE_PASSIVE;
> +	} else if (dm_is_dm_major(major(dev)))
>  		ap_state = BL_PATH_STATE_PSEUDO;
>  	else
>  		ap_state = bldev_read_ap_state(fd);
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index 5fe3dff..f53a616 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -181,6 +181,8 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
>  		/* FIXME: should we use better algorithm for disk scan? */
>  		mapped = verify_sig(disk, sig);
>  		if (mapped) {
> +			BL_LOG_INFO("%s: using device %s\n",
> +					__func__, disk->valid_path->full_path);
>  			vol->param.bv_dev = disk->dev;
>  			vol->bv_size = disk->size;
>  			break;
> diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
> index 0f4f148..8ffb19e 100644
> --- a/utils/blkmapd/dm-device.c
> +++ b/utils/blkmapd/dm-device.c
> @@ -400,6 +400,8 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  			}
>  			dev = node->bv_vols[0]->param.bv_dev;
>  			tmp = table->params;
> +			BL_LOG_INFO("%s: major %u minor %u", __func__,
> +					MAJOR(dev), MINOR(dev));
>  			if (!dm_format_dev(tmp, DM_PARAMS_LEN,
>  					   MAJOR(dev), MINOR(dev))) {
>  				free(table);
> @@ -459,6 +461,8 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
>  				strcpy(table->target_type, "linear");
>  				tmp = table->params;
>  				dev = node->bv_vols[i]->param.bv_dev;
> +				BL_LOG_INFO("%s: major %u minor %u", __func__,
> +					MAJOR(dev), MINOR(dev));
>  				if (!dm_format_dev(tmp, DM_PARAMS_LEN,
>  						   MAJOR(dev), MINOR(dev))) {
>  					free(table);
> 
