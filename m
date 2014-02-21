Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60341 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386AbaBUS75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Feb 2014 13:59:57 -0500
Date: Fri, 21 Feb 2014 13:59:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSd: NFSv4.1 OPEN must use the session-derived client id
Message-ID: <20140221185954.GH13433@fieldses.org>
References: <1393006233-15366-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1393006233-15366-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 21, 2014 at 01:10:33PM -0500, Trond Myklebust wrote:
> RFC5661 states:
> 
>  The client can set the clientid field to any value and the server MUST
>  ignore it.  Instead, the server MUST derive the client ID from the
>  session ID of the SEQUENCE operation of the COMPOUND request
> 
> Make it so...

See fs/nfsd/nfs4proc.c:nfsd4_open():

	if (nfsd4_has_session(cstate))
		copy_clientid(&open->op_clientid, cstate->session);

Do you have an actual test case that's failing?

--b.


> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 693e1458e2ca..d23f4cdbc891 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2826,6 +2826,21 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
>  	return nfserr_bad_seqid;
>  }
>  
> +/*
> + * RFC5661: OPEN MUST ignore the client-supplied clientid argument and
> + * substitute the session clientid
> + */
> +static void nfsd41_set_open_clientid(struct nfsd4_compound_state *cstate,
> +		struct nfsd4_open *open)
> +{
> +	struct nfs4_client *clp;
> +
> +	if (!nfsd4_has_session(cstate))
> +		return;
> +	clp = cstate->session->se_client;
> +	memcpy(&open->op_clientid, &clp->cl_clientid, sizeof(open->op_clientid));
> +}
> +
>  __be32
>  nfsd4_process_open1(struct nfsd4_compound_state *cstate,
>  		    struct nfsd4_open *open, struct nfsd_net *nn)
> @@ -2836,6 +2851,8 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
>  	struct nfs4_openowner *oo = NULL;
>  	__be32 status;
>  
> +	nfsd41_set_open_clientid(cstate, open);
> +
>  	if (STALE_CLIENTID(&open->op_clientid, nn))
>  		return nfserr_stale_clientid;
>  	/*
> -- 
> 1.8.5.3
> 
