From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] NFS: Use cached nlm_host when calling
	nlmclnt_proc()
Date: Tue, 8 Jan 2008 16:42:51 +0000
Message-ID: <20080108164251.GB20897@infradead.org>
References: <20080108153221.20097.13404.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36784 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbYAHQm5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 11:42:57 -0500
In-Reply-To: <20080108153221.20097.13404.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2008 at 10:32:22AM -0500, Chuck Lever wrote:
> +int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
>  {
>  	struct nlm_rqst		*call;
>  	sigset_t		oldset;
>  	unsigned long		flags;
> +	int			status;
>  
>  	if (host == NULL)
>  		return -ENOLCK;

I think this check can just go away aswell.  It's a quite catastrophic
API useage error and deserves to get a crash instead of addition cargo
cult checks.  Might be good to add kerneldoc comments for all the
exported APIs you touch/add btw to make this entirely clear.

>  nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
>  {
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +	struct nlm_host *host = NFS_SERVER(inode)->nlm_host;
> +
> +	return nlmclnt_proc(host, cmd, fl);
>  }
>
>  static int
>  nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
>  {
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +	struct nlm_host *host = NFS_SERVER(inode)->nlm_host;
> +
> +	return nlmclnt_proc(host, cmd, fl);
>  }

These two are completely identical, any reason there's two copies here?
