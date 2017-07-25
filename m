Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41404 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751996AbdGYUvA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 16:51:00 -0400
Date: Tue, 25 Jul 2017 16:51:00 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 03/11] atomicio: removed a warning
Message-ID: <20170725205100.GA15694@fieldses.org>
References: <20170721163806.15803-1-steved@redhat.com>
 <20170721163806.15803-4-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170721163806.15803-4-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 21, 2017 at 12:37:58PM -0400, Steve Dickson wrote:
> atomicio.c:43:7: warning: this statement may fall through [-Wimplicit-fallthrough=]
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/nfs/atomicio.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/support/nfs/atomicio.c b/support/nfs/atomicio.c
> index 5e760e6..9bf65b9 100644
> --- a/support/nfs/atomicio.c
> +++ b/support/nfs/atomicio.c
> @@ -42,6 +42,8 @@ ssize_t atomicio(ssize_t(*f) (int, void *, size_t), int fd, void *_s, size_t n)
>  		case -1:
>  			if (errno == EINTR || errno == EAGAIN)
>  				continue;
> +			break;
> +			/* FALLTHRU */

And I thought I was confused before!

--b.

>  		case 0:
>  			if (pos != 0)
>  				return pos;
> -- 
> 2.13.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
