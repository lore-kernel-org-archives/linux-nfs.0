Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f54.google.com ([74.125.82.54]:61506 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757334Ab3CUL10 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 07:27:26 -0400
Received: by mail-wg0-f54.google.com with SMTP id fm10so2214123wgb.9
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2013 04:27:24 -0700 (PDT)
Message-ID: <514AEE9A.3090907@tonian.com>
Date: Thu, 21 Mar 2013 13:27:22 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>,
        Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH 3/3] NFSv4.1: Add a helper pnfs_commit_and_return_layout
References: <1363801148-29998-1-git-send-email-Trond.Myklebust@netapp.com> <1363801148-29998-2-git-send-email-Trond.Myklebust@netapp.com> <1363801148-29998-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363801148-29998-3-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-20 19:39, Trond Myklebust wrote:
> In order to be able to safely return the layout in nfs4_proc_setattr,
> we need to block new uses of the layout, wait for all outstanding
> users of the layout to complete, commit the layout and then return it.
> 
> This patch adds a helper in order to do all this safely.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/nfs4proc.c |  2 +-
>  fs/nfs/pnfs.c     | 22 ++++++++++++++++++++++
>  fs/nfs/pnfs.h     |  6 ++++++
>  3 files changed, 29 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5122753..c560c8f 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2695,7 +2695,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>  	int status;
>  
>  	if (pnfs_ld_layoutret_on_setattr(inode))
> -		pnfs_return_layout(inode);
> +		pnfs_commit_and_return_layout(inode);
>  
>  	nfs_fattr_init(fattr);
>  	
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 45badca..5a5e14d 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -868,6 +868,28 @@ out:
>  }
>  EXPORT_SYMBOL_GPL(_pnfs_return_layout);
>  
> +int
> +pnfs_commit_and_return_layout(struct inode *inode)
> +{
> +	struct pnfs_layout_hdr *lo;
> +	int ret;
> +
> +	spin_lock(&inode->i_lock);
> +	lo = NFS_I(inode)->layout;
> +	if (lo == NULL) {
> +		spin_unlock(&inode->i_lock);
> +		return 0;
> +	}
> +	/* Block new layoutgets and read/write to ds */
> +	lo->plh_block_lgets++;
> +	spin_unlock(&inode->i_lock);
> +	filemap_fdatawait(inode->i_mapping);
> +	ret = pnfs_layoutcommit_inode(inode, true);
> +	if (ret == 0)
> +		ret = _pnfs_return_layout(inode);

else {
	spin_lock(&inode->i_lock);
	lo->plh_block_lgets--;
	spin_unlock(&inode->i_lock);
}

?

Benny

> +	return ret;
> +}
> +
>  bool pnfs_roc(struct inode *ino)
>  {
>  	struct pnfs_layout_hdr *lo;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 94ba804..f5f8a47 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -219,6 +219,7 @@ void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>  void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>  int _pnfs_return_layout(struct inode *);
> +int pnfs_commit_and_return_layout(struct inode *);
>  void pnfs_ld_write_done(struct nfs_write_data *);
>  void pnfs_ld_read_done(struct nfs_read_data *);
>  struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
> @@ -407,6 +408,11 @@ static inline int pnfs_return_layout(struct inode *ino)
>  	return 0;
>  }
>  
> +static inline int pnfs_commit_and_return_layout(struct inode *inode)
> +{
> +	return 0;
> +}
> +
>  static inline bool
>  pnfs_ld_layoutret_on_setattr(struct inode *inode)
>  {
> 
