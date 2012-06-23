Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40876 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613Ab2FWPJE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jun 2012 11:09:04 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Namjae Jeon <linkinjeon@gmail.com>
CC: "<bfields@fieldses.org>" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<akpm@linux-foundation.org>" <akpm@linux-foundation.org>,
        "<bharrosh@panasas.com>" <bharrosh@panasas.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        Vivek Trivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on
 nfs server.
Date: Sat, 23 Jun 2012 15:09:01 +0000
Message-ID: <5451C4C3-C8DB-4010-85C1-8775F9703CC1@netapp.com>
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com>
In-Reply-To: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Again NACK...

If you want to add support for new functionality to the NFS standard then do it through the IETF process, not the Linux kernel.

Trond
--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

On Jun 23, 2012, at 6:47 AM, Namjae Jeon wrote:

> From: Namjae Jeon <namjae.jeon@samsung.com>
> 
> This patch disable readahead for a file on NFS Server when
> posix_fadvise(fd..., POSIX_FADV_RANDOM) is called on NFS
> Client.
> 
> Readahead on the file can be enabled again with
> posix_fadvise(fd..., POSIX_FADV_NORMAL)
> 
> This patch is provides performance boost in a scenario like
> traversing a directory with large number of files(e.g. ~5000 files),
> showing thumbnail view for an image directory, file attributes of
> various music files, preview dialog for video files etc.
> 
> To simulate the scenario we performed a traverse test on a directory
> containing 5000 files. When OPEN/READDIR/STAT/READ(4k)
> is called on all 5000 files, total time is reduced by 19.6 %.
> 
> Without this patch:
> #> ./traverse_time huge_test_dir 4096
> Traversed Path : huge_test_dir/ read_size = 4096
> Total Time Taken : 22326 msec   <--------
> IMPORTANT TIMINGS
> OPEN DIR TIME (15915 usec)
> READ DIR TIME (8092117 usec)
> STAT TIME (118791 usec)
> OPEN TIME (1361520 usec)
> CLOSE TIME (27134 usec)
> READ TIME(12647454 usec)
> ADVISE TIME(9066 usec)
> MEMSET TIME(7 usec)
> READ DATA : 20480000
> READ SPEED:     1.54MB/sec
> 
> With this patch:
> #> ./traverse_time huge_test_dir 4096
> Traversed Path : huge_test_dir/ read_size = 4096
> Total Time Taken : 17949 msec   <--------
> IMPORTANT TIMINGS
> OPEN DIR TIME (15868 usec)
> READ DIR TIME (7982147 usec)
> STAT TIME (118780 usec)
> OPEN TIME (1369376 usec)
> CLOSE TIME (28216 usec)
> READ TIME(8372115 usec)
> ADVISE TIME(8923 usec)
> MEMSET TIME(7 usec)
> READ DATA : 20480000
> READ SPEED(only read):     2.33MB/sec
> 
> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
> Signed-off-by: Amit Sahrawat <a.sahrawat@samsung.com>
> ---
> fs/nfs/file.c      |    3 +++
> fs/nfs/nfs2xdr.c   |    5 +++--
> fs/nfs/nfs3xdr.c   |    5 +++--
> fs/nfs/nfs4xdr.c   |    5 +++--
> fs/nfsd/nfs3proc.c |    2 +-
> fs/nfsd/nfs3xdr.c  |    1 +
> fs/nfsd/nfs4xdr.c  |    5 +++--
> fs/nfsd/nfsproc.c  |    2 +-
> fs/nfsd/nfsxdr.c   |    1 +
> fs/nfsd/vfs.c      |   24 +++++++++++++++++++++---
> fs/nfsd/vfs.h      |    6 ++++--
> fs/nfsd/xdr.h      |    1 +
> fs/nfsd/xdr3.h     |    1 +
> fs/nfsd/xdr4.h     |    1 +
> 14 files changed, 47 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index a6708e6b..89fdc43 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -192,6 +192,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
> 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
> 	struct inode * inode = dentry->d_inode;
> 	ssize_t result;
> +	struct nfs_open_context *ctx = nfs_file_open_context(iocb->ki_filp);
> 
> 	if (iocb->ki_filp->f_flags & O_DIRECT)
> 		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
> @@ -200,6 +201,8 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
> 		dentry->d_parent->d_name.name, dentry->d_name.name,
> 		(unsigned long) iov_length(iov, nr_segs), (unsigned long) pos);
> 
> +	ctx->mode = iocb->ki_filp->f_mode;
> +
> 	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
> 	if (!result) {
> 		result = generic_file_aio_read(iocb, iov, nr_segs, pos);
> diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
> index d04f0df..76b3e48 100644
> --- a/fs/nfs/nfs2xdr.c
> +++ b/fs/nfs/nfs2xdr.c
> @@ -44,7 +44,7 @@
> #define NFS_removeargs_sz	(NFS_fhandle_sz+NFS_filename_sz)
> #define NFS_sattrargs_sz	(NFS_fhandle_sz+NFS_sattr_sz)
> #define NFS_readlinkargs_sz	(NFS_fhandle_sz)
> -#define NFS_readargs_sz		(NFS_fhandle_sz+3)
> +#define NFS_readargs_sz		(NFS_fhandle_sz+4)
> #define NFS_writeargs_sz	(NFS_fhandle_sz+4)
> #define NFS_createargs_sz	(NFS_diropargs_sz+NFS_sattr_sz)
> #define NFS_renameargs_sz	(NFS_diropargs_sz+NFS_diropargs_sz)
> @@ -612,10 +612,11 @@ static void encode_readargs(struct xdr_stream *xdr,
> 
> 	encode_fhandle(xdr, args->fh);
> 
> -	p = xdr_reserve_space(xdr, 4 + 4 + 4);
> +	p = xdr_reserve_space(xdr, 4 + 4 + 4 + 4);
> 	*p++ = cpu_to_be32(offset);
> 	*p++ = cpu_to_be32(count);
> 	*p = cpu_to_be32(count);
> +	*++p = cpu_to_be32(args->context->mode);
> }
> 
> static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index 6cbe894..d0876cb 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -49,7 +49,7 @@
> #define NFS3_lookupargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
> #define NFS3_accessargs_sz	(NFS3_fh_sz+1)
> #define NFS3_readlinkargs_sz	(NFS3_fh_sz)
> -#define NFS3_readargs_sz	(NFS3_fh_sz+3)
> +#define NFS3_readargs_sz	(NFS3_fh_sz+4)
> #define NFS3_writeargs_sz	(NFS3_fh_sz+5)
> #define NFS3_createargs_sz	(NFS3_diropargs_sz+NFS3_sattr_sz)
> #define NFS3_mkdirargs_sz	(NFS3_diropargs_sz+NFS3_sattr_sz)
> @@ -951,9 +951,10 @@ static void encode_read3args(struct xdr_stream *xdr,
> 
> 	encode_nfs_fh3(xdr, args->fh);
> 
> -	p = xdr_reserve_space(xdr, 8 + 4);
> +	p = xdr_reserve_space(xdr, 8 + 4 + 4);
> 	p = xdr_encode_hyper(p, args->offset);
> 	*p = cpu_to_be32(args->count);
> +	*++p = cpu_to_be32(args->context->mode);
> }
> 
> static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 610ebcc..fbdd8ce 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -188,7 +188,7 @@ static int nfs4_stat_to_errno(int);
> #define decode_setattr_maxsz	(op_decode_hdr_maxsz + \
> 				 nfs4_fattr_bitmap_maxsz)
> #define encode_read_maxsz	(op_encode_hdr_maxsz + \
> -				 encode_stateid_maxsz + 3)
> +				 encode_stateid_maxsz + 4)
> #define decode_read_maxsz	(op_decode_hdr_maxsz + 2)
> #define encode_readdir_maxsz	(op_encode_hdr_maxsz + \
> 				 2 + encode_verifier_maxsz + 5)
> @@ -1532,9 +1532,10 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
> 	encode_open_stateid(xdr, args->context, args->lock_context,
> 			FMODE_READ, hdr->minorversion);
> 
> -	p = reserve_space(xdr, 12);
> +	p = reserve_space(xdr, 16);
> 	p = xdr_encode_hyper(p, args->offset);
> 	*p = cpu_to_be32(args->count);
> +	*++p = cpu_to_be32(args->context->mode);
> }
> 
> static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req, struct compound_hdr *hdr)
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 9095f3c..d599629 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -171,7 +171,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
> 	nfserr = nfsd_read(rqstp, &resp->fh,
> 				  argp->offset,
> 			   	  rqstp->rq_vec, argp->vlen,
> -				  &resp->count);
> +				  &resp->count, argp->f_mode);
> 	if (nfserr == 0) {
> 		struct inode	*inode = resp->fh.fh_dentry->d_inode;
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 43f46cd..d940bc9 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -345,6 +345,7 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
> 		v++;
> 	}
> 	args->vlen = v;
> +	args->f_mode = ntohl(*p++);
> 	return xdr_argsize_check(rqstp, p);
> }
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 4949667..34cb726 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -875,9 +875,10 @@ nfsd4_decode_read(struct nfsd4_compoundargs *argp, struct nfsd4_read *read)
> 	status = nfsd4_decode_stateid(argp, &read->rd_stateid);
> 	if (status)
> 		return status;
> -	READ_BUF(12);
> +	READ_BUF(16);
> 	READ64(read->rd_offset);
> 	READ32(read->rd_length);
> +	READ32(read->rd_f_mode);
> 
> 	DECODE_TAIL;
> }
> @@ -2958,7 +2959,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
> 
> 	nfserr = nfsd_read_file(read->rd_rqstp, read->rd_fhp, read->rd_filp,
> 			read->rd_offset, resp->rqstp->rq_vec, read->rd_vlen,
> -			&maxcount);
> +			&maxcount, read->rd_f_mode);
> 
> 	if (nfserr)
> 		return nfserr;
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index e15dc45..8903975 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -147,7 +147,7 @@ nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
> 	nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh),
> 				  argp->offset,
> 			   	  rqstp->rq_vec, argp->vlen,
> -				  &resp->count);
> +				  &resp->count, argp->f_mode);
> 
> 	if (nfserr) return nfserr;
> 	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index 65ec595..3d76274 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -269,6 +269,7 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
> 		v++;
> 	}
> 	args->vlen = v;
> +	args->f_mode = ntohl(*p++);
> 	return xdr_argsize_check(rqstp, p);
> }
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index c8bd9c3..8fc82d7 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1067,7 +1067,8 @@ out_nfserr:
>  * N.B. After this call fhp needs an fh_put
>  */
> __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> -	loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
> +	loff_t offset, struct kvec *vec, int vlen, unsigned long *count,
> +	unsigned long f_mode)
> {
> 	struct file *file;
> 	struct inode *inode;
> @@ -1078,6 +1079,12 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> 	if (err)
> 		return err;
> 
> +	if (f_mode & FMODE_RANDOM) {
> +		spin_lock(&file->f_lock);
> +		file->f_mode |= FMODE_RANDOM;
> +		spin_unlock(&file->f_lock);
> +	}
> +
> 	inode = file->f_path.dentry->d_inode;
> 
> 	/* Get readahead parameters */
> @@ -1106,7 +1113,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> __be32
> nfsd_read_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> 		loff_t offset, struct kvec *vec, int vlen,
> -		unsigned long *count)
> +		unsigned long *count, unsigned long f_mode)
> {
> 	__be32		err;
> 
> @@ -1115,9 +1122,20 @@ nfsd_read_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> 				NFSD_MAY_READ|NFSD_MAY_OWNER_OVERRIDE);
> 		if (err)
> 			goto out;
> +
> +		if (f_mode & FMODE_RANDOM) {
> +			spin_lock(&file->f_lock);
> +			file->f_mode |= FMODE_RANDOM;
> +			spin_unlock(&file->f_lock);
> +		} else {
> +			spin_lock(&file->f_lock);
> +			file->f_mode &= ~FMODE_RANDOM;
> +			spin_unlock(&file->f_lock);
> +		}
> +
> 		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
> 	} else /* Note file may still be NULL in NFSv4 special stateid case: */
> -		err = nfsd_read(rqstp, fhp, offset, vec, vlen, count);
> +		err = nfsd_read(rqstp, fhp, offset, vec, vlen, count, f_mode);
> out:
> 	return err;
> }
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index ec0611b..c181cdb 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -72,9 +72,11 @@ __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
> 				int, struct file **);
> void		nfsd_close(struct file *);
> __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
> -				loff_t, struct kvec *, int, unsigned long *);
> +				loff_t, struct kvec *, int, unsigned long *,
> +				unsigned long);
> __be32 		nfsd_read_file(struct svc_rqst *, struct svc_fh *, struct file *,
> -				loff_t, struct kvec *, int, unsigned long *);
> +				loff_t, struct kvec *, int, unsigned long *,
> +				unsigned long);
> __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
> 				loff_t, struct kvec *,int, unsigned long *, int *);
> __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
> diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
> index 53b1863..520d5e6 100644
> --- a/fs/nfsd/xdr.h
> +++ b/fs/nfsd/xdr.h
> @@ -27,6 +27,7 @@ struct nfsd_readargs {
> 	__u32			offset;
> 	__u32			count;
> 	int			vlen;
> +	__u32			f_mode;
> };
> 
> struct nfsd_writeargs {
> diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
> index 7df980e..15fdff4 100644
> --- a/fs/nfsd/xdr3.h
> +++ b/fs/nfsd/xdr3.h
> @@ -32,6 +32,7 @@ struct nfsd3_readargs {
> 	__u64			offset;
> 	__u32			count;
> 	int			vlen;
> +	__u32			f_mode;
> };
> 
> struct nfsd3_writeargs {
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index acd127d..49d6ce3 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -270,6 +270,7 @@ struct nfsd4_read {
> 	u32		rd_length;          /* request */
> 	int		rd_vlen;
> 	struct file     *rd_filp;
> +	u32		rd_f_mode;			/* request */
> 	
> 	struct svc_rqst *rd_rqstp;          /* response */
> 	struct svc_fh * rd_fhp;             /* response */
> -- 
> 1.7.9.5
> 

