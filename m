Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826AbbLBQLL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 11:11:11 -0500
Subject: Re: [PATCH 1/2] nfs-utils: libnsm.a: do not close file if open failed
To: Vivek Trivedi <t.vivek@samsung.com>, linux-nfs@vger.kernel.org
References: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <565F181C.201@RedHat.com>
Date: Wed, 2 Dec 2015 11:11:08 -0500
MIME-Version: 1.0
In-Reply-To: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/2015 06:16 AM, Vivek Trivedi wrote:
> If file open failed, no need to issue close system call in
> nsm_get_state and closeall.
I guess this makes sense... but what problem is this patch fixing?

steved.

> 
> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
> ---
>  support/nfs/closeall.c |    3 ++-
>  support/nsm/file.c     |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
> index 38fb162..a69bf35 100644
> --- a/support/nfs/closeall.c
> +++ b/support/nfs/closeall.c
> @@ -31,6 +31,7 @@ closeall(int min)
>  	} else {
>  		int fd = sysconf(_SC_OPEN_MAX);
>  		while (--fd >= min)
> -			(void) close(fd);
> +			if(fd >= 0)
> +				(void) close(fd);
>  	}
>  }
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 4711c2c..7a8b504 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -536,7 +536,8 @@ nsm_get_state(_Bool update)
>  		state++;
>  
>  update:
> -	(void)close(fd);
> +	if(fd >= 0)
> +		(void)close(fd);
>  
>  	if (update) {
>  		state += 2;
> 
