Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52306 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760116Ab2D0L2n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 07:28:43 -0400
Date: Fri, 27 Apr 2012 07:28:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@netapp.com>
Cc: SteveD@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountd: support IPv6 [] escaping with fsloc hosts
Message-ID: <20120427112840.GB14973@fieldses.org>
References: <1335279607-46861-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335279607-46861-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 24, 2012 at 11:00:07AM -0400, Weston Andros Adamson wrote:
> mountd uses colons to split fsloc hosts, but this doesn't work with IPv6
> addresses (they contain ':').
> To fix this, mountd is changed to expect all IPv6 addresses to be escaped
> by '[' and ']' so colons that are part of the address may be skipped.
> To fix IPv6 referrals, this patch must be used with the nfsd patch that
> properly parses escaped IPv6 addresses in fs_location->hosts.

Looks OK to me.--b.

> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
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
> -- 
> 1.7.4.4
> 
