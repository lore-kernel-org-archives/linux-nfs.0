Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751131AbdBBLW2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Feb 2017 06:22:28 -0500
Subject: Re: [PATCH] [nfs-utils] fix mount fail that caused by uninitialized
 struct
To: yin-jianhong@163.com, linux-nfs@vger.kernel.org
References: <1485067624-3659-1-git-send-email-yin-jianhong@163.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <0d557242-7169-eaab-77de-c42bd384dcac@RedHat.com>
Date: Thu, 2 Feb 2017 06:22:27 -0500
MIME-Version: 1.0
In-Reply-To: <1485067624-3659-1-git-send-email-yin-jianhong@163.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/22/2017 01:47 AM, yin-jianhong@163.com wrote:
> From: "Jianhong.Yin" <yin-jianhong@163.com>
>
> recent changes of utils/mount cause a regression mount fail:
>   https://bugzilla.redhat.com/show_bug.cgi?id=1415024
> can not reproduce it on x86_64(gcc on x86_64 might do struct
> initialize by default, I'm not sure). but it can be reproduced
> always on platform ppc64le aarch64.
>
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
Committed...

steved.
> ---
>  utils/mount/network.c | 1 +
>  utils/mount/stropts.c | 4 ++++
>  2 files changed, 5 insertions(+)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 7dceb2d..d1c8fec 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1638,6 +1638,7 @@ int nfs_options2pmap(struct mount_options *options,
>  		     struct pmap *nfs_pmap, struct pmap *mnt_pmap)
>  {
>  	struct nfs_version version;
> +	memset(&version, 0, sizeof(version));
>  
>  	if (!nfs_nfs_program(options, &nfs_pmap->pm_prog))
>  		return 0;
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 387d734..a9ff95d 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -517,6 +517,10 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options, int checkv4)
>  	unsigned long protocol;
>  	struct pmap mnt_pmap;
>  
> +	/* initialize structs */
> +	memset(&nfs_pmap, 0, sizeof(struct pmap));
> +	memset(&mnt_pmap, 0, sizeof(struct pmap));
> +
>  	/*
>  	 * Version and transport negotiation is not required
>  	 * and does not work for RDMA mounts.

