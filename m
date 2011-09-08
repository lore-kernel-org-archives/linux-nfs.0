Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:53009 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932740Ab1IHNNH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 09:13:07 -0400
Message-ID: <4E68BCD4.9030202@nexenta.com>
Date: Thu, 08 Sep 2011 17:02:12 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: tao.peng@emc.com
CC: Trond.Myklebust@netapp.com, gusev.vitaliy@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com> <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com> <F19688880B763E40B28B2B462677FBF805C3299C9C@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C3299C9C@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/08/2011 02:00 PM, tao.peng@emc.com wrote:
> Hi, Gusev,

Hello Tao!

> Yes, you are right. How about following patch?
>
>  From 14c6da67565fb31c2d2775ccefd93251f348910d Mon Sep 17 00:00:00 2001
> From: Peng Tao<bergwolf@gmail.com>
> Date: Thu, 8 Sep 2011 00:57:02 -0400
> Subject: [PATCH] nfsv4: fix race in layoutcommit lseg list create/free
>
> Since there can be more than one layoutcommit proc happen the same time,
> lseg list create/free should be protected. Otherwise lseg list
> may get corrupted.
>
> Reported-by: Vitaliy Gusev<gusev.vitaliy@nexenta.com>
> Signed-off-by: Peng Tao<peng_tao@emc.com>
> ---
>   fs/nfs/nfs4proc.c |    2 ++
>   1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8c77039..da7c20c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5964,6 +5964,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>   	struct pnfs_layout_segment *lseg, *tmp;
>
>   	pnfs_cleanup_layoutcommit(data);
> +	spin_lock(&data->args.inode->i_lock);

I think lock over list_del_init(&lseg->pls_lc_list) is enough, because

1. here lseg is deleted from unique (placed in stack) data and there is 
no any race during deletion.


2. Only one thing must be protected - list_empty status at 
pnfs_list_write_lseg (after my patch).

    The problem is that list_del_init is placed before 
test_and_clear_bit and spinlock can be some kind of barrier for 
protection against adding lseg to new data->lseg_list at
pnfs_list_write_lseg.

    Do reordering list_del_init with test_and_clear_bit is not good, 
because lseg can be invalid after put_lseg.


>   	/* Matched by references in pnfs_set_layoutcommit */
>   	list_for_each_entry_safe(lseg, tmp,&data->lseg_list, pls_lc_list) {
>   		list_del_init(&lseg->pls_lc_list);
> @@ -5971,6 +5972,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>   				&lseg->pls_flags))
>   			put_lseg(lseg);
>   	}
> +	spin_unlock(&data->args.inode->i_lock);
>   	put_rpccred(data->cred);
>   	kfree(data);
>   }

