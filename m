Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41176 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbaEHQzx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2014 12:55:53 -0400
Date: Thu, 8 May 2014 12:55:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Cleanup unused comments and codes in
 summarize_posix_acl
Message-ID: <20140508165553.GF20976@fieldses.org>
References: <534A897E.10303@gmail.com>
 <534A8D29.5070101@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <534A8D29.5070101@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd rather leave the comment there as long as we keep the memset.

I think you're right about the pe initialization, I don't know why
that's there....

--b.

On Sun, Apr 13, 2014 at 09:12:09PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4acl.c | 7 -------
>  1 file changed, 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 6f3f392..de5d66b 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -193,16 +193,9 @@ summarize_posix_acl(struct posix_acl *acl, struct
> posix_acl_summary *pas)
>  {
>  	struct posix_acl_entry *pa, *pe;
> 
> -	/*
> -	 * Only pas.users and pas.groups need initialization; previous
> -	 * posix_acl_valid() calls ensure that the other fields will be
> -	 * initialized in the following loop.  But, just to placate gcc:
> -	 */
>  	memset(pas, 0, sizeof(*pas));
>  	pas->mask = 07;
> 
> -	pe = acl->a_entries + acl->a_count;
> -
>  	FOREACH_ACL_ENTRY(pa, acl, pe) {
>  		switch (pa->e_tag) {
>  			case ACL_USER_OBJ:
> -- 
> 1.9.0
> 
