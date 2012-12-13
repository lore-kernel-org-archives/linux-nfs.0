Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55816 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756584Ab2LMQuc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 11:50:32 -0500
Date: Thu, 13 Dec 2012 11:50:28 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Suresh Jayaraman <sjayaraman@suse.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] idmapd: allow non-ASCII characters (UTF-8) in NFSv4
 domain name
Message-ID: <20121213165028.GE24855@fieldses.org>
References: <50CA0254.4030308@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50CA0254.4030308@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 09:59:08PM +0530, Suresh Jayaraman wrote:
> 
> The validateascii() check in imconv() maps NFSv4 domain names with non-ASCII
> characters to 'nobody'. In setups where Active directory or LDAP is used this
> causes names with UTF-8 characters to be mapped to 'nobody' because of this
> check.
> 
> As Bruce Fields puts it:
> 
> "idmapd doesn't seem like the right place to enforce restrictions on names.
> Once the system has allowed a name it's too late to be complaining about it
> here."
> 
> Remove the check from imconv() and remove the validateascii() function itself
> as the only user of that function is being removed by this patch.

Thanks, seem fine.  The only other thing I notice is that
validateascii() also checks (in a slightly strange way) for null
termination of the string, and it's the only place in idmapd that does.

But I think it'd be a kernel bug to pass up a non-terminated string
here, so skipping that check is fine too.

Possibly worth a comment, or a check just for null-termination if you
want to be extra-careful.

--b.

> @@ -652,10 +651,6 @@ imconv(struct idmap_client *ic, struct idmap_msg *im)
>  			    im->im_id, im->im_name);
>  		break;
>  	case IDMAP_CONV_NAMETOID:
> -		if (validateascii(im->im_name, sizeof(im->im_name)) == -1) {
> -			im->im_status |= IDMAP_STATUS_INVALIDMSG;
> -			return;
> -		}
>  		nametoidres(im);
>  		if (verbose > 1)
>  			xlog_warn("%s %s: (%s) name \"%s\" -> id \"%d\"",
> @@ -855,25 +850,6 @@ nametoidres(struct idmap_msg *im)
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
> 
