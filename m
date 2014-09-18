Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39631 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932277AbaIRQwb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 12:52:31 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so1885457pab.32
        for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 09:52:31 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] exportfs: Properly parse IPv6 literal strings with null termination
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <1410997719-17913-1-git-send-email-todd.vierling@oracle.com>
Date: Thu, 18 Sep 2014 09:52:28 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5D0058B9-354A-4E1A-AC60-EB071487F78E@gmail.com>
References: <1410997719-17913-1-git-send-email-todd.vierling@oracle.com>
To: Todd Vierling <todd.vierling@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for chasing this down, Todd!

On Sep 17, 2014, at 4:48 PM, Todd Vierling <todd.vierling@oracle.com> wrote:

> The original implementation was using strncpy() with a truncation
> length to an uninitialized stack buffer, leaving a string that
> was only null terminated by luck.
> 
> While here, change to use no-copy semantics (no extra buffer) to
> avoid buffer overflows altogether.

Needs

Fixes: 4663c648 (exportfs: Support raw IPv6 addresses with "client:/path”)

And needs a Signed-off-by.

I wonder about the “no-copy” change. I thought that on some systems,
the tool chain makes the command line arguments read-only.

> ---
> utils/exportfs/exportfs.c | 18 ++++++++----------
> 1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index e7d1ac8..bdea12b 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -351,16 +351,15 @@ static int exportfs_generic(char *arg, char *options, int verbose)
> 
> static int exportfs_ipv6(char *arg, char *options, int verbose)
> {
> -	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
> +	char *path, *c;
> 
> 	arg++;
> 	c = strchr(arg, ']');
> 	if (c == NULL)
> 		return 1;
> -	strncpy(hname, arg, c - arg);
> 
> 	/* no colon means this is a wildcarded DNS hostname */
> -	if (strchr(hname, ':') == NULL)
> +	if (memchr(arg, ':', c - arg) == NULL)
> 		return exportfs_generic(--arg, options, verbose);
> 
> 	path = strstr(c, ":/");
> @@ -370,9 +369,9 @@ static int exportfs_ipv6(char *arg, char *options, int verbose)
> 
> 	/* if there's anything between the closing brace and the
> 	 * path separator, it's probably a prefix length */
> -	strcat(hname, ++c);
> +	memmove(c, c + 1, path - c);
> 
> -	exportfs_parsed(hname, path, options, verbose);
> +	exportfs_parsed(arg, path, options, verbose);
> 	return 0;
> }
> 
> @@ -458,16 +457,15 @@ static int unexportfs_generic(char *arg, int verbose)
> 
> static int unexportfs_ipv6(char *arg, int verbose)
> {
> -	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
> +	char *path, *c;
> 
> 	arg++;
> 	c = strchr(arg, ']');
> 	if (c == NULL)
> 		return 1;
> -	strncpy(hname, arg, c - arg);
> 
> 	/* no colon means this is a wildcarded DNS hostname */
> -	if (strchr(hname, ':') == NULL)
> +	if (memchr(arg, ':', c - arg) == NULL)
> 		return unexportfs_generic(--arg, verbose);
> 
> 	path = strstr(c, ":/");
> @@ -477,9 +475,9 @@ static int unexportfs_ipv6(char *arg, int verbose)
> 
> 	/* if there's anything between the closing brace and the
> 	 * path separator, it's probably a prefix length */
> -	strcat(hname, ++c);
> +	memmove(c, c + 1, path - c);
> 
> -	unexportfs_parsed(hname, path, verbose);
> +	unexportfs_parsed(arg, path, verbose);
> 	return 0;
> }
> 
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chucklever@gmail.com



