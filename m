From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/8] NFS: Add separate mountd status code decoders for each mountd version
Date: Fri, 12 Jun 2009 17:07:50 -0400
Message-ID: <106661C9-CE4E-4F27-8791-DE869D7FE0D4@oracle.com>
References: <20090501163507.25681.14463.stgit@ingres.1015granger.net> <20090501163651.25681.95115.stgit@ingres.1015granger.net> <1244840137.32257.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:49193 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029AbZFLVH4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2009 17:07:56 -0400
In-Reply-To: <1244840137.32257.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 12, 2009, at 4:55 PM, Trond Myklebust wrote:

> On Fri, 2009-05-01 at 12:36 -0400, Chuck Lever wrote:
>> Introduce data structures and xdr_stream-based decoding functions for
>> unmarshalling mountd status codes properly.
>>
>> Mountd version 3 uses specific standard error return codes that are
>> not errno values and not NFS3ERR_ values.  These have a well-defined
>> standard mapping to local errno values.  Introduce data structures
>> and a decoder function that map these status codes to local errno
>> values properly.  This is new functionality (but not used yet).
>>
>> Version 1 mountd status values are defined by RFC 1094 as UNIX error
>> values (errno values).  Errno values on heterogeneous systems do not
>> necessarily match each other.  To avoid exposing possibly incorrect
>> errno values to upper layers, the current XDR decoder converts all
>> non-zero MNT version 1 status codes to -EACCES.
>>
>> The OpenGroup XNFS standard provides a mapping similar to but smaller
>> than the version 3 error codes.  Implement a decoder that uses the  
>> XNFS
>> error codes, replacing the current decoder.
>>
>> For both mountd protocol versions, map unrecognized errors to - 
>> EACCES.
>>
>> Finally we introduce a replacement data structure for mnt_fhstatus
>> at this time, which is used by the new XDR decoders.  In addition to
>> documenting that the status value returned by the XDR decoders is
>> always an errno, this new structure will be expanded in subsequent
>> patches.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfs/mount_clnt.c |  134 +++++++++++++++++++++++++++++++++++++++++ 
>> ++++++++++
>> 1 files changed, 134 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
>> index 7b81914..cdda067 100644
>> --- a/fs/nfs/mount_clnt.c
>> +++ b/fs/nfs/mount_clnt.c
>> @@ -29,6 +29,8 @@
>>  * XDR data type sizes
>>  */
>> #define encode_dirpath_sz	XDR_QUADLEN(sizeof(u32) + MNTPATHLEN)
>> +#define MNT_status_sz		XDR_QUADLEN(sizeof(u32))
>> +#define MNT_fhs_status_sz	XDR_QUADLEN(sizeof(u32))
>
> XDR_QUADLEN() applies to strings only. Please just use naked numbers
> here. I've already fixed up the previous patch that did this.

OK, I'll fix these up.  So the redriven patch applies, did you change  
encode_dirpath_sz to be:

#define encode_dirpath_sz	(1 + XDR_QUADLEN(MNTPATHLEN))

Actually, just send what you have so I can see what exactly you want  
here.

But, where does it say XDR_QUADLEN applies to strings only?  The  
documenting comment just says "Buffer adjustment".

>> /*
>>  * XDR argument and result sizes
>> @@ -61,6 +63,83 @@ enum {
>>
>> static struct rpc_program	mnt_program;
>>
>> +/*
>> + * Defined by OpenGroup XNFS Version 3W, chapter 8
>> + */
>> +enum mountstat {
>> +	MNT_OK			= 0,
>> +	MNT_EPERM		= 1,
>> +	MNT_ENOENT		= 2,
>> +	MNT_EACCES		= 13,
>> +	MNT_EINVAL		= 22,
>> +};
>> +
>> +#define MNT_MAPERRNO(name) \
>> +	{ \
>> +		.status		= MNT_E##name, \
>> +		.errno		= -E##name, \
>> +	}
>
> It would be nice to avoid this kind of macro. Please inline instead.

Would you like the PROC macro replaced with open code as well?

