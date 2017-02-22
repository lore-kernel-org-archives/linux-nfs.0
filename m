Return-Path: <jlayton@redhat.com>
Message-ID: <1487765584.2886.8.camel@redhat.com>
Subject: Re: [PATCH 3/4] locks: Set FL_CLOSE when removing flock locks on
 close()
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust
 <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 22 Feb 2017 07:13:04 -0500
In-Reply-To: <c43ab767372bd73a60a4e1c97b39bb6fc0722590.1487691345.git.bcodding@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
	 <c43ab767372bd73a60a4e1c97b39bb6fc0722590.1487691345.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-02-21 at 10:39 -0500, Benjamin Coddington wrote:
> Set FL_CLOSE in fl_flags as in locks_remove_posix() when clearing locks.
> NFS will check for this flag to ensure an unlock is sent in a following
> patch.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/locks.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
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

Looks good. I'm fine with merging this one via the NFS tree, btw...

Reviewed-by: Jeff Layton <jlayton@redhat.com>
