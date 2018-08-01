Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:35190 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389344AbeHAQCx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 12:02:53 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 4/4] NFSD: Handle full-length symlinks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180801141406.GD16651@fieldses.org>
Date: Wed, 1 Aug 2018 10:16:52 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E69AF667-87AA-441D-9768-1F342FA59F50@oracle.com>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180727151910.21878.49021.stgit@klimt.1015granger.net>
 <20180801141406.GD16651@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 1, 2018, at 10:14 AM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Fri, Jul 27, 2018 at 11:19:10AM -0400, Chuck Lever wrote:
>> I've given up on the idea of zero-copy handling of SYMLINK on the
>> server side. This is because the Linux VFS symlink API requires the
>> symlink pathname to be in a NUL-terminated kmalloc'd buffer. The
>> NUL-termination is going to be problematic (watching out for
>> landing on a page boundary and dealing with a 4096-byte pathname).
>>=20
>> I don't believe that SYMLINK creation is on a performance path or is
>> requested frequently enough that it will cause noticeable CPU cache
>> pollution due to data copies.
>=20
> Sounds fine.
>=20
> The limits here are weird.  In the v2 case the maximum length is
> NFS_MAXPATHLEN =3D=3D 1024.  OK, I see, I guess that limit was imposed =
by
> the NFSv2 protocol.

Right.


> In the v3 case it's NFS3_MAXPATHLEN =3D=3D PATH_MAX =3D=3D
> 4096.  But we were imposing an artificial max of 4095 just so we could
> fit the result in one page with null termination.
>=20
> OK, makes sense to me (though I can't recall anyone actually =
complaining
> about that limit).

I haven't heard complaints either. I'm just trying to make this
code a little more sensible. :-)


