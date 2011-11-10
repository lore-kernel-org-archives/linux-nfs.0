Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35141 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab1KJIoS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 03:44:18 -0500
Received: by fagn18 with SMTP id n18so260233fag.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 00:44:16 -0800 (PST)
Message-ID: <4EBB8EDD.9090107@tonian.com>
Date: Thu, 10 Nov 2011 10:44:13 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH 6/8] pnfsblock: clean up _add_entry
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com> <1320851766-1834-7-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1320851766-1834-7-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-09 17:16, Peng Tao wrote:
> It is wrong to kmalloc in _add_entry() as it is inside
> spinlock. memory should be already allocated _add_entry() is called.

What about the call from _set_range, it is passing NULL?

> So BUG instead if we fail to find a match and no memory preallocated.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/blocklayout/extents.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
> index f383524..952ea8a 100644
> --- a/fs/nfs/blocklayout/extents.c
> +++ b/fs/nfs/blocklayout/extents.c
> @@ -110,13 +110,8 @@ static int _add_entry(struct my_tree *tree, u64 s, int32_t tag,
>  		return 0;
>  	} else {
>  		struct pnfs_inval_tracking *new;
> -		if (storage)
> -			new = storage;
> -		else {
> -			new = kmalloc(sizeof(*new), GFP_NOFS);
> -			if (!new)
> -				return -ENOMEM;
> -		}
> +		BUG_ON(!storage);

The BUG isn't needed as you dereference the pointer right away.

Benny

> +		new = storage;
>  		new->it_sector = s;
>  		new->it_tags = (1 << tag);
>  		list_add(&new->it_link, &pos->it_link);
