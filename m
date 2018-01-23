Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:56044 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751293AbeAWBJo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jan 2018 20:09:44 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v2 3/3] NFSD: Clean up symlink argument XDR decoders
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180122220004.GB16585@fieldses.org>
Date: Mon, 22 Jan 2018 17:09:35 -0800
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E0C9EADF-504F-4CCF-933E-07CD6AE041DE@oracle.com>
References: <20180103203849.7074.9609.stgit@klimt.1015granger.net>
 <20180103204235.7074.64787.stgit@klimt.1015granger.net>
 <20180122220004.GB16585@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 22, 2018, at 2:00 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Wed, Jan 03, 2018 at 03:42:35PM -0500, Chuck Lever wrote:
>> Move common code in NFSD's symlink arg decoders into a helper. The
>> immediate benefits include:
>>=20
>> - one fewer data copies on transports that support DDP
>> - no memory allocation in the NFSv4 XDR decoder
>> - consistent error checking across all versions
>> - reduction of code duplication
>> - support for both legal forms of SYMLINK requests on RDMA
>>   transports for all versions of NFS (in particular, NFSv2, for
>>   completeness)
>>=20
>> In the long term, this helper is an appropriate spot to perform a
>> per-transport call-out to fill the pathname argument using, say,
>> RDMA Reads.
>>=20
>> Filling the pathname in the proc function also means that eventually
>> the incoming filehandle can be interpreted so that filesystem-
>> specific memory can be allocated as a sink for the pathname
>> argument, rather than using anonymous pages.
>>=20
>> Wondering why the current code punts a zero-length SYMLINK. Is it
>> illegal to create a zero-length SYMLINK on Linux?
>=20
> SYMLINK(2) says
>=20
> 	ENOENT A directory component in linkpath does not exist or is a
> 	dangling symbolic link, or target or linkpath is an empty
> 	string.
>=20
> That doesn't explain the INVAL, or why this is the right place to be
> checking it.

RFC 1813:

NFS3ERR_IO
      NFS3ERR_ACCES
      NFS3ERR_EXIST
      NFS3ERR_NOTDIR
      NFS3ERR_NOSPC
      NFS3ERR_ROFS
      NFS3ERR_NAMETOOLONG
      NFS3ERR_DQUOT
      NFS3ERR_STALE
      NFS3ERR_BADHANDLE
      NFS3ERR_NOTSUPP
      NFS3ERR_SERVERFAULT

Interestingly, neither INVAL nor NOENT are valid
status codes for NFSv3 SYMLINK. NFS3ERR_NOTSUPP
might be closest, I suppose.

RFC 5661 says explicitly:
=20
If the objname has a length of zero, or if objname does not obey the
UTF-8 definition, the error NFS4ERR_INVAL will be returned.

And lists these as valid status codes for CREATE(NF4LNK):
=20
| NFS4ERR_ACCESS, NFS4ERR_ATTRNOTSUPP,       |
| NFS4ERR_BADCHAR, NFS4ERR_BADNAME,          |
| NFS4ERR_BADOWNER, NFS4ERR_BADTYPE,         |
| NFS4ERR_BADXDR, NFS4ERR_DEADSESSION,       |
| NFS4ERR_DELAY, NFS4ERR_DQUOT,              |
| NFS4ERR_EXIST, NFS4ERR_FHEXPIRED,          |
| NFS4ERR_INVAL, NFS4ERR_IO, NFS4ERR_MLINK,  |
| NFS4ERR_MOVED, NFS4ERR_NAMETOOLONG,        |
| NFS4ERR_NOFILEHANDLE, NFS4ERR_NOSPC,       |
| NFS4ERR_NOTDIR, NFS4ERR_OP_NOT_IN_SESSION, |
| NFS4ERR_PERM, NFS4ERR_REP_TOO_BIG,         |
| NFS4ERR_REP_TOO_BIG_TO_CACHE,              |
| NFS4ERR_REQ_TOO_BIG,                       |
| NFS4ERR_RETRY_UNCACHED_REP, NFS4ERR_ROFS,  |
| NFS4ERR_SERVERFAULT, NFS4ERR_STALE,        |
| NFS4ERR_TOO_MANY_OPS,                      |
| NFS4ERR_UNSAFE_COMPOUND                    |


