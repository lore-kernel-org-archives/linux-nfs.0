Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60582 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932226AbdGTSmo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jul 2017 14:42:44 -0400
Date: Thu, 20 Jul 2017 14:42:44 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/11] present_address: remove a warning
Message-ID: <20170720184244.GD19909@fieldses.org>
References: <20170719205354.10006-1-steved@redhat.com>
 <20170719205354.10006-3-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170719205354.10006-3-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 19, 2017 at 04:53:45PM -0400, Steve Dickson wrote:
> tcpwrapper.c:73:6: warning: this statement may fall through [-Wimplicit-fallthrough=]

This one looks like a real bugfix to me; could use a changelog.

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/misc/tcpwrapper.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
> index 06b0a46..3128053 100644
> --- a/support/misc/tcpwrapper.c
> +++ b/support/misc/tcpwrapper.c
> @@ -72,6 +72,7 @@ present_address(const struct sockaddr *sap, char *buf, const size_t buflen)
>  	case AF_INET:
>  		if (inet_ntop(AF_INET, &sin->sin_addr, buf, len) != 0)
>  			return;
> +		break;
>  	case AF_INET6:
>  		if (inet_ntop(AF_INET6, &sin6->sin6_addr, buf, len) != 0)
>  			return;
> -- 
> 2.13.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
