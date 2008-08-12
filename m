From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/7] nfsd: fix nfsd4_encode_open buffer space
	reservation
Date: Tue, 12 Aug 2008 14:31:12 -0400
Message-ID: <20080812183112.GA30729@fieldses.org>
References: <48A1CB0C.4090906@panasas.com> <1218563081-25364-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56230 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbYHLSbQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2008 14:31:16 -0400
In-Reply-To: <1218563081-25364-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2008 at 08:44:41PM +0300, Benny Halevy wrote:
> nfsd4_encode_open first reservation is currently for 36 + sizeof(stateid_t)
> while it writes after the stateid a cinfo (20 bytes) and 5 more 4-bytes
> words, for a total of 40 + sizeof(stateid_t).

Thanks, yep.  I wish this was all a little more automated!

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index cfe9d5c..4ec52f9 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2142,7 +2142,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
>  	if (nfserr)
>  		goto out;
>  
> -	RESERVE_SPACE(36 + sizeof(stateid_t));
> +	RESERVE_SPACE(40 + sizeof(stateid_t));
>  	WRITE32(open->op_stateid.si_generation);
>  	WRITEMEM(&open->op_stateid.si_opaque, sizeof(stateid_opaque_t));
>  	WRITECINFO(open->op_cinfo);
> -- 
> 1.5.6.5
> 
