Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50698 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757898Ab3KMUCq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 15:02:46 -0500
Message-ID: <5283DAE4.3030608@netapp.com>
Date: Wed, 13 Nov 2013 15:02:44 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: Bruce Fields <bfields@fieldses.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 3/3] NFSD: Implement SEEK
References: <1384371057-16454-1-git-send-email-bjschuma@netapp.com> <1384371057-16454-4-git-send-email-bjschuma@netapp.com> <5000397E-1879-4ED1-B761-8C7BB8D87F81@netapp.com>
In-Reply-To: <5000397E-1879-4ED1-B761-8C7BB8D87F81@netapp.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/13/2013 03:01 PM, Weston Andros Adamson wrote:
> 
> On Nov 13, 2013, at 2:30 PM, Anna Schumaker <bjschuma@netapp.com> wrote:
> 
>> This patch adds in the SEEK operation used by clients doing an llseek on
>> a file to find either hole or data segments.  I am making the assumption
>> that allocated == true in the NFS4_CONTENT_DATA case and false for the
>> NFS4_CONTENT_HOLE case.
>>
>> Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
>>
>> ---
>> Changed in V3:
>> - SEEK is only compiled in when CONFIG_NFSD_V4_2_SEEK is enabled
>>
>> fs/nfsd/Kconfig      | 12 +++++++++++
>> fs/nfsd/nfs4proc.c   | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>> fs/nfsd/nfs4xdr.c    | 48 +++++++++++++++++++++++++++++++++++++++++
>> fs/nfsd/xdr4.h       | 16 ++++++++++++++
>> include/linux/nfs4.h |  6 ++++++
>> 5 files changed, 142 insertions(+)
>>
>> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
>> index dc8f1ef..680e017 100644
>> --- a/fs/nfsd/Kconfig
>> +++ b/fs/nfsd/Kconfig
>> @@ -81,6 +81,18 @@ config NFSD_V4
>>
>> 	  If unsure, say N.
>>
>> +config NFSD_V4_2_SEEK
>> +	bool "Enable SEEK support for the NFS v4.2 server"
>> +	depends on NFSD_V4
>> +	help
>> +	  Say Y here if you want to enable support for the NFS v4.2 operation
>> +	  SEEK, which adds in SEEK_HOLE and SEEK_DATA support.
>> +
>> +	  WARNING: there is still a chance of backwards-incompatible protocol
>> +	  changes.  This feature is targeted at developers and testers only.
>> +
>> +	  If unsure, say N.
>> +
>> config NFSD_V4_SECURITY_LABEL
>> 	bool "Provide Security Label support for NFSv4 server"
>> 	depends on NFSD_V4 && SECURITY
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 419572f..1283ca7 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1028,6 +1028,59 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> 	return status;
>> }
>>
>> +#ifdef CONFIG_NFSD_V4_2_SEEK
>> +static __be32
>> +nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		struct nfsd4_seek *seek)
>> +{
>> +	struct file *file;
>> +	loff_t end_pos = 0;
>> +	__be32 status;
>> +
>> +	nfs4_lock_state();
>> +	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> +					    &seek->seek_stateid,
>> +					    RD_STATE | WR_STATE, &file);
>> +	if (status != nfs_ok) {
>> +		nfs4_unlock_state();
>> +		return status;
>> +	} else
> 
> this else isn’t needed.

Good catch, thanks!

Anna

