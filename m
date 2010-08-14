From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix NULL dereference in nfsd_statfs()
Date: Sat, 14 Aug 2010 09:02:35 -0400
Message-ID: <20100814130235.GA28304@fieldses.org>
References: <s5h4oeywrde.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756356Ab0HNNEd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Aug 2010 09:04:33 -0400
In-Reply-To: <s5h4oeywrde.wl%tiwai@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 13, 2010 at 03:53:49PM +0200, Takashi Iwai wrote:
> The commit ebabe9a9001af0af56c0c2780ca1576246e7a74b
>     pass a struct path to vfs_statfs
> introduced the struct path initialization, and this seems to trigger
> an Oops on my machine.
> 
> fh_dentry field may be NULL and set later in fh_verify(), thus the
> initialization of path must be after fh_verify().
> 
> Signed-off-by: Takashi Iwai <tiwai@suse.de>

I'm travelling, but, looks good:

	Acked-by: J. Bruce Fields <bfields@redhat.com>

--b.

> ---
>  fs/nfsd/vfs.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 96360a8..661a6cf 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -2033,15 +2033,17 @@ out:
>  __be32
>  nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat, int access)
>  {
> -	struct path path = {
> -		.mnt	= fhp->fh_export->ex_path.mnt,
> -		.dentry	= fhp->fh_dentry,
> -	};
>  	__be32 err;
>  
>  	err = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP | access);
> -	if (!err && vfs_statfs(&path, stat))
> -		err = nfserr_io;
> +	if (!err) {
> +		struct path path = {
> +			.mnt	= fhp->fh_export->ex_path.mnt,
> +			.dentry	= fhp->fh_dentry,
> +		};
> +		if (vfs_statfs(&path, stat))
> +			err = nfserr_io;
> +	}
>  	return err;
>  }
>  
> -- 
> 1.7.2.1
> 
