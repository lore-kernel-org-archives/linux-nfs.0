Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33542 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932655AbdBQUZs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 15:25:48 -0500
Date: Fri, 17 Feb 2017 15:25:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd/callback: Drop an useless data copy when
 comparing sessionid
Message-ID: <20170217202546.GK10894@fieldses.org>
References: <dd77a6cd-c269-e326-ced6-d91a858d389b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <dd77a6cd-c269-e326-ced6-d91a858d389b@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These three look fine, thanks; applying.--b.

On Sun, Feb 05, 2017 at 09:57:48AM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4callback.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index ea74149..0274db6 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -397,13 +397,10 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
>  				    struct nfsd4_callback *cb)
>  {
>  	struct nfsd4_session *session = cb->cb_clp->cl_cb_session;
> -	struct nfs4_sessionid id;
> -	int status;
> +	int status = -ESERVERFAULT;
>  	__be32 *p;
>  	u32 dummy;
>  
> -	status = -ESERVERFAULT;
> -
>  	/*
>  	 * If the server returns different values for sessionID, slotID or
>  	 * sequence number, the server is looney tunes.
> @@ -411,9 +408,8 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
>  	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4 + 4 + 4);
>  	if (unlikely(p == NULL))
>  		goto out_overflow;
> -	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
> -	if (memcmp(id.data, session->se_sessionid.data,
> -					NFS4_MAX_SESSIONID_LEN) != 0) {
> +
> +	if (memcmp(p, session->se_sessionid.data, NFS4_MAX_SESSIONID_LEN)) {
>  		dprintk("NFS: %s Invalid session id\n", __func__);
>  		goto out;
>  	}
> -- 
> 2.9.3
