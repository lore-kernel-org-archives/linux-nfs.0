Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757271Ab2D0MsW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 08:48:22 -0400
Date: Fri, 27 Apr 2012 08:48:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@netapp.com>
Cc: SteveD@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add IPv6 addr escaping to fs_location hosts
Message-ID: <20120427124820.GC14973@fieldses.org>
References: <1335280079-47424-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335280079-47424-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 24, 2012 at 11:07:59AM -0400, Weston Andros Adamson wrote:
> The fs_location->hosts list is split on colons, but this doesn't work when
> IPv6 addresses are used (they contain colons).
> This patch adds the function nfsd4_encode_components_esc() to
> allow the caller to specify escape characters when splitting on 'sep'.
> In order to fix referrals, this patch must be used with the mountd patch
> that similarly fixes IPv6 [] escaping.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> Sorry, I posted a slightly older version of this patch.  This is the one
> we want!

Whoops, right, applying this version....--b.

> 
>  fs/nfsd/nfs4xdr.c |   40 +++++++++++++++++++++++++++++++++-------
>  1 files changed, 33 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 74c00bc..eabd0d9 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1744,15 +1744,16 @@ static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, _
>  }
>  
>  /* Encode as an array of strings the string given with components
> - * separated @sep.
> + * separated @sep, escaped with esc_enter and esc_exit.
>   */
> -static __be32 nfsd4_encode_components(char sep, char *components,
> -				   __be32 **pp, int *buflen)
> +static __be32 nfsd4_encode_components_esc(char sep, char *components,
> +				   __be32 **pp, int *buflen,
> +				   char esc_enter, char esc_exit)
>  {
>  	__be32 *p = *pp;
>  	__be32 *countp = p;
>  	int strlen, count=0;
> -	char *str, *end;
> +	char *str, *end, *next;
>  
>  	dprintk("nfsd4_encode_components(%s)\n", components);
>  	if ((*buflen -= 4) < 0)
> @@ -1760,8 +1761,23 @@ static __be32 nfsd4_encode_components(char sep, char *components,
>  	WRITE32(0); /* We will fill this in with @count later */
>  	end = str = components;
>  	while (*end) {
> -		for (; *end && (*end != sep); end++)
> -			; /* Point to end of component */
> +		bool found_esc = false;
> +
> +		/* try to parse as esc_start, ..., esc_end, sep */
> +		if (*str == esc_enter) {
> +			for (; *end && (*end != esc_exit); end++)
> +				/* find esc_exit or end of string */;
> +			next = end + 1;
> +			if (*end && (!*next || *next == sep)) {
> +				str++;
> +				found_esc = true;
> +			}
> +		}
> +
> +		if (!found_esc)
> +			for (; *end && (*end != sep); end++)
> +				/* find sep or end of string */;
> +
>  		strlen = end - str;
>  		if (strlen) {
>  			if ((*buflen -= ((XDR_QUADLEN(strlen) << 2) + 4)) < 0)
> @@ -1780,6 +1796,15 @@ static __be32 nfsd4_encode_components(char sep, char *components,
>  	return 0;
>  }
>  
> +/* Encode as an array of strings the string given with components
> + * separated @sep.
> + */
> +static __be32 nfsd4_encode_components(char sep, char *components,
> +				   __be32 **pp, int *buflen)
> +{
> +	return nfsd4_encode_components_esc(sep, components, pp, buflen, 0, 0);
> +}
> +
>  /*
>   * encode a location element of a fs_locations structure
>   */
> @@ -1789,7 +1814,8 @@ static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
>  	__be32 status;
>  	__be32 *p = *pp;
>  
> -	status = nfsd4_encode_components(':', location->hosts, &p, buflen);
> +	status = nfsd4_encode_components_esc(':', location->hosts, &p, buflen,
> +						'[', ']');
>  	if (status)
>  		return status;
>  	status = nfsd4_encode_components('/', location->path, &p, buflen);
> -- 
> 1.7.4.4
> 
