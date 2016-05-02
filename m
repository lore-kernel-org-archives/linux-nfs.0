Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36354 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022AbcEBP6f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 11:58:35 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6AD133B724
	for <linux-nfs@vger.kernel.org>; Mon,  2 May 2016 15:58:34 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] exportfs: replace one xlog(D_GENERAL) in
 host_canonname()
To: Scott Mayhew <smayhew@redhat.com>
References: <1461936366-26852-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <57277929.7030405@RedHat.com>
Date: Mon, 2 May 2016 11:58:33 -0400
MIME-Version: 1.0
In-Reply-To: <1461936366-26852-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/29/2016 09:26 AM, Scott Mayhew wrote:
> If we fall back to using the numeric host then we shouldn't call
> xlog with D_GENERAL.  That can cause 'exportfs -u' to exit with a 1
> if, for example, you have exports using ip addresses that can't be
> resolved to hostnames.  Use D_PARSE instead.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  support/export/hostname.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 94e98a5..5c4c824 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -230,7 +230,7 @@ host_canonname(const struct sockaddr *sap)
>  	default:
>  		(void)getnameinfo(sap, salen, buf, (socklen_t)sizeof(buf),
>  							NULL, 0, NI_NUMERICHOST);
> -		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
> +		xlog(D_PARSE, "%s: failed to resolve %s: %s",
>  				__func__, buf, gai_strerror(error));
>  		return NULL;
>  	}
> -- 2.4.11
> 
