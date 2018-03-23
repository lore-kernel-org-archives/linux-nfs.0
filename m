Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:41852 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbeCWWh4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2018 18:37:56 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v1 1/2] NFSD: Clean up write argument XDR decoders
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4061A951-7FA1-4E85-9D04-3AB5F20A4A7B@oracle.com>
Date: Fri, 23 Mar 2018 18:37:51 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <ABCD8B94-C1F9-475A-AF45-53DC3EAEFB41@oracle.com>
References: <20180319184647.10100.25736.stgit@klimt.1015granger.net>
 <20180319185648.10100.94060.stgit@klimt.1015granger.net>
 <20180323213253.GV4288@fieldses.org>
 <4061A951-7FA1-4E85-9D04-3AB5F20A4A7B@oracle.com>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 23, 2018, at 5:55 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>=20
>=20
>> On Mar 23, 2018, at 5:32 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>>=20
>> If I understand correctly, in the v4 case you change the way the page
>> data is passed by using rq_arg.pages instead of a list of pages for =
each
>> write.
>>=20
>> I don't think that handles the case of compounds with multiple =
writes.
>>=20
>> If all the writes are contained in a page, then you may be OK, since =
the
>> wr_head iovec is all the information you need to pass the write data
>> from the xdr code to the proc code.
>>=20
>> But if there are multiple larger writes, you also need to know where =
the
>> page data is.  You're depending on rq_arg.pages for that, but there's
>> only one of those per compound.
>=20
> I thought we were going to handle that case by chaining xdr_bufs--
> one per NFSv4 WRITE operation. There has to be some structured way
> to pass distinct write payloads up to the NFS server, otherwise
> direct placement is impossible.

Thinking on this a little more, I think you are saying the new shared
decoder is adequate for NFSv2 and NFSv3, but not for NFSv4. Would you
accept a patch that kept the NFSv2 and NFSv3 parts of this patch, but
dropped the NFSv4-related hunks?

Likewise for the symlink decoder patch?

And we can still use a transport call-out in the XDR decoders, just as
we have discussed. (I think I've misremembered our discussion about
chaining xdr_bufs).

It's just that the XDR decoder can't be shared between NFSv4 and the
NFSv2/NFSv3 code paths.


