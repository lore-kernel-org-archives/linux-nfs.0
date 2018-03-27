Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:36306 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbeC0VWe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 17:22:34 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v2 15/18] nfsd: Add I/O trace points in the NFSv4 read
 proc
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180327201447.GD22077@fieldses.org>
Date: Tue, 27 Mar 2018 17:22:28 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1C2194E1-E7A1-447F-AEAC-4750A950F94E@oracle.com>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
 <20180327145340.7710.93006.stgit@oracle-ib-101.nfsv4bat.org>
 <97BBDD8C-AE6F-480B-8C6A-A98B2CDF9E10@oracle.com>
 <20180327201447.GD22077@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 27, 2018, at 4:14 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> Could you check that I got this right in
>=20
> 	git://linux-nfs.org/~bfields/linux.git nfsd-next

You changed it correctly.

However, the patch description says "Also, we want to record any local =
I/O error that occurs, and the total count of bytes that were actually =
moved."

Therefore I think we want to pass host_err rather than maxcount to =
trace_nfsd_read_io_done, in both NFSv4 read helpers.

Do you want me to resend with these fixes?


> --b.
>=20
> On Tue, Mar 27, 2018 at 12:57:17PM -0400, Chuck Lever wrote:
>>=20
>>=20
>>> On Mar 27, 2018, at 10:53 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>=20
>>> NFSv4 read compound processing invokes nfsd_splice_read and
>>> nfs_readv directly, so the trace points currently in nfsd_read are
>>> not effective for NFSv4 reads.
>>>=20
>>> Move and copy the trace points so that NFSv4 reads are captured.
>>> Also, we want to record any local I/O error that occurs, and
>>> the total count of bytes that were actually moved. And, also
>>> whether splice or vectored read was used.
>>>=20
>>> The svc_fh is not passed to the read helpers, so some code
>>> duplication is necessary.
>>>=20
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> fs/nfsd/nfs4proc.c |    5 +++++
>>> fs/nfsd/nfs4xdr.c  |   56 =
+++++++++++++++++++++++++++++++++++++---------------
>>> fs/nfsd/trace.h    |    4 +++-
>>> fs/nfsd/vfs.c      |   54 =
++++++++++++++++++++++----------------------------
>>> fs/nfsd/vfs.h      |    8 ++++---
>>> 5 files changed, 76 insertions(+), 51 deletions(-)
>>>=20
>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>>> index b93673e..39016b6 100644
>>> --- a/fs/nfsd/nfs4proc.c
>>> +++ b/fs/nfsd/nfs4proc.c
>>> @@ -751,6 +751,9 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst =
*rqstp, struct svc_fh *fh)
>>> 	if (read->rd_offset >=3D OFFSET_MAX)
>>> 		return nfserr_inval;
>>>=20
>>> +	trace_nfsd_read_start(rqstp, &cstate->current_fh,
>>> +			      read->rd_offset, read->rd_length);
>>> +
>>> 	/*
>>> 	 * If we do a zero copy read, then a client will see read data
>>> 	 * that reflects the state of the file *after* performing the
>>> @@ -783,6 +786,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst =
*rqstp, struct svc_fh *fh)
>>> {
>>> 	if (u->read.rd_filp)
>>> 		fput(u->read.rd_filp);
>>> +	trace_nfsd_read_done(u->read.rd_rqstp, u->read.rd_fhp,
>>> +			     u->read.rd_offset, u->read.rd_length);
>>> }
>>>=20
>>> static __be32
>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>> index e502fd1..d03059a 100644
>>> --- a/fs/nfsd/nfs4xdr.c
>>> +++ b/fs/nfsd/nfs4xdr.c
>>> @@ -37,6 +37,7 @@
>>> #include <linux/file.h>
>>> #include <linux/slab.h>
>>> #include <linux/namei.h>
>>> +#include <linux/fsnotify.h>
>>> #include <linux/statfs.h>
>>> #include <linux/utsname.h>
>>> #include <linux/pagemap.h>
>>> @@ -50,6 +51,7 @@
>>> #include "cache.h"
>>> #include "netns.h"
>>> #include "pnfs.h"
>>> +#include "trace.h"
>>>=20
>>> #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>>> #include <linux/security.h>
>>> @@ -3416,28 +3418,28 @@ static __be32 nfsd4_encode_splice_read(
>>> {
>>> 	struct xdr_stream *xdr =3D &resp->xdr;
>>> 	struct xdr_buf *buf =3D xdr->buf;
>>> +	int host_err;
>>> 	u32 eof;
>>> 	long len;
>>> 	int space_left;
>>> -	__be32 nfserr;
>>> 	__be32 *p =3D xdr->p - 2;
>>>=20
>>> 	/* Make sure there will be room for padding if needed */
>>> 	if (xdr->end - xdr->p < 1)
>>> 		return nfserr_resource;
>>>=20
>>> +	trace_nfsd_read_splice(resp->rqstp, read->rd_fhp,
>>> +			       read->rd_offset, maxcount);
>>> 	len =3D maxcount;
>>> -	nfserr =3D nfsd_splice_read(read->rd_rqstp, file,
>>> +	host_err =3D nfsd_splice_read(read->rd_rqstp, file,
>>> 				  read->rd_offset, &maxcount);
>>> -	if (nfserr) {
>>> -		/*
>>> -		 * nfsd_splice_actor may have already messed with the
>>> -		 * page length; reset it so as not to confuse
>>> -		 * xdr_truncate_encode:
>>> -		 */
>>> -		buf->page_len =3D 0;
>>> -		return nfserr;
>>> -	}
>>> +	if (host_err < 0)
>>> +		goto err;
>>> +	trace_nfsd_read_io_done(read->rd_rqstp, read->rd_fhp,
>>> +				read->rd_offset, maxcount);
>>> +	maxcount =3D host_err;
>>> +	nfsdstats.io_read +=3D maxcount;
>>> +	fsnotify_access(file);
>>>=20
>>> 	eof =3D nfsd_eof_on_read(len, maxcount, read->rd_offset,
>>> 				=
d_inode(read->rd_fhp->fh_dentry)->i_size);
>>> @@ -3470,6 +3472,17 @@ static __be32 nfsd4_encode_splice_read(
>>> 	xdr->end =3D (__be32 *)((void *)xdr->end + space_left);
>>>=20
>>> 	return 0;
>>> +
>>> +err:
>>> +	/*
>>> +	 * nfsd_splice_actor may have already messed with the
>>> +	 * page length; reset it so as not to confuse
>>> +	 * xdr_truncate_encode:
>>> +	 */
>>> +	buf->page_len =3D 0;
>>> +	trace_nfsd_read_err(read->rd_rqstp, read->rd_fhp,
>>> +			    read->rd_offset, host_err);
>>> +	return nfserrno(host_err);
>>> }
>>>=20
>>> static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>>> @@ -3477,12 +3490,12 @@ static __be32 nfsd4_encode_readv(struct =
nfsd4_compoundres *resp,
>>> 				 struct file *file, unsigned long =
maxcount)
>>> {
>>> 	struct xdr_stream *xdr =3D &resp->xdr;
>>> +	int host_err;
>>> 	u32 eof;
>>> 	int v;
>>> 	int starting_len =3D xdr->buf->len - 8;
>>> 	long len;
>>> 	int thislen;
>>> -	__be32 nfserr;
>>> 	__be32 tmp;
>>> 	__be32 *p;
>>> 	u32 zzz =3D 0;
>>> @@ -3510,11 +3523,18 @@ static __be32 nfsd4_encode_readv(struct =
nfsd4_compoundres *resp,
>>> 	}
>>> 	read->rd_vlen =3D v;
>>>=20
>>> +	trace_nfsd_read_vector(resp->rqstp, read->rd_fhp,
>>> +			       read->rd_offset, maxcount);
>>> 	len =3D maxcount;
>>> -	nfserr =3D nfsd_readv(file, read->rd_offset, =
resp->rqstp->rq_vec,
>>> -			read->rd_vlen, &maxcount);
>>> -	if (nfserr)
>>> -		return nfserr;
>>> +	host_err =3D nfsd_readv(file, read->rd_offset, =
resp->rqstp->rq_vec,
>>> +			      read->rd_vlen, &maxcount);
>>> +	if (host_err < 0)
>>> +		goto err;
>>> +	trace_nfsd_read_io_done(resp->rqstp, read->rd_fhp,
>>> +				read->rd_offset, maxcount);
>>=20
>> I missed a spot.
>>=20
>> +	maxcount =3D host_err;
>>=20
>>> +	nfsdstats.io_read +=3D maxcount;
>>> +	fsnotify_access(file);
>>> +
>>> 	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
>>>=20
>>> 	eof =3D nfsd_eof_on_read(len, maxcount, read->rd_offset,
>>> @@ -3530,6 +3550,10 @@ static __be32 nfsd4_encode_readv(struct =
nfsd4_compoundres *resp,
>>> 								&zzz, =
pad);
>>> 	return 0;
>>>=20
>>> +err:
>>> +	trace_nfsd_read_err(resp->rqstp, read->rd_fhp,
>>> +			    read->rd_offset, host_err);
>>> +	return nfserrno(host_err);
>>> }
>>>=20
>>> static __be32
>>> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
>>> index 653e9ee..a8bbd9d 100644
>>> --- a/fs/nfsd/trace.h
>>> +++ b/fs/nfsd/trace.h
>>> @@ -43,7 +43,8 @@
>>> 	TP_ARGS(rqstp, fhp, offset, len))
>>>=20
>>> DEFINE_NFSD_IO_EVENT(read_start);
>>> -DEFINE_NFSD_IO_EVENT(read_opened);
>>> +DEFINE_NFSD_IO_EVENT(read_splice);
>>> +DEFINE_NFSD_IO_EVENT(read_vector);
>>> DEFINE_NFSD_IO_EVENT(read_io_done);
>>> DEFINE_NFSD_IO_EVENT(read_done);
>>> DEFINE_NFSD_IO_EVENT(write_start);
>>> @@ -82,6 +83,7 @@
>>> 		 int		len),		\
>>> 	TP_ARGS(rqstp, fhp, offset, len))
>>>=20
>>> +DEFINE_NFSD_ERR_EVENT(read_err);
>>> DEFINE_NFSD_ERR_EVENT(write_err);
>>>=20
>>> #include "state.h"
>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>>> index ee59a0b..0fa54b5 100644
>>> --- a/fs/nfsd/vfs.c
>>> +++ b/fs/nfsd/vfs.c
>>> @@ -881,19 +881,7 @@ static int nfsd_direct_splice_actor(struct =
pipe_inode_info *pipe,
>>> 	return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
>>> }
>>>=20
>>> -static __be32
>>> -nfsd_finish_read(struct file *file, unsigned long *count, int =
host_err)
>>> -{
>>> -	if (host_err >=3D 0) {
>>> -		nfsdstats.io_read +=3D host_err;
>>> -		*count =3D host_err;
>>> -		fsnotify_access(file);
>>> -		return 0;
>>> -	} else=20
>>> -		return nfserrno(host_err);
>>> -}
>>> -
>>> -__be32 nfsd_splice_read(struct svc_rqst *rqstp,
>>> +int nfsd_splice_read(struct svc_rqst *rqstp,
>>> 		     struct file *file, loff_t offset, unsigned long =
*count)
>>> {
>>> 	struct splice_desc sd =3D {
>>> @@ -902,23 +890,18 @@ __be32 nfsd_splice_read(struct svc_rqst =
*rqstp,
>>> 		.pos		=3D offset,
>>> 		.u.data		=3D rqstp,
>>> 	};
>>> -	int host_err;
>>>=20
>>> 	rqstp->rq_next_page =3D rqstp->rq_respages + 1;
>>> -	host_err =3D splice_direct_to_actor(file, &sd, =
nfsd_direct_splice_actor);
>>> -	return nfsd_finish_read(file, count, host_err);
>>> +	return splice_direct_to_actor(file, &sd, =
nfsd_direct_splice_actor);
>>> }
>>>=20
>>> -__be32 nfsd_readv(struct file *file, loff_t offset, struct kvec =
*vec, int vlen,
>>> -		unsigned long *count)
>>> +int nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, =
int vlen,
>>> +	       unsigned long *count)
>>> {
>>> 	struct iov_iter iter;
>>> -	int host_err;
>>>=20
>>> 	iov_iter_kvec(&iter, READ | ITER_KVEC, vec, vlen, *count);
>>> -	host_err =3D vfs_iter_read(file, &iter, &offset, 0);
>>> -
>>> -	return nfsd_finish_read(file, count, host_err);
>>> +	return vfs_iter_read(file, &iter, &offset, 0);
>>> }
>>>=20
>>> /*
>>> @@ -1025,6 +1008,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, =
struct svc_fh *fhp,
>>> {
>>> 	struct file *file;
>>> 	struct raparms	*ra;
>>> +	int host_err;
>>> 	__be32 err;
>>>=20
>>> 	trace_nfsd_read_start(rqstp, fhp, offset, *count);
>>> @@ -1034,14 +1018,24 @@ __be32 nfsd_read(struct svc_rqst *rqstp, =
struct svc_fh *fhp,
>>>=20
>>> 	ra =3D nfsd_init_raparms(file);
>>>=20
>>> -	trace_nfsd_read_opened(rqstp, fhp, offset, *count);
>>> -
>>> -	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, =
&rqstp->rq_flags))
>>> -		err =3D nfsd_splice_read(rqstp, file, offset, count);
>>> -	else
>>> -		err =3D nfsd_readv(file, offset, vec, vlen, count);
>>> -
>>> -	trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
>>> +	if (file->f_op->splice_read &&
>>> +	    test_bit(RQ_SPLICE_OK, &rqstp->rq_flags)) {
>>> +		trace_nfsd_read_splice(rqstp, fhp, offset, *count);
>>> +		host_err =3D nfsd_splice_read(rqstp, file, offset, =
count);
>>> +	} else {
>>> +		trace_nfsd_read_vector(rqstp, fhp, offset, *count);
>>> +		host_err =3D nfsd_readv(file, offset, vec, vlen, count);
>>> +	}
>>> +	if (host_err >=3D 0) {
>>> +		trace_nfsd_read_io_done(rqstp, fhp, offset, host_err);
>>> +		nfsdstats.io_read +=3D host_err;
>>> +		*count =3D host_err;
>>> +		fsnotify_access(file);
>>> +		err =3D nfs_ok;
>>> +	} else  {
>>> +		trace_nfsd_read_err(rqstp, fhp, offset, host_err);
>>> +		err =3D nfserrno(host_err);
>>> +	}
>>>=20
>>> 	if (ra)
>>> 		nfsd_put_raparams(file, ra);
>>> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
>>> index be6d8e0..d9131c3 100644
>>> --- a/fs/nfsd/vfs.h
>>> +++ b/fs/nfsd/vfs.h
>>> @@ -78,10 +78,10 @@ __be32		nfsd_commit(struct svc_rqst *, =
struct svc_fh *,
>>> __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, =
umode_t,
>>> 				int, struct file **);
>>> struct raparms;
>>> -__be32		nfsd_splice_read(struct svc_rqst *,
>>> -				struct file *, loff_t, unsigned long *);
>>> -__be32		nfsd_readv(struct file *, loff_t, struct kvec *, =
int,
>>> -				unsigned long *);
>>> +int		nfsd_splice_read(struct svc_rqst *rqstp, struct =
file *file,
>>> +				loff_t offset, unsigned long *count);
>>> +int		nfsd_readv(struct file *file, loff_t offset, =
struct kvec *vec,
>>> +				int vlen, unsigned long *count);
>>> __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
>>> 				loff_t, struct kvec *, int, unsigned =
long *);
>>> __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *, =
loff_t,
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> --
>> Chuck Lever
>>=20
>>=20

--
Chuck Lever



