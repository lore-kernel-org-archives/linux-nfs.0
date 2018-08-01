Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33690 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389190AbeHAOsi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 10:48:38 -0400
Date: Wed, 1 Aug 2018 09:02:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: Mark expected switch fall-through
Message-ID: <20180801130257.GB16651@fieldses.org>
References: <20180801022410.GA21621@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180801022410.GA21621@embeddedor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2018 at 09:24:10PM -0500, Gustavo A. R. Silva wrote:
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.

Thanks, applying for 2.19.

--b.
> 
> Warning level 2 was used: -Wimplicit-fallthrough=2
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>  fs/nfsd/nfs4callback.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 2a979aa9..5dd56e9 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -1078,6 +1078,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
>  		break;
>  	case -ESERVERFAULT:
>  		++session->se_cb_seq_nr;
> +		/* Fall through */
>  	case 1:
>  	case -NFS4ERR_BADSESSION:
>  		nfsd4_mark_cb_fault(cb->cb_clp, cb->cb_seq_status);
> -- 
> 2.7.4
