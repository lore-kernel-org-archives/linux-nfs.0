Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35199 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753533Ab0I3Vdb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 17:33:31 -0400
Message-ID: <4CA50229.9000103@panasas.com>
Date: Thu, 30 Sep 2010 23:33:29 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 15/16] nfsd4: add new connections to session
References: <1285863553-8945-1-git-send-email-bfields@redhat.com> <1285863553-8945-16-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-16-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-30 18:19, J. Bruce Fields wrote:
> As long as we're not implementing any session security, we should just
> automatically add any new connections that come along to the list of
> sessions associated with the session.

Doesn't the client need to send BIND_CONN_TO_SESSION?

18.34. Operation 41: BIND_CONN_TO_SESSION - Associate Connection with Session:

   BIND_CONN_TO_SESSION is used to associate additional connections with
   a session.  It MUST be used on the connection being associated with
   the session.

Also, with these patches, can we set SEQ4_STATUS_CB_PATH_DOWN if there's
no backchannel?

Benny

> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
>  1 files changed, 47 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3b4d74c..596702e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -658,13 +658,18 @@ static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp)
>  	return conn;
>  }
>  
> +static void __nfsd4_hash_conn(struct nfsd4_conn *conn, struct nfsd4_session *ses)
> +{
> +	conn->cn_session = ses;
> +	list_add(&conn->cn_persession, &ses->se_conns);
> +}
> +
>  static void nfsd4_hash_conn(struct nfsd4_conn *conn, struct nfsd4_session *ses)
>  {
>  	struct nfs4_client *clp = ses->se_client;
>  
>  	spin_lock(&clp->cl_lock);
> -	conn->cn_session = ses;
> -	list_add(&conn->cn_persession, &ses->se_conns);
> +	__nfsd4_hash_conn(conn, ses);
>  	spin_unlock(&clp->cl_lock);
>  }
>  
> @@ -1612,6 +1617,44 @@ out:
>  	return status;
>  }
>  
> +static struct nfsd4_conn *__nfsd4_find_conn(struct svc_rqst *r, struct nfsd4_session *s)
> +{
> +	struct nfsd4_conn *c;
> +
> +	list_for_each_entry(c, &s->se_conns, cn_persession) {
> +		if (c->cn_xprt == r->rq_xprt) {
> +			return c;
> +		}
> +	}
> +	return NULL;
> +}
> +
> +static void nfsd4_sequence_check_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
> +{
> +	struct nfs4_client *clp = ses->se_client;
> +	struct nfsd4_conn *c, *new = NULL;
> +
> +	spin_lock(&clp->cl_lock);
> +	c = __nfsd4_find_conn(rqstp, ses);
> +	spin_unlock(&clp->cl_lock);
> +	if (c)
> +		return;
> +
> +	new = alloc_conn(rqstp);
> +
> +	spin_lock(&clp->cl_lock);
> +	c = __nfsd4_find_conn(rqstp, ses);
> +	if (c) {
> +		spin_unlock(&clp->cl_lock);
> +		free_conn(new);
> +		return;
> +	}
> +	__nfsd4_hash_conn(new, ses);
> +	spin_unlock(&clp->cl_lock);
> +	nfsd4_register_conn(new);
> +	return;
> +}
> +
>  __be32
>  nfsd4_sequence(struct svc_rqst *rqstp,
>  	       struct nfsd4_compound_state *cstate,
> @@ -1656,6 +1699,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	if (status)
>  		goto out;
>  
> +	nfsd4_sequence_check_conn(rqstp, session);
> +
>  	/* Success! bump slot seqid */
>  	slot->sl_inuse = true;
>  	slot->sl_seqid = seq->seqid;