>> +
>> +static struct {
>> +	u32 status;
>> +	int errno;
>> +} mnt_errtbl[] = {
>> +	{
>> +		.status		= MNT_OK,
>> +		.errno		= 0,
>> +	},
>> +	MNT_MAPERRNO(PERM),
>> +	MNT_MAPERRNO(NOENT),
>> +	MNT_MAPERRNO(ACCES),
>> +	MNT_MAPERRNO(INVAL),
>> +};
>> +
>> +/*
>> + * Defined by RFC 1813, section 5.1.5
>> + */
>> +enum mountstat3 {
>> +	MNT3_OK			= 0,		/* no error */
>> +	MNT3ERR_PERM		= 1,		/* Not owner */
>> +	MNT3ERR_NOENT		= 2,		/* No such file or directory */
>> +	MNT3ERR_IO		= 5,		/* I/O error */
>> +	MNT3ERR_ACCES		= 13,		/* Permission denied */
>> +	MNT3ERR_NOTDIR		= 20,		/* Not a directory */
>> +	MNT3ERR_INVAL		= 22,		/* Invalid argument */
>> +	MNT3ERR_NAMETOOLONG	= 63,		/* Filename too long */
>> +	MNT3ERR_NOTSUPP		= 10004,	/* Operation not supported */
>> +	MNT3ERR_SERVERFAULT	= 10006,	/* A failure on the server */
>> +};
>> +
>> +#define MNT3_MAPERRNO(name) \
>> +	{ \
>> +		.status		= MNT3ERR_##name, \
>> +		.errno		= -E##name, \
>> +	}
>
> See above
>
>> +static struct {
>> +	u32 status;
>> +	int errno;
>> +} mnt3_errtbl[] = {
>> +	{
>> +		.status		= MNT3_OK,
>> +		.errno		= 0,
>> +	},
>> +	MNT3_MAPERRNO(PERM),
>> +	MNT3_MAPERRNO(NOENT),
>> +	MNT3_MAPERRNO(IO),
>> +	MNT3_MAPERRNO(ACCES),
>> +	MNT3_MAPERRNO(NOTDIR),
>> +	MNT3_MAPERRNO(INVAL),
>> +	MNT3_MAPERRNO(NAMETOOLONG),
>> +	MNT3_MAPERRNO(NOTSUPP),
>> +	MNT3_MAPERRNO(SERVERFAULT),
>> +};
>> +
>> +struct mountres {
>> +	int errno;
>> +	struct nfs_fh *fh;
>> +};
>> +
>> struct mnt_fhstatus {
>> 	u32 status;
>> 	struct nfs_fh *fh;
>> @@ -179,6 +258,61 @@ static int xdr_decode_fhstatus(struct rpc_rqst  
>> *req, __be32 *p,
>> 	return 0;
>> }
>>
>> +/*
>> + * RFC 1094: "A non-zero status indicates some sort of error.  In  
>> this
>> + * case, the status is a UNIX error number."  This can be  
>> problematic
>> + * if the server and client use different errno values for the same
>> + * error.
>> + *
>> + * However, the OpenGroup XNFS spec provides a simple mapping that  
>> is
>> + * independent of local errno values on the server and the client.
>> + */
>> +static int decode_status(struct xdr_stream *xdr, struct mountres  
>> *res)
>> +{
>> +	unsigned int i;
>> +	u32 status;
>> +	__be32 *p;
>> +
>> +	p = xdr_inline_decode(xdr, sizeof(status));
>> +	if (unlikely(p == NULL))
>> +		return -EIO;
>> +	status = ntohl(*p);
>> +
>> +	for (i = 0; i <= ARRAY_SIZE(mnt_errtbl); i++) {
>> +		if (mnt_errtbl[i].status == status) {
>> +			res->errno = mnt_errtbl[i].errno;
>> +			return 0;
>> +		}
>> +	}
>> +
>> +	dprintk("NFS: unrecognized MNT status code: %u\n", status);
>> +	res->errno = -EACCES;
>> +	return 0;
>> +}
>> +
>> +static int decode_fhs_status(struct xdr_stream *xdr, struct  
>> mountres *res)
>> +{
>> +	unsigned int i;
>> +	u32 status;
>> +	__be32 *p;
>> +
>> +	p = xdr_inline_decode(xdr, sizeof(status));
>> +	if (unlikely(p == NULL))
>> +		return -EIO;
>> +	status = ntohl(*p);
>> +
>> +	for (i = 0; i <= ARRAY_SIZE(mnt3_errtbl); i++) {
>> +		if (mnt3_errtbl[i].status == status) {
>> +			res->errno = mnt3_errtbl[i].errno;
>> +			return 0;
>> +		}
>> +	}
>> +
>> +	dprintk("NFS: unrecognized MNT3 status code: %u\n", status);
>> +	res->errno = -EACCES;
>> +	return 0;
>> +}
>> +
>> static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
>> 				struct mnt_fhstatus *res)
>> {
>>
>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
