Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab2EAS5Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 14:57:16 -0400
Message-ID: <4FA031FD.6040501@RedHat.com>
Date: Tue, 01 May 2012 14:57:01 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountd: support IPv6 [] escaping with fsloc hosts
References: <1335279607-46861-1-git-send-email-dros@netapp.com>
In-Reply-To: <1335279607-46861-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/24/2012 11:00 AM, Weston Andros Adamson wrote:
> mountd uses colons to split fsloc hosts, but this doesn't work with IPv6
> addresses (they contain ':').
> To fix this, mountd is changed to expect all IPv6 addresses to be escaped
> by '[' and ']' so colons that are part of the address may be skipped.
> To fix IPv6 referrals, this patch must be used with the nfsd patch that
> properly parses escaped IPv6 addresses in fs_location->hosts.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
Committed...

steved.
> ---
>  utils/mountd/fsloc.c |   20 +++++++++++++++++---
>  1 files changed, 17 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/mountd/fsloc.c b/utils/mountd/fsloc.c
> index 704b7a0..bc737d1 100644
> --- a/utils/mountd/fsloc.c
> +++ b/utils/mountd/fsloc.c
> @@ -120,10 +120,11 @@ static struct servers *parse_list(char **list)
>   */
>  static struct servers *method_list(char *data)
>  {
> -	char *copy, *ptr=data;
> +	char *copy, *ptr=data, *p;
>  	char **list;
>  	int i, listsize;
>  	struct servers *rv=NULL;
> +	bool v6esc = false;
>  
>  	xlog(L_NOTICE, "method_list(%s)", data);
>  	for (ptr--, listsize=1; ptr; ptr=index(ptr, ':'), listsize++)
> @@ -134,9 +135,22 @@ static struct servers *method_list(char *data)
>  		xlog(L_NOTICE, "converted to %s", copy);
>  	if (list && copy) {
>  		ptr = copy;
> -		for (i=0; i<listsize; i++) {
> -			list[i] = strsep(&ptr, ":");
> +		for (p = ptr, i = 0; *p && i < listsize; p++) {
> +			if (*p == '[')
> +				v6esc = true;
> +			else if (*p == ']')
> +				v6esc = false;
> +
> +			if (!v6esc && *p == ':') {
> +				*p = '\0';
> +				if (*ptr)
> +					list[i++] = ptr;
> +				ptr = p + 1;
> +			}
>  		}
> +		if (*ptr)
> +			list[i++] = ptr;
> +		list[i] = NULL;
>  		rv = parse_list(list);
>  	}
>  	free(copy);
> -- 1.7.4.4
> 
