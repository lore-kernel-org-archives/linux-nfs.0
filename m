Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43196 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbcGRUcn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2016 16:32:43 -0400
Date: Mon, 18 Jul 2016 16:32:42 -0400
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/8] mountd: don't add paths to non-mounted export points
 to pseudo-root
Message-ID: <20160718203242.GD12304@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble>
 <20160714022643.5874.27117.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160714022643.5874.27117.stgit@noble>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 14, 2016 at 12:26:43PM +1000, NeilBrown wrote:
> export points with the "mountpoint" flag should not be exported
> if they aren't mounted.
> They shouldn't even appear in the pseudo-root filesystem.
> So add an appropriate check to v4root_set().
> 
> This means that the v4root might need to be recomputed whenever a
> filesystem is mounted or unmounted.  So when there are export points
> with the "mountpoint" flag, check for changes in the mount table.
> This is done be measuring the size of /proc/mounts.

Surely there's some more reliable measurement--could we track some data
about the mountpoint itself, maybe?

But I'd still like some more justification for this change in logic.
Does anyone currently use the "mp" option?  If not, could we just
deprecate it?  If so, can we really get away with changing it this way?

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  support/include/v4root.h |    2 +-
>  utils/mountd/auth.c      |   29 +++++++++++++++++++++++++++--
>  utils/mountd/v4root.c    |   11 ++++++++++-
>  3 files changed, 38 insertions(+), 4 deletions(-)
> 
> diff --git a/support/include/v4root.h b/support/include/v4root.h
> index 706c15c70d95..406fd4e43e5a 100644
> --- a/support/include/v4root.h
> +++ b/support/include/v4root.h
> @@ -10,6 +10,6 @@
>  #define V4ROOT_H
>  
>  extern int v4root_needed;
> -extern void v4root_set(void);
> +extern void v4root_set(int *mountpoints_checked);
>  
>  #endif /* V4ROOT_H */
> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> index 0881d9a6edba..5bd7e6622307 100644
> --- a/utils/mountd/auth.c
> +++ b/utils/mountd/auth.c
> @@ -77,6 +77,29 @@ check_useipaddr(void)
>  		cache_flush(1);
>  }
>  
> +static int mountpoints_changed(void)
> +{
> +	static int last_size = 0;
> +	int size;
> +	int fd;
> +	char buf[4096];
> +	int n;
> +
> +	fd = open("/proc/mounts", O_RDONLY);
> +	if (fd < 0)
> +		/* ignore mountpoint changes if we cannot read /proc/mounts */
> +		return 0;
> +	size = 0;
> +	while ((n = read(fd, buf, sizeof(buf))) > 0)
> +		size += n;
> +	if (n < 0)
> +		return 0;
> +	if (size == last_size)
> +		return 0;
> +	last_size = size;
> +	return 1;
> +}
> +
>  unsigned int
>  auth_reload()
>  {
> @@ -84,6 +107,7 @@ auth_reload()
>  	static ino_t		last_inode;
>  	static int		last_fd = -1;
>  	static unsigned int	counter;
> +	static int		mountpoints_checked = 0;
>  	int			fd;
>  
>  	if ((fd = open(_PATH_ETAB, O_RDONLY)) < 0) {
> @@ -91,7 +115,8 @@ auth_reload()
>  	} else if (fstat(fd, &stb) < 0) {
>  		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
>  		close(fd);
> -	} else if (last_fd != -1 && stb.st_ino == last_inode) {
> +	} else if (last_fd != -1 && stb.st_ino == last_inode &&
> +		   (!mountpoints_checked || !mountpoints_changed())) {
>  		/* We opened the etab file before, and its inode
>  		 * number hasn't changed since then.
>  		 */
> @@ -114,7 +139,7 @@ auth_reload()
>  	memset(&my_client, 0, sizeof(my_client));
>  	xtab_export_read();
>  	check_useipaddr();
> -	v4root_set();
> +	v4root_set(&mountpoints_checked);
>  
>  	++counter;
>  
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index d52172592823..1a5778f9c7de 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -183,7 +183,7 @@ static int v4root_add_parents(nfs_export *exp)
>   * looking for components of the v4 mount.
>   */
>  void
> -v4root_set()
> +v4root_set(int *mountpoints_checked)
>  {
>  	nfs_export	*exp;
>  	int	i;
> @@ -193,6 +193,7 @@ v4root_set()
>  	if (!v4root_support())
>  		return;
>  
> +	*mountpoints_checked = 0;
>  	for (i = 0; i < MCL_MAXTYPES; i++) {
>  		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
>  			if (exp->m_export.e_flags & NFSEXP_V4ROOT)
> @@ -202,6 +203,14 @@ v4root_set()
>  				 */
>  				continue;
>  
> +			if (exp->m_export.e_mountpoint) {
> +				*mountpoints_checked = 1;
> +				if (!is_mountpoint(exp->m_export.e_mountpoint[0]?
> +						   exp->m_export.e_mountpoint:
> +						   exp->m_export.e_path))
> +					continue;
> +			}
> +
>  			if (strcmp(exp->m_export.e_path, "/") == 0 &&
>  			    !(exp->m_export.e_flags & NFSEXP_FSID)) {
>  				/* Force '/' to be exported as fsid == 0*/
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
