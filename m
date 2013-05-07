Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757929Ab3EGQBk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 12:01:40 -0400
Message-ID: <51892562.1050903@RedHat.com>
Date: Tue, 07 May 2013 12:01:38 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: Fix is_subdirectory again.
References: <20130502170511.646e2717@notabene.brown>
In-Reply-To: <20130502170511.646e2717@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/13 03:05, NeilBrown wrote:
> 
> 
> Hi Steve,
>  I just noticed
> 
> commit ebe2826ca571a3959c3b5c8e29686c621f2775cf
> Author: Steve Dickson <steved@redhat.com>
> Date:   Sat Mar 23 10:30:17 2013 -0400
> 
>     mountd: regression in crossmounts
> 
> Sorry I missed the email you presumably sent me to let me know
> that I had caused a regression.
Yes I should have... That was my bad... 
> 
> Here is the proper fix.
Yes it does work..  thanks! 

The new is committed!

steved.
> 
> Thanks,
> NeilBrown
> 
> 
> Subject: [PATCH] mountd: Fix is_subdirectory again.
> 
> commit ebe2826ca571a (mountd: regression in crossmounts)
> said it was:
>     Reverting the logic of commit 8e2fb3fc until
>     a better solution can be found for the original
>     problem.
> 
> here is the "something better".
> 
> The problem was that is_subdirectory() would also succeed if the two
> directories were the same.  This is needed for path_matches() which
> needs to see if the child is same-or-descendant.
> 
> So this patch rearranges path_matches() to do the "are they the same"
> test itself and only bother with is_subdirectory() if it they are not
> the same.
> 
> So now is_subdirectory() can be strict, and so can be usable for
> subexport(), which needs a strong 'in subdirectory - not the same' test.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 737927c..517aa62 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -347,20 +347,26 @@ static char *next_mnt(void **v, char *p)
>  
>  static int is_subdirectory(char *child, char *parent)
>  {
> +	/* Check is child is strictly a subdirectory of
> +	 * parent or a more distant descendant.
> +	 */
>  	size_t l = strlen(parent);
>  
> -	if (strcmp(parent, "/") == 0)
> +	if (strcmp(parent, "/") == 0 && child[1] != 0)
>  		return 1;
>  
> -	return strcmp(child, parent) == 0
> -		|| (strncmp(child, parent, l) == 0 && child[l] == '/');
> +	return (strncmp(child, parent, l) == 0 && child[l] == '/');
>  }
>  
>  static int path_matches(nfs_export *exp, char *path)
>  {
> -	if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
> -		return is_subdirectory(path, exp->m_export.e_path);
> -	return strcmp(path, exp->m_export.e_path) == 0;
> +	/* Does the path match the export?  I.e. is it an
> +	 * exact match, or does the export have CROSSMOUNT, and path
> +	 * is a descendant?
> +	 */
> +	return strcmp(path, exp->m_export.e_path) == 0
> +		|| ((exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
> +		    && is_subdirectory(path, exp->m_export.e_path));
>  }
>  
>  static int
> @@ -369,15 +375,13 @@ export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
>  	return path_matches(exp, path) && client_matches(exp, dom, ai);
>  }
>  
> -/* True iff e1 is a child of e2 and e2 has crossmnt set: */
> +/* True iff e1 is a child of e2 (or descendant) and e2 has crossmnt set: */
>  static bool subexport(struct exportent *e1, struct exportent *e2)
>  {
>  	char *p1 = e1->e_path, *p2 = e2->e_path;
> -	size_t l2 = strlen(p2);
>  
>  	return e2->e_flags & NFSEXP_CROSSMOUNT
> -		&& strncmp(p1, p2, l2) == 0
> -		&& p1[l2] == '/';
> +		&& is_subdirectory(p1, p2);
>  }
>  
>  struct parsed_fsid {
> 