> I'm a little nervous about the NULL termination in
> svc_fill_symlink_pathname; how do we know it's safe to write a zero
> there?  I haven't checked it carefully yet.

svc_fill_symlink_pathname grabs a whole fresh page
from @rqstp. It is safe to write bytes anywhere in
that page.


> --g.
>=20
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfsd/nfs3proc.c         |   10 +++++++
>> fs/nfsd/nfs3xdr.c          |   51 ++++++++-------------------------
>> fs/nfsd/nfs4proc.c         |    7 +++++
>> fs/nfsd/nfs4xdr.c          |   10 +++++--
>> fs/nfsd/nfsproc.c          |   14 +++++----
>> fs/nfsd/nfsxdr.c           |   49 +++++++++++++++++++-------------
>> fs/nfsd/xdr.h              |    1 +
>> fs/nfsd/xdr3.h             |    1 +
>> fs/nfsd/xdr4.h             |    2 +
>> include/linux/sunrpc/svc.h |    2 +
>> net/sunrpc/svc.c           |   67 =
++++++++++++++++++++++++++++++++++++++++++++
>> 11 files changed, 146 insertions(+), 68 deletions(-)
>>=20
>> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>> index 2dd95eb..6259a4b 100644
>> --- a/fs/nfsd/nfs3proc.c
>> +++ b/fs/nfsd/nfs3proc.c
>> @@ -283,6 +283,16 @@
>> 	struct nfsd3_diropres *resp =3D rqstp->rq_resp;
>> 	__be32	nfserr;
>>=20
>> +	if (argp->tlen =3D=3D 0)
>> +		RETURN_STATUS(nfserr_inval);
>> +	if (argp->tlen > NFS3_MAXPATHLEN)
>> +		RETURN_STATUS(nfserr_nametoolong);
>> +
>> +	argp->tname =3D svc_fill_symlink_pathname(rqstp, &argp->first,
>> +						argp->tlen);
>> +	if (IS_ERR(argp->tname))
>> +		RETURN_STATUS(nfserrno(PTR_ERR(argp->tname)));
>> +
>> 	dprintk("nfsd: SYMLINK(3)  %s %.*s -> %.*s\n",
>> 				SVCFH_fmt(&argp->ffh),
>> 				argp->flen, argp->fname,
>> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
>> index 240cdb0e..78b555b 100644
>> --- a/fs/nfsd/nfs3xdr.c
>> +++ b/fs/nfsd/nfs3xdr.c
>> @@ -452,51 +452,24 @@ void fill_post_wcc(struct svc_fh *fhp)
>> nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
>> {
>> 	struct nfsd3_symlinkargs *args =3D rqstp->rq_argp;
>> -	unsigned int len, avail;
>> -	char *old, *new;
>> -	struct kvec *vec;
>> +	char *base =3D (char *)p;
>> +	size_t dlen;
>>=20
>> 	if (!(p =3D decode_fh(p, &args->ffh)) ||
>> -	    !(p =3D decode_filename(p, &args->fname, &args->flen))
>> -		)
>> +	    !(p =3D decode_filename(p, &args->fname, &args->flen)))
>> 		return 0;
>> 	p =3D decode_sattr3(p, &args->attrs);
>>=20
>> -	/* now decode the pathname, which might be larger than the first =
page.
>> -	 * As we have to check for nul's anyway, we copy it into a new =
page
>> -	 * This page appears in the rq_res.pages list, but as pages_len =
is always
>> -	 * 0, it won't get in the way
>> -	 */
>> -	len =3D ntohl(*p++);
>> -	if (len =3D=3D 0 || len > NFS3_MAXPATHLEN || len >=3D PAGE_SIZE)
>> -		return 0;
>> -	args->tname =3D new =3D page_address(*(rqstp->rq_next_page++));
>> -	args->tlen =3D len;
>> -	/* first copy and check from the first page */
>> -	old =3D (char*)p;
>> -	vec =3D &rqstp->rq_arg.head[0];
>> -	if ((void *)old > vec->iov_base + vec->iov_len)
>> -		return 0;
>> -	avail =3D vec->iov_len - (old - (char*)vec->iov_base);
>> -	while (len && avail && *old) {
>> -		*new++ =3D *old++;
>> -		len--;
>> -		avail--;
>> -	}
>> -	/* now copy next page if there is one */
>> -	if (len && !avail && rqstp->rq_arg.page_len) {
>> -		avail =3D min_t(unsigned int, rqstp->rq_arg.page_len, =
PAGE_SIZE);
>> -		old =3D page_address(rqstp->rq_arg.pages[0]);
>> -	}
>> -	while (len && avail && *old) {
>> -		*new++ =3D *old++;
>> -		len--;
>> -		avail--;
>> -	}
>> -	*new =3D '\0';
>> -	if (len)
>> -		return 0;
>> +	args->tlen =3D ntohl(*p++);
>>=20
>> +	args->first.iov_base =3D p;
>> +	args->first.iov_len =3D rqstp->rq_arg.head[0].iov_len;
>> +	args->first.iov_len -=3D (char *)p - base;
>> +
>> +	dlen =3D args->first.iov_len + rqstp->rq_arg.page_len +
>> +	       rqstp->rq_arg.tail[0].iov_len;
>> +	if (dlen < XDR_QUADLEN(args->tlen) << 2)
>> +		return 0;
>> 	return 1;
>> }
>>=20
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 5029b96..36bd1f7 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -605,6 +605,13 @@ static void gen_boot_verifier(nfs4_verifier =
*verifier, struct net *net)
>>=20
>> 	switch (create->cr_type) {
>> 	case NF4LNK:
>> +		if (create->cr_datalen > NFS4_MAXPATHLEN)
>> +			return nfserr_nametoolong;
>> +		create->cr_data =3D
>> +			svc_fill_symlink_pathname(rqstp, =
&create->cr_first,
>> +						  create->cr_datalen);
>> +		if (IS_ERR(create->cr_data))
>> +			return nfserrno(PTR_ERR(create->cr_data));
>> 		status =3D nfsd_symlink(rqstp, &cstate->current_fh,
>> 				      create->cr_name, =
create->cr_namelen,
>> 				      create->cr_data, &resfh);
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index bd25230..d05384e 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -648,6 +648,7 @@ static __be32 =
nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
>> static __be32
>> nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct =
nfsd4_create *create)
>> {
>> +	struct kvec *head;
>> 	DECODE_HEAD;
>>=20
>> 	READ_BUF(4);
>> @@ -656,10 +657,13 @@ static __be32 =
nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
>> 	case NF4LNK:
>> 		READ_BUF(4);
>> 		create->cr_datalen =3D be32_to_cpup(p++);
>> +		if (create->cr_datalen =3D=3D 0)
>> +			return nfserr_inval;
>> +		head =3D argp->rqstp->rq_arg.head;
>> +		create->cr_first.iov_base =3D p;
>> +		create->cr_first.iov_len =3D head->iov_len;
>> +		create->cr_first.iov_len -=3D (char *)p - (char =
*)head->iov_base;
>> 		READ_BUF(create->cr_datalen);
>> -		create->cr_data =3D svcxdr_dupstr(argp, p, =
create->cr_datalen);
>> -		if (!create->cr_data)
>> -			return nfserr_jukebox;
>> 		break;
>> 	case NF4BLK:
>> 	case NF4CHR:
>> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
>> index 1995ea6..f107f9f 100644
>> --- a/fs/nfsd/nfsproc.c
>> +++ b/fs/nfsd/nfsproc.c
>> @@ -449,17 +449,19 @@
>> 	struct svc_fh	newfh;
>> 	__be32		nfserr;
>>=20
>> +	if (argp->tlen > NFS_MAXPATHLEN)
>> +		return nfserr_nametoolong;
>> +
>> +	argp->tname =3D svc_fill_symlink_pathname(rqstp, &argp->first,
>> +						argp->tlen);
>> +	if (IS_ERR(argp->tname))
>> +		return nfserrno(PTR_ERR(argp->tname));
>> +
>> 	dprintk("nfsd: SYMLINK  %s %.*s -> %.*s\n",
>> 		SVCFH_fmt(&argp->ffh), argp->flen, argp->fname,
>> 		argp->tlen, argp->tname);
>>=20
>> 	fh_init(&newfh, NFS_FHSIZE);
>> -	/*
>> -	 * Crazy hack: the request fits in a page, and already-decoded
>> -	 * attributes follow argp->tname, so it's safe to just write a
>> -	 * null to ensure it's null-terminated:
>> -	 */
>> -	argp->tname[argp->tlen] =3D '\0';
>> 	nfserr =3D nfsd_symlink(rqstp, &argp->ffh, argp->fname, =
argp->flen,
>> 						 argp->tname, &newfh);
>>=20
>> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
>> index 165e25e..8fcd047 100644
>> --- a/fs/nfsd/nfsxdr.c
>> +++ b/fs/nfsd/nfsxdr.c
>> @@ -71,22 +71,6 @@ __be32 *nfs2svc_decode_fh(__be32 *p, struct svc_fh =
*fhp)
>> }
>>=20
>> static __be32 *
>> -decode_pathname(__be32 *p, char **namp, unsigned int *lenp)
>> -{
>> -	char		*name;
>> -	unsigned int	i;
>> -
>> -	if ((p =3D xdr_decode_string_inplace(p, namp, lenp, =
NFS_MAXPATHLEN)) !=3D NULL) {
>> -		for (i =3D 0, name =3D *namp; i < *lenp; i++, name++) {
>> -			if (*name =3D=3D '\0')
>> -				return NULL;
>> -		}
>> -	}
>> -
>> -	return p;
>> -}
>> -
>> -static __be32 *
>> decode_sattr(__be32 *p, struct iattr *iap)
>> {
>> 	u32	tmp, tmp1;
>> @@ -383,14 +367,39 @@ __be32 *nfs2svc_encode_fattr(struct svc_rqst =
*rqstp, __be32 *p, struct svc_fh *f
>> nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p)
>> {
>> 	struct nfsd_symlinkargs *args =3D rqstp->rq_argp;
>> +	char *base =3D (char *)p;
>> +	size_t xdrlen;
>>=20
>> 	if (   !(p =3D decode_fh(p, &args->ffh))
>> -	    || !(p =3D decode_filename(p, &args->fname, &args->flen))
>> -	    || !(p =3D decode_pathname(p, &args->tname, &args->tlen)))
>> +	    || !(p =3D decode_filename(p, &args->fname, &args->flen)))
>> 		return 0;
>> -	p =3D decode_sattr(p, &args->attrs);
>>=20
>> -	return xdr_argsize_check(rqstp, p);
>> +	args->tlen =3D ntohl(*p++);
>> +	if (args->tlen =3D=3D 0)
>> +		return 0;
>> +
>> +	args->first.iov_base =3D p;
>> +	args->first.iov_len =3D rqstp->rq_arg.head[0].iov_len;
>> +	args->first.iov_len -=3D (char *)p - base;
>> +
>> +	/* This request is never larger than a page. Therefore,
>> +	 * transport will deliver either:
>> +	 * 1. pathname in the pagelist -> sattr is in the tail.
>> +	 * 2. everything in the head buffer -> sattr is in the head.
>> +	 */
>> +	if (rqstp->rq_arg.page_len) {
>> +		if (args->tlen !=3D rqstp->rq_arg.page_len)
>> +			return 0;
>> +		p =3D rqstp->rq_arg.tail[0].iov_base;
>> +	} else {
>> +		xdrlen =3D XDR_QUADLEN(args->tlen);
>> +		if (xdrlen > args->first.iov_len - (8 * sizeof(__be32)))
>> +			return 0;
>> +		p +=3D xdrlen;
>> +	}
>> +	decode_sattr(p, &args->attrs);
>> +
>> +	return 1;
>> }
>>=20
>> int
>> diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
>> index a765c41..ea7cca3 100644
>> --- a/fs/nfsd/xdr.h
>> +++ b/fs/nfsd/xdr.h
>> @@ -72,6 +72,7 @@ struct nfsd_symlinkargs {
>> 	char *			tname;
>> 	unsigned int		tlen;
>> 	struct iattr		attrs;
>> +	struct kvec		first;
>> };
>>=20
>> struct nfsd_readdirargs {
>> diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
>> index deccf7f..2cb29e9 100644
>> --- a/fs/nfsd/xdr3.h
>> +++ b/fs/nfsd/xdr3.h
>> @@ -90,6 +90,7 @@ struct nfsd3_symlinkargs {
>> 	char *			tname;
>> 	unsigned int		tlen;
>> 	struct iattr		attrs;
>> +	struct kvec		first;
>> };
>>=20
>> struct nfsd3_readdirargs {
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index d56219d..b485cd1 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -110,6 +110,7 @@ struct nfsd4_create {
>> 		struct {
>> 			u32 datalen;
>> 			char *data;
>> +			struct kvec first;
>> 		} link;   /* NF4LNK */
>> 		struct {
>> 			u32 specdata1;
>> @@ -124,6 +125,7 @@ struct nfsd4_create {
>> };
>> #define cr_datalen	u.link.datalen
>> #define cr_data		u.link.data
>> +#define cr_first	u.link.first
>> #define cr_specdata1	u.dev.specdata1
>> #define cr_specdata2	u.dev.specdata2
>>=20
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 238b9ae..fd5846e 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -495,6 +495,8 @@ int		   svc_register(const struct =
svc_serv *, struct net *, const int,
>> char *		   svc_print_addr(struct svc_rqst *, char *, =
size_t);
>> unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
>> 					 struct kvec *first, size_t =
total);
>> +char		  *svc_fill_symlink_pathname(struct svc_rqst =
*rqstp,
>> +					     struct kvec *first, size_t =
total);
>>=20
>> #define	RPC_MAX_ADDRBUFLEN	(63U)
>>=20
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 759b668..fc93406 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -1578,3 +1578,70 @@ unsigned int svc_fill_write_vector(struct =
svc_rqst *rqstp, struct kvec *first,
>> 	return i;
>> }
>> EXPORT_SYMBOL_GPL(svc_fill_write_vector);
>> +
>> +/**
>> + * svc_fill_symlink_pathname - Construct pathname argument for VFS =
symlink call
>> + * @rqstp: svc_rqst to operate on
>> + * @first: buffer containing first section of pathname
>> + * @total: total length of the pathname argument
>> + *
>> + * Returns pointer to a NUL-terminated string, or an ERR_PTR. The =
buffer is
>> + * released automatically when @rqstp is recycled.
>> + */
>> +char *svc_fill_symlink_pathname(struct svc_rqst *rqstp, struct kvec =
*first,
>> +				size_t total)
>> +{
>> +	struct xdr_buf *arg =3D &rqstp->rq_arg;
>> +	struct page **pages;
>> +	char *result;
>> +
>> +	/* VFS API demands a NUL-terminated pathname. This function
>> +	 * uses a page from @rqstp as the pathname buffer, to enable
>> +	 * direct placement. Thus the total buffer size is PAGE_SIZE.
>> +	 * Space in this buffer for NUL-termination requires that we
>> +	 * cap the size of the returned symlink pathname just a
>> +	 * little early.
>> +	 */
>> +	if (total > PAGE_SIZE - 1)
>> +		return ERR_PTR(-ENAMETOOLONG);
>> +
>> +	/* Some types of transport can present the pathname entirely
>> +	 * in rq_arg.pages. If not, then copy the pathname into one
>> +	 * page.
>> +	 */
>> +	pages =3D arg->pages;
>> +	WARN_ON_ONCE(arg->page_base !=3D 0);
>> +	if (first->iov_base =3D=3D 0) {
>> +		result =3D page_address(*pages);
>> +		result[total] =3D '\0';
>> +	} else {
>> +		size_t len, remaining;
>> +		char *dst;
>> +
>> +		result =3D page_address(*(rqstp->rq_next_page++));
>> +		dst =3D result;
>> +		remaining =3D total;
>> +
>> +		len =3D min_t(size_t, total, first->iov_len);
>> +		memcpy(dst, first->iov_base, len);
>> +		dst +=3D len;
>> +		remaining -=3D len;
>> +
>> +		/* No more than one page left */
>> +		if (remaining) {
>> +			len =3D min_t(size_t, remaining, PAGE_SIZE);
>> +			memcpy(dst, page_address(*pages), len);
>> +			dst +=3D len;
>> +		}
>> +
>> +		*dst =3D '\0';
>> +	}
>> +
>> +	/* Sanity check: we don't allow the pathname argument to
>> +	 * contain a NUL byte.
>> +	 */
>> +	if (strlen(result) !=3D total)
>> +		return ERR_PTR(-EINVAL);
>> +	return result;
>> +}
>> +EXPORT_SYMBOL_GPL(svc_fill_symlink_pathname);

--
Chuck Lever



