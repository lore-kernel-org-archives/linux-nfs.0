From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NFS: prevent remounts on shared superblocks
Date: Sat, 12 Apr 2008 10:42:50 -0400
Message-ID: <20080412104250.1e574c9f@tleilax.poochiereds.net>
References: <1208010798-22782-1-git-send-email-jlayton@redhat.com>
	<1208010798-22782-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1208010798-22782-2-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 12 Apr 2008 10:33:18 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> When we're given a remount request, we likely have some mount options
> that will be changed. If the superblock is shared, however, we can't
> allow those new options to be applied without affecting every mount
> that's associated with this superblock. Track the number of mounts
> associated with the superblock, and fail any remount attempts
> that involve a shared superblock.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/client.c           |    1 +
>  fs/nfs/super.c            |   15 +++++++++++++--
>  include/linux/nfs_fs_sb.h |    1 +
>  3 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index c5c0175..950f4d2 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -828,6 +828,7 @@ static struct nfs_server *nfs_alloc_server(void)
>  
>  	init_waitqueue_head(&server->active_wq);
>  	atomic_set(&server->active, 0);
> +	atomic_set(&server->mounts, 0);
>  
>  	server->io_stats = nfs_alloc_iostats();
>  	if (!server->io_stats) {
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index b49f90f..f080f1e 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -592,6 +592,7 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
>  	struct nfs_server *server = NFS_SB(vfsmnt->mnt_sb);
>  	struct rpc_clnt *rpc;
>  
> +	atomic_dec(&server->mounts);
>  	if (!(flags & MNT_FORCE))
>  		return;
>  	/* -EIO all pending I/O */
> @@ -1359,6 +1360,14 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
>  	struct nfs4_mount_data *options4 = (struct nfs4_mount_data *)raw_data;
>  
>  	/*
> +	 * We're presumably remounting to change some mount options. Fail
> +	 * the mount if the superblock is shared, since the change would
> +	 * affect all the mounts sharing this superblock
> +	 */
> +	if (atomic_read(&nfss->mounts) > 1)
> +		return -EBUSY;
> +
> +	/*
>  	 * Userspace mount programs that send binary options generally send
>  	 * them populated with default values. We have no way to know which
>  	 * ones were explicitly specified. Fall back to legacy behavior and
> @@ -1615,7 +1624,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
>  
>  	if (s->s_fs_info != server) {
>  		nfs_free_server(server);
> -		server = NULL;
> +		server = (struct nfs_server *) s->s_fs_info;
>  	}
>  
>  	if (!s->s_root) {
> @@ -1633,6 +1642,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
>  	if (error)
>  		goto error_splat_root;
>  
> +	atomic_inc(&server->mounts);
>  	s->s_flags |= MS_ACTIVE;
>  	mnt->mnt_sb = s;
>  	mnt->mnt_root = mntroot;
> @@ -2001,7 +2011,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
>  
>  	if (s->s_fs_info != server) {
>  		nfs_free_server(server);
> -		server = NULL;
> +		server = (struct nfs_server *) s->s_fs_info;
>  	}
>  
>  	if (!s->s_root) {
> @@ -2015,6 +2025,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
>  		goto error_splat_super;
>  	}
>  
> +	atomic_inc(&server->mounts);
>  	s->s_flags |= MS_ACTIVE;
>  	mnt->mnt_sb = s;
>  	mnt->mnt_root = mntroot;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 3423c67..c98f522 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -117,6 +117,7 @@ struct nfs_server {
>  
>  	atomic_t active; /* Keep trace of any activity to this server */
>  	wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
> +	atomic_t		mounts;	/* # of mounts sharing this sb */
>  };
>  
>  /* Server capabilities */

Just a note that I'm not truly thrilled with this patch, but didn't see
any other way to do this. The s_count doesn't really seem to be
suitable for checking this since it can get incremented for other
reasons besides sharing superblocks.

The alternative would be to walk the list of mounts in the kernel and
count the number that use this superblock. But with different mount
namespaces I'm not sure how to do that...

If a counter does seem reasonable here, I'm not sure of atomic_t is
warranted for this.

Comments appreciated...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
