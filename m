From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 05/10] NFS: Fix compiler warnings
	in	fs/nfs/callback_xdr.c
Date: Sat, 26 May 2007 14:20:43 -0400
Message-ID: <1180203643.5517.16.camel@heimdal.trondhjem.org>
References: <20070525214120.28668.92981.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hs0su-00040g-0d
	for nfs@lists.sourceforge.net; Sat, 26 May 2007 11:21:02 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hs0sw-0002MB-Pi
	for nfs@lists.sourceforge.net; Sat, 26 May 2007 11:21:02 -0700
In-Reply-To: <20070525214120.28668.92981.stgit@schiele.1015granger.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-25 at 17:41 -0400, Chuck Lever wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/callback_xdr.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 849a202..d664193 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -139,7 +139,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
>  	if (unlikely(status != 0))
>  		return status;
>  	/* We do not like overly long tags! */
> -	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ-12 || hdr->taglen < 0) {
> +	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
>  		printk("NFSv4 CALLBACK %s: client sent tag of length %u\n",
>  				__FUNCTION__, hdr->taglen);
>  		return htonl(NFS4ERR_RESOURCE);
> @@ -379,7 +379,7 @@ static __be32 process_op(struct svc_rqst *rqstp,
>  	}
>  
>  	maxlen = xdr_out->end - xdr_out->p;
> -	if (maxlen > 0 && maxlen < PAGE_SIZE) {
> +	if (maxlen > 0 && maxlen < (long) PAGE_SIZE) {
				     ^^^^^^ shouldn't be needed. We've just checked that maxlen > 0.
>  		if (likely(status == 0 && op->decode_args != NULL))
>  			status = op->decode_args(rqstp, xdr_in, argp);
>  		if (likely(status == 0 && op->process_op != NULL))
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
