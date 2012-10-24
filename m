Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36353 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933818Ab2JXTm1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 15:42:27 -0400
Date: Wed, 24 Oct 2012 15:42:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: ycnian@gmail.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfs: fix wrong object type in lockowner_slab
Message-ID: <20121024194224.GB6697@fieldses.org>
References: <1351061059-29318-1-git-send-email-ycnian@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351061059-29318-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 24, 2012 at 02:44:19PM +0800, ycnian@gmail.com wrote:
> From: Yanchuan Nian <ycnian@gmail.com>
> 
> The object type in the cache of lockowner_slab is wrong, and it is better to fix it.
> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> ---
>  fs/nfsd/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index cc894ed..1609eb2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2325,7 +2325,7 @@ nfsd4_init_slabs(void)
>  	if (openowner_slab == NULL)
>  		goto out_nomem;
>  	lockowner_slab = kmem_cache_create("nfsd4_lockowners",
> -			sizeof(struct nfs4_openowner), 0, 0, NULL);
> +			sizeof(struct nfs4_lockowner), 0, 0, NULL);

Thanks!

The first three fields of each are the same, the rest is:

	struct nfs4_openowner {
		...
		pointer
		time_t
		unsigned char
	}

	struct nfs4_lockowner {
		...
		struct list_head
	}

Is it always true that

	sizeof(struct nfs4_openowner) >= sizeof9struct nfs4_lockowner)

?  I think so, in which case this isn't urgent.... Applying for 3.8.

--b.

>  	if (lockowner_slab == NULL)
>  		goto out_nomem;
>  	file_slab = kmem_cache_create("nfsd4_files",
> -- 
> 1.7.4.4
> 
