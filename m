From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Mon, 8 Mar 2010 08:25:16 +1100
Message-ID: <20100308082516.260e5f70@notabene.brown>
References: <20100307200607.GA13006@fieldses.org>
	<1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
	<1267992481-13332-2-git-send-email-bfields@citi.umich.edu>
	<1267992481-13332-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56966 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868Ab0CGVZZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 16:25:25 -0500
In-Reply-To: <1267992481-13332-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun,  7 Mar 2010 15:08:01 -0500
"J. Bruce Fields" <bfields@citi.umich.edu> wrote:

> The extra cache entries added here all get the options of the parent
> export.  This is incorrect, since once of the children may be explicitly
> exported with different options, and the parent crossmnt shouldn't
> override the explicit child export.
> 
> What's more, this is unnecessary, since in the newcache case we'll
> request these on demand when we need them.

Are you sure that removing this doesn't break something else?
It was explicitly added in commit 323d1c4d69b65ab36d, apparently for a good
reason.

Also, it shouldn't be causing the problem described as cache_export_ent
should only be called where 'exp' is the lowest (furthest from the root)
export for any directory in 'path'.  So any child mounts that are found
should not be explicitly exported.


This code is needed to handle a case where you have
/a /a/b /a/b/c all mount points, /a is exported with crossmnt,
and a mount request comes in for /a/b/c (or /a/b).
mountd needs to get the filehandle for /a/b/c, so that filesystem must be
exported to the kernel.  We cannot really on upcalls filling in that
information as doing so would cause mountd to deadlock - it asks the kernel
for a filehandle, the kernel asks it for export information, and mountd is
single-threaded...

Are you sure that removing this actually fixes a problem?

NeilBrown


> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  utils/mountd/cache.c |   40 ----------------------------------------
>  1 files changed, 0 insertions(+), 40 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 7dec468..200e179 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -817,46 +817,6 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
>  		     " fsid= required", exp->e_path);
>  	}
>  
> -	while (err == 0 && (exp->e_flags & NFSEXP_CROSSMOUNT) && path) {
> -		/* really an 'if', but we can break out of
> -		 * a 'while' more easily */
> -		/* Look along 'path' for other filesystems
> -		 * and export them with the same options
> -		 */
> -		struct stat stb;
> -		int l = strlen(exp->e_path);
> -		int dev;
> -
> -		if (strlen(path) <= l || path[l] != '/' ||
> -		    strncmp(exp->e_path, path, l) != 0)
> -			break;
> -		if (stat(exp->e_path, &stb) != 0)
> -			break;
> -		dev = stb.st_dev;
> -		while(path[l] == '/') {
> -			char c;
> -			/* errors for submount should fail whole filesystem */
> -			int err2;
> -
> -			l++;
> -			while (path[l] != '/' && path[l])
> -				l++;
> -			c = path[l];
> -			path[l] = 0;
> -			err2 = lstat(path, &stb);
> -			path[l] = c;
> -			if (err2 < 0)
> -				break;
> -			if (stb.st_dev == dev)
> -				continue;
> -			dev = stb.st_dev;
> -			path[l] = 0;
> -			dump_to_cache(f, domain, path, exp);
> -			path[l] = c;
> -		}
> -		break;
> -	}
> -
>  	fclose(f);
>  	return err;
>  }

