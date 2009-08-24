From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATHC] nfsd: Fix a couple issues with POSIX->NFSv4 ACL
	conversion
Date: Mon, 24 Aug 2009 19:59:44 -0400
Message-ID: <20090824235944.GH8532@fieldses.org>
References: <1250287351.32255.3.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39199 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753965AbZHXX7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 19:59:43 -0400
In-Reply-To: <1250287351.32255.3.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 14, 2009 at 03:02:30PM -0700, Frank Filz wrote:
> 1. GROUP@ Allow entry doesn't have NFS4_ACE_IDENTIFIER_GROUP, This
> appears to have been introduced by accident as part of commit
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=bec50c47aaf6f1f9247f1860547ab394a0802a4c

It's good to flip that bit every now and then just to keep client
implementations on their toes....

	(Slightly more seriously, the 4.1 draft says "The
	ACE4_IDENTIFIER_GROUP flag MUST be ignored on entries with these
	special identifiers.  When encoding entries with these special
	identifiers, the ACE4_IDENTIFIER_GROUP flag SHOULD be set to
	zero."  It really shouldn't matter either way, but the point is
	that this flag is used to distinguish named users from named
	groups (since unix allows a group to have the same name as a
	user), so it doesn't really make sense to use it on a special
	identifier such as this.)

> 2. The group deny entries end up denying tcy even though tcy was just
> allowed by the allow entry. This appears to be due to:
> 	ace->access_mask = mask_from_posix(deny, flags);
> instead of:
> 	ace->access_mask = deny_mask_from_posix(deny, flags);

Yup, good catch, thanks.  I'll apply the second chunk from this patch
(and adjust the comment appropriately).

--b.

> 
> Frank
> 
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> ---
>  fs/nfsd/nfs4acl.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 54b8b41..ae37ec4 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -295,7 +295,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
>  	group_owner_entry = pa;
>  
>  	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
> -	ace->flag = eflag;
> +	ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
>  	ace->access_mask = mask_from_posix(pas.group, flags);
>  	ace->whotype = NFS4_ACL_WHO_GROUP;
>  	ace++;
> @@ -335,7 +335,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
>  		if (deny) {
>  			ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
>  			ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
> -			ace->access_mask = mask_from_posix(deny, flags);
> +			ace->access_mask = deny_mask_from_posix(deny, flags);
>  			ace->whotype = NFS4_ACL_WHO_NAMED;
>  			ace->who = pa->e_id;
>  			ace++;
> -- 
> 1.5.2.2
> 
> 
> 
