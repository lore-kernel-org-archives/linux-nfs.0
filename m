Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35426 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559Ab2LQPPJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:15:09 -0500
Date: Mon, 17 Dec 2012 10:15:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Suresh Jayaraman <sjayaraman@suse.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] idmapd: allow non-ASCII characters (UTF-8) in NFSv4
 domain name
Message-ID: <20121217151502.GB23546@fieldses.org>
References: <50CB2C3E.8090306@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50CB2C3E.8090306@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 14, 2012 at 07:10:14PM +0530, Suresh Jayaraman wrote:
> The validateascii() check in imconv() maps NFSv4 domain names with non-ASCII
> characters to 'nobody'. In setups where Active directory or LDAP is used this
> causes names with UTF-8 characters to being mapped to 'nobody' because of this
> check.
> 
> As Bruce Fields puts it:
> 
> "idmapd doesn't seem like the right place to enforce restrictions on names.
> Once the system has allowed a name it's too late to be complaining about it
> here."
> 
> Replace the validateascii() call in imconv() with a check for null-termination
> just to be extra-careful and remove the validateascii() function itself
> as the only user of that function is being removed by this patch.

Seems OK, thanks.--b.

> 
> 
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.com>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> ---
>  utils/idmapd/idmapd.c |   28 +++++-----------------------
>  1 file changed, 5 insertions(+), 23 deletions(-)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index e80efb4..9d66225 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -145,7 +145,6 @@ static void svrreopen(int, short, void *);
>  static int  nfsopen(struct idmap_client *);
>  static void nfscb(int, short, void *);
>  static void nfsdcb(int, short, void *);
> -static int  validateascii(char *, u_int32_t);
>  static int  addfield(char **, ssize_t *, char *);
>  static int  getfield(char **, char *, size_t);
>  
> @@ -642,6 +641,8 @@ out:
>  static void
>  imconv(struct idmap_client *ic, struct idmap_msg *im)
>  {
> +	u_int32_t len;
> +
>  	switch (im->im_conv) {
>  	case IDMAP_CONV_IDTONAME:
>  		idtonameres(im);
> @@ -652,10 +653,10 @@ imconv(struct idmap_client *ic, struct idmap_msg *im)
>  			    im->im_id, im->im_name);
>  		break;
>  	case IDMAP_CONV_NAMETOID:
> -		if (validateascii(im->im_name, sizeof(im->im_name)) == -1) {
> -			im->im_status |= IDMAP_STATUS_INVALIDMSG;
> +		len = strnlen(im->im_name, IDMAP_NAMESZ - 1);
> +		/* Check for NULL termination just to be careful */
> +		if (im->im_name[len+1] != '\0')
>  			return;
> -		}
>  		nametoidres(im);
>  		if (verbose > 1)
>  			xlog_warn("%s %s: (%s) name \"%s\" -> id \"%d\"",
> @@ -855,25 +856,6 @@ nametoidres(struct idmap_msg *im)
>  }
>  
>  static int
> -validateascii(char *string, u_int32_t len)
> -{
> -	u_int32_t i;
> -
> -	for (i = 0; i < len; i++) {
> -		if (string[i] == '\0')
> -			break;
> -
> -		if (string[i] & 0x80)
> -			return (-1);
> -	}
> -
> -	if ((i >= len) || string[i] != '\0')
> -		return (-1);
> -
> -	return (i + 1);
> -}
> -
> -static int
>  addfield(char **bpp, ssize_t *bsizp, char *fld)
>  {
>  	char ch, *bp = *bpp;
