Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267Ab1GMAZY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 20:25:24 -0400
Date: Tue, 12 Jul 2011 20:25:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2 v3] nfsd41: check the size of request
Message-ID: <20110713002522.GJ2162@fieldses.org>
References: <4E0EDEBE.8040902@cn.fujitsu.com>
 <20110706164306.GC30349@fieldses.org>
 <4E16CA48.3030308@cn.fujitsu.com>
 <20110708200319.GC13886@fieldses.org>
 <4E17BACC.8030901@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E17BACC.8030901@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 09, 2011 at 10:19:56AM +0800, Mi Jinlong wrote:
> This patch checks request's size when it consists SEQUENCE.
> Also modifies the format of some function which length exceed 80.
> 
> v3:
>    remove the check about only SEQUENCE operation.
>    check the size immediately after find session.
>    modify some function's format which length exceed 80.

No, please don't ever mix unrelated formatting changes into a patch.

We can leave those lines alone; the occasional long line isn't a big
problem.

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |   24 ++++++++++++++++++++----
>  1 files changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e98f3c2..9cce11c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1645,7 +1645,8 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
>  	return status;
>  }
>  
> -static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4_sessionid *sid)
> +static bool nfsd4_compound_in_session(struct nfsd4_session *session,
> +				      struct nfs4_sessionid *sid)
>  {
>  	if (!session)
>  		return 0;
> @@ -1695,7 +1696,8 @@ out:
>  	return status;
>  }
>  
> -static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt, struct nfsd4_session *s)
> +static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt,
> +					    struct nfsd4_session *s)
>  {
>  	struct nfsd4_conn *c;
>  
> @@ -1707,7 +1709,8 @@ static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt, struct nfsd4_s
>  	return NULL;
>  }
>  
> -static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_session *ses)
> +static void nfsd4_sequence_check_conn(struct nfsd4_conn *new,
> +				      struct nfsd4_session *ses)
>  {
>  	struct nfs4_client *clp = ses->se_client;
>  	struct nfsd4_conn *c;
> @@ -1729,13 +1732,22 @@ static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_sessi
>  	return;
>  }
>  
> -static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_session *session)
> +static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp,
> +				       struct nfsd4_session *session)
>  {
>  	struct nfsd4_compoundargs *args = rqstp->rq_argp;
>  
>  	return args->opcnt > session->se_fchannel.maxops;
>  }
>  
> +static bool nfsd4_request_too_big(struct svc_rqst *rqstp,
> +				  struct nfsd4_session *session)
> +{
> +	struct xdr_buf *xb = &rqstp->rq_arg;
> +
> +	return xb->len > session->se_fchannel.maxreq_sz;
> +}
> +
>  __be32
>  nfsd4_sequence(struct svc_rqst *rqstp,
>  	       struct nfsd4_compound_state *cstate,
> @@ -1768,6 +1780,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	if (nfsd4_session_too_many_ops(rqstp, session))
>  		goto out;
>  
> +	status = nfserr_req_too_big;
> +	if (nfsd4_request_too_big(rqstp, session))
> +		goto out;
> +
>  	status = nfserr_badslot;
>  	if (seq->slotid >= session->se_fchannel.maxreqs)
>  		goto out;
> -- 
> 1.7.5.4
> 
> 
> 
