From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH nfsd-next] nfsd: Export get_task_comm for nfsd
Date: Thu, 23 Sep 2010 10:39:06 -0400
Message-ID: <20100923143906.GC1054@fieldses.org>
References: <4C9B176E.4090808@parallels.com>
 <20100923140550.GA10137@infradead.org>
 <4C9B63B2.4030907@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33438 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755589Ab0IWOkj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 10:40:39 -0400
In-Reply-To: <4C9B63B2.4030907@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 23, 2010 at 06:26:58PM +0400, Pavel Emelyanov wrote:
> > Why doesn't it simply use current->comm as countless other users?
> 
> Yep, this is indeed better...
> 
> The git://linux-nfs.org/~bfields/linux.git nfsd-next branch doesn't
> compile when nfsd is a module with the following error:
> 
>    ERROR: "get_task_comm" [fs/nfsd/nfsd.ko] undefined!
> 
> Replace the get_task_comm call with direct comm access, which is
> safe for current.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.

--b.

> 
> ---
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 83c82ed..b6e192d 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -129,12 +129,10 @@ static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size
>  {
>  	static int warned;
>  	if (file->f_dentry->d_name.name[0] == '.' && !warned) {
> -		char name[sizeof(current->comm)];
>  		printk(KERN_INFO
>  		       "Warning: \"%s\" uses deprecated NFSD interface: %s."
>  		       "  This will be removed in 2.6.40\n",
> -		       get_task_comm(name, current),
> -		       file->f_dentry->d_name.name);
> +		       current->comm, file->f_dentry->d_name.name);
>  		warned = 1;
>  	}
>  	if (! file->private_data) {
