Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15949 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755933Ab1DTUEB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 16:04:01 -0400
Subject: Re: [RFC 04/27] pnfs: layoutret_on_setattr
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303320401-21106-1-git-send-email-bhalevy@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
	 <1303320401-21106-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 16:03:58 -0400
Message-ID: <1303329838.23206.30.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-20 at 20:26 +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c |    3 +++
>  fs/nfs/pnfs.h     |   22 ++++++++++++++++++++++
>  2 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b03defb..b4df7a6 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2332,6 +2332,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>  	struct nfs4_state *state = NULL;
>  	int status;
>  
> +	if (pnfs_ld_layoutret_on_setattr(inode))
> +		pnfs_return_layout(inode, NULL, true);

There is nothing that prevents further reads and writes being scheduled
after this, so what is the plan to prevent them from being sent to the
MDS?
Also, why are we doing this in the case of a file time update or a
modebits update? It seems relevant only for the case of a size update.

> +
>  	nfs_fattr_init(fattr);
>  	
>  	/* Search for an existing open(O_WRITE) file */
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index a308f3c..3506ad4 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -64,12 +64,18 @@ enum {
>  	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
>  };
>  
> +enum layoutdriver_policy_flags {
> +	/* Should the pNFS client commit and return the layout upon a setattr */
> +	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
> +};
> +
>  /* Per-layout driver specific registration structure */
>  struct pnfs_layoutdriver_type {
>  	struct list_head pnfs_tblid;
>  	const u32 id;
>  	const char *name;
>  	struct module *owner;
> +	unsigned flags;
>  	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
>  	void (*free_lseg) (struct pnfs_layout_segment *lseg);
>  
> @@ -228,6 +234,16 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
>  		put_lseg(req->wb_commit_lseg);
>  }
>  
> +/* Should the pNFS client commit and return the layout upon a setattr */
> +static inline bool
> +pnfs_ld_layoutret_on_setattr(struct inode *inode)
> +{
> +	if (!pnfs_enabled_sb(NFS_SERVER(inode)))
> +		return false;
> +	return NFS_SERVER(inode)->pnfs_curr_ld->flags &
> +		PNFS_LAYOUTRET_ON_SETATTR;
> +}
> +
>  static inline int pnfs_return_layout(struct inode *ino,
>  				     struct pnfs_layout_range *range,
>  				     bool wait)
> @@ -290,6 +306,12 @@ static inline int pnfs_return_layout(struct inode *ino,
>  }
>  
>  static inline bool
> +pnfs_ld_layoutret_on_setattr(struct inode *inode)
> +{
> +	return false;
> +}
> +
> +static inline bool
>  pnfs_roc(struct inode *ino)
>  {
>  	return false;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

