From: Valerie Aurora <vaurora@redhat.com>
Subject: Re: [PATCH 05/39] whiteout/NFSD: Don't return information about whiteouts to userspace
Date: Thu, 6 May 2010 14:01:51 -0400
Message-ID: <20100506180151.GA21062@shell>
References: <1272928358-20854-1-git-send-email-vaurora@redhat.com> <1272928358-20854-6-git-send-email-vaurora@redhat.com> <20100504093731.3a45ff5f@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Jan Blunck <jblunck@suse.de>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100504093731.3a45ff5f@notabene.brown>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 04, 2010 at 09:37:31AM +1000, Neil Brown wrote:
> On Mon,  3 May 2010 16:12:04 -0700
> Valerie Aurora <vaurora@redhat.com> wrote:
> 
> > From: Jan Blunck <jblunck@suse.de>
> > 
> > Userspace isn't ready for handling another file type, so silently drop
> > whiteout directory entries before they leave the kernel.
> 
> Feels very intrusive doesn't it....
> 
> Have you considered something like the following?

Hrm, I see how that could be more elegant, but I'd rather avoid yet
another layer of function pointer passing around.  This code is
already hard enough to review...

-VAL

> NeilBrown
> 
> diff --git a/fs/readdir.c b/fs/readdir.c
> index 7723401..4c5b347 100644
> --- a/fs/readdir.c
> +++ b/fs/readdir.c
> @@ -19,10 +19,26 @@
>  
>  #include <asm/uaccess.h>
>  
> +struct readdir_info {
> +	filldir_t filler;
> +	void *data;
> +};
> +
> +static int white_out(void *vrdi, const char *name, int namlen,
> +		     loff_t offset, u64 ino, unsigned int d_type)
> +{
> +	struct readdir_info *rdi = vrdi;
> +	if (d_type == DT_WHT)
> +		return 0;
> +	return rdi->filler(rdi->data, name, namlen, offset, info, d_type);
> +}
> +
>  int vfs_readdir(struct file *file, filldir_t filler, void *buf)
>  {
>  	struct inode *inode = file->f_path.dentry->d_inode;
>  	int res = -ENOTDIR;
> +	struct readir_info rdi = { filler, buf };
> +
>  	if (!file->f_op || !file->f_op->readdir)
>  		goto out;
>  
> @@ -36,7 +52,7 @@ int vfs_readdir(struct file *file, filldir_t filler, void *buf)
>  
>  	res = -ENOENT;
>  	if (!IS_DEADDIR(inode)) {
> -		res = file->f_op->readdir(file, buf, filler);
> +		res = file->f_op->readdir(file, &rdi, white_out);
>  		file_accessed(file);
>  	}
>  	mutex_unlock(&inode->i_mutex);
