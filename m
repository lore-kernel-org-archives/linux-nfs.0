Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58956 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaG0N7t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:59:49 -0400
Date: Sun, 27 Jul 2014 06:59:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 25/40] nfsd: Keep a reference to the open stateid for the
 NFSv4.0 replay cache
Message-ID: <20140727135948.GB5062@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-26-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-26-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -	nfsd4_cleanup_open_state(open, status);
> -	if (open->op_openowner)
> -		nfsd4_cstate_assign_replay(cstate,
> -				&open->op_openowner->oo_owner);
> +	nfsd4_cleanup_open_state(cstate, open, status);

This was just added in the last patch, seems like you should introduce this
form of nfsd4_cleanup_open_state in the earlier patch.

> index 6886135b82ec..4f518fb453b5 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2951,6 +2951,27 @@ static void init_nfs4_replay(struct nfs4_replay *rp)
>  	mutex_init(&rp->rp_mutex);
>  }
>  
> +static void nfsd4_cstate_assign_replay(struct nfsd4_compound_state *cstate,
> +		struct nfs4_stateowner *so)

> +void nfsd4_cstate_clear_replay(struct nfsd4_compound_state *cstate)

And keep these in nfs4state.c from the start.

