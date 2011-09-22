Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:54534 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751219Ab1IVQEK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 12:04:10 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: David Howells <dhowells@redhat.com>
Cc: miklos@szeredi.hu, viro@ZenIV.linux.org.uk, jlayton@redhat.com,
        gregkh@suse.de, torvalds@linux-foundation.org,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
References: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Sep 2011 00:04:03 +0800
Message-ID: <1316707443.3346.44.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-09-22 at 14:45 +0100, David Howells wrote:
> Directly suppress automount on the following:
> 
> 	[l]stat
> 	[l]getxattr
> 	[l]setxattr
> 	[l]listxattr
> 	[l]removexattr
> 	name_to_handle_at
> 	fstatat
> 	statfs
> 	utimes
> 
> But provide an AT_AUTOMOUNT_FOLLOW path where possible to override that
> behaviour.
> 
> This changes the behaviour back to before the in-VFS automount patches were
> applied, thus, for example, preventing stat() from causing automounting, but
> allows it to be overridden where possible.
> 
> However, what about the following:
> 
> 	umount
> 	faccessat
> 	fchmodat, chmod
> 	fchownat, lchown, chown
> 
> Should these or should these not cause automounting?
> 
> It's possible that with these additions, the whole decision point in
> follow_automount() can be reduced to just a check of LOOKUP_NO_AUTOMOUNT.

As I have said I don't agree with any of this, including the original
change from Miklos.

But, I also ended up supporting it.

I haven't checked what the side effects would be but using the
LOOKUP_DIRECTORY flag in walks that get caught by the removal of the
LOOKUP_FOLLOW test in follow_automount() and retaining Miklos's original
patch is probably a more natural solution IMO.

After all, automount points are always directories and if we think they
might also need to be automounted then that would cause them to be
mounted, and always has done so.

> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  fs/fhandle.c          |    2 +-
>  fs/stat.c             |    8 ++++----
>  fs/statfs.c           |    3 ++-
>  fs/utimes.c           |   10 +++++++---
>  fs/xattr.c            |   20 ++++++++++++--------
>  include/linux/fcntl.h |    1 +
>  6 files changed, 27 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/fhandle.c b/fs/fhandle.c
> index 6b08864..bc0f327 100644
> --- a/fs/fhandle.c
> +++ b/fs/fhandle.c
> @@ -92,7 +92,7 @@ SYSCALL_DEFINE5(name_to_handle_at, int, dfd, const char __user *, name,
>  		int, flag)
>  {
>  	struct path path;
> -	int lookup_flags;
> +	int lookup_flags = LOOKUP_NO_AUTOMOUNT;
>  	int err;
>  
>  	if ((flag & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
> diff --git a/fs/stat.c b/fs/stat.c
> index ba5316f..e39b489 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> @@ -73,16 +73,16 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
>  {
>  	struct path path;
>  	int error = -EINVAL;
> -	int lookup_flags = 0;
> +	int lookup_flags = LOOKUP_NO_AUTOMOUNT;
>  
>  	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
> -		      AT_EMPTY_PATH)) != 0)
> +		      AT_EMPTY_PATH | AT_AUTOMOUNT_FOLLOW)) != 0)
>  		goto out;
>  
>  	if (!(flag & AT_SYMLINK_NOFOLLOW))
>  		lookup_flags |= LOOKUP_FOLLOW;
> -	if (flag & AT_NO_AUTOMOUNT)
> -		lookup_flags |= LOOKUP_NO_AUTOMOUNT;
> +	if (!(flag & AT_AUTOMOUNT_FOLLOW))
> +		lookup_flags &= ~LOOKUP_NO_AUTOMOUNT;
>  	if (flag & AT_EMPTY_PATH)
>  		lookup_flags |= LOOKUP_EMPTY;
>  
> diff --git a/fs/statfs.c b/fs/statfs.c
> index 8244924..fe64701 100644
> --- a/fs/statfs.c
> +++ b/fs/statfs.c
> @@ -76,7 +76,8 @@ EXPORT_SYMBOL(vfs_statfs);
>  int user_statfs(const char __user *pathname, struct kstatfs *st)
>  {
>  	struct path path;
> -	int error = user_path(pathname, &path);
> +	int error = user_path_at(AT_FDCWD, pathname, LOOKUP_NO_AUTOMOUNT,
> +				 &path);
>  	if (!error) {
>  		error = vfs_statfs(&path, st);
>  		path_put(&path);
> diff --git a/fs/utimes.c b/fs/utimes.c
> index ba653f3..e9bf196 100644
> --- a/fs/utimes.c
> +++ b/fs/utimes.c
> @@ -136,13 +136,15 @@ long do_utimes(int dfd, const char __user *filename, struct timespec *times,
>  		goto out;
>  	}
>  
> -	if (flags & ~AT_SYMLINK_NOFOLLOW)
> +	if (flags & ~(AT_SYMLINK_NOFOLLOW |
> +		      AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW))
>  		goto out;
>  
>  	if (filename == NULL && dfd != AT_FDCWD) {
>  		struct file *file;
>  
> -		if (flags & AT_SYMLINK_NOFOLLOW)
> +		if (flags & (AT_SYMLINK_NOFOLLOW |
> +			     AT_NO_AUTOMOUNT | AT_AUTOMOUNT_FOLLOW))
>  			goto out;
>  
>  		file = fget(dfd);
> @@ -154,10 +156,12 @@ long do_utimes(int dfd, const char __user *filename, struct timespec *times,
>  		fput(file);
>  	} else {
>  		struct path path;
> -		int lookup_flags = 0;
> +		int lookup_flags = LOOKUP_NO_AUTOMOUNT;
>  
>  		if (!(flags & AT_SYMLINK_NOFOLLOW))
>  			lookup_flags |= LOOKUP_FOLLOW;
> +		if (flags & AT_AUTOMOUNT_FOLLOW)
> +			lookup_flags &= ~LOOKUP_NO_AUTOMOUNT;
>  
>  		error = user_path_at(dfd, filename, lookup_flags, &path);
>  		if (error)
> diff --git a/fs/xattr.c b/fs/xattr.c
> index f060663..7c462ae 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -290,7 +290,8 @@ SYSCALL_DEFINE5(setxattr, const char __user *, pathname,
>  	struct path path;
>  	int error;
>  
> -	error = user_path(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname,
> +			     LOOKUP_FOLLOW | LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = mnt_want_write(path.mnt);
> @@ -309,7 +310,7 @@ SYSCALL_DEFINE5(lsetxattr, const char __user *, pathname,
>  	struct path path;
>  	int error;
>  
> -	error = user_lpath(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname, LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = mnt_want_write(path.mnt);
> @@ -386,7 +387,8 @@ SYSCALL_DEFINE4(getxattr, const char __user *, pathname,
>  	struct path path;
>  	ssize_t error;
>  
> -	error = user_path(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname,
> +			     LOOKUP_FOLLOW | LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = getxattr(path.dentry, name, value, size);
> @@ -400,7 +402,7 @@ SYSCALL_DEFINE4(lgetxattr, const char __user *, pathname,
>  	struct path path;
>  	ssize_t error;
>  
> -	error = user_lpath(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname, LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = getxattr(path.dentry, name, value, size);
> @@ -459,7 +461,8 @@ SYSCALL_DEFINE3(listxattr, const char __user *, pathname, char __user *, list,
>  	struct path path;
>  	ssize_t error;
>  
> -	error = user_path(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname,
> +			     LOOKUP_FOLLOW | LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = listxattr(path.dentry, list, size);
> @@ -473,7 +476,7 @@ SYSCALL_DEFINE3(llistxattr, const char __user *, pathname, char __user *, list,
>  	struct path path;
>  	ssize_t error;
>  
> -	error = user_lpath(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname, LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = listxattr(path.dentry, list, size);
> @@ -519,7 +522,8 @@ SYSCALL_DEFINE2(removexattr, const char __user *, pathname,
>  	struct path path;
>  	int error;
>  
> -	error = user_path(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname,
> +			     LOOKUP_FOLLOW | LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = mnt_want_write(path.mnt);
> @@ -537,7 +541,7 @@ SYSCALL_DEFINE2(lremovexattr, const char __user *, pathname,
>  	struct path path;
>  	int error;
>  
> -	error = user_lpath(pathname, &path);
> +	error = user_path_at(AT_FDCWD, pathname, LOOKUP_NO_AUTOMOUNT, &path);
>  	if (error)
>  		return error;
>  	error = mnt_want_write(path.mnt);
> diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
> index f550f89..768fb66 100644
> --- a/include/linux/fcntl.h
> +++ b/include/linux/fcntl.h
> @@ -47,6 +47,7 @@
>  #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
>  #define AT_NO_AUTOMOUNT		0x800	/* Suppress terminal automount traversal */
>  #define AT_EMPTY_PATH		0x1000	/* Allow empty relative pathname */
> +#define AT_AUTOMOUNT_FOLLOW	0x2000	/* Follow terminal automounts */
>  
>  #ifdef __KERNEL__
>  
> 


