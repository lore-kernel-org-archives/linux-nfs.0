Return-Path: <bfields@fieldses.org>
Date: Tue, 19 Dec 2017 10:43:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: permit layoutget of executable-only files
Message-ID: <20171219154330.GA19967@fieldses.org>
References: <2f621da7f3633e5a127ac89d886738c35ea02880.1513693981.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2f621da7f3633e5a127ac89d886738c35ea02880.1513693981.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 19, 2017 at 09:35:25AM -0500, Benjamin Coddington wrote:
> Clients must be able to read a file in order to execute it, and for pNFS
> that means the client needs to be able to perform a LAYOUTGET on the file.
> 
> This behavior for executable-only files was added for OPEN in commit
> a043226bc140 "nfsd4: permit read opens of executable-only files".
> 
> This fixes up xfstests generic/126 on block/scsi layouts.

Thanks, applied.  So the server was returning NFS4ERR_ACCESS and the
client was returning that to the application?  I was wondering for a
moment whether the client should instead try falling back to MDS IO,
but.... But I don't think that makes sense.  The client's probably
correct to interpret ACCESS as just meaning that user can't read the
file.  The server has plenty of other errors to choose from if it just
wants to deny the layout for some reason.  OK.

--b.

> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 8487486ec496..8ce60986fb75 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1372,14 +1372,14 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
>  	const struct nfsd4_layout_ops *ops;
>  	struct nfs4_layout_stateid *ls;
>  	__be32 nfserr;
> -	int accmode;
> +	int accmode = NFSD_MAY_READ_IF_EXEC;
>  
>  	switch (lgp->lg_seg.iomode) {
>  	case IOMODE_READ:
> -		accmode = NFSD_MAY_READ;
> +		accmode |= NFSD_MAY_READ;
>  		break;
>  	case IOMODE_RW:
> -		accmode = NFSD_MAY_READ | NFSD_MAY_WRITE;
> +		accmode |= NFSD_MAY_READ | NFSD_MAY_WRITE;
>  		break;
>  	default:
>  		dprintk("%s: invalid iomode %d\n",
> -- 
> 2.9.3
