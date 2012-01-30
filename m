Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44386 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab2A3WrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 17:47:12 -0500
Date: Mon, 30 Jan 2012 17:47:11 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: fix default iosize calculation on 32bit
Message-ID: <20120130224711.GA2967@fieldses.org>
References: <1327963365-2921-1-git-send-email-bfields@redhat.com>
 <1327963365-2921-2-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327963365-2921-2-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 30, 2012 at 05:42:45PM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The rpc buffers will be allocated out of low memory, so we should really
> only be taking that into account.

I could have sworm this problem had already been fixed, or at least
discussed, but can't find any reference now.

--b.

> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfssvc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 2ad5ffe..53c89f7 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -314,7 +314,7 @@ static int nfsd_get_default_max_blksize(void)
>  	unsigned long bytes;
>  
>  	si_meminfo(&i);
> -	target = i.totalram << PAGE_SHIFT;
> +	target = (i.totalram - i.totalhigh) << PAGE_SHIFT;
>  	/*
>  	 * Aim for 1/4096 of memory per thread This gives 1MB on 4Gig
>  	 * machines, but only uses 32K on 128M machines.  Bottom out at
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
