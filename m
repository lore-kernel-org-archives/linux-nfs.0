Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:34783 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754539Ab2CBSrH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 13:47:07 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 2 Mar 2012 13:47:06 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 52C9F6E8054
	for <linux-nfs@vger.kernel.org>; Fri,  2 Mar 2012 13:45:58 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q22IjvhR257216
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 13:45:58 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q22IjvE3004907
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 15:45:57 -0300
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q22Ijvib004858
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 15:45:57 -0300
Date: Fri, 2 Mar 2012 12:45:56 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: strip of extra slashes in device name
Message-ID: <20120302184556.GA6880@us.ibm.com>
References: <1330707221-4005-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1330707221-4005-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My kernel doesn't seem to strip '/' from its /proc/mounts. What kernel
are you using? Anyway, how about something similar to the following
patch that fixes only NFSv4 atm:

http://www.spinics.net/lists/linux-nfs/msg27351.html

Regards, Malahal.

Steve Dickson [steved@redhat.com] wrote:
> The kernel strips off extra '/' when the  device is entered
> into /proc/mounts. So that umounts can this devices, strip off
> any extra '/' before storing the device in the mtab.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/mount.c |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index eea00af..eb63f50 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -485,6 +485,24 @@ int main(int argc, char *argv[])
>  		goto out;
>  	}
>  	/*
> +	 * The kernel strips off extra '/' when the device is entered 
> +	 * into /proc/mounts. So that umounts can this devices, strip off
> +	 * any extra '/' before storing the device in the mtab.
> +	 */
> +	if (strstr(spec, "//") != NULL) {
> +		char *colen, *slash;
> +
> +		if ((colen = strchr(spec, ':'))) {
> +			slash = (colen + 1);
> +			while (*slash && *(slash+1) == '/')
> +				slash++;
> +			while (*slash)
> +				*(++colen) = *(slash++);
> +			*(colen+1) = '\0';
> +		}
> +	}
> +
> +	/*
>  	 * Concatenate mount options from the configuration file
>  	 */
>  	mount_opts = mount_config_opts(spec, mount_point, mount_opts);
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

