Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52690 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731373AbeHWR4K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 13:56:10 -0400
Date: Thu, 23 Aug 2018 10:26:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Paul B. Henson" <henson@acm.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Remove invalid flags that aren't part of the NFSv4 ACL
 spec, will never be received, and should never be sent.
Message-ID: <20180823142614.GA1019@fieldses.org>
References: <4787be845392f04e@lisa.pbhware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4787be845392f04e@lisa.pbhware.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied, thanks!--b.

On Thu, Aug 23, 2018 at 12:25:58AM +0000, Paul B. Henson wrote:
> ---
>  include/libacl_nfs4.h               | 3 ---
>  include/nfs4.h                      | 3 ---
>  libnfs4acl/nfs4_ace_from_string.c   | 9 ---------
>  libnfs4acl/nfs4_get_ace_flags.c     | 6 ------
>  libnfs4acl/nfs4_print_ace_verbose.c | 6 ------
>  5 files changed, 27 deletions(-)
> 
> diff --git a/include/libacl_nfs4.h b/include/libacl_nfs4.h
> index 654061c..d3786c3 100644
> --- a/include/libacl_nfs4.h
> +++ b/include/libacl_nfs4.h
> @@ -54,9 +54,6 @@
>  #define FLAG_SUCCESSFUL_ACCESS		'S'
>  #define FLAG_FAILED_ACCESS		'F'
>  #define FLAG_GROUP			'g'
> -#define FLAG_OWNER_AT			'O'
> -#define FLAG_GROUP_AT			'G'
> -#define FLAG_EVERYONE_AT		'E'
>  
>  #define PERM_READ_DATA			'r'
>  #define PERM_WRITE_DATA			'w'
> diff --git a/include/nfs4.h b/include/nfs4.h
> index c6d5b62..da6eefb 100644
> --- a/include/nfs4.h
> +++ b/include/nfs4.h
> @@ -62,9 +62,6 @@
>  #define NFS4_ACE_SUCCESSFUL_ACCESS_ACE_FLAG   0x00000010
>  #define NFS4_ACE_FAILED_ACCESS_ACE_FLAG       0x00000020
>  #define NFS4_ACE_IDENTIFIER_GROUP             0x00000040
> -#define NFS4_ACE_OWNER                        0x00000080
> -#define NFS4_ACE_GROUP                        0x00000100
> -#define NFS4_ACE_EVERYONE                     0x00000200
>  
>  #define NFS4_ACE_READ_DATA                    0x00000001
>  #define NFS4_ACE_LIST_DIRECTORY               0x00000001
> diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
> index a7a3036..ab8401a 100644
> --- a/libnfs4acl/nfs4_ace_from_string.c
> +++ b/libnfs4acl/nfs4_ace_from_string.c
> @@ -209,15 +209,6 @@ struct nfs4_ace * nfs4_ace_from_string(char *ace_buf, int is_dir)
>  			case FLAG_GROUP:
>  				flags |= NFS4_ACE_IDENTIFIER_GROUP;
>  				break;
> -			case FLAG_OWNER_AT:
> -				flags |= NFS4_ACE_OWNER;
> -				break;
> -			case FLAG_GROUP_AT:
> -				flags |= NFS4_ACE_GROUP;
> -				break;
> -			case FLAG_EVERYONE_AT:
> -				flags |= NFS4_ACE_EVERYONE;
> -				break;
>  			default:
>  				fprintf(stderr,"Bad Ace Flag:%c\n", *field);
>  				goto out_free;
> diff --git a/libnfs4acl/nfs4_get_ace_flags.c b/libnfs4acl/nfs4_get_ace_flags.c
> index 339a838..1d28ed4 100644
> --- a/libnfs4acl/nfs4_get_ace_flags.c
> +++ b/libnfs4acl/nfs4_get_ace_flags.c
> @@ -53,12 +53,6 @@ char* nfs4_get_ace_flags(struct nfs4_ace *ace, char *buf)
>  		*buf++ = FLAG_FAILED_ACCESS;;
>  	if (flags & NFS4_ACE_IDENTIFIER_GROUP)
>  		*buf++ = FLAG_GROUP;
> -	if (flags & NFS4_ACE_OWNER)
> -		*buf++ = FLAG_OWNER_AT;
> -	if (flags & NFS4_ACE_GROUP)
> -		*buf++ = FLAG_GROUP_AT;
> -	if (flags & NFS4_ACE_EVERYONE)
> -		*buf++ = FLAG_EVERYONE_AT;
>  	*buf = '\0';
>  
>  	return bp;
> diff --git a/libnfs4acl/nfs4_print_ace_verbose.c b/libnfs4acl/nfs4_print_ace_verbose.c
> index de9b424..96a6573 100644
> --- a/libnfs4acl/nfs4_print_ace_verbose.c
> +++ b/libnfs4acl/nfs4_print_ace_verbose.c
> @@ -131,12 +131,6 @@ int nfs4_print_ace_verbose(struct nfs4_ace * ace, u32 is_dir)
>  		printf("\t\tNFS4_ACE_FAILED_ACCESS_ACE_FLAG\n");
>  	if (flag & NFS4_ACE_IDENTIFIER_GROUP)
>  		printf("\t\tNFS4_ACE_IDENTIFIER_GROUP\n");
> -	if (flag & NFS4_ACE_OWNER)
> -		printf("\t\tNFS4_ACE_OWNER\n");
> -	if (flag & NFS4_ACE_GROUP)
> -		printf("\t\tNFS4_ACE_GROUP\n");
> -	if (flag & NFS4_ACE_EVERYONE)
> -		printf("\t\tNFS4_ACE_EVERYONE\n");
>  
>  
>  	mask = ace->access_mask;
> -- 
> 2.17.1
