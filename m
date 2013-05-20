Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56461 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756561Ab3ETUkL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 16:40:11 -0400
Date: Mon, 20 May 2013 16:40:09 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/6] NFSv4.1: Enable state protection
Message-ID: <20130520204009.GH14677@fieldses.org>
References: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-3-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-4-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-5-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-6-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1369070227-40671-6-git-send-email-Trond.Myklebust@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 20, 2013 at 01:17:07PM -0400, Trond Myklebust wrote:
> Use the EXCHGID4_FLAG_BIND_PRINC_STATEID exchange_id flag to enable
> stateid protection. This means that if we create a stateid using a
> particular principal, then we must use the same principal if we
> want to change that state.

Note that knfsd ignores this--its EXCHANGE_ID will always return with
the flag unset regardless of what the client requests.  My understanding
is that that's legal ("Whether a bit is set or cleared on the arguments'
flags does not force the server to set or clear the same bit on the
results' side.")

(Definitely not opposed to implementing it, just haven't gotten around
to it.)

--b.

> IOW: if we OPEN a file using a particular credential, then we have
> to use the same credential in subsequent OPEN_DOWNGRADE, CLOSE,
> or DELEGRETURN operations that use that stateid.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7cdc706..3e21d43 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5528,7 +5528,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  	struct nfs41_exchange_id_args args = {
>  		.verifier = &verifier,
>  		.client = clp,
> -		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
> +		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
> +			EXCHGID4_FLAG_BIND_PRINC_STATEID,
>  	};
>  	struct nfs41_exchange_id_res res = {
>  		0
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
