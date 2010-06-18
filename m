From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/2] pnfs-post-submit: Revert "pnfs-submit: Remove unused
 encode_getattr_three code"
Date: Fri, 18 Jun 2010 17:19:22 -0400
Message-ID: <4C1BE2DA.5020206@panasas.com>
References: <1276736809-9423-1-git-send-email-iisaman@netapp.com> <1276736809-9423-2-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:63135 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003Ab0FRVTQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 17:19:16 -0400
Received: by qyk1 with SMTP id 1so199306qyk.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 14:19:15 -0700 (PDT)
In-Reply-To: <1276736809-9423-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yeah.  This actually belongs to the pnfs-block branch.
I'll move it there.

Benny

On Jun. 16, 2010, 21:06 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> ---
>  fs/nfs/nfs4xdr.c |   29 +++++++++++++++++++++++++++++
>  1 files changed, 29 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 9ef0f0a..c0bdb60 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1060,6 +1060,35 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
>  	hdr->replen += decode_getattr_maxsz;
>  }
>  
> +static void
> +encode_getattr_three(struct xdr_stream *xdr,
> +		     uint32_t bm0, uint32_t bm1, uint32_t bm2,
> +		     struct compound_hdr *hdr)
> +{
> +	__be32 *p;
> +
> +	p = reserve_space(xdr, 4);
> +	*p = cpu_to_be32(OP_GETATTR);
> +	if (bm2) {
> +		p = reserve_space(xdr, 16);
> +		*p++ = cpu_to_be32(3);
> +		*p++ = cpu_to_be32(bm0);
> +		*p++ = cpu_to_be32(bm1);
> +		*p = cpu_to_be32(bm2);
> +	} else if (bm1) {
> +		p = reserve_space(xdr, 12);
> +		*p++ = cpu_to_be32(2);
> +		*p++ = cpu_to_be32(bm0);
> +		*p = cpu_to_be32(bm1);
> +	} else {
> +		p = reserve_space(xdr, 8);
> +		*p++ = cpu_to_be32(1);
> +		*p = cpu_to_be32(bm0);
> +	}
> +	hdr->nops++;
> +	hdr->replen += decode_getattr_maxsz;
> +}
> +
>  static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
>  {
>  	encode_getattr_two(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
