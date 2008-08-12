From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/7] nfsd: nfs4xdr encode_stateid helper function
Date: Tue, 12 Aug 2008 14:39:41 -0400
Message-ID: <20080812183941.GB30729@fieldses.org>
References: <48A1CB0C.4090906@panasas.com> <1218563107-25393-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781AbYHLSjn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2008 14:39:43 -0400
In-Reply-To: <1218563107-25393-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2008 at 08:45:07PM +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |   76 ++++++++++++++++++++++------------------------------
>  1 files changed, 32 insertions(+), 44 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 4ec52f9..96da1aa 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
...
> @@ -2083,12 +2091,9 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
>  {
>  	ENCODE_SEQID_OP_HEAD;
>  
> -	if (!nfserr) {
> -		RESERVE_SPACE(4 + sizeof(stateid_t));

Hm, so that was a little over before (a harmless error, but better to
have it fixed).

--b.

> -		WRITE32(lock->lk_resp_stateid.si_generation);
> -		WRITEMEM(&lock->lk_resp_stateid.si_opaque, sizeof(stateid_opaque_t));
> -		ADJUST_ARGS();
