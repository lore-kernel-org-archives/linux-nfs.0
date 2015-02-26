Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbbBZThi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 14:37:38 -0500
Message-ID: <54EF75FC.9070904@RedHat.com>
Date: Thu, 26 Feb 2015 14:37:32 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - nfs-utils] mountd: fix next_mnt handling for "/"
References: <20150216121856.7efe2237@notabene.brown>
In-Reply-To: <20150216121856.7efe2237@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/15/2015 08:18 PM, NeilBrown wrote:
> 
> 
> If the (exported) path passed to next_mnt() is simply "/", next_mnt()
> will not report any children, as none start with "/" followed by
> a '/'.
> So make a special case for strlen(p)==1.  In that case, return all
> children.
> 
> This gives correct handling if only "/" is exported.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed!

steved.

> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index c23d384d24eb..ac36b6d9f21e 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -377,6 +377,7 @@ static char *next_mnt(void **v, char *p)
>  	} else
>  		f = *v;
>  	while ((me = getmntent(f)) != NULL &&
> +	       l > 1 &&
>  	       (strncmp(me->mnt_dir, p, l) != 0 ||
>  		me->mnt_dir[l] != '/'))
>  		;
> 
