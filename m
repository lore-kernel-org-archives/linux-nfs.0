Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35218 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756406Ab0ERPlG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 May 2010 11:41:06 -0400
Date: Tue, 18 May 2010 11:41:03 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: Fix uninitialized ptr access in find_file()
Message-ID: <20100518154103.GG17823@fieldses.org>
References: <4BF16825.2060805@openvz.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BF16825.2060805@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 17, 2010 at 08:00:37PM +0400, Pavel Emelyanov wrote:
> The alloc_init_file() first adds a file to the hash and then
> initializes its fi_inode, fi_id and fi_had_conflict.
> 
> The uninitialized fi_inode can thus be erroneously checked by
> the find_file(), so move the hash insertion lower.
> 
> I didn't find whether the same can be true for two other fields, 
> but the common sense tells me it's better to initialize an object 
> before putting it into a global hash table :)

This code (and any code which looks up items in the file_hashtbl) is
currently all under the big state mutex; the spinlock is necessary only
to protect against some callback code which may remove entries without
holding the state lock.

Nevertheless, we hope to eventually pare down the use of the state lock,
so this looks like an obvious bug waiting to happen.  Applied for 2.6.35
(with changelog edits to clarify the risk).  Thanks!

--b.

> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 84b0fe9..296eded 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1757,12 +1757,12 @@ alloc_init_file(struct inode *ino)
>  		INIT_LIST_HEAD(&fp->fi_hash);
>  		INIT_LIST_HEAD(&fp->fi_stateids);
>  		INIT_LIST_HEAD(&fp->fi_delegations);
> -		spin_lock(&recall_lock);
> -		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
> -		spin_unlock(&recall_lock);
>  		fp->fi_inode = igrab(ino);
>  		fp->fi_id = current_fileid++;
>  		fp->fi_had_conflict = false;
> +		spin_lock(&recall_lock);
> +		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
> +		spin_unlock(&recall_lock);
>  		return fp;
>  	}
>  	return NULL;
> 
