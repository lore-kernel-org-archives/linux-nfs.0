Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40686 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754487AbeDBVcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Apr 2018 17:32:45 -0400
Date: Mon, 2 Apr 2018 17:32:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] nfsd: Add I/O trace points in the NFSv4 read proc
Message-ID: <20180402213244.GB10940@fieldses.org>
References: <20180328172741.10746.19214.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180328172741.10746.19214.stgit@oracle-ib-101.nfsv4bat.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 01:29:11PM -0400, Chuck Lever wrote:
> NFSv4 read compound processing invokes nfsd_splice_read and
> nfs_readv directly, so the trace points currently in nfsd_read are
> not invoked for NFSv4 reads.
> 
> Move the NFSD READ trace points to common helpers so that NFSv4
> reads are captured.
> 
> Also, record any local I/O error that occurs, the total count of
> bytes that were actually returned, and whether splice or vectored
> read was used.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hi Bruce-
> 
> This version replaces v2 "nfsd: Add I/O trace points in the NFSv4
> read proc".

Applying, thanks!

--b.

> 
> Changes since v2:
> - Ensure NFSv4 and legacy NFS READ encoders behave the same
> 
> 
>  fs/nfsd/nfs4proc.c |    5 +++++
>  fs/nfsd/nfs4xdr.c  |   10 ++++++----
>  fs/nfsd/trace.h    |    4 +++-
>  fs/nfsd/vfs.c      |   34 ++++++++++++++++++----------------
>  fs/nfsd/vfs.h      |   11 +++++++----
>  5 files changed, 39 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index b93673e..39016b6 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -751,6 +751,9 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  	if (read->rd_offset >= OFFSET_MAX)
>  		return nfserr_inval;
>  
> +	trace_nfsd_read_start(rqstp, &cstate->current_fh,
> +			      read->rd_offset, read->rd_length);
> +
>  	/*
>  	 * If we do a zero copy read, then a client will see read data
>  	 * that reflects the state of the file *after* performing the
> @@ -783,6 +786,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  {
>  	if (u->read.rd_filp)
>  		fput(u->read.rd_filp);
> +	trace_nfsd_read_done(u->read.rd_rqstp, u->read.rd_fhp,
> +			     u->read.rd_offset, u->read.rd_length);
>  }
>  
>  static __be32
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index e502fd1..f99d426 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3427,8 +3427,9 @@ static __be32 nfsd4_encode_splice_read(
>  		return nfserr_resource;
>  
>  	len = maxcount;
> -	nfserr = nfsd_splice_read(read->rd_rqstp, file,
> -				  read->rd_offset, &maxcount);
> +	nfserr = nfsd_splice_read(read->rd_rqstp, read->rd_fhp,
> +				  file, read->rd_offset, &maxcount);
> +	read->rd_length = maxcount;
>  	if (nfserr) {
>  		/*
>  		 * nfsd_splice_actor may have already messed with the
> @@ -3511,8 +3512,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	read->rd_vlen = v;
>  
>  	len = maxcount;
> -	nfserr = nfsd_readv(file, read->rd_offset, resp->rqstp->rq_vec,
> -			read->rd_vlen, &maxcount);
> +	nfserr = nfsd_readv(resp->rqstp, read->rd_fhp, file, read->rd_offset,
> +			    resp->rqstp->rq_vec, read->rd_vlen, &maxcount);
> +	read->rd_length = maxcount;
>  	if (nfserr)
>  		return nfserr;
>  	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
> index 653e9ee..a8bbd9d 100644
> --- a/fs/nfsd/trace.h
> +++ b/fs/nfsd/trace.h
> @@ -43,7 +43,8 @@
>  	TP_ARGS(rqstp, fhp, offset, len))
>  
>  DEFINE_NFSD_IO_EVENT(read_start);
> -DEFINE_NFSD_IO_EVENT(read_opened);
> +DEFINE_NFSD_IO_EVENT(read_splice);
> +DEFINE_NFSD_IO_EVENT(read_vector);
>  DEFINE_NFSD_IO_EVENT(read_io_done);
>  DEFINE_NFSD_IO_EVENT(read_done);
>  DEFINE_NFSD_IO_EVENT(write_start);
> @@ -82,6 +83,7 @@
>  		 int		len),		\
>  	TP_ARGS(rqstp, fhp, offset, len))
>  
> +DEFINE_NFSD_ERR_EVENT(read_err);
>  DEFINE_NFSD_ERR_EVENT(write_err);
>  
>  #include "state.h"
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index ee59a0b..2410b09 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -881,20 +881,24 @@ static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,
>  	return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
>  }
>  
> -static __be32
> -nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
> +static __be32 nfsd_finish_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			       struct file *file, loff_t offset,
> +			       unsigned long *count, int host_err)
>  {
>  	if (host_err >= 0) {
>  		nfsdstats.io_read += host_err;
>  		*count = host_err;
>  		fsnotify_access(file);
> +		trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
>  		return 0;
> -	} else 
> +	} else {
> +		trace_nfsd_read_err(rqstp, fhp, offset, host_err);
>  		return nfserrno(host_err);
> +	}
>  }
>  
> -__be32 nfsd_splice_read(struct svc_rqst *rqstp,
> -		     struct file *file, loff_t offset, unsigned long *count)
> +__be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			struct file *file, loff_t offset, unsigned long *count)
>  {
>  	struct splice_desc sd = {
>  		.len		= 0,
> @@ -904,21 +908,23 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp,
>  	};
>  	int host_err;
>  
> +	trace_nfsd_read_splice(rqstp, fhp, offset, *count);
>  	rqstp->rq_next_page = rqstp->rq_respages + 1;
>  	host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
> -	return nfsd_finish_read(file, count, host_err);
> +	return nfsd_finish_read(rqstp, fhp, file, offset, count, host_err);
>  }
>  
> -__be32 nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
> -		unsigned long *count)
> +__be32 nfsd_readv(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		  struct file *file, loff_t offset,
> +		  struct kvec *vec, int vlen, unsigned long *count)
>  {
>  	struct iov_iter iter;
>  	int host_err;
>  
> +	trace_nfsd_read_vector(rqstp, fhp, offset, *count);
>  	iov_iter_kvec(&iter, READ | ITER_KVEC, vec, vlen, *count);
>  	host_err = vfs_iter_read(file, &iter, &offset, 0);
> -
> -	return nfsd_finish_read(file, count, host_err);
> +	return nfsd_finish_read(rqstp, fhp, file, offset, count, host_err);
>  }
>  
>  /*
> @@ -1034,14 +1040,10 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  
>  	ra = nfsd_init_raparms(file);
>  
> -	trace_nfsd_read_opened(rqstp, fhp, offset, *count);
> -
>  	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &rqstp->rq_flags))
> -		err = nfsd_splice_read(rqstp, file, offset, count);
> +		err = nfsd_splice_read(rqstp, fhp, file, offset, count);
>  	else
> -		err = nfsd_readv(file, offset, vec, vlen, count);
> -
> -	trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
> +		err = nfsd_readv(rqstp, fhp, file, offset, vec, vlen, count);
>  
>  	if (ra)
>  		nfsd_put_raparams(file, ra);
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index be6d8e0..a7e1073 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -78,10 +78,13 @@ __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
>  __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
>  				int, struct file **);
>  struct raparms;
> -__be32		nfsd_splice_read(struct svc_rqst *,
> -				struct file *, loff_t, unsigned long *);
> -__be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
> -				unsigned long *);
> +__be32		nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +				struct file *file, loff_t offset,
> +				unsigned long *count);
> +__be32		nfsd_readv(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +				struct file *file, loff_t offset,
> +				struct kvec *vec, int vlen,
> +				unsigned long *count);
>  __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
>  				loff_t, struct kvec *, int, unsigned long *);
>  __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *, loff_t,
