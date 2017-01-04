Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53954 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761219AbdADR3J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 12:29:09 -0500
Date: Wed, 4 Jan 2017 12:29:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFSD: only support readonly export for !fsync and
 readonly filesystem
Message-ID: <20170104172906.GC17649@fieldses.org>
References: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 31, 2016 at 09:18:08PM +0800, Kinglong Mee wrote:
> Commit fae5096ad217
> "nfsd: assume writeable exportabled filesystems have f_sync"
> have remove the checking of f_sync.
> 
> Christoph Hellwig suggests,
> "Warn and refuse the writable export."
> 
> I think just covert to a readonly export for !fsync filesystem,
> also, for a readonly filesystem is reasonable.

Hmmm.  It's not something we've done before.  Off hand, I can't see why
it would cause a problem, but I'm not convinced yet.

Could you add to the changelog a description of the use case you gave
Christoph in your defense of this idea?

Also:

> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/export.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 43e109c..3ec3b6b 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -358,6 +358,18 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
>  	if (*flags & NFSEXP_V4ROOT)
>  		*flags |= NFSEXP_READONLY;
>  
> +	/*
> +	 * Convert to a readonly export for that,
> +	 * 1. not supported fsync filesystem,
> +	 * 2. readonly filesystem.
> +	 */
> +	if ((!inode->i_fop->fsync || IS_RDONLY(inode))
> +	    && !(*flags & NFSEXP_READONLY)) {
> +		dprintk("exp_export: Only support readonly export "
> +			"for fsync unsupported or readonly filesystem.\n");

Something like this might be more helpful:

	"Filesystem %s: exporting read-only\n", IS_RDONLY(inode) ?
			"is read-only" : "has no fsync method"

Also if we passed the dentry to check_export, could we do something
like:

	"%s %s: exporting read-only\n", d_path(dentry,...), IS_RDONLY...

here and in the other warnings?

--b.

> +		*flags |= NFSEXP_READONLY;
> +	}
> +
>  	/* There are two requirements on a filesystem to be exportable.
>  	 * 1:  We must be able to identify the filesystem from a number.
>  	 *       either a device number (so FS_REQUIRES_DEV needed)
> -- 
> 2.9.3