> --b.
>=20
>=20
>>=20
>> There will be two places where a transport callout will be necessary
>> to fill in the rqstp: one will be in the svc_fill_symlink_pathname()
>> helper that is used by NFSv2 and NFSv3, and the other will be in
>> nfsd4_decode_create().
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfsd/nfs3proc.c         |    2 +
>> fs/nfsd/nfsproc.c          |    2 +
>> include/linux/sunrpc/svc.h |    3 +-
>> net/sunrpc/svc.c           |   67 =
++++++++++++++++----------------------------
>> 4 files changed, 31 insertions(+), 43 deletions(-)
>>=20
>> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>> index 8d1c2d1a..9eb8086 100644
>> --- a/fs/nfsd/nfs3proc.c
>> +++ b/fs/nfsd/nfs3proc.c
>> @@ -290,6 +290,7 @@
>> 		RETURN_STATUS(nfserr_nametoolong);
>>=20
>> 	argp->tname =3D svc_fill_symlink_pathname(rqstp, &argp->first,
>> +						=
page_address(rqstp->rq_arg.pages[0]),
>> 						argp->tlen);
>> 	if (IS_ERR(argp->tname))
>> 		RETURN_STATUS(nfserrno(PTR_ERR(argp->tname)));
>> @@ -303,6 +304,7 @@
>> 	fh_init(&resp->fh, NFS3_FHSIZE);
>> 	nfserr =3D nfsd_symlink(rqstp, &resp->dirfh, argp->fname, =
argp->flen,
>> 						   argp->tname, =
&resp->fh);
>> +	kfree(argp->tname);
>> 	RETURN_STATUS(nfserr);
>> }
>>=20
>> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
>> index a6faee5..0d20fd1 100644
>> --- a/fs/nfsd/nfsproc.c
>> +++ b/fs/nfsd/nfsproc.c
>> @@ -454,6 +454,7 @@
>> 		return nfserr_nametoolong;
>>=20
>> 	argp->tname =3D svc_fill_symlink_pathname(rqstp, &argp->first,
>> +						=
page_address(rqstp->rq_arg.pages[0]),
>> 						argp->tlen);
>> 	if (IS_ERR(argp->tname))
>> 		return nfserrno(PTR_ERR(argp->tname));
>> @@ -466,6 +467,7 @@
>> 	nfserr =3D nfsd_symlink(rqstp, &argp->ffh, argp->fname, =
argp->flen,
>> 						 argp->tname, &newfh);
>>=20
>> +	kfree(argp->tname);
>> 	fh_put(&argp->ffh);
>> 	fh_put(&newfh);
>> 	return nfserr;
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 43f88bd..73e130a 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -499,7 +499,8 @@ unsigned int	   svc_fill_write_vector(struct =
svc_rqst *rqstp,
>> 					 struct page **pages,
>> 					 struct kvec *first, size_t =
total);
>> char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
>> -					     struct kvec *first, size_t =
total);
>> +					     struct kvec *first, void =
*p,
>> +					     size_t total);
>>=20
>> #define	RPC_MAX_ADDRBUFLEN	(63U)
>>=20
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 2194ed5..d13e05f 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -1577,65 +1577,48 @@ unsigned int svc_fill_write_vector(struct =
svc_rqst *rqstp, struct page **pages,
>>  * svc_fill_symlink_pathname - Construct pathname argument for VFS =
symlink call
>>  * @rqstp: svc_rqst to operate on
>>  * @first: buffer containing first section of pathname
>> + * @p: buffer containing remaining section of pathname
>>  * @total: total length of the pathname argument
>>  *
>> - * Returns pointer to a NUL-terminated string, or an ERR_PTR. The =
buffer is
>> - * released automatically when @rqstp is recycled.
>> + * The VFS symlink API demands a NUL-terminated pathname in mapped =
memory.
>> + * Returns pointer to a NUL-terminated string, or an ERR_PTR. Caller =
must free
>> + * the returned string.
>>  */
>> char *svc_fill_symlink_pathname(struct svc_rqst *rqstp, struct kvec =
*first,
>> -				size_t total)
>> +				void *p, size_t total)
>> {
>> -	struct xdr_buf *arg =3D &rqstp->rq_arg;
>> -	struct page **pages;
>> -	char *result;
>> -
>> -	/* VFS API demands a NUL-terminated pathname. This function
>> -	 * uses a page from @rqstp as the pathname buffer, to enable
>> -	 * direct placement. Thus the total buffer size is PAGE_SIZE.
>> -	 * Space in this buffer for NUL-termination requires that we
>> -	 * cap the size of the returned symlink pathname just a
>> -	 * little early.
>> -	 */
>> -	if (total > PAGE_SIZE - 1)
>> -		return ERR_PTR(-ENAMETOOLONG);
>> +	size_t len, remaining;
>> +	char *result, *dst;
>>=20
>> -	/* Some types of transport can present the pathname entirely
>> -	 * in rq_arg.pages. If not, then copy the pathname into one
>> -	 * page.
>> -	 */
>> -	pages =3D arg->pages;
>> -	WARN_ON_ONCE(arg->page_base !=3D 0);
>> -	if (first->iov_base =3D=3D 0) {
>> -		result =3D page_address(*pages);
>> -		result[total] =3D '\0';
>> -	} else {
>> -		size_t len, remaining;
>> -		char *dst;
>> +	result =3D kmalloc(total + 1, GFP_KERNEL);
>> +	if (!result)
>> +		return ERR_PTR(-ESERVERFAULT);
>>=20
>> -		result =3D page_address(*(rqstp->rq_next_page++));
>> -		dst =3D result;
>> -		remaining =3D total;
>> +	dst =3D result;
>> +	remaining =3D total;
>>=20
>> -		len =3D min_t(size_t, total, first->iov_len);
>> +	len =3D min_t(size_t, total, first->iov_len);
>> +	if (len) {
>> 		memcpy(dst, first->iov_base, len);
>> 		dst +=3D len;
>> 		remaining -=3D len;
>> +	}
>>=20
>> -		/* No more than one page left */
>> -		if (remaining) {
>> -			len =3D min_t(size_t, remaining, PAGE_SIZE);
>> -			memcpy(dst, page_address(*pages), len);
>> -			dst +=3D len;
>> -		}
>> -
>> -		*dst =3D '\0';
>> +	if (remaining) {
>> +		len =3D min_t(size_t, remaining, PAGE_SIZE);
>> +		memcpy(dst, p, len);
>> +		dst +=3D len;
>> 	}
>>=20
>> -	/* Sanity check: we don't allow the pathname argument to
>> +	*dst =3D '\0';
>> +
>> +	/* Sanity check: Linux doesn't allow the pathname argument to
>> 	 * contain a NUL byte.
>> 	 */
>> -	if (strlen(result) !=3D total)
>> +	if (strlen(result) !=3D total) {
>> +		kfree(result);
>> 		return ERR_PTR(-EINVAL);
>> +	}
>> 	return result;
>> }
>> EXPORT_SYMBOL_GPL(svc_fill_symlink_pathname);

--
Chuck Lever



