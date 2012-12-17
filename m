Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab2LQVqh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 16:46:37 -0500
Message-ID: <50CF929D.70209@RedHat.com>
Date: Mon, 17 Dec 2012 16:46:05 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [nfs-utils PATCH] mountd: fix is_subdirectory to understand '/'
References: <20121213112342.720ddc6d@notabene.brown>
In-Reply-To: <20121213112342.720ddc6d@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/12/12 19:23, NeilBrown wrote:
> 
> The is_subdirectory() function checks if a given 'child' is a subdirectory
> of the given 'parent'.
> However it always fails if 'parent' == "/"  (because 'child' doesn't begin
> with 'parent' followed by "/").
> 
> So change is_subdirectory() to special-case "/".
> 
> subexport() also tests if one directory is a subdirectory of the
> other, and contains the same bug.  So change it to use is_subdirectory().
> 
> Finally, move is_subdirectory() and related path_matches() and
> export_matches() earlier in the file to avoid a forward-reference.
> 
> This patch fixes a bug wherein if you export "/" with 'crossmnt', the
> crossmnt flag is ineffective and you can only access the root
> filesystem, not any descendants.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.

> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 3853bb6..45012be 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -343,6 +343,30 @@ static char *next_mnt(void **v, char *p)
>  	return me->mnt_dir;
>  }
>  
> +static int is_subdirectory(char *child, char *parent)
> +{
> +	size_t l = strlen(parent);
> +
> +	if (strcmp(parent, "/") == 0)
> +		return 1;
> +
> +	return strcmp(child, parent) == 0
> +		|| (strncmp(child, parent, l) == 0 && child[l] == '/');
> +}
> +
> +static int path_matches(nfs_export *exp, char *path)
> +{
> +	if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
> +		return is_subdirectory(path, exp->m_export.e_path);
> +	return strcmp(path, exp->m_export.e_path) == 0;
> +}
> +
> +static int
> +export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
> +{
> +	return path_matches(exp, path) && client_matches(exp, dom, ai);
> +}
> +
>  /* True iff e1 is a child of e2 and e2 has crossmnt set: */
>  static bool subexport(struct exportent *e1, struct exportent *e2)
>  {
> @@ -350,8 +374,7 @@ static bool subexport(struct exportent *e1, struct exportent *e2)
>  	size_t l2 = strlen(p2);
>  
>  	return e2->e_flags & NFSEXP_CROSSMOUNT
> -	       && strncmp(p1, p2, l2) == 0
> -	       && p1[l2] == '/';
> +		&& is_subdirectory(p1, p2);
>  }
>  
>  struct parsed_fsid {
> @@ -752,27 +775,6 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
>  	return qword_eol(f);
>  }
>  
> -static int is_subdirectory(char *child, char *parent)
> -{
> -	size_t l = strlen(parent);
> -
> -	return strcmp(child, parent) == 0
> -		|| (strncmp(child, parent, l) == 0 && child[l] == '/');
> -}
> -
> -static int path_matches(nfs_export *exp, char *path)
> -{
> -	if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
> -		return is_subdirectory(path, exp->m_export.e_path);
> -	return strcmp(path, exp->m_export.e_path) == 0;
> -}
> -
> -static int
> -export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
> -{
> -	return path_matches(exp, path) && client_matches(exp, dom, ai);
> -}
> -
>  static nfs_export *
>  lookup_export(char *dom, char *path, struct addrinfo *ai)
>  {
> 
