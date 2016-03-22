Return-Path: <bfields@fieldses.org>
Date: Tue, 22 Mar 2016 12:46:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: use short read rather than i_size to set eof
Message-ID: <20160322164624.GB4083@fieldses.org>
References: <20160321213655.GB807@fieldses.org>
 <82e4c7a9756b21a4645421d04735ccf491b4296a.1458571329.git.bcodding@redhat.com>
 <a156abbff4553a431ebafd3b6b84a5eb7f7202c5.1458651136.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a156abbff4553a431ebafd3b6b84a5eb7f7202c5.1458651136.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 22, 2016 at 10:28:36AM -0400, Benjamin Coddington wrote:
> On Mon, 21 Mar 2016, J. Bruce Fields wrote:
> > On Mon, Mar 21, 2016 at 10:42:25AM -0400, Benjamin Coddington wrote:
> > > Use the result of a local read to determine when to set the eof flag.
> > > This
> > > allows us to return the location of the end of the file atomically at
> > > the
> > > time of the read.
> >
> > My only question is whether we should instead do something like:
> >
> >   eof = (res > cnt) || (offset + cnt >= i_size)
> 
> Yes, let's do that.
> 
> > That'd fix the reported bug without changing existing behavior
> > otherwise.
> >
> > But maybe it's unlikely any client depends on existing behavior.
> >
> > The only test failure I'm seeing is on pynfs WRT13, which literally just
> > checks that a 6-byte read of a 6-byte file returns with eof set.  The
> > test is correct (the spec does clearly require eof to be set in that
> > case), but maybe it's not important.
> 
> The above change will fix this up and be correct in the absence of races
> which saves the client from having to perform another full RPC just to
> retrieve eof.

Seems likely to be rare (and possibly papered over by caching--does the
client even send a read if it would extend past the size returned from a
recent getattr?).

But, this does seem like the most conservative approach for now.
Applying.

Thanks!

--b.

> This passes WRT13:
> 
> 8<------------------------------------------------------------------------
> 
> Use the result of a local read to determine when to set the eof flag.  This
> allows us to return the location of the end of the file atomically at the
> time of the read.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfsd/nfs3proc.c |    7 ++++---
>  fs/nfsd/nfs4xdr.c  |   11 +++++++----
>  2 files changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 7b755b7..83c9abb 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -147,6 +147,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
>  {
>  	__be32	nfserr;
>  	u32	max_blocksize = svc_max_payload(rqstp);
> +	unsigned long cnt = min(argp->count, max_blocksize);
>  
>  	dprintk("nfsd: READ(3) %s %lu bytes at %Lu\n",
>  				SVCFH_fmt(&argp->fh),
> @@ -157,7 +158,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
>  	 * 1 (status) + 22 (post_op_attr) + 1 (count) + 1 (eof)
>  	 * + 1 (xdr opaque byte count) = 26
>  	 */
> -	resp->count = min(argp->count, max_blocksize);
> +	resp->count = cnt;
>  	svc_reserve_auth(rqstp, ((1 + NFS3_POST_OP_ATTR_WORDS + 3)<<2) + resp->count +4);
>  
>  	fh_copy(&resp->fh, &argp->fh);
> @@ -167,8 +168,8 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
>  				  &resp->count);
>  	if (nfserr == 0) {
>  		struct inode	*inode = d_inode(resp->fh.fh_dentry);
> -
> -		resp->eof = (argp->offset + resp->count) >= inode->i_size;
> +		resp->eof = (cnt > resp->count) ||
> +			((argp->offset + resp->count) >= inode->i_size);
>  	}
>  
>  	RETURN_STATUS(nfserr);
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d6ef095..1d26b2b 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3362,6 +3362,7 @@ static __be32 nfsd4_encode_splice_read(
>  	struct xdr_stream *xdr = &resp->xdr;
>  	struct xdr_buf *buf = xdr->buf;
>  	u32 eof;
> +	long len;
>  	int space_left;
>  	__be32 nfserr;
>  	__be32 *p = xdr->p - 2;
> @@ -3370,6 +3371,7 @@ static __be32 nfsd4_encode_splice_read(
>  	if (xdr->end - xdr->p < 1)
>  		return nfserr_resource;
>  
> +	len = maxcount;
>  	nfserr = nfsd_splice_read(read->rd_rqstp, file,
>  				  read->rd_offset, &maxcount);
>  	if (nfserr) {
> @@ -3382,8 +3384,8 @@ static __be32 nfsd4_encode_splice_read(
>  		return nfserr;
>  	}
>  
> -	eof = (read->rd_offset + maxcount >=
> -	       d_inode(read->rd_fhp->fh_dentry)->i_size);
> +	eof = (len > maxcount) ||
> +		((read->rd_offset + maxcount >= d_inode(read->rd_fhp->fh_dentry)->i_size));
>  
>  	*(p++) = htonl(eof);
>  	*(p++) = htonl(maxcount);
> @@ -3453,14 +3455,15 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	}
>  	read->rd_vlen = v;
>  
> +	len = maxcount;
>  	nfserr = nfsd_readv(file, read->rd_offset, resp->rqstp->rq_vec,
>  			read->rd_vlen, &maxcount);
>  	if (nfserr)
>  		return nfserr;
>  	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
>  
> -	eof = (read->rd_offset + maxcount >=
> -	       d_inode(read->rd_fhp->fh_dentry)->i_size);
> +	eof = (len > maxcount) ||
> +		((read->rd_offset + maxcount >= d_inode(read->rd_fhp->fh_dentry)->i_size));
>  
>  	tmp = htonl(eof);
>  	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
> -- 
> 1.7.1
