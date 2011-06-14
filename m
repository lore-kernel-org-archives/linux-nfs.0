Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34351 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab1FNQPk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 12:15:40 -0400
Received: by iyb14 with SMTP id 14so4797053iyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 09:15:40 -0700 (PDT)
Message-ID: <4DF78929.6050205@gmail.com>
Date: Tue, 14 Jun 2011 12:15:37 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 34/34] NFS41: do not update isize if inode needs layoutcommit
References: <cover.1307921137.git.rees@umich.edu> <e2fb9618168391b74186ebc670b7741bacc1f835.1307921138.git.rees@umich.edu>
In-Reply-To: <e2fb9618168391b74186ebc670b7741bacc1f835.1307921138.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

reminder: this is a generic patch that should be pushed upstream
separately.

Benny

On 2011-06-12 19:45, Jim Rees wrote:
> From: Peng Tao <bergwolf@gmail.com>
> 
> Layout commit is supposed to set server file size similiar to nfs pages.
> We should not update client file size for the same reason.
> Otherwise we will lose what we have at hand.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
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
