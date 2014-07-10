Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38274 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbaGJSTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 14:19:45 -0400
Date: Thu, 10 Jul 2014 14:19:44 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: swise@ogc.net, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH 2/2] svcrdma: Remove extra writeargs sanity check for
 NFSv2/3
Message-ID: <20140710181944.GB26561@fieldses.org>
References: <20140710174225.3734.44692.stgit@klimt.1015granger.net>
 <20140710174435.3734.69638.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710174435.3734.69638.stgit@klimt.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 01:44:35PM -0400, Chuck Lever wrote:
> The server should comply with RFC 5667,

Where's the relevant language?  (I took a quick look but didn't see it.)

> and handle WRITE payloads
> that may not have a zero pad on the end (XDR length round-up).
> 
> Fixes: f34b9568 (The NFSv2/NFSv3 server does not handle zero...)
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=246
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfs3xdr.c |   15 +--------------
>  fs/nfsd/nfsxdr.c  |   16 +---------------
>  2 files changed, 2 insertions(+), 29 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index e6c01e8..6074f6a 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -361,7 +361,7 @@ int
>  nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
>  					struct nfsd3_writeargs *args)
>  {
> -	unsigned int len, v, hdr, dlen;
> +	unsigned int len, v, hdr;
>  	u32 max_blocksize = svc_max_payload(rqstp);
>  
>  	p = decode_fh(p, &args->fh);
> @@ -383,19 +383,6 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
>  	 * bytes.
>  	 */
>  	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
> -	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
> -		- hdr;
> -	/*
> -	 * Round the length of the data which was specified up to
> -	 * the next multiple of XDR units and then compare that
> -	 * against the length which was actually received.
> -	 * Note that when RPCSEC/GSS (for example) is used, the
> -	 * data buffer can be padded so dlen might be larger
> -	 * than required.  It must never be smaller.
> -	 */
> -	if (dlen < XDR_QUADLEN(len)*4)
> -		return 0;
> -
>  	if (args->count > max_blocksize) {
>  		args->count = max_blocksize;
>  		len = args->len = max_blocksize;
And then:
}
        rqstp->rq_vec[0].iov_base = (void*)p;
        rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
        v = 0;
        while (len > rqstp->rq_vec[v].iov_len) {
                len -= rqstp->rq_vec[v].iov_len;
                v++;
                rqstp->rq_vec[v].iov_base = page_address(rqstp->rq_pages[v]);
                rqstp->rq_vec[v].iov_len = PAGE_SIZE;
        }
        rqstp->rq_vec[v].iov_len = len;
        args->vlen = v + 1;
        return 1;

So if len is allowed to be larger than the available space, then the rq_vec
will get filled with data beyond the end of the client's request.

I believe the max_blocksize check will at least ensure that rq_pages[v]
is always still a valid page, so we shouldn't crash.  But it could
contain random data, and writing that data to a file could disclose
information we don't mean to.

Am I missing something?  The v2 case looks similar.

So I think you just want to drop the round-up of len, not the whole
check.

--b.


> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index 1ac306b..1f5347e 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -280,7 +280,7 @@ int
>  nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
>  					struct nfsd_writeargs *args)
>  {
> -	unsigned int len, hdr, dlen;
> +	unsigned int len, hdr;
>  	int v;
>  
>  	p = decode_fh(p, &args->fh);
> @@ -302,20 +302,6 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
>  	 * bytes.
>  	 */
>  	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
> -	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
> -		- hdr;
> -
> -	/*
> -	 * Round the length of the data which was specified up to
> -	 * the next multiple of XDR units and then compare that
> -	 * against the length which was actually received.
> -	 * Note that when RPCSEC/GSS (for example) is used, the
> -	 * data buffer can be padded so dlen might be larger
> -	 * than required.  It must never be smaller.
> -	 */
> -	if (dlen < XDR_QUADLEN(len)*4)
> -		return 0;
> -
>  	rqstp->rq_vec[0].iov_base = (void*)p;
>  	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
>  	v = 0;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
:set 

> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index 1ac306b..1f5347e 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -280,7 +280,7 @@ int
>  nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
>  					struct nfsd_writeargs *args)
>  {
> -	unsigned int len, hdr, dlen;
> +	unsigned int len, hdr;
>  	int v;
>  
>  	p = decode_fh(p, &args->fh);
> @@ -302,20 +302,6 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
>  	 * bytes.
>  	 */
>  	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
> -	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
> -		- hdr;
> -
> -	/*
> -	 * Round the length of the data which was specified up to
> -	 * the next multiple of XDR units and then compare that
> -	 * against the length which was actually received.
> -	 * Note that when RPCSEC/GSS (for example) is used, the
> -	 * data buffer can be padded so dlen might be larger
> -	 * than required.  It must never be smaller.
> -	 */
> -	if (dlen < XDR_QUADLEN(len)*4)
> -		return 0;
> -
>  	rqstp->rq_vec[0].iov_base = (void*)p;
>  	rqstp->rq_vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
>  	v = 0;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
