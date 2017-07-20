Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60560 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935408AbdGTSYE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jul 2017 14:24:04 -0400
Date: Thu, 20 Jul 2017 14:24:03 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 03/11] atomicio: removed a warning
Message-ID: <20170720182403.GA19909@fieldses.org>
References: <20170719205354.10006-1-steved@redhat.com>
 <20170719205354.10006-4-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170719205354.10006-4-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 19, 2017 at 04:53:46PM -0400, Steve Dickson wrote:
> atomicio.c:43:7: warning: this statement may fall through [-Wimplicit-fallthrough=]

I think this is wrong.  For example, if we don't have permission to do
the IO, this causes atomicio() to return 0 instead of -1.

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/nfs/atomicio.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/support/nfs/atomicio.c b/support/nfs/atomicio.c
> index 5e760e6..0234072 100644
> --- a/support/nfs/atomicio.c
> +++ b/support/nfs/atomicio.c
> @@ -42,6 +42,7 @@ ssize_t atomicio(ssize_t(*f) (int, void *, size_t), int fd, void *_s, size_t n)
>  		case -1:
>  			if (errno == EINTR || errno == EAGAIN)
>  				continue;
> +			break;
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
