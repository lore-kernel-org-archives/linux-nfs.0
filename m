Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbcCVUvv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2016 16:51:51 -0400
Date: Tue, 22 Mar 2016 16:51:47 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: use short read rather than i_size to set eof
In-Reply-To: <20160322185336.GD4083@fieldses.org>
Message-ID: <alpine.OSX.2.19.9992.1603221645050.19930@planck>
References: <20160321213655.GB807@fieldses.org> <82e4c7a9756b21a4645421d04735ccf491b4296a.1458571329.git.bcodding@redhat.com> <a156abbff4553a431ebafd3b6b84a5eb7f7202c5.1458651136.git.bcodding@redhat.com> <20160322164624.GB4083@fieldses.org>
 <20160322185336.GD4083@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 22 Mar 2016, J. Bruce Fields wrote:

> Possibly overkill, but I think I'll fold in something like this if you
> don't see an objection.

No objection.  To answer your earlier question (does the client even send a
read if it would extend past the size returned from a recent getattr?):

Looks to me (by testing with a server that never sets eof) the answer is no.
The client won't issue reads beyond the end of the file.

Also the previous patch's subject is now a little misleading.  Maybe
s/rather than/as well as/ would do.

Ben

> commit 58e18a2a14a0
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Mar 22 14:08:11 2016 -0400
>
>     nfsd: document read eof logic
>
>     The choice of checks here is a little subtle, let's document this for
>     posterity.
>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 83c9abb33e8b..df0f0a86f21d 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -168,8 +168,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
>  				  &resp->count);
>  	if (nfserr == 0) {
>  		struct inode	*inode = d_inode(resp->fh.fh_dentry);
> -		resp->eof = (cnt > resp->count) ||
> -			((argp->offset + resp->count) >= inode->i_size);
> +		resp->eof = nfsd_eof_on_read(cnt, resp->count, argp->offset, inode->i_size);
>  	}
>
>  	RETURN_STATUS(nfserr);
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 90232bd7e498..9df898ba648f 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3387,8 +3387,8 @@ static __be32 nfsd4_encode_splice_read(
>  		return nfserr;
>  	}
>
> -	eof = (len > maxcount) ||
> -		((read->rd_offset + maxcount >= d_inode(read->rd_fhp->fh_dentry)->i_size));
> +	eof = nfsd_eof_on_read(len, maxcount, read->rd_offset,
> +				d_inode(read->rd_fhp->fh_dentry)->i_size);
>
>  	*(p++) = htonl(eof);
>  	*(p++) = htonl(maxcount);
> @@ -3465,8 +3465,8 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  		return nfserr;
>  	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
>
> -	eof = (len > maxcount) ||
> -		((read->rd_offset + maxcount >= d_inode(read->rd_fhp->fh_dentry)->i_size));
> +	eof = nfsd_eof_on_read(len, maxcount, read->rd_offset,
> +				d_inode(read->rd_fhp->fh_dentry)->i_size);
>
>  	tmp = htonl(eof);
>  	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index c11ba316f23f..6244e073c137 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -139,4 +139,24 @@ static inline int nfsd_create_is_exclusive(int createmode)
>  	       || createmode == NFS4_CREATE_EXCLUSIVE4_1;
>  }
>
> +static inline bool nfsd_eof_on_read(long requested, long read,
> +				loff_t offset, loff_t size)
> +{
> +	/* We assume a short read means eof: */
> +	if (requested > read)
> +		return true;
> +	/*
> +	 * A non-short read might also reach end of file.  The spec
> +	 * still requires us to set eof in that case.
> +	 *
> +	 * Further operations may have modified the file size since
> +	 * the read, so the following check is not atomic with the read.
> +	 * The only case we've seen that cause a problem for a client
> +	 * is the case where the read returned a count of 0 without
> +	 * setting eof.  That case was fixed by the addition of the
> +	 * above check.
> +	 */
> +	return (offset + read >= size);
> +}
> +
>  #endif /* LINUX_NFSD_VFS_H */
>
