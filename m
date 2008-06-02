From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] rpc: Push down the ioctl BKL into the RPC code
Date: Mon, 2 Jun 2008 12:15:49 -0400
Message-ID: <20080602161549.GC18887@fieldses.org>
References: <20080522222730.311832af@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond@netapp.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757063AbYFBQQP@vger.kernel.org>
In-Reply-To: <20080522222730.311832af@core>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 22, 2008 at 10:27:30PM +0100, Alan Cox wrote:
> One or two bits I couldn't figure out if the BKL could be dropped for
> 
> Signed-off-by: Alan Cox <alan@redhat.com>

Ack to the net/sunrpc/cache.c change.

The net/sunrpc/rpc_pipe.c changes look fine too, except that there's no
point keeping the BKL anywhere there.

As a matter of fact I think that rpc_pipe_ioctl *is* racy, but that's a
preexisting problem--it needs the i_lock or i_mutex, not the BKL.

(I'm not sure how important the rpci->ops check is, but the "len"
calculation would make more sense if it were atomic, and couldn't the
separate check and dereference of filp->private data lead to a null
deference?)

--b.

> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index c996671..0c1af5d 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -826,11 +826,11 @@ cache_poll(struct file *filp, poll_table *wait)
>  	return mask;
>  }
>  
> -static int
> -cache_ioctl(struct inode *ino, struct file *filp,
> -	    unsigned int cmd, unsigned long arg)
> +static long
> +cache_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
>  {
>  	int len = 0;
> +	struct inode *ino = filp->f_path.dentry->d_inode;
>  	struct cache_reader *rp = filp->private_data;
>  	struct cache_queue *cq;
>  	struct cache_detail *cd = PDE(ino)->data;
> @@ -918,7 +918,7 @@ static const struct file_operations cache_file_operations = {
>  	.read		= cache_read,
>  	.write		= cache_write,
>  	.poll		= cache_poll,
> -	.ioctl		= cache_ioctl, /* for FIONREAD */
> +	.unlocked_ioctl	= cache_ioctl, /* for FIONREAD */
>  	.open		= cache_open,
>  	.release	= cache_release,
>  };
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 5a9b0e7..80bca08 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -296,23 +296,26 @@ rpc_pipe_poll(struct file *filp, struct poll_table_struct *wait)
>  	return mask;
>  }
>  
> -static int
> -rpc_pipe_ioctl(struct inode *ino, struct file *filp,
> -		unsigned int cmd, unsigned long arg)
> +static long
> +rpc_pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
>  {
>  	struct rpc_inode *rpci = RPC_I(filp->f_path.dentry->d_inode);
>  	int len;
>  
>  	switch (cmd) {
>  	case FIONREAD:
> -		if (rpci->ops == NULL)
> +		lock_kernel();
> +		if (rpci->ops == NULL) {
> +			unlock_kernel();
>  			return -EPIPE;
> +		}
>  		len = rpci->pipelen;
>  		if (filp->private_data) {
>  			struct rpc_pipe_msg *msg;
>  			msg = (struct rpc_pipe_msg *)filp->private_data;
>  			len += msg->len - msg->copied;
>  		}
> +		unlock_kernel();
>  		return put_user(len, (int __user *)arg);
>  	default:
>  		return -EINVAL;
> @@ -325,7 +328,7 @@ static const struct file_operations rpc_pipe_fops = {
>  	.read		= rpc_pipe_read,
>  	.write		= rpc_pipe_write,
>  	.poll		= rpc_pipe_poll,
> -	.ioctl		= rpc_pipe_ioctl,
> +	.unlocked_ioctl	= rpc_pipe_ioctl,
>  	.open		= rpc_pipe_open,
>  	.release	= rpc_pipe_release,
>  };
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
