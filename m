From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount: segmentation faults on UDP mounts
Date: Tue, 17 Feb 2009 15:51:58 -0500
Message-ID: <6ADC5253-D4DE-4893-B88E-5EA4DD982C05@oracle.com>
References: <499B2175.8030203@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:41431 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbZBQUw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 15:52:56 -0500
In-Reply-To: <499B2175.8030203-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Acked-by: Chuck Lever <chuck.lever@oracle.com>

On Feb 17, 2009, at Feb 17, 2009, 3:43 PM, Steve Dickson wrote:

> This came in over the weekend... when a server only supports
> UDP mounts, mount seg faults... this patch fixes the problem...
>
> steved.
>
> commit 52ec1b5fceece8f63b97afc6d6b78bfabff12669
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Feb 17 15:33:58 2009 -0500
>
>    The mount sockaddr len (mnt_salen) is not be set in
>    nfs_extract_server_addresses() which causes the mount.nfs
>    command to segmentation fault when a NFS server only
>    supports UDP mounts.
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 770b5b5..c369136 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -331,9 +331,10 @@ static int nfs_extract_server_addresses(struct  
> mount_options *options,
> 		return 0;
>
> 	option = po_get(options, "mountaddr");
> -	if (option == NULL)
> +	if (option == NULL) {
> 		memcpy(mnt_saddr, nfs_saddr, *nfs_salen);
> -	else if (!nfs_string_to_sockaddr(option, strlen(option),
> +		*mnt_salen = *nfs_salen;
> +	} else if (!nfs_string_to_sockaddr(option, strlen(option),
> 						mnt_saddr, mnt_salen))
> 		return 0;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
