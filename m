Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23015 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104Ab1BWQtG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 11:49:06 -0500
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
Date: Wed, 23 Feb 2011 08:48:51 -0800
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <EEB9D74B-D547-4C43-AC8B-B8B58EBD9A54@oracle.com>
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 22, 2011, at 2:43 PM, Benny Halevy wrote:

> Fix bug introduced in patch
> 85a56480 NFSD: Update XDR decoders in NFSv4 callback client
> 
> Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
> it must account for their space in their xdr stream when calling xdr_inline_decode

The real problem is that decoding for the next operation in the compound will start too early in the buffer, because we didn't account for the ignored 8 bytes here, yes?

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> fs/nfsd/nfs4callback.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index da54498..d046bdb 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -592,7 +592,7 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
> 	 * If the server returns different values for sessionID, slotID or
> 	 * sequence number, the server is looney tunes.
> 	 */
> -	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4);
> +	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4 + 4 + 4);
> 	if (unlikely(p == NULL))
> 		goto out_overflow;
> 	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
> -- 
> 1.7.3.4
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



