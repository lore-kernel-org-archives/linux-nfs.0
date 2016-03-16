Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137AbcCPSTq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 14:19:46 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 17C9146213
	for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 18:19:46 +0000 (UTC)
Subject: Re: [PATCH] libexport.a: fix missing brace in host_ntop() fallback
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
References: <1455805236-30534-1-git-send-email-stefanha@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E9A3C1.10500@RedHat.com>
Date: Wed, 16 Mar 2016 14:19:45 -0400
MIME-Version: 1.0
In-Reply-To: <1455805236-30534-1-git-send-email-stefanha@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/18/2016 09:20 AM, Stefan Hajnoczi wrote:
> An if statement has been missing a brace since host_ntop() was added in
> commit 94ce1eb94babb4c587b2826452fb053cba745098 ("libexport.a: Add
> helpers to manage DNS lookups").
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
Committed... 

steved.

> ---
>  support/export/hostname.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 4daabe9..94e98a5 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -69,7 +69,7 @@ host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
>  
>  	memset(buf, 0, buflen);
>  
> -	if (sin->sin_family != AF_INET)
> +	if (sin->sin_family != AF_INET) {
>  		(void)strncpy(buf, "bad family", buflen - 1);
>  		return buf;
>  	}
> 
