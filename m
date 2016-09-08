Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:62451 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751302AbcIHRjY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Sep 2016 13:39:24 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH 1/9] nfs: the length argument to read_buf should be
 unsigned
To: Jeff Layton <jlayton@redhat.com>, <trond.myklebust@primarydata.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
 <1473174760-29859-2-git-send-email-jlayton@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Message-ID: <ed805f06-e8e4-4e96-6d4d-0d374437ed7f@Netapp.com>
Date: Thu, 8 Sep 2016 13:39:20 -0400
MIME-Version: 1.0
In-Reply-To: <1473174760-29859-2-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On 09/06/2016 11:12 AM, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/callback_xdr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 656f68f7fe53..d6a40c06ec26 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -72,7 +72,7 @@ static int nfs4_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
>  	return xdr_ressize_check(rqstp, p);
>  }
>  
> -static __be32 *read_buf(struct xdr_stream *xdr, int nbytes)
> +static __be32 *read_buf(struct xdr_stream *xdr, unsigned int nbytes)

Looks like the nbytes argument is only used by xdr_inline_decode(), which expects a size_t instead of an unsigned int.  If we're changing argument types, then maybe we should change it to a size_t instead.

Thoughts?
Anna

>  {
>  	__be32 *p;
>  
> 

