Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50084 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932296Ab3EBPQh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 11:16:37 -0400
Date: Thu, 2 May 2013 11:16:34 -0400
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: Fix is_subdirectory again.
Message-ID: <20130502151634.GE15728@fieldses.org>
References: <20130502170511.646e2717@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130502170511.646e2717@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 02, 2013 at 05:05:11PM +1000, NeilBrown wrote:
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

Yup.  The strategy around here is to bury people in email and trust they
have industrial-strength filtering.

And I could have added Neil on the cc: too and forgot, oops:

	http://marc.info/?l=linux-nfs&m=136404930104976&w=2

> Here is the proper fix.

I'm dense.  I still had to scratch my head a while:

So: in a case like the one steved gives:

	/home *(rw,fsid=0,crossmnt)
	/home/fs1 *(rw,crossmnt)
	/home/fs1/fs2/fs3 *(rw,nohide)

where nfsd_fh is asked to look for an export with fsid=0, it gets a
match on the export of /home.  But that loop there keeps going in case
it finds some better match.  In particular it considers any mountpoints
under /home as candidates, since /home has "crossmnt".  And they all
match too.  So it considers in sequence the possibilities:

	(found=/export of /home, found_path=/home)
	(found=/export of /home, found_path=/home/fs1)
	(found=/export of /home, found_path=/home/fs1/fs2/fs3)

The subexport() test--designed to favor crossmnt exports which are
"closer" to the target filesystem--passes in each case, so we end up
taking the last.

So we pass down the longest path to the kernel, it does an export upcall
for that path, the hilarity ensues.

Anyway:

	Acked-by: J. Bruce Fields <bfields@redhat.com>

But this all still gives me a mild headache:

	- it only works if we iterate through the submounts in the
	  correct order?
	- should fsid= be inherited by crossmnt anyway?
	- nfsd_fh() is too long, and the logic (with those extra loop
	  control variables declared static inside the CROSSMOUNT case)
	  could be more straightforward.

--b.

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


