From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: add missed CONFIG_NFSD_DEPRECATED
Date: Mon, 13 Dec 2010 19:13:34 -0500
Message-ID: <20101214001334.GH9394@fieldses.org>
References: <1292044877-4701-1-git-send-email-bookjovi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bookjovi@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292044877-4701-1-git-send-email-bookjovi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 11, 2010 at 12:21:17AM -0500, bookjovi@gmail.com wrote:
> these pieces of code only make sense when CONFIG_NFSD_DEPRECATED enabled
> 
> Signed-off-by: Jovi Zhang <bookjovi@gmail.com>

OK, thanks; applied for 2.6.38.--b.

> 
>  fs/nfsd/nfsctl.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 4514ebb..6840ec3 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -127,6 +127,7 @@ static ssize_t nfsctl_transaction_write(struct file *file, const char __user *bu
>  
>  static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
>  {
> +#ifdef CONFIG_NFSD_DEPRECATED
>  	static int warned;
>  	if (file->f_dentry->d_name.name[0] == '.' && !warned) {
>  		printk(KERN_INFO
> @@ -135,6 +136,7 @@ static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size
>  		       current->comm, file->f_dentry->d_name.name);
>  		warned = 1;
>  	}
> +#endif
>  	if (! file->private_data) {
>  		/* An attempt to read a transaction file without writing
>  		 * causes a 0-byte write so that the file can return
