From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 015/100] nfsd: Fix handling of negative lengths in read_buf()
Date: Mon, 28 Jan 2008 13:00:47 -0500
Message-ID: <346EF0C5-EFD6-4187-BA51-1946142920AB@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <1201303040-7779-2-git-send-email-bfields@citi.umich.edu> <1201303040-7779-3-git-send-email-bfields@citi.umich.edu> <1201303040-7779-4-git-send-email-bfields@citi.umich.edu> <1201303040-7779-5-git-send-email-bfields@citi.umich.edu> <1201303040-7779-6-git-send-email-bfields@citi.umich.edu> <1201303040-7779-7-git-send-email-bfields@citi.umich.edu> <1201303040-7779-8-git-send-email-bfields@citi.umich.edu> <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umi
 ch.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:20314 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbYA1SBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 13:01:03 -0500
In-Reply-To: <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
> The length "nbytes" passed into read_buf should never be negative, but
> we check only for too-large values of "nbytes", not for too-small
> values.  Make nbytes unsigned, so it's clear that the former tests are
> sufficient.  (Despite this read_buf() currently correctly returns  
> an xdr
> error in the case of a negative length, thanks to an unsigned
> comparison with size_of() and bounds-checking in kmalloc().  This  
> seems
> very fragile, though.)
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4xdr.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 5733394..25c7ae2 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -148,7 +148,7 @@ xdr_error:					\
>  	}					\
>  } while (0)
>
> -static __be32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
> +static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  {
>  	/* We want more bytes than seem to be available.
>  	 * Maybe we need a new page, maybe we have just run out

Changing nbytes to an unsigned introduces a mixed-sign comparison:

         int avail = (char*)argp->end - (char*)argp->p;
         __be32 *p;
         if (avail + argp->pagelen < nbytes)  <<<<<<

"avail" and "argp->pagelen" are signed ints.

                 return NULL;
         if (avail + PAGE_SIZE < nbytes) /* need more than a page !! */
                 return NULL;

PAGE_SIZE is unsigned long (defined as "1UL << PAGE_SHIFT"), so  
changing nbytes may have additional unintended consequences.

We need careful review of everywhere argp->pagelen is used throughout  
this file.  But I think just this simple fix is inadequate.

> @@ -169,6 +169,11 @@ static __be32 *read_buf(struct  
> nfsd4_compoundargs *argp, int nbytes)
>  			return NULL;
>  		
>  	}
> +	/*
> +	 * The following memcpy is safe because read_buf is always
> +	 * called with nbytes > avail, and the two cases above both
> +	 * guarantee p points to at least nbytes bytes.
> +	 */
>  	memcpy(p, argp->p, avail);
>  	/* step to next page */
>  	argp->p = page_address(argp->pagelist[0]);
> -- 
> 1.5.4.rc2.60.gb2e62
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



