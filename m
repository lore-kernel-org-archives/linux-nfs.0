Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbaA1PKk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jan 2014 10:10:40 -0500
Date: Tue, 28 Jan 2014 10:10:37 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix races in nfs_revalidate_mapping
Message-ID: <20140128101037.35e04fb7@tlielax.poochiereds.net>
In-Reply-To: <1390920550-5543-1-git-send-email-trond.myklebust@primarydata.com>
References: <20140128091849.6f3090cc@tlielax.poochiereds.net>
	<1390920550-5543-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 28 Jan 2014 09:49:10 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Commit d529ef83c355f97027ff85298a9709fe06216a66 (NFS: fix the handling
> of NFS_INO_INVALID_DATA flag in nfs_revalidate_mapping) introduces
> a potential race, since it doesn't test the value of nfsi->cache_validity
> and set the bitlock in nfsi->flags atomically.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/inode.c | 22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 0a972ee9ccc1..8a5bcb6040ac 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1038,24 +1038,22 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
>  				  nfs_wait_bit_killable, TASK_KILLABLE);
>  		if (ret)
>  			goto out;
> -		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA))
> +		spin_lock(&inode->i_lock);
> +		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA)) {
> +			spin_unlock(&inode->i_lock);
>  			goto out;
> +		}
>  		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING, bitlock))
>  			break;
> -	}
> -

I don't think that patch will help.

Consider the case where we have two tasks that enter
nfs_revalidate_mapping simultaneously. NFS_INO_INVALIDATING is
initially clear and NFS_INO_INVALID_DATA is set:

Task 1                              Task2
---------------------------------------------------------------------
wait_on_bit(NFS_INO_INVALIDATING)   wait_on_bit(NFS_INO_INVALIDATING)

gets i_lock                         spins on i_lock

checks NFS_INO_INVALID_DATA

sets NFS_INO_INVALIDATING

clears NFS_INO_INVALID_DATA

drops i_lock                        gets i_lock, finds that NFS_INO_INVALID_DATA
                                    is clear, and exits the function

calls nfs_invalidate_mapping


...so task2 just returned from nfs_revalidate_mapping before the pages
got invalidated.

> -	spin_lock(&inode->i_lock);
> -	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
> -		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
> -		spin_unlock(&inode->i_lock);
> -		trace_nfs_invalidate_mapping_enter(inode);
> -		ret = nfs_invalidate_mapping(inode, mapping);
> -		trace_nfs_invalidate_mapping_exit(inode, ret);
> -	} else {
> -		/* something raced in and cleared the flag */
>  		spin_unlock(&inode->i_lock);
>  	}
>  
> +	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
> +	spin_unlock(&inode->i_lock);
> +	trace_nfs_invalidate_mapping_enter(inode);
> +	ret = nfs_invalidate_mapping(inode, mapping);
> +	trace_nfs_invalidate_mapping_exit(inode, ret);
> +
>  	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
>  	smp_mb__after_clear_bit();
>  	wake_up_bit(bitlock, NFS_INO_INVALIDATING);


-- 
Jeff Layton <jlayton@redhat.com>
