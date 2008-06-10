From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/7] NFS: Make nfs_llseek methods consistent
Date: Tue, 10 Jun 2008 14:27:00 -0400
Message-ID: <1213122420.20459.2.camel@localhost>
References: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
	 <20080527202915.6651.44947.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4573 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbYFJS1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 14:27:03 -0400
In-Reply-To: <20080527202915.6651.44947.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-27 at 16:29 -0400, Chuck Lever wrote:
> Clean up: Report the same debugging info in nfs_llseek_dir() and
> nfs_llseek_file().
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/dir.c  |   12 ++++++++++--
>  fs/nfs/file.c |    7 +++++++
>  2 files changed, 17 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 1bc8bc6..36e51f7 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -603,7 +603,15 @@ out:
>  
>  static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
>  {
> -	mutex_lock(&filp->f_path.dentry->d_inode->i_mutex);
> +	struct dentry *dentry = filp->f_path.dentry;
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +
> +	dfprintk(VFS, "NFS: llseek dir(%s/%s, %lld, %d)\n",
> +			dentry->d_parent->d_name.name,
> +			dentry->d_name.name,
> +			offset, origin);
> +
> +	mutex_lock(&inode->i_mutex);
>  	switch (origin) {
>  		case 1:
>  			offset += filp->f_pos;
> @@ -619,7 +627,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
>  		nfs_file_open_context(filp)->dir_cookie = 0;
>  	}
>  out:
> -	mutex_unlock(&filp->f_path.dentry->d_inode->i_mutex);
> +	mutex_unlock(&inode->i_mutex);
>  	return offset;
>  }
>  
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index e452903..06a1322 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -170,6 +170,13 @@ force_reval:
>  
>  static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
>  {
> +	struct dentry *dentry = filp->f_path.dentry;
> +
> +	dfprintk(VFS, "NFS: llseek file(%s/%s, %lld, %d)\n",
> +			dentry->d_parent->d_name.name,
> +			dentry->d_name.name,
> +			offset, origin);
> +

This will result in 'unused variable' warnings for 'dentry' if you
compile with #undef RPC_DEBUG.

>  	/* origin == SEEK_END => we must revalidate the cached file length */
>  	if (origin == SEEK_END) {
>  		struct inode *inode = filp->f_mapping->host;
> 
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
