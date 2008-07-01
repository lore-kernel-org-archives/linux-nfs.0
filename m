From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] nfs: sysctl's should use USER_HZ not HZ
Date: Tue, 1 Jul 2008 11:50:23 -0700
Message-ID: <20080701115023.4d9c1a8b@extreme>
References: <20080701114429.539d7fb0@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37237 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758437AbYGASuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2008 14:50:24 -0400
In-Reply-To: <20080701114429.539d7fb0@extreme>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Jul 2008 11:44:29 -0700
Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:

> There is no good way to tell what the internal value of kernel HZ is
> from userspace, so all administrative interfaces are supposed to use
> either USER_HZ (100) or other absolute time units.  Two of the NFS sysctl
> values are still using HZ, and can be simply converted to USER_HZ.
> 
> Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
> 
> --- a/fs/nfs/sysctl.c	2008-07-01 11:37:13.000000000 -0700
> +++ b/fs/nfs/sysctl.c	2008-07-01 11:38:21.000000000 -0700
> @@ -37,7 +37,7 @@ static ctl_table nfs_cb_sysctls[] = {
>  		.data = &nfs_idmap_cache_timeout,
>  		.maxlen = sizeof(int),
>  		.mode = 0644,
> -		.proc_handler = &proc_dointvec_jiffies,
> +		.proc_handler = &proc_dointvec_userhz_jiffies,
>  		.strategy = &sysctl_jiffies,
>  	},
>  #endif
> @@ -47,7 +47,7 @@ static ctl_table nfs_cb_sysctls[] = {
>  		.data		= &nfs_mountpoint_expiry_timeout,
>  		.maxlen		= sizeof(nfs_mountpoint_expiry_timeout),
>  		.mode		= 0644,
> -		.proc_handler	= &proc_dointvec_jiffies,
> +		.proc_handler	= &proc_dointvec_userhz_jiffies,
>  		.strategy	= &sysctl_jiffies,
>  	},
>  	{

Never mind... proc_dointvec_jiffies converts to/from seconds.
