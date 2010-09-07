Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab0IGNhP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 09:37:15 -0400
Date: Tue, 7 Sep 2010 09:40:58 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC][PATCH] nfs: support legacy NFS flock behavior via mount
 option
Message-ID: <20100907094058.2f499050@corrin.poochiereds.net>
In-Reply-To: <4C84DFA7.7050507@suse.de>
References: <4C84DFA7.7050507@suse.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 06 Sep 2010 18:03:43 +0530
Suresh Jayaraman <sjayaraman@suse.de> wrote:

> NFS clients since 2.6.12 support flock()locks by emulating the
> BSD-style locks in terms of POSIX byte range locks. So the NFS client
> does not allow to lock the same file using both flock() and fcntl
> byte-range locks.
> 
> For some Windows applications which seem to use both share mode locks
> (flock()) and fcntl byte range locks sequentially on the same file,
> the locking is failing as the lock has already been acquired. i.e. the
> flock mapped as posix locks collide with actual byte range locks from
> the same process. The problem was observed on a setup with Windows
> clients accessing Excel files on a Samba exported share which is
> originally a NFS mount from a NetApp filer. Since kernels < 2.6.12 does
> not support flock, what was working (as flock locks were local) in
> older kernels is not working with newer kernels.
> 
> This could be seen as a bug in the implementation of the windows
> application or a NFS client regression, but that is debatable.
> In the spirit of not breaking existing setups, this patch adds mount
> options "flock=local" that enables older flock behavior and
> "flock=fcntl" that allows the current flock behavior.
> 
> Here's the test program used to test the locking behavior:
> 
> /*
>  * nfs-lock: Simple program to lock a file using flock and then using fcntl
>  * Used to Test flock behavior on NFS (to be run on NFS mounts)
>  *      Usage: ./nfs-lock <file> 
>  */
> #include <stdio.h>
> #include <string.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <errno.h>
> #include <sys/file.h>
> 
> void usage()
> {
>         fprintf(stdout, "Usage: nfs-lock <file>\n");
>         exit(1);
> }
> 
> int main(int argc, char *argv[])
> {
>         char *file = argv[1];
>         struct flock lock;
>         int fd, rc;
> 
>         if (argc !=2)
>                 usage();
> 
>         fd = open(file, O_RDWR);
>         if (fd < 0) {
>                 perror("open");
>                 return 1;
>         }
> 
>         /* acquire flock */
>         printf("nfs-lock: Trying to acquire flock lock\n");
>         rc = flock(fd, LOCK_EX);
>         if (rc)
>                 perror("flock");
> 
>         memset(&lock, 0, sizeof(lock));
>         lock.l_type = F_WRLCK;
>         printf("nfs-lock: Trying to acquire fcntl lock\n");
>         rc = fcntl(fd, F_SETLK, &lock);
>         if (rc) {
>                 perror("fcntl");
>                 return 1;
>         }
>         printf("nfs-lock: fcntl obtained successfully on the file\n");
> 
>         flock(fd, LOCK_UN);
>         fcntl(fd, F_UNLCK, &lock);
>         close(fd);
> 
>         return 0;
> }
> 
> Cc: Neil Brown <neilb@suse.de>
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> ---
>  fs/nfs/file.c             |    6 +++++-
>  fs/nfs/super.c            |   33 +++++++++++++++++++++++++++++++++
>  include/linux/nfs_mount.h |    2 ++
>  3 files changed, 40 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index eb51bd6..2384382 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -825,12 +825,16 @@ out_err:
>   */
>  static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
>  {
> +	struct inode *inode = filp->f_mapping->host;
> +
>  	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
>  			filp->f_path.dentry->d_parent->d_name.name,
>  			filp->f_path.dentry->d_name.name,
>  			fl->fl_type, fl->fl_flags);
>  
> -	if (!(fl->fl_flags & FL_FLOCK))
> +	/* flock is considered local if mounted with "-o flock=local" */
> +	if ((NFS_SERVER(inode)->flags & NFS_MOUNT_FLOCK_LOCAL) ||
> +			(!(fl->fl_flags & FL_FLOCK)))
>  		return -ENOLCK;
>  
>  	/* We're simulating flock() locks using posix locks on the server */
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index ec3966e..65c780d 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -100,6 +100,7 @@ enum {
>  	Opt_addr, Opt_mountaddr, Opt_clientaddr,
>  	Opt_lookupcache,
>  	Opt_fscache_uniq,
> +	Opt_flock,
>  
>  	/* Special mount options */
>  	Opt_userspace, Opt_deprecated, Opt_sloppy,
> @@ -171,6 +172,7 @@ static const match_table_t nfs_mount_option_tokens = {
>  
>  	{ Opt_lookupcache, "lookupcache=%s" },
>  	{ Opt_fscache_uniq, "fsc=%s" },
> +	{ Opt_flock, "flock=%s" },
>  
>  	{ Opt_err, NULL }
>  };
> @@ -236,6 +238,18 @@ static match_table_t nfs_lookupcache_tokens = {
>  	{ Opt_lookupcache_err, NULL }
>  };
>  
> +enum {
> +	Opt_flock_local, Opt_flock_fcntl,
> +	Opt_flock_err
> +};
> +
> +static match_table_t nfs_flock_tokens = {
> +	{ Opt_flock_local, "local" },
> +	{ Opt_flock_fcntl, "fcntl" },
> +
> +	{ Opt_flock_err, NULL }
> +};
> +
>  
>  static void nfs_umount_begin(struct super_block *);
>  static int  nfs_statfs(struct dentry *, struct kstatfs *);
> @@ -1412,6 +1426,25 @@ static int nfs_parse_mount_options(char *raw,
>  			mnt->fscache_uniq = string;
>  			mnt->options |= NFS_OPTION_FSCACHE;
>  			break;
> +		case Opt_flock:
> +			string = match_strdup(args);
> +			if (string == NULL)
> +				goto out_nomem;
> +			token = match_token(string, nfs_flock_tokens, args);
> +			kfree(string);
> +			switch (token) {
> +				case Opt_flock_local:
> +					mnt->flags |= NFS_MOUNT_FLOCK_LOCAL;
> +					break;
> +				case Opt_flock_fcntl:
> +					mnt->flags &= ~NFS_MOUNT_FLOCK_LOCAL;
> +					break;
> +				default:
> +					dfprintk(MOUNT, "NFS:	invalid	"
> +							"flock argument\n");
> +					return 0;
> +			};
> +			break;
>  
>  		/*
>  		 * Special options
> diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
> index 5d59ae8..ee08dae 100644
> --- a/include/linux/nfs_mount.h
> +++ b/include/linux/nfs_mount.h
> @@ -71,4 +71,6 @@ struct nfs_mount_data {
>  #define NFS_MOUNT_NORESVPORT		0x40000
>  #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
>  
> +#define NFS_MOUNT_FLOCK_LOCAL	0x100000
> +
>  #endif
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

I like the overall concept of this patch. I too think flock emulation
needs to be tunable since it's not really part of the NFS spec and it
can be problematic in some cases.

I had considered doing something similar a while back with a module
option. This seems better though since it's more granular.

Acked-by: Jeff Layton <jlayton@redhat.com>
