Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51006 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716Ab1FNOiO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 10:38:14 -0400
Received: by iwn34 with SMTP id 34so4697129iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 07:38:14 -0700 (PDT)
Message-ID: <4DF77254.2090608@gmail.com>
Date: Tue, 14 Jun 2011 10:38:12 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] nfs4.1: pnfs_find_lseg only looks at first element
 in list
References: <1308059788-17381-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1308059788-17381-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-14 09:56, Fred Isaman wrote:
> The break condition to skip out of the loop if we've gone too far was
> reversed, causing the function to abort after looking at the first
> list entry.
> 
> Reported-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/pnfs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 1abb300..c640f91 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -895,7 +895,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
>  			ret = get_lseg(lseg);
>  			break;
>  		}
> -		if (cmp_layout(range, &lseg->pls_range) > 0)
> +		if (cmp_layout(range, &lseg->pls_range) < 0)

Fred, this is too harsh since we might break if range->offset == lseg->pls_range.offset
&& range->length > lseg->pls_range.length.

The simplest condition is just:
		if (lseg->pls_range.offset > range->offset)

Benny

>  			break;
>  	}
>  
