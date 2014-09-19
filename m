Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756204AbaISOg0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 10:36:26 -0400
Message-ID: <541C3F67.7000300@RedHat.com>
Date: Fri, 19 Sep 2014 10:36:23 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Todd Vierling <todd.vierling@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] exportfs: Properly parse IPv6 literal strings with
 null termination
References: <1411060744-14328-1-git-send-email-todd.vierling@oracle.com>
In-Reply-To: <1411060744-14328-1-git-send-email-todd.vierling@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/18/2014 01:19 PM, Todd Vierling wrote:
> The original implementation was using strncpy() with a truncation
> length to an uninitialized stack buffer, leaving a string that
> was only null terminated by luck.
> 
> While here, change to use no-copy semantics (no extra buffer) to
> avoid buffer overflows altogether. exportfs already modifies argv
> contents elsewhere, so this doesn't break anything anew.
> 
> Fixes: 4663c648 (exportfs: Support raw IPv6 addresses with "client:/path")
> 
> Signed-off-by: Todd Vierling <todd.vierling@oracle.com>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
>  utils/exportfs/exportfs.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index e7d1ac8..bdea12b 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -351,16 +351,15 @@ static int exportfs_generic(char *arg, char *options, int verbose)
>  
>  static int exportfs_ipv6(char *arg, char *options, int verbose)
>  {
> -	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
> +	char *path, *c;
>  
>  	arg++;
>  	c = strchr(arg, ']');
>  	if (c == NULL)
>  		return 1;
> -	strncpy(hname, arg, c - arg);
>  
>  	/* no colon means this is a wildcarded DNS hostname */
> -	if (strchr(hname, ':') == NULL)
> +	if (memchr(arg, ':', c - arg) == NULL)
>  		return exportfs_generic(--arg, options, verbose);
>  
>  	path = strstr(c, ":/");
> @@ -370,9 +369,9 @@ static int exportfs_ipv6(char *arg, char *options, int verbose)
>  
>  	/* if there's anything between the closing brace and the
>  	 * path separator, it's probably a prefix length */
> -	strcat(hname, ++c);
> +	memmove(c, c + 1, path - c);
>  
> -	exportfs_parsed(hname, path, options, verbose);
> +	exportfs_parsed(arg, path, options, verbose);
>  	return 0;
>  }
>  
> @@ -458,16 +457,15 @@ static int unexportfs_generic(char *arg, int verbose)
>  
>  static int unexportfs_ipv6(char *arg, int verbose)
>  {
> -	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
> +	char *path, *c;
>  
>  	arg++;
>  	c = strchr(arg, ']');
>  	if (c == NULL)
>  		return 1;
> -	strncpy(hname, arg, c - arg);
>  
>  	/* no colon means this is a wildcarded DNS hostname */
> -	if (strchr(hname, ':') == NULL)
> +	if (memchr(arg, ':', c - arg) == NULL)
>  		return unexportfs_generic(--arg, verbose);
>  
>  	path = strstr(c, ":/");
> @@ -477,9 +475,9 @@ static int unexportfs_ipv6(char *arg, int verbose)
>  
>  	/* if there's anything between the closing brace and the
>  	 * path separator, it's probably a prefix length */
> -	strcat(hname, ++c);
> +	memmove(c, c + 1, path - c);
>  
> -	unexportfs_parsed(hname, path, verbose);
> +	unexportfs_parsed(arg, path, verbose);
>  	return 0;
>  }
>  
> 
