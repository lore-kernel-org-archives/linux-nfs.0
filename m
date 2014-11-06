Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:48932 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846AbaKFULe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2014 15:11:34 -0500
Message-ID: <545BD5F3.7030904@Netapp.com>
Date: Thu, 6 Nov 2014 15:11:31 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 2/3] nfsd: Add ALLOCATE support
References: <1414788826-21474-1-git-send-email-Anna.Schumaker@Netapp.com> <1414788826-21474-3-git-send-email-Anna.Schumaker@Netapp.com> <20141106200843.GC22638@fieldses.org>
In-Reply-To: <20141106200843.GC22638@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/06/2014 03:08 PM, J. Bruce Fields wrote:
> On Fri, Oct 31, 2014 at 04:53:45PM -0400, Anna.Schumaker@netapp.com wrote:
>> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>
>> The ALLOCATE operation is used to preallocate space in a file.  I can do
>> this by using vfs_fallocate() to do the actual preallocation.
>>
>> ALLOCATE only returns a status indicator, so we don't need to write a
>> special encode() function.
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>> ---
>>  fs/nfsd/nfs4proc.c | 36 ++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfs4xdr.c  | 19 ++++++++++++++++++-
>>  fs/nfsd/vfs.c      | 20 ++++++++++++++++++++
>>  fs/nfsd/vfs.h      |  2 ++
>>  fs/nfsd/xdr4.h     |  8 ++++++++
>>  5 files changed, 84 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index cdeb3cf..57bfcad 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1014,6 +1014,36 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  }
>>  
>>  static __be32
>> +nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		struct nfsd4_fallocate *fallocate, int flags)
>> +{
>> +	__be32 status = nfserr_notsupp;
>> +	struct file *file;
>> +
>> +	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> +					    &fallocate->falloc_stateid,
>> +					    WR_STATE, &file);
>> +	if (status != nfs_ok) {
>> +		dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
>> +		return status;
>> +	}
>> +
>> +	status = nfsd4_vfs_fallocate(rqstp, &cstate->current_fh, file,
>> +				     fallocate->falloc_offset,
>> +				     fallocate->falloc_length,
>> +				     flags);
>> +	fput(file);
>> +	return status;
>> +}
>> +
>> +static __be32
>> +nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +	       struct nfsd4_fallocate *fallocate)
>> +{
>> +	return nfsd4_fallocate(rqstp, cstate, fallocate, 0);
>> +}
>> +
>> +static __be32
>>  nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  		struct nfsd4_seek *seek)
>>  {
>> @@ -1926,6 +1956,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
>>  	},
>>  
>>  	/* NFSv4.2 operations */
>> +	[OP_ALLOCATE] = {
>> +		.op_func = (nfsd4op_func)nfsd4_allocate,
>> +		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
>> +		.op_name = "OP_ALLOCATE",
>> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
>> +	},
>>  	[OP_SEEK] = {
>>  		.op_func = (nfsd4op_func)nfsd4_seek,
>>  		.op_name = "OP_SEEK",
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index eeea7a9..a60cff8 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1514,6 +1514,23 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>>  }
>>  
>>  static __be32
>> +nfsd4_decode_fallocate(struct nfsd4_compoundargs *argp,
>> +		       struct nfsd4_fallocate *fallocate)
>> +{
>> +	DECODE_HEAD;
>> +
>> +	status = nfsd4_decode_stateid(argp, &fallocate->falloc_stateid);
>> +	if (status)
>> +		return status;
>> +
>> +	READ_BUF(16);
>> +	p = xdr_decode_hyper(p, &fallocate->falloc_offset);
>> +	xdr_decode_hyper(p, &fallocate->falloc_length);
>> +
>> +	DECODE_TAIL;
>> +}
>> +
>> +static __be32
>>  nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
>>  {
>>  	DECODE_HEAD;
>> @@ -1604,7 +1621,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
>>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
>>  
>>  	/* new operations for NFSv4.2 */
>> -	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
>>  	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
>>  	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
>>  	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 989129e..9d29631 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -16,6 +16,7 @@
>>  #include <linux/fs.h>
>>  #include <linux/file.h>
>>  #include <linux/splice.h>
>> +#include <linux/falloc.h>
>>  #include <linux/fcntl.h>
>>  #include <linux/namei.h>
>>  #include <linux/delay.h>
>> @@ -533,6 +534,25 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  }
>>  #endif
>>  
>> +__be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> +			   struct file *file, loff_t offset, loff_t len,
>> +			   int flags)
>> +{
>> +	__be32 err;
>> +	int error;
>> +
>> +	err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry, NFSD_MAY_WRITE);
>> +	if (err)
>> +		return err;
>> +
>> +	error = vfs_fallocate(file, flags, offset, len);
>> +	if (!error)
>> +		error = commit_metadata(fhp);
>> +
>> +	if (error == -ENODEV)
>> +		return nfserr_inval;
> 
> If I'm reading the code right, this is the case where we try to
> fallocate on something other than a regular file?
> 
> Actually the vfs code has a note syaing filesystems may allow fallocate
> on directories.  Do we?  There's nothing explicit in the spec that I can
> see but I don't think it'd make sense.
> 
> So how about replacing this by an explicit check for the type before the
> fallocate call?

Sure thing!  I should probably check that on both client and server side.

Anna
> 
> (And also add a note to the spec requiring NFS4ERR_INVAL on anything not
> a regular file.)
> 
> Otherwise these patches look fine.
> 
> --b.
> 
>> +	return nfserrno(error);
>> +}
>>  #endif /* defined(CONFIG_NFSD_V4) */
>>  
>>  #ifdef CONFIG_NFSD_V3
>> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
>> index c2ff3f1..7ffdb14 100644
>> --- a/fs/nfsd/vfs.h
>> +++ b/fs/nfsd/vfs.h
>> @@ -54,6 +54,8 @@ int nfsd_mountpoint(struct dentry *, struct svc_export *);
>>  #ifdef CONFIG_NFSD_V4
>>  __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
>>  		    struct xdr_netobj *);
>> +__be32		nfsd4_vfs_fallocate(struct svc_rqst *, struct svc_fh *,
>> +				    struct file *, loff_t, loff_t, int);
>>  #endif /* CONFIG_NFSD_V4 */
>>  __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
>>  				char *name, int len, struct iattr *attrs,
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index 5720e94..eeaa0d0 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -428,6 +428,13 @@ struct nfsd4_reclaim_complete {
>>  	u32 rca_one_fs;
>>  };
>>  
>> +struct nfsd4_fallocate {
>> +	/* request */
>> +	stateid_t	falloc_stateid;
>> +	loff_t		falloc_offset;
>> +	u64		falloc_length;
>> +};
>> +
>>  struct nfsd4_seek {
>>  	/* request */
>>  	stateid_t	seek_stateid;
>> @@ -486,6 +493,7 @@ struct nfsd4_op {
>>  		struct nfsd4_free_stateid	free_stateid;
>>  
>>  		/* NFSv4.2 */
>> +		struct nfsd4_fallocate		allocate;
>>  		struct nfsd4_seek		seek;
>>  	} u;
>>  	struct nfs4_replay *			replay;
>> -- 
>> 2.1.3
>>

