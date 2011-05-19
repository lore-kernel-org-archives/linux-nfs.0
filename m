Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58513 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753210Ab1ESAvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 20:51:52 -0400
Date: Wed, 18 May 2011 20:51:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd41: error out when client sets maxreq_sz or
 maxresp_sz too small
Message-ID: <20110519005151.GD26545@fieldses.org>
References: <4DD32B1B.8090709@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DD32B1B.8090709@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 18, 2011 at 10:12:43AM +0800, Mi Jinlong wrote:
> According to RFC5661, 18.36.3, 
> 
>  "if the client selects a value for ca_maxresponsesize such that
>   a replier on a channel could never send a response,the server
>   SHOULD return NFS4ERR_TOOSMALL in the CREATE_SESSION reply."
> 
> This patch let server error out when client sets maxreq_sz less than
> SEQUENCE request size, and maxresp_sz less than a SEQUENCE reply size.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4xdr.c |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c6766af..8983d03 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -131,6 +131,14 @@ xdr_error:					\
>  	}					\
>  } while (0)
>  
> +#define op_decode_hdr_size	(1)
> +#define op_encode_hdr_size	(2)
> +
> +#define decode_sequence_size	(op_decode_hdr_size + \
> +				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 4)
> +#define encode_sequence_size	(op_encode_hdr_size + \
> +				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
> +

>From the description of ca_maxrequestsize on p. 515:

	"This size represents the XDR encoded size of the request,
	including the RPC headers (including security flavor credentials
	and verifiers) but excludes any RPC transport framing headers."

There's no way to know how big the verifier and credential will be, but
for the purposes of this function I guess we could assume they're both 2
u32's (flavor + zero length).

Looks fine to me otherwise.

I assume you checked these are the ops that give the shortest possible
request and response.

--b.

>  static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  {
>  	/* We want more bytes than seem to be available.
> @@ -1154,7 +1162,17 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  	READ_BUF(28);
>  	READ32(dummy); /* headerpadsz is always 0 */
>  	READ32(sess->fore_channel.maxreq_sz);
> +	if (sess->fore_channel.maxreq_sz < decode_sequence_size) {
> +		status = nfserr_toosmall;
> +		goto out;
> +	}
> +
>  	READ32(sess->fore_channel.maxresp_sz);
> +	if (sess->fore_channel.maxresp_sz < encode_sequence_size) {
> +		status = nfserr_toosmall;
> +		goto out;
> +	}
> +
>  	READ32(sess->fore_channel.maxresp_cached);
>  	READ32(sess->fore_channel.maxops);
>  	READ32(sess->fore_channel.maxreqs);
> -- 
> 1.7.4.5
> 
> 
> 
