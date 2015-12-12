Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261AbbLLMMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Dec 2015 07:12:18 -0500
Subject: Re: [PATCH 2/2] nfs-utils: mount.nfs: fix null pointer derefernce in
 nfs_parse_simple_hostname
To: Vivek Trivedi <t.vivek@samsung.com>, linux-nfs@vger.kernel.org
References: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
 <1449054998-19308-2-git-send-email-t.vivek@samsung.com>
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <566C0F21.8040804@RedHat.com>
Date: Sat, 12 Dec 2015 07:12:17 -0500
MIME-Version: 1.0
In-Reply-To: <1449054998-19308-2-git-send-email-t.vivek@samsung.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/2015 06:16 AM, Vivek Trivedi wrote:
> In function nfs_parse_simple_hostname, hostname can be NULL,
> dereferncing it while passing it to free(*hostname) may result in segfault.
> 
> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
Committed... 

steved.

> ---
>  utils/mount/parse_dev.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/parse_dev.c b/utils/mount/parse_dev.c
> index d64b83d..0d3bcb9 100644
> --- a/utils/mount/parse_dev.c
> +++ b/utils/mount/parse_dev.c
> @@ -118,7 +118,8 @@ static int nfs_parse_simple_hostname(const char *dev,
>  	if (pathname) {
>  		*pathname = strndup(colon, path_len);
>  		if (*pathname == NULL) {
> -			free(*hostname);
> +			if (hostname)
> +				free(*hostname);
>  			return nfs_pdn_nomem_err();
>  		}
>  	}
> 
