From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 8/9] fs: nfs: misused copy_to_user() return value
Date: Fri, 30 Jul 2010 13:47:27 -0400
Message-ID: <1280512047.12852.8.camel@heimdal.trondhjem.org>
References: <1280488190-20979-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kernel-janitors@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1280488190-20979-1-git-send-email-segooon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-07-30 at 15:09 +0400, Kulikov Vasiliy wrote:
> copy_to_user() returns nonzero value on error, this value may be any
> value between 0 and requested count, not only requested count.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
> ---
>  fs/nfs/idmap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 21a84d4..a9f2cd5 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -362,7 +362,7 @@ idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
>  	unsigned long left;
>  
>  	left = copy_to_user(dst, data, mlen);
> -	if (left == mlen) {
> +	if (left)
>  		msg->errno = -EFAULT;
>  		return -EFAULT;
>  	}

...and we do handle the case where copy_to_user returns less than the
requested number of bytes: it is called a 'short read' and is quite
allowed in POSIX. The userland application can just call sys_read()
again...

Trond