> 
> -dros
> 
>> +		get_file(file);
>> +	nfs4_unlock_state();
>> +
>> +	switch (seek->seek_whence) {
>> +	case NFS4_CONTENT_APP_DATA_HOLE:
>> +		status = nfserr_union_notsupp;
>> +		break;
>> +	case NFS4_CONTENT_DATA:
>> +		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_DATA);
>> +		end_pos = vfs_llseek(file, seek->seek_pos, SEEK_HOLE);
>> +		seek->seek_allocated = true;
>> +		break;
>> +	case NFS4_CONTENT_HOLE:
>> +		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_HOLE);
>> +		end_pos = vfs_llseek(file, seek->seek_pos, SEEK_DATA);
>> +		seek->seek_allocated = false;
>> +		break;
>> +	default:
>> +		status = nfs_ok;
>> +		seek->seek_eof = true;
>> +		goto out;
>> +	}
>> +
>> +	if (seek->seek_pos < 0) {
>> +		status = nfserrno(seek->seek_pos);
>> +		goto out;
>> +	}
>> +
>> +	seek->seek_length = end_pos - seek->seek_pos;
>> +
>> +out:
>> +	fput(file);
>> +	return status;
>> +}
>> +#endif /* CONFIG_NFSD_V4_2_SEEK */
>> +
>> /* This routine never returns NFS_OK!  If there are no other errors, it
>>  * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
>>  * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
>> @@ -1840,6 +1893,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
>> 		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
>> 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>> 	},
>> +
>> +#ifdef CONFIG_NFSD_V4_2_SEEK
>> +	[OP_SEEK] = {
>> +		.op_func = (nfsd4op_func)nfsd4_seek,
>> +		.op_name = "OP_SEEK",
>> +	},
>> +#endif /* CONFIG_NFSD_V4_2_SEEK */
>> };
>>
>> #ifdef NFSD_DEBUG
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 3af6c46..7041039 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1507,6 +1507,24 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>> 	DECODE_TAIL;
>> }
>>
>> +#ifdef CONFIG_NFSD_V4_2_SEEK
>> +static __be32
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
>> +#endif /* CONFIG_NFSD_V4_2_SEEK */
>> +
>> static __be32
>> nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
>> {
>> @@ -1589,7 +1607,11 @@ static nfsd4_dec nfsd4_dec_ops[] = {
>> 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> 	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +#ifdef CONFIG_NFSD_V4_2_SEEK
>> +	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
>> +#else
>> 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +#endif /* CONFIG_NFSD_V4_2_SEEK */
>> 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> };
>>
>> @@ -3514,6 +3536,28 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
>> 	return nfserr;
>> }
>>
>> +#ifdef CONFIG_NFSD_V4_2_SEEK
>> +static __be32
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
>> +	WRITE64(seek->seek_pos);
>> +	WRITE64(seek->seek_length);
>> +	WRITE32(seek->seek_allocated);
>> +	ADJUST_ARGS();
>> +
>> +	return nfserr;
>> +}
>> +#endif /* CONFIG_NFSD_V4_2_SEEK */
>> +
>> static __be32
>> nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
>> {
>> @@ -3595,7 +3639,11 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>> 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
>> 	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
>> 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
>> +#ifdef CONFIG_NFSD_V4_2_SEEK
>> +	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
>> +#else
>> 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
>> +#endif /* CONFIG_NFSD_V4_2_SEEK */
>> 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
>> };
>>
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index b3ed644..c2f4e30 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -430,6 +430,19 @@ struct nfsd4_reclaim_complete {
>> 	u32 rca_one_fs;
>> };
>>
>> +struct nfsd4_seek {
>> +	/* request */
>> +	stateid_t	seek_stateid;
>> +	loff_t		seek_offset;
>> +	u32		seek_whence;
>> +
>> +	/* response */
>> +	u64		seek_pos;
>> +	u32		seek_eof;
>> +	u64		seek_length;
>> +	u32		seek_allocated;
>> +};
>> +
>> struct nfsd4_op {
>> 	int					opnum;
>> 	__be32					status;
>> @@ -475,6 +488,9 @@ struct nfsd4_op {
>> 		struct nfsd4_reclaim_complete	reclaim_complete;
>> 		struct nfsd4_test_stateid	test_stateid;
>> 		struct nfsd4_free_stateid	free_stateid;
>> +
>> +		/* NFSv4.2 */
>> +		struct nfsd4_seek		seek;
>> 	} u;
>> 	struct nfs4_replay *			replay;
>> };
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index e58e0eb..a35b0b6 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -558,4 +558,10 @@ struct nfs4_deviceid {
>> 	char data[NFS4_DEVICEID4_SIZE];
>> };
>>
>> +enum data_content4 {
>> +	NFS4_CONTENT_DATA		= 0,
>> +	NFS4_CONTENT_APP_DATA_HOLE	= 1,
>> +	NFS4_CONTENT_HOLE		= 2,
>> +};
>> +
>> #endif
>> -- 
>> 1.8.4.2
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

