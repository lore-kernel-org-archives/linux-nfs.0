Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754924Ab1BWAMO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Feb 2011 19:12:14 -0500
Date: Tue, 22 Feb 2011 16:11:01 -0800
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
Message-ID: <20110223001100.GC5543@pad.home.fieldses.org>
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1298414602-17029-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 22, 2011 at 02:43:22PM -0800, Benny Halevy wrote:
> Fix bug introduced in patch
> 85a56480 NFSD: Update XDR decoders in NFSv4 callback client
> 
> Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
> it must account for their space in their xdr stream when calling xdr_inline_decode

Thanks, applying for 2.6.38.  (How come you caught this, and I didn't?
I guess it's just that the object code depends more on the callback
returns?)

--b.

> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index da54498..d046bdb 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -592,7 +592,7 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
>  	 * If the server returns different values for sessionID, slotID or
>  	 * sequence number, the server is looney tunes.
>  	 */
> -	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4);
> +	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4 + 4 + 4);
>  	if (unlikely(p == NULL))
>  		goto out_overflow;
>  	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
> -- 
> 1.7.3.4
> 
