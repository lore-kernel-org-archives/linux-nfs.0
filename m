Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:65057 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab1FHCFp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 22:05:45 -0400
Received: by vxi39 with SMTP id 39so38056vxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2011 19:05:45 -0700 (PDT)
Message-ID: <4DEED8FC.4000000@panasas.com>
Date: Tue, 07 Jun 2011 22:05:48 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 88/88] NFS41: do not update isize if inode needs layoutcommit
References: <cover.1307464381.git.rees@umich.edu> <8d4549ecda23f5ada0c88677c9505cba2830dad5.1307464382.git.rees@umich.edu>
In-Reply-To: <8d4549ecda23f5ada0c88677c9505cba2830dad5.1307464382.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Better send generic patches separately.
This patch needs to go upstream and to stable 2.6.39

Benny

On 2011-06-07 13:36, Jim Rees wrote:
> From: Peng Tao <bergwolf@gmail.com>
> 
> Layout commit is supposed to set server file size similiar to nfs pages.
> We should not update client file size for the same reason.
> Otherwise we will lose what we have at hand.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/inode.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 144f2a3..3f1eb81 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1294,7 +1294,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  		if (new_isize != cur_isize) {
>  			/* Do we perhaps have any outstanding writes, or has
>  			 * the file grown beyond our last write? */
> -			if (nfsi->npages == 0 || new_isize > cur_isize) {
> +			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) ||
> +			     new_isize > cur_isize) {
>  				i_size_write(inode, new_isize);
>  				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
>  			}
