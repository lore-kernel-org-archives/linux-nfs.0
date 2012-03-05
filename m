Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:48979 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab2CEBIC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Mar 2012 20:08:02 -0500
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <8F1C4F4B-BC08-446A-99F9-34AB4722E365@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 04/11] NFSv4: Add a helper for encoding opaque data
Date: Sun, 4 Mar 2012 20:08:42 -0500
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Er.  This collides with a patch I sent earlier this week.

Sent from my iPad

On Mar 4, 2012, at 6:02 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/nfs4xdr.c |   14 +++++++++-----
> 1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index af11e8b..de4cb5c 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -885,6 +885,14 @@ static __be32 *reserve_space(struct xdr_stream *xdr, size_t nbytes)
>    return p;
> }
> 
> +static void encode_opaque_fixed(struct xdr_stream *xdr, const void *buf, size_t len)
> +{
> +    __be32 *p;
> +
> +    p = xdr_reserve_space(xdr, len);
> +    xdr_encode_opaque_fixed(p, buf, len);
> +}
> +
> static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
> {
>    __be32 *p;
> @@ -922,11 +930,7 @@ static void encode_nops(struct compound_hdr *hdr)
> 
> static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
> {
> -    __be32 *p;
> -
> -    p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
> -    BUG_ON(p == NULL);
> -    xdr_encode_opaque_fixed(p, verf->data, NFS4_VERIFIER_SIZE);
> +    encode_opaque_fixed(xdr, verf->data, NFS4_VERIFIER_SIZE);
> }
> 
> static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs_server *server)
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
