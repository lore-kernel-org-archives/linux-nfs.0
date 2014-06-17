Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932135AbaFQSG5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2014 14:06:57 -0400
Message-ID: <53A083BD.5080403@RedHat.com>
Date: Tue, 17 Jun 2014 14:06:53 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: add support for case-insensitive file names.
References: <20140612124947.725f47bd@notabene.brown>
In-Reply-To: <20140612124947.725f47bd@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/11/2014 10:49 PM, NeilBrown wrote:
> 
> 
> Case insensitive filesystems support textually distinct names for the
> same directory. i.e. you can access it with a name other than the
> canonical name.
> For example if you
>   mkdir /mnt/export
> 
> then add /mnt/EXPORT to /etc/exports, and on a client
>   mount server:/mnt/EXPORT /import
> 
> then the mount will work, but if the kernel on the server needs to
> refresh the export information, it will ask about "/mnt/export", which
> is not listed in /etc/exports and so will fail.
> 
> To fix this we need mountd to perform case-insensitive name
> comparisons, but only when the filesystem would, and in exactly the
> same way that the filesystem would.
> 
> So, when comparing paths for equality first try some simple heuristics
> which will not be fooled by case and then ask the kernel if they are
> the same.
> 
> By preference we use name_to_handle_at() as it reports the mntid which
> can distinguish between bind mounts.  If that is not available, use
> lstat() and compare rdev and ino.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed...

steved.

> 
> ---
> This was discussed a little while ago under the subject
>   Should exportfs/mountd cope with case-insensitive directory names.
> 
> I've added name_to_handle_at support if it is available to
> get a more precise result.
> 
> I've tested by exporting a subdirectory of a VFAT filesystem using a different
> name than the one the directory was created with.
> This works with old code until you
> 
> date +%s > /proc/net/rpc/nfsd.export/flush 
> 
> (or wait 15 minutes) at which point you get a stale file handle.
> With the patch, you don't get the stale file handle.
> 
> 
> Thanks,
> NeilBrown
> 
> diff --git a/configure.ac b/configure.ac
> index 7b93de6386db..408f4c85bd98 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -411,7 +411,7 @@ AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
>                 getnameinfo getrpcbyname getifaddrs \
>                 gettimeofday hasmntopt inet_ntoa innetgr memset mkdir pathconf \
>                 ppoll realpath rmdir select socket strcasecmp strchr strdup \
> -               strerror strrchr strtol strtoul sigprocmask])
> +               strerror strrchr strtol strtoul sigprocmask name_to_handle_at])
>  
>  
>  dnl *************************************************************
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 9a1bb2767ac2..6dad257e03ce 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -377,6 +377,80 @@ static char *next_mnt(void **v, char *p)
>  	return me->mnt_dir;
>  }
>  
> +/* same_path() check is two paths refer to the same directory.
> + * We don't rely on 'strcmp()' as some filesystems support case-insensitive
> + * names and we might have two different names for the one directory.
> + * Theoretically the lengths of the names could be different, but the
> + * number of components must be the same.
> + * So if the paths have the same number of components (but aren't identical)
> + * we ask the kernel if they are the same thing.
> + * By preference we use name_to_handle_at(), as the mntid it returns
> + * will distinguish between bind-mount points.  If that isn't available
> + * we fall back on lstat, which is usually good enough.
> + */
> +static inline int count_slashes(char *p)
> +{
> +	int cnt = 0;
> +	while (*p)
> +		if (*p++ == '/')
> +			cnt++;
> +	return cnt;
> +}
> +
> +static int same_path(char *child, char *parent, int len)
> +{
> +	static char p[PATH_MAX];
> +	if (len <= 0)
> +		len = strlen(child);
> +	strncpy(p, child, len);
> +	p[len] = 0;
> +	if (strcmp(p, parent) == 0)
> +		return 1;
> +
> +	/* If number of '/' are different, they must be different */
> +	if (count_slashes(p) != count_slashes(parent))
> +		return 0;
> +
> +#if HAVE_NAME_TO_HANDLE_AT
> +	struct {
> +		struct file_handle fh;
> +		unsigned char handle[128];
> +	} fchild, fparent;
> +	int mnt_child, mnt_parent;
> +	fchild.fh.handle_bytes = 128;
> +	fparent.fh.handle_bytes = 128;
> +	if (name_to_handle_at(AT_FDCWD, p, &fchild.fh, &mnt_child, 0) != 0) {
> +		if (errno == ENOSYS)
> +			goto fallback;
> +		return 0;
> +	}
> +	if (name_to_handle_at(AT_FDCWD, parent, &fparent.fh, &mnt_parent, 0) != 0)
> +		return 0;
> +	if (mnt_child != mnt_parent ||
> +	    fchild.fh.handle_bytes != fparent.fh.handle_bytes ||
> +	    fchild.fh.handle_type != fparent.fh.handle_type ||
> +	    memcmp(fchild.handle, fparent.handle,
> +		   fchild.fh.handle_bytes) != 0)
> +		return 0;
> +	return 1;
> +fallback:;
> +#endif
> +	/* This is nearly good enough.  However if a directory is
> +	 * bind-mounted in two places and both are exported, it
> +	 * could give a false positive
> +	 */
> +	struct stat sc, sp;
> +	if (lstat(p, &sc) != 0)
> +		return 0;
> +	if (lstat(parent, &sp) != 0)
> +		return 0;
> +	if (sc.st_dev != sp.st_dev)
> +		return 0;
> +	if (sc.st_ino != sp.st_ino)
> +		return 0;
> +	return 1;
> +}
> +
>  static int is_subdirectory(char *child, char *parent)
>  {
>  	/* Check is child is strictly a subdirectory of
> @@ -387,7 +461,7 @@ static int is_subdirectory(char *child, char *parent)
>  	if (strcmp(parent, "/") == 0 && child[1] != 0)
>  		return 1;
>  
> -	return (strncmp(child, parent, l) == 0 && child[l] == '/');
> +	return (same_path(child, parent, l) && child[l] == '/');
>  }
>  
>  static int path_matches(nfs_export *exp, char *path)
> @@ -396,7 +470,7 @@ static int path_matches(nfs_export *exp, char *path)
>  	 * exact match, or does the export have CROSSMOUNT, and path
>  	 * is a descendant?
>  	 */
> -	return strcmp(path, exp->m_export.e_path) == 0
> +	return same_path(path, exp->m_export.e_path, 0)
>  		|| ((exp->m_export.e_flags & NFSEXP_CROSSMOUNT)
>  		    && is_subdirectory(path, exp->m_export.e_path));
>  }
> 
