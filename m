Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6617 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754896Ab3J2MxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 08:53:08 -0400
Message-ID: <526FAFB2.8040300@netapp.com>
Date: Tue, 29 Oct 2013 08:53:06 -0400
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-5-git-send-email-bjschuma@netapp.com> <20131028215126.GP31322@fieldses.org>
In-Reply-To: <20131028215126.GP31322@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 28 Oct 2013 05:51:26 PM EDT, J. Bruce Fields wrote:
> On Mon, Oct 28, 2013 at 10:57:26AM -0400, Anna Schumaker wrote:
>> This patch adds in the SEEK operation used by clients doing an llseek on
>> a file to find either hole or data sections in a file.  I'm faking the
>> "allocated" status right now, since I haven't quite figured out how to
>> tell if a range is allocated on disk yet.
>>
>> This patch is missing correctly determining the "allocated" status of
>> the HOLE / DATA range.  I expect I'll need to learn all about how fiemap
>> works before properly setting these values.
>>
>> Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfsd/nfs4proc.c   | 44 ++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfs4xdr.c    | 40 ++++++++++++++++++++++++++++++++++++++--
>>  fs/nfsd/xdr4.h       | 15 +++++++++++++++
>>  include/linux/nfs4.h |  2 +-
>>  4 files changed, 98 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 3210c6f..bc45ed2 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1064,6 +1064,45 @@ nfsd4_write_plus(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	return nfserr_union_notsupp;
>>  }
>>
>> +static __be32
>> +nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		struct nfsd4_seek *seek)
>> +{
>> +	struct file *file;
>> +	loff_t pos, end_pos;
>> +	__be32 status;
>> +
>> +	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> +					    &seek->seek_stateid,
>> +					    RD_STATE | WR_STATE, &file);
>
> Note nfs4_preprocess_stateid_op requires the caller to hold the state
> lock.  Andyou want to either hold it till you're done using "file" or
> take a reference on file before dropping it.

That's useful to know.  I'll fix it up here, and anywhere else I call 
nfs4_preprocess_stateid_op()!
>
> --b.
>
>> +	if (status != nfs_ok)
>> +		return status;
>> +
>> +	if (seek->seek_whence == NFS4_CONTENT_DATA) {
>> +		pos = vfs_llseek(file, seek->seek_offset, SEEK_DATA);
>> +		end_pos = vfs_llseek(file, pos, SEEK_HOLE);
>> +		seek->seek_allocated = true;
>> +	} else {
>> +		pos = vfs_llseek(file, seek->seek_offset, SEEK_HOLE);
>> +		end_pos = vfs_llseek(file, pos, SEEK_DATA);
>> +		seek->seek_allocated = false;
>> +	}
>> +
>> +	if (pos < 0)
>> +		return nfserrno(pos);
>> +	else if (end_pos == -ENXIO) {
>> +		seek->seek_length = 0;
>> +		seek->seek_eof = true;
>> +	} else if (end_pos < 0)
>> +		return nfserrno(end_pos);
>> +	else
>> +		seek->seek_length = end_pos - pos;
>> +
>> +	seek->seek_offset = pos;
>> +
>> +	return nfs_ok;
>> +}
>> +
>>  /* This routine never returns NFS_OK!  If there are no other errors, it
>>   * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
>>   * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
>> @@ -1885,6 +1924,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
>>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
>>  		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
>>  	},
>> +
>> +	[OP_SEEK] = {
>> +		.op_func = (nfsd4op_func)nfsd4_seek,
>> +		.op_name = "OP_SEEK",
>> +	},
>>  };
>>
>>  #ifdef NFSD_DEBUG
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 1e4e9af..8434740 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1511,6 +1511,22 @@ nfsd4_decode_write_plus(struct nfsd4_compoundargs *argp,
>>  }
>>
>>  static __be32
>> +nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
>> +{
>> +	DECODE_HEAD;
>> +
>> +	status = nfsd4_decode_stateid(argp, &seek->seek_stateid);
>> +	if (status)
>> +		return status;
>> +
>> +	READ_BUF(12);
>> +	READ64(seek->seek_offset);
>> +	READ32(seek->seek_whence);
>> +
>> +	DECODE_TAIL;
>> +}
>> +
>> +static __be32
>>  nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
>>  {
>>  	return nfs_ok;
>> @@ -1693,7 +1709,7 @@ static nfsd4_dec nfsd42_dec_ops[] = {
>>  	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
>>  	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_write_plus,
>>  	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> -	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
>>  	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
>>  };
>>
>> @@ -3650,6 +3666,26 @@ nfsd4_encode_write_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
>>  }
>>
>>  static __be32
>> +nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
>> +		  struct nfsd4_seek *seek)
>> +{
>> +	__be32 *p;
>> +
>> +	if (nfserr)
>> +		return nfserr;
>> +
>> +	RESERVE_SPACE(28);
>> +	WRITE32(seek->seek_eof);
>> +	WRITE32(seek->seek_whence);
>> +	WRITE64(seek->seek_offset);
>> +	WRITE64(seek->seek_length);
>> +	WRITE32(seek->seek_allocated);
>> +	ADJUST_ARGS();
>> +
>> +	return nfserr;
>> +}
>> +
>> +static __be32
>>  nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
>>  {
>>  	return nfserr;
>> @@ -3730,7 +3766,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>>  	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
>>  	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_write_plus,
>>  	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
>> -	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
>> +	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
>>  	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
>>  };
>>
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index aaef9ab..ae9debc 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -451,6 +451,20 @@ struct nfsd4_write_plus {
>>  	struct nfsd42_write_res	wp_res;
>>  };
>>
>> +struct nfsd4_seek {
>> +	/* request */
>> +	stateid_t	seek_stateid;
>> +
>> +	/* Shared between request and response */
>> +	u64		seek_offset;
>> +	u32		seek_whence;
>> +
>> +	/* response */
>> +	u32		seek_eof;
>> +	u64		seek_length;
>> +	u32		seek_allocated;
>> +};
>> +
>>  struct nfsd4_op {
>>  	int					opnum;
>>  	__be32					status;
>> @@ -499,6 +513,7 @@ struct nfsd4_op {
>>
>>  		/* NFSv4.2 */
>>  		struct nfsd4_write_plus		write_plus;
>> +		struct nfsd4_seek		seek;
>>  	} u;
>>  	struct nfs4_replay *			replay;
>>  };
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index 55ed991..81d6b09 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -128,7 +128,7 @@ enum nfs_opnum4 {
>>  Needs to be updated if more operations are defined in future.*/
>>
>>  #define FIRST_NFS4_OP	OP_ACCESS
>> -#define LAST_NFS4_OP 	OP_WRITE_PLUS
>> +#define LAST_NFS4_OP 	OP_SEEK
>>
>>  enum nfsstat4 {
>>  	NFS4_OK = 0,
>> --
>> 1.8.4.1
>>


