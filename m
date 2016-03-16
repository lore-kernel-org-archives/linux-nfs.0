Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39749 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137AbcCPSTO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 14:19:14 -0400
Subject: Re: [PATCH] mount.nfs - hide EBUSY errors.
To: NeilBrown <neilb@suse.com>
References: <877fi2raey.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E9A3A0.40002@RedHat.com>
Date: Wed, 16 Mar 2016 14:19:12 -0400
MIME-Version: 1.0
In-Reply-To: <877fi2raey.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/17/2016 09:59 PM, NeilBrown wrote:
> 
> Linux only returns EBUSY for a non-remount mount if the exact
> requested filesystem is already mounted.  Arguably this is not an
> error.
> 
> "mount -a" tries to see if each requested filesystem is already mounted.
> Sometimes it gets it wrong - e.g. hostname aliases can confuse it.
> So "mount -a" will report a failure "already mounted", which is
> wrong because it should filter those out.
> 
> An easy fix it just to be silent about EBUSY.  As the requested
> result (a given filesystem being mounted at a given location) is in
> effect after the EBUSY return, we can just treat it as success.
> 
> This removes the confusing "already mounted" errors.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... 

steved.

> ---
>  utils/mount/stropts.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 86829a902bfd..320dde2fab92 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -960,6 +960,15 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>  		if (nfs_try_mount(mi))
>  			return EX_SUCCESS;
>  
> +		if (errno == EBUSY)
> +			/* The only cause of EBUSY is if exactly the desired
> +			 * filesystem is already mounted.  That can arguably
> +			 * be seen as success.  "mount -a" tries to optimise
> +			 * out this case but sometimes fails.  Help it out
> +			 * by pretending everything is rosy
> +			 */
> +			return EX_SUCCESS;
> +
>  		if (nfs_is_permanent_error(errno))
>  			break;
>  
> 
