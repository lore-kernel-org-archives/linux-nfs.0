Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246Ab1JCMys (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Oct 2011 08:54:48 -0400
Message-ID: <4E89B094.4030308@RedHat.com>
Date: Mon, 03 Oct 2011 08:54:44 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Luk Claes <luk@debian.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] blkmapd: Use getconf(_SC_PAGE_SIZE)
References: <1317576450-26056-1-git-send-email-luk@debian.org>
In-Reply-To: <1317576450-26056-1-git-send-email-luk@debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/02/2011 01:27 PM, Luk Claes wrote:
> PAGE_SIZE is not exported by all architectures as it is not fixed: it can depend on the model of the machine. So it's better to query the system configuration for the actual page size on the machine.
> 
> Signed-off-by: Luk Claes <luk@debian.org>
Committed...

steved.
> ---
>  utils/blkmapd/device-process.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index 27ff374..652a7a8 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -296,7 +296,7 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
>  		off_t stripe_unit = vol->param.bv_stripe_unit;
>  		/* Check limitations imposed by device-mapper */
>  		if ((stripe_unit & (stripe_unit - 1)) != 0
> -		    || stripe_unit < (off_t) (PAGE_SIZE >> 9))
> +		    || stripe_unit < (off_t) (sysconf(_SC_PAGE_SIZE) >> 9))
>  			return -EIO;
>  		BLK_READBUF(p, end, 4);
>  		READ32(vol->bv_vol_n);