>> To catch the regression I think we'd need a test that sends a =
compound
>> with two greater-than-one-page writes and distinct write data and =
then
>> reads back the results to check they're correct.  I don't think we =
have
>> one currently, though it wouldn't be hard to do in pynfs.
>>=20
>> It's honestly not an important case, but I'd rather not break it.
>=20
> I believe Solaris handles direct writev() using multiple WRITE
> operations per COMPOUND, but I could be wrong.
>=20
>=20
>> --b.
>>=20
>> On Mon, Mar 19, 2018 at 02:56:48PM -0400, Chuck Lever wrote:
>>> Move common code in NFSD's write arg decoders into a helper. The
>>> immediate benefit is reduction of code duplication and some nice
>>> micro-optimizations (see below).
>>>=20
>>> However, in the long term, this helper could perform a per-transport
>>> call-out to fill the rq_vec (say, using RDMA Reads).
>>>=20
>>> The legacy WRITE decoders and procs are changed to work like NFSv4,
>>> which constructs the rq_vec just before it is about to call
>>> vfs_writev.
>>>=20
>>> Why? Calling a transport call-out from the proc instead of the XDR
>>> decoder means that the incoming FH can be resolved to a particular
>>> filesystem and file. This would allow pages from the backing file to
>>> be presented to the transport to be filled, rather than presenting
>>> anonymous pages and copying or swapping them into the file's page
>>> cache later.
>>>=20
>>> I also prefer using the pages in rq_arg.pages, instead of pulling
>>> the data pages directly out of the rqstp::rq_pages array. This is
>>> currently the way the NFSv3 write decoder works, but the other two
>>> do not seem to take this approach. Fixing this removes the only
>>> reference to rq_pages found in NFSD, eliminating an NFSD assumption
>>> about how transports use the pages in rq_pages.
>>>=20
>>> Lastly, avoid setting up the first element of rq_vec as a zero-
>>> length buffer. This happens with an RDMA transport when a normal
>>> Read chunk is present because the data payload is in rq_arg's
>>> page list (none of it is in the head buffer).
>>>=20
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> fs/nfsd/nfs3proc.c         |    8 ++++++--
>>> fs/nfsd/nfs3xdr.c          |   16 ++++------------
>>> fs/nfsd/nfs4proc.c         |   30 ++++++------------------------
>>> fs/nfsd/nfs4xdr.c          |    1 -
>>> fs/nfsd/nfsproc.c          |    9 +++++++--
>>> fs/nfsd/nfsxdr.c           |   14 ++------------
>>> fs/nfsd/xdr.h              |    2 +-
>>> fs/nfsd/xdr3.h             |    2 +-
>>> fs/nfsd/xdr4.h             |    1 -
>>> include/linux/sunrpc/svc.h |    2 ++
>>> net/sunrpc/svc.c           |   42 =
++++++++++++++++++++++++++++++++++++++++++
>>> 11 files changed, 71 insertions(+), 56 deletions(-)
>>>=20
>>> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>>> index 1d0ce3c..2dd95eb 100644
>>> --- a/fs/nfsd/nfs3proc.c
>>> +++ b/fs/nfsd/nfs3proc.c
>>> @@ -192,6 +192,7 @@
>>> 	struct nfsd3_writeres *resp =3D rqstp->rq_resp;
>>> 	__be32	nfserr;
>>> 	unsigned long cnt =3D argp->len;
>>> +	unsigned int nvecs;
>>>=20
>>> 	dprintk("nfsd: WRITE(3)    %s %d bytes at %Lu%s\n",
>>> 				SVCFH_fmt(&argp->fh),
>>> @@ -201,9 +202,12 @@
>>>=20
>>> 	fh_copy(&resp->fh, &argp->fh);
>>> 	resp->committed =3D argp->stable;
>>> +	nvecs =3D svc_fill_write_vector(rqstp, &argp->first, cnt);
>>> +	if (!nvecs)
>>> +		RETURN_STATUS(nfserr_io);
>>> 	nfserr =3D nfsd_write(rqstp, &resp->fh, argp->offset,
>>> -				rqstp->rq_vec, argp->vlen,
>>> -				&cnt, resp->committed);
>>> +			    rqstp->rq_vec, nvecs, &cnt,
>>> +			    resp->committed);
>>> 	resp->count =3D cnt;
>>> 	RETURN_STATUS(nfserr);
>>> }
>>> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
>>> index 1a70581..e19fc5d 100644
>>> --- a/fs/nfsd/nfs3xdr.c
>>> +++ b/fs/nfsd/nfs3xdr.c
>>> @@ -391,7 +391,7 @@ void fill_post_wcc(struct svc_fh *fhp)
>>> nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p)
>>> {
>>> 	struct nfsd3_writeargs *args =3D rqstp->rq_argp;
>>> -	unsigned int len, v, hdr, dlen;
>>> +	unsigned int len, hdr, dlen;
>>> 	u32 max_blocksize =3D svc_max_payload(rqstp);
>>> 	struct kvec *head =3D rqstp->rq_arg.head;
>>> 	struct kvec *tail =3D rqstp->rq_arg.tail;
>>> @@ -433,17 +433,9 @@ void fill_post_wcc(struct svc_fh *fhp)
>>> 		args->count =3D max_blocksize;
>>> 		len =3D args->len =3D max_blocksize;
>>> 	}
>>> -	rqstp->rq_vec[0].iov_base =3D (void*)p;
>>> -	rqstp->rq_vec[0].iov_len =3D head->iov_len - hdr;
>>> -	v =3D 0;
>>> -	while (len > rqstp->rq_vec[v].iov_len) {
>>> -		len -=3D rqstp->rq_vec[v].iov_len;
>>> -		v++;
>>> -		rqstp->rq_vec[v].iov_base =3D =
page_address(rqstp->rq_pages[v]);
>>> -		rqstp->rq_vec[v].iov_len =3D PAGE_SIZE;
>>> -	}
>>> -	rqstp->rq_vec[v].iov_len =3D len;
>>> -	args->vlen =3D v + 1;
>>> +
>>> +	args->first.iov_base =3D (void *)p;
>>> +	args->first.iov_len =3D head->iov_len - hdr;
>>> 	return 1;
>>> }
>>>=20
>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>>> index 0df37e0..cf30544 100644
>>> --- a/fs/nfsd/nfs4proc.c
>>> +++ b/fs/nfsd/nfs4proc.c
>>> @@ -974,24 +974,6 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst =
*rqstp, struct svc_fh *fh)
>>> 	return status;
>>> }
>>>=20
>>> -static int fill_in_write_vector(struct kvec *vec, struct =
nfsd4_write *write)
>>> -{
>>> -        int i =3D 1;
>>> -        int buflen =3D write->wr_buflen;
>>> -
>>> -        vec[0].iov_base =3D write->wr_head.iov_base;
>>> -        vec[0].iov_len =3D min_t(int, buflen, =
write->wr_head.iov_len);
>>> -        buflen -=3D vec[0].iov_len;
>>> -
>>> -        while (buflen) {
>>> -                vec[i].iov_base =3D =
page_address(write->wr_pagelist[i - 1]);
>>> -                vec[i].iov_len =3D min_t(int, PAGE_SIZE, buflen);
>>> -                buflen -=3D vec[i].iov_len;
>>> -                i++;
>>> -        }
>>> -        return i;
>>> -}
>>> -
>>> static __be32
>>> nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state =
*cstate,
>>> 	    union nfsd4_op_u *u)
>>> @@ -1000,8 +982,8 @@ static int fill_in_write_vector(struct kvec =
*vec, struct nfsd4_write *write)
>>> 	stateid_t *stateid =3D &write->wr_stateid;
>>> 	struct file *filp =3D NULL;
>>> 	__be32 status =3D nfs_ok;
>>> +	unsigned int nvecs;
>>> 	unsigned long cnt;
>>> -	int nvecs;
>>>=20
>>> 	if (write->wr_offset >=3D OFFSET_MAX)
>>> 		return nfserr_inval;
>>> @@ -1019,12 +1001,12 @@ static int fill_in_write_vector(struct kvec =
*vec, struct nfsd4_write *write)
>>> 	write->wr_how_written =3D write->wr_stable_how;
>>> 	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
>>>=20
>>> -	nvecs =3D fill_in_write_vector(rqstp->rq_vec, write);
>>> -	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
>>> -
>>> +	nvecs =3D svc_fill_write_vector(rqstp, &write->wr_head, cnt);
>>> +	if (!nvecs)
>>> +		return nfserr_io;
>>> 	status =3D nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
>>> -				write->wr_offset, rqstp->rq_vec, nvecs, =
&cnt,
>>> -				write->wr_how_written);
>>> +				write->wr_offset, rqstp->rq_vec, nvecs,
>>> +				&cnt, write->wr_how_written);
>>> 	fput(filp);
>>>=20
>>> 	write->wr_bytes_written =3D cnt;
>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>> index f75cc7d..d33c8aa 100644
>>> --- a/fs/nfsd/nfs4xdr.c
>>> +++ b/fs/nfsd/nfs4xdr.c
>>> @@ -1286,7 +1286,6 @@ static __be32 nfsd4_decode_opaque(struct =
nfsd4_compoundargs *argp, struct xdr_ne
>>> 	}
>>> 	write->wr_head.iov_base =3D p;
>>> 	write->wr_head.iov_len =3D avail;
>>> -	write->wr_pagelist =3D argp->pagelist;
>>>=20
>>> 	len =3D XDR_QUADLEN(write->wr_buflen) << 2;
>>> 	if (len >=3D avail) {
>>> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
>>> index 43c0419..1995ea6 100644
>>> --- a/fs/nfsd/nfsproc.c
>>> +++ b/fs/nfsd/nfsproc.c
>>> @@ -212,13 +212,18 @@
>>> 	struct nfsd_attrstat *resp =3D rqstp->rq_resp;
>>> 	__be32	nfserr;
>>> 	unsigned long cnt =3D argp->len;
>>> +	unsigned int nvecs;
>>>=20
>>> 	dprintk("nfsd: WRITE    %s %d bytes at %d\n",
>>> 		SVCFH_fmt(&argp->fh),
>>> 		argp->len, argp->offset);
>>>=20
>>> -	nfserr =3D nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), =
argp->offset,
>>> -				rqstp->rq_vec, argp->vlen, &cnt, =
NFS_DATA_SYNC);
>>> +	nvecs =3D svc_fill_write_vector(rqstp, &argp->first, cnt);
>>> +	if (!nvecs)
>>> +		return nfserr_io;
>>> +	nfserr =3D nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
>>> +			    argp->offset, rqstp->rq_vec, nvecs,
>>> +			    &cnt, NFS_DATA_SYNC);
>>> 	return nfsd_return_attrs(nfserr, resp);
>>> }
>>>=20
>>> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
>>> index 79b6064..db24ae8 100644
>>> --- a/fs/nfsd/nfsxdr.c
>>> +++ b/fs/nfsd/nfsxdr.c
>>> @@ -287,7 +287,6 @@ __be32 *nfs2svc_encode_fattr(struct svc_rqst =
*rqstp, __be32 *p, struct svc_fh *f
>>> 	struct nfsd_writeargs *args =3D rqstp->rq_argp;
>>> 	unsigned int len, hdr, dlen;
>>> 	struct kvec *head =3D rqstp->rq_arg.head;
>>> -	int v;
>>>=20
>>> 	p =3D decode_fh(p, &args->fh);
>>> 	if (!p)
>>> @@ -323,17 +322,8 @@ __be32 *nfs2svc_encode_fattr(struct svc_rqst =
*rqstp, __be32 *p, struct svc_fh *f
>>> 	if (dlen < XDR_QUADLEN(len)*4)
>>> 		return 0;
>>>=20
>>> -	rqstp->rq_vec[0].iov_base =3D (void*)p;
>>> -	rqstp->rq_vec[0].iov_len =3D head->iov_len - hdr;
>>> -	v =3D 0;
>>> -	while (len > rqstp->rq_vec[v].iov_len) {
>>> -		len -=3D rqstp->rq_vec[v].iov_len;
>>> -		v++;
>>> -		rqstp->rq_vec[v].iov_base =3D =
page_address(rqstp->rq_pages[v]);
>>> -		rqstp->rq_vec[v].iov_len =3D PAGE_SIZE;
>>> -	}
>>> -	rqstp->rq_vec[v].iov_len =3D len;
>>> -	args->vlen =3D v + 1;
>>> +	args->first.iov_base =3D (void *)p;
>>> +	args->first.iov_len =3D head->iov_len - hdr;
>>> 	return 1;
>>> }
>>>=20
>>> diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
>>> index 2f4f22e..a765c41 100644
>>> --- a/fs/nfsd/xdr.h
>>> +++ b/fs/nfsd/xdr.h
>>> @@ -34,7 +34,7 @@ struct nfsd_writeargs {
>>> 	svc_fh			fh;
>>> 	__u32			offset;
>>> 	int			len;
>>> -	int			vlen;
>>> +	struct kvec		first;
>>> };
>>>=20
>>> struct nfsd_createargs {
>>> diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
>>> index 056bf8a..deccf7f 100644
>>> --- a/fs/nfsd/xdr3.h
>>> +++ b/fs/nfsd/xdr3.h
>>> @@ -41,7 +41,7 @@ struct nfsd3_writeargs {
>>> 	__u32			count;
>>> 	int			stable;
>>> 	__u32			len;
>>> -	int			vlen;
>>> +	struct kvec		first;
>>> };
>>>=20
>>> struct nfsd3_createargs {
>>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>>> index bc29511..d56219d 100644
>>> --- a/fs/nfsd/xdr4.h
>>> +++ b/fs/nfsd/xdr4.h
>>> @@ -390,7 +390,6 @@ struct nfsd4_write {
>>> 	u32		wr_stable_how;      /* request */
>>> 	u32		wr_buflen;          /* request */
>>> 	struct kvec	wr_head;
>>> -	struct page **	wr_pagelist;        /* request */
>>>=20
>>> 	u32		wr_bytes_written;   /* response */
>>> 	u32		wr_how_written;     /* response */
>>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>>> index 1939709..6dc7879 100644
>>> --- a/include/linux/sunrpc/svc.h
>>> +++ b/include/linux/sunrpc/svc.h
>>> @@ -494,6 +494,8 @@ int		   svc_register(const struct =
svc_serv *, struct net *, const int,
>>> void		   svc_reserve(struct svc_rqst *rqstp, int =
space);
>>> struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
>>> char *		   svc_print_addr(struct svc_rqst *, char *, =
size_t);
>>> +unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
>>> +					 struct kvec *first, size_t =
total);
>>>=20
>>> #define	RPC_MAX_ADDRBUFLEN	(63U)
>>>=20
>>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>>> index f19987f..a155e2d 100644
>>> --- a/net/sunrpc/svc.c
>>> +++ b/net/sunrpc/svc.c
>>> @@ -1533,3 +1533,45 @@ u32 svc_max_payload(const struct svc_rqst =
*rqstp)
>>> 	return max;
>>> }
>>> EXPORT_SYMBOL_GPL(svc_max_payload);
>>> +
>>> +/**
>>> + * svc_fill_write_vector - Construct data argument for VFS write =
call
>>> + * @rqstp: svc_rqst to operate on
>>> + * @first: buffer containing first section of write payload
>>> + * @total: total number of bytes of write payload
>>> + *
>>> + * Returns the number of elements populated in the data argument =
array.
>>> + */
>>> +unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct =
kvec *first,
>>> +				   size_t total)
>>> +{
>>> +	struct kvec *vec =3D rqstp->rq_vec;
>>> +	struct page **pages;
>>> +	unsigned int i;
>>> +
>>> +	/* Some types of transport can present the write payload
>>> +	 * entirely in rq_arg.pages. In this case, @first is empty.
>>> +	 */
>>> +	i =3D 0;
>>> +	if (first->iov_len) {
>>> +		vec[i].iov_base =3D first->iov_base;
>>> +		vec[i].iov_len =3D min_t(size_t, total, first->iov_len);
>>> +		total -=3D vec[i].iov_len;
>>> +		++i;
>>> +	}
>>> +
>>> +	WARN_ON_ONCE(rqstp->rq_arg.page_base !=3D 0);
>>> +	pages =3D rqstp->rq_arg.pages;
>>> +	while (total) {
>>> +		vec[i].iov_base =3D page_address(*pages);
>>> +		vec[i].iov_len =3D min_t(size_t, total, PAGE_SIZE);
>>> +		total -=3D vec[i].iov_len;
>>> +		++i;
>>> +
>>> +		++pages;
>>> +	}
>>> +
>>> +	WARN_ON_ONCE(i > ARRAY_SIZE(rqstp->rq_vec));
>>> +	return i;
>>> +}
>>> +EXPORT_SYMBOL_GPL(svc_fill_write_vector);
>=20
> --
> Chuck Lever
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



