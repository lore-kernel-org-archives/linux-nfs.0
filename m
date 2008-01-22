From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: parenthesize NFS_*(inode) parameters
Date: Tue, 22 Jan 2008 09:50:38 -0500
Message-ID: <1201013438.30335.5.camel@heimdal.trondhjem.org>
References: <1201012083-9860-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFSv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50447 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbYAVOu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 09:50:56 -0500
In-Reply-To: <1201012083-9860-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-22 at 16:28 +0200, Benny Halevy wrote:
> Otherwise e.g., NFS_SERVER(&nfsi->vfs_inode) does not compile.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfs_fs.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 0477a4c..5a5d3fe 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -221,10 +221,10 @@ static inline struct nfs_inode *NFS_I(struct inode *inode)
>  {
>  	return container_of(inode, struct nfs_inode, vfs_inode);
>  }
> -#define NFS_SB(s)		((struct nfs_server *)(s->s_fs_info))
> +#define NFS_SB(s)		((struct nfs_server *)((s)->s_fs_info))
>  
>  #define NFS_FH(inode)			(&NFS_I(inode)->fh)
> -#define NFS_SERVER(inode)		(NFS_SB(inode->i_sb))
> +#define NFS_SERVER(inode)		(NFS_SB((inode)->i_sb))
>  #define NFS_CLIENT(inode)		(NFS_SERVER(inode)->client)
>  #define NFS_PROTO(inode)		(NFS_SERVER(inode)->nfs_client->rpc_ops)
>  #define NFS_COOKIEVERF(inode)		(NFS_I(inode)->cookieverf)

They should really be converted into inlined functions.

Cheers
  Trond
