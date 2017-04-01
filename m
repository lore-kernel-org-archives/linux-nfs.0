Return-Path: <jlayton@redhat.com>
Message-ID: <1491054638.18117.4.camel@redhat.com>
Subject: Re: [PATCH 3/6] locks: Set FL_CLOSE when removing flock locks on
 close()
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>, Trond Myklebust
 <trond.myklebust@primarydata.com>, Anna Schumaker
 <anna.schumaker@netapp.com>,  bfields@fieldses.org, Miklos Szeredi
 <miklos@szeredi.hu>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Sat, 01 Apr 2017 09:50:38 -0400
In-Reply-To: <263565f7e1c80222c10c8102fc112f1ce97ccfe8.1491015671.git.bcodding@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
	 <263565f7e1c80222c10c8102fc112f1ce97ccfe8.1491015671.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-03-31 at 23:16 -0400, Benjamin Coddington wrote:
> Set FL_CLOSE in fl_flags as in locks_remove_posix() when clearing locks.
> NFS will check for this flag to ensure an unlock is sent in a following
> patch.
> 

Might be nice to add some verbiage here about why fuse needs to be
changed, just for posterity. I recall the discussion a while back so I
think the change itself looks fine.

> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/fuse/file.c     | 2 +-
>  fs/locks.c         | 2 +-
>  include/linux/fs.h | 2 ++
>  3 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index 2401c5dabb2a..79e1a3a048a8 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -2172,7 +2172,7 @@ static int fuse_setlk(struct file *file, struct file_lock *fl, int flock)
>  	}
>  
>  	/* Unlock on close is handled by the flush method */
> -	if (fl->fl_flags & FL_CLOSE)
> +	if (fl->fl_flags & FL_CLOSE_POSIX == FL_CLOSE_POSIX)
>  		return 0;
>  
>  	fuse_lk_fill(&args, file, fl, opcode, pid, flock, &inarg);
> diff --git a/fs/locks.c b/fs/locks.c
> index 26811321d39b..af2031a1fcff 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -2504,7 +2504,7 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
>  		.fl_owner = filp,
>  		.fl_pid = current->tgid,
>  		.fl_file = filp,
> -		.fl_flags = FL_FLOCK,
> +		.fl_flags = FL_FLOCK | FL_CLOSE,
>  		.fl_type = F_UNLCK,
>  		.fl_end = OFFSET_MAX,
>  	};
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 2ba074328894..e964ae0a9c29 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -903,6 +903,8 @@ static inline struct file *get_file(struct file *f)
>  #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
>  #define FL_LAYOUT	2048	/* outstanding pNFS layout */
>  
> +#define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
> +
>  /*
>   * Special return value from posix_lock_file() and vfs_lock_file() for
>   * asynchronous locking.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
