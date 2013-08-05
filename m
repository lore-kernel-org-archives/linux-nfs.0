Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56138 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047Ab3HEUmE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Aug 2013 16:42:04 -0400
Date: Mon, 5 Aug 2013 16:42:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix SP4_MACH_CRED negotiation in EXCHANGE_ID
Message-ID: <20130805204200.GE1583@fieldses.org>
References: <1375732027-4905-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1375732027-4905-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 05, 2013 at 03:47:07PM -0400, Weston Andros Adamson wrote:
>  - don't BUG_ON() when not SP4_NONE
>  - calculate recv and send reserve sizes correctly

Looks good, thanks!  (Ouch to that BUG_ON...).

Could I get the client-side code you're using to test this?

It's fine if it's a mess, I just want to be able to run it once and see
a mount work.

--b.

> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c | 2 +-
>  fs/nfsd/nfs4xdr.c  | 5 ++---
>  2 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 0d4c410..419572f 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1524,7 +1524,7 @@ static inline u32 nfsd4_write_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  static inline u32 nfsd4_exchange_id_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
>  	return (op_encode_hdr_size + 2 + 1 + /* eir_clientid, eir_sequenceid */\
> -		1 + 1 + 0 + /* eir_flags, spr_how, SP4_NONE (for now) */\
> +		1 + 1 + 2 + /* eir_flags, spr_how, spo_must_enforce & _allow */\
>  		2 + /*eir_server_owner.so_minor_id */\
>  		/* eir_server_owner.so_major_id<> */\
>  		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 +\
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 0c0f3ea9..c2a4701 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3360,7 +3360,8 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>  		8 /* eir_clientid */ +
>  		4 /* eir_sequenceid */ +
>  		4 /* eir_flags */ +
> -		4 /* spr_how (SP4_NONE) */ +
> +		4 /* spr_how */ +
> +		8 /* spo_must_enforce, spo_must_allow */ +
>  		8 /* so_minor_id */ +
>  		4 /* so_major_id.len */ +
>  		(XDR_QUADLEN(major_id_sz) * 4) +
> @@ -3372,8 +3373,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	WRITE32(exid->seqid);
>  	WRITE32(exid->flags);
>  
> -	/* state_protect4_r. Currently only support SP4_NONE */
> -	BUG_ON(exid->spa_how != SP4_NONE);
>  	WRITE32(exid->spa_how);
>  	switch (exid->spa_how) {
>  	case SP4_NONE:
> -- 
> 1.7.12.4 (Apple Git-37)
> 
