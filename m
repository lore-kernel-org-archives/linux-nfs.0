Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38097 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab2BDAYi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2012 19:24:38 -0500
Received: by iacb35 with SMTP id b35so5452641iac.19
        for <linux-nfs@vger.kernel.org>; Fri, 03 Feb 2012 16:24:37 -0800 (PST)
Message-ID: <4F2C0A3F.6020002@gmail.com>
Date: Sat, 04 Feb 2012 00:24:31 +0800
From: Mi Jinlong <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Mi Jinlong <mijinlong@cn.fujitsu.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: cleanup setting of default max_block_size
References: <1327963365-2921-1-git-send-email-bfields@redhat.com> <4F273FD4.3020005@cn.fujitsu.com> <20120201214656.GA19075@fieldses.org> <20120203204931.GC2999@fieldses.org>
In-Reply-To: <20120203204931.GC2999@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2012-2-4 4:49, J. Bruce Fields 写道:
> On Wed, Feb 01, 2012 at 04:46:56PM -0500, bfields wrote:
>> On Tue, Jan 31, 2012 at 09:11:48AM +0800, Mi Jinlong wrote:
>>>    Should use target = i.totalram<<  (PAGE_SHIFT - 12);
>>>
>>>    target = i.totalram<<  PAGE_SHIFT; and
>>>    target<<= 12;
>>>    means target = i.totalram<<  (PAGE_SHIFT + 12);
>>
>> Yes, thanks for catching that.
>>
>> Also, splitting up the calculation as I did above risks overflow at the
>> first step.
>>
>> I'll fix that....
>
> Here are the fixed patches.--b.
>
>> From 87b0fc7deb5feccf93b022f6a976e8441152dbb2 Mon Sep 17 00:00:00 2001
> From: "J. Bruce Fields"<bfields@redhat.com>
> Date: Mon, 30 Jan 2012 16:18:35 -0500
> Subject: [PATCH 1/2] nfsd: cleanup setting of default max_block_size
>
> Move calculation of the default into a helper function.
>
> Get rid of an unused variable "err" while we're there.
>
> Thanks to Mi Jinlong for catching an arithmetic error in a previous
> version.
>
> Cc: Mi Jinlong<mijinlong@cn.fujitsu.com>
> Signed-off-by: J. Bruce Fields<bfields@redhat.com>
> ---
>   fs/nfsd/nfssvc.c |   44 ++++++++++++++++++++++++--------------------
>   1 files changed, 24 insertions(+), 20 deletions(-)
>
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index eda7d7e..e9eb408 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -307,33 +307,37 @@ static void set_max_drc(void)
>   	dprintk("%s nfsd_drc_max_mem %u \n", __func__, nfsd_drc_max_mem);
>   }
>
> -int nfsd_create_serv(void)
> +static int nfsd_get_default_max_blksize(void)
>   {
> -	int err = 0;
> +	struct sysinfo i;
> +	unsigned long long target;
> +	unsigned long ret;
> +
> +	si_meminfo(&i);
> +	target = i.totalram<<  PAGE_SHIFT;
> +	/*
> +	 * Aim for 1/4096 of memory per thread This gives 1MB on 4Gig
> +	 * machines, but only uses 32K on 128M machines.  Bottom out at
> +	 * 8K on 32M and smaller.  Of course, this is only a default.
> +	 */
> +	target>>= 12;

    Why don't using target = i.totalram << (PAGE_SHIFT - 12) as before?
    The result of the two forms is more likely different.

    Is there some other reason ?

thanks,
Mi Jinlong


> +
> +	ret = NFSSVC_MAXBLKSIZE;
> +	while (ret>  target&&  ret>= 8*1024*2)
> +		ret /= 2;
> +	return ret;
> +}
>
> +int nfsd_create_serv(void)
> +{
>   	WARN_ON(!mutex_is_locked(&nfsd_mutex));
>   	if (nfsd_serv) {
>   		svc_get(nfsd_serv);
>   		return 0;
>   	}
> -	if (nfsd_max_blksize == 0) {
> -		/* choose a suitable default */
> -		struct sysinfo i;
> -		si_meminfo(&i);
> -		/* Aim for 1/4096 of memory per thread
> -		 * This gives 1MB on 4Gig machines
> -		 * But only uses 32K on 128M machines.
> -		 * Bottom out at 8K on 32M and smaller.
> -		 * Of course, this is only a default.
> -		 */
> -		nfsd_max_blksize = NFSSVC_MAXBLKSIZE;
> -		i.totalram<<= PAGE_SHIFT - 12;
> -		while (nfsd_max_blksize>  i.totalram&&
> -		       nfsd_max_blksize>= 8*1024*2)
> -			nfsd_max_blksize /= 2;
> -	}
> +	if (nfsd_max_blksize == 0)
> +		nfsd_max_blksize = nfsd_get_default_max_blksize();
>   	nfsd_reset_versions();
> -
>   	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
>   				      nfsd_last_thread, nfsd, THIS_MODULE);
>   	if (nfsd_serv == NULL)
> @@ -341,7 +345,7 @@ int nfsd_create_serv(void)
>
>   	set_max_drc();
>   	do_gettimeofday(&nfssvc_boot);		/* record boot time */
> -	return err;
> +	return 0;
>   }
>
>   int nfsd_nrpools(void)

