From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: nfsd4: fix cb_recall encoding
Date: Tue, 25 May 2010 09:14:02 +0300
Message-ID: <4BFB6AAA.5090308@panasas.com>
References: <20100524152825.GB18625@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Michael Groshans <groshans@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17958 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752835Ab0EYGOF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 02:14:05 -0400
In-Reply-To: <20100524152825.GB18625@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 24, 2010, 18:28 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> "nfsd: nfs4callback encode_stateid helper function" forgot to reserve
> more space after return from the new helper.
> 
> Reported-by: Michael Groshans <groshans@citi.umich.edu>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4callback.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> Benny, maybe you could fix that patch and then pass it upstream?

Sure.  I submitted this fix to the pnfs tree and will test and
send a fixed version of "nfsd: nfs4callback encode_stateid helper function"
upstream.

Benny

> 
> --b.
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index b279738..238e0b8 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -246,6 +246,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
>  	RESERVE_SPACE(4);
>  	WRITE32(OP_CB_RECALL);
>  	encode_stateid(xdr, &dp->dl_stateid);
> +	RESERVE_SPACE(8 + (XDR_QUADLEN(len) << 2));
>  	WRITE32(0); /* truncate optimization not implemented */
>  	WRITE32(len);
>  	WRITEMEM(&dp->dl_fh.fh_base, len);

