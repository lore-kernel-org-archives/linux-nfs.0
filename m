Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab1FTTcA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2011 15:32:00 -0400
Date: Mon, 20 Jun 2011 15:31:58 -0400
To: Benny Halevy <benny@tonian.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: allow OP_DESTROY_CLIENTID to be only op in
 COMPOUND
Message-ID: <20110620193158.GA18369@fieldses.org>
References: <1308238750-9822-1-git-send-email-benny@tonian.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1308238750-9822-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 16, 2011 at 11:39:10AM -0400, Benny Halevy wrote:
> >From RFC5661, section 18.50:
>    DESTROY_CLIENTID MAY be preceded with a SEQUENCE operation as long as
>    the client ID derived from the session ID of SEQUENCE is not the same
>    as the client ID to be destroyed.  If the client IDs are the same,
>    then the server MUST return NFS4ERR_CLIENTID_BUSY.
> 
> (that's not implemented yet)
> 
>    If DESTROY_CLIENTID is not prefixed by SEQUENCE, it MUST be the only
>    operation in the COMPOUND request (otherwise, the server MUST return
>    NFS4ERR_NOT_ONLY_OP).

Applying for 3.1, with a note that:

	"This fixes the error return; before, we returned
	NFS4ERR_OP_NOT_IN_SESSION; after this patch, we return
	NFS4ERR_NOTSUPP."

(I think that's what you saw?)

--b.

> 
> Signed-off-by: Benny Halevy <benny@tonian.com>
> ---
>  fs/nfsd/nfs4proc.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 730b6e7..02adcc3 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1773,6 +1773,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
>  		.op_name = "OP_SEQUENCE",
>  	},
> +	[OP_DESTROY_CLIENTID] = {
> +		.op_func = NULL,
> +		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
> +		.op_name = "OP_DESTROY_CLIENTID",
> +	},
>  	[OP_RECLAIM_COMPLETE] = {
>  		.op_func = (nfsd4op_func)nfsd4_reclaim_complete,
>  		.op_flags = ALLOWED_WITHOUT_FH,
> -- 
> 1.7.4.4
> 
