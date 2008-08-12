From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
Date: Tue, 12 Aug 2008 15:04:10 -0400
Message-ID: <20080812190410.GC30729@fieldses.org>
References: <48A1CB0C.4090906@panasas.com> <1218563178-25480-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34780 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbYHLTEM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2008 15:04:12 -0400
In-Reply-To: <1218563178-25480-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2008 at 08:46:18PM +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |   99 +++++++++++++++++++++++++++++-----------------------
>  1 files changed, 55 insertions(+), 44 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 47ac498..9570b1b 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
>  static __be32
> @@ -929,9 +939,10 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
>  	int len;
>  	DECODE_HEAD;
>  
> -	READ_BUF(sizeof(stateid_opaque_t) + 20);
> -	READ32(write->wr_stateid.si_generation);
> -	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
> +	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
> +	if (status)
> +		return status;
> +	READ_BUF(16);

How did that 20 become a 16?

OK, I guess this is another case of a preexisting arithmetic error.
Anywhere that error would have had immediate consequences, but here
thanks to the hand-coded write-data decoding, the incorrect argp->p
isn't used except to check that there's space for the incoming data.
And previously that check was more pessimistic than necessary.

--b.

>  	READ64(write->wr_offset);
>  	READ32(write->wr_stable_how);
>  	if (write->wr_stable_how > 2)
> -- 
> 1.5.6.5
> 
