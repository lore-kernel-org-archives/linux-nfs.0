Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17701 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756104Ab0I3V5K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 17:57:10 -0400
Date: Thu, 30 Sep 2010 17:57:07 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 15/16] nfsd4: add new connections to session
Message-ID: <20100930215707.GE2612@pad.home.fieldses.org>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
 <1285863553-8945-16-git-send-email-bfields@redhat.com>
 <4CA50229.9000103@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA50229.9000103@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 11:33:29PM +0200, Benny Halevy wrote:
> On 2010-09-30 18:19, J. Bruce Fields wrote:
> > As long as we're not implementing any session security, we should just
> > automatically add any new connections that come along to the list of
> > sessions associated with the session.
> 
> Doesn't the client need to send BIND_CONN_TO_SESSION?
> 
> 18.34. Operation 41: BIND_CONN_TO_SESSION - Associate Connection with Session:
> 
>    BIND_CONN_TO_SESSION is used to associate additional connections with
>    a session.  It MUST be used on the connection being associated with
>    the session.

As I understand it, we just add them automatically, unless some sort of
state protection is in force.  (Which we haven't implemented yet.)

> Also, with these patches, can we set SEQ4_STATUS_CB_PATH_DOWN if there's
> no backchannel?

Just debugging that part....  Tomorrow, hopefully!

--b.

> 
> Benny
> 
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
> >  1 files changed, 47 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 3b4d74c..596702e 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -658,13 +658,18 @@ static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp)
> >  	return conn;
> >  }
> >  
> > +static void __nfsd4_hash_conn(struct nfsd4_conn *conn, struct nfsd4_session *ses)
> > +{
> > +	conn->cn_session = ses;
> > +	list_add(&conn->cn_persession, &ses->se_conns);
> > +}
> > +
> >  static void nfsd4_hash_conn(struct nfsd4_conn *conn, struct nfsd4_session *ses)
> >  {
> >  	struct nfs4_client *clp = ses->se_client;
> >  
> >  	spin_lock(&clp->cl_lock);
> > -	conn->cn_session = ses;
> > -	list_add(&conn->cn_persession, &ses->se_conns);
> > +	__nfsd4_hash_conn(conn, ses);
> >  	spin_unlock(&clp->cl_lock);
> >  }
> >  
> > @@ -1612,6 +1617,44 @@ out:
> >  	return status;
> >  }
> >  
> > +static struct nfsd4_conn *__nfsd4_find_conn(struct svc_rqst *r, struct nfsd4_session *s)
> > +{
> > +	struct nfsd4_conn *c;
> > +
> > +	list_for_each_entry(c, &s->se_conns, cn_persession) {
> > +		if (c->cn_xprt == r->rq_xprt) {
> > +			return c;
> > +		}
> > +	}
> > +	return NULL;
> > +}
> > +
> > +static void nfsd4_sequence_check_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
> > +{
> > +	struct nfs4_client *clp = ses->se_client;
> > +	struct nfsd4_conn *c, *new = NULL;
> > +
> > +	spin_lock(&clp->cl_lock);
> > +	c = __nfsd4_find_conn(rqstp, ses);
> > +	spin_unlock(&clp->cl_lock);
> > +	if (c)
> > +		return;
> > +
> > +	new = alloc_conn(rqstp);
> > +
> > +	spin_lock(&clp->cl_lock);
> > +	c = __nfsd4_find_conn(rqstp, ses);
> > +	if (c) {
> > +		spin_unlock(&clp->cl_lock);
> > +		free_conn(new);
> > +		return;
> > +	}
> > +	__nfsd4_hash_conn(new, ses);
> > +	spin_unlock(&clp->cl_lock);
> > +	nfsd4_register_conn(new);
> > +	return;
> > +}
> > +
> >  __be32
> >  nfsd4_sequence(struct svc_rqst *rqstp,
> >  	       struct nfsd4_compound_state *cstate,
> > @@ -1656,6 +1699,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> >  	if (status)
> >  		goto out;
> >  
> > +	nfsd4_sequence_check_conn(rqstp, session);
> > +
> >  	/* Success! bump slot seqid */
> >  	slot->sl_inuse = true;
> >  	slot->sl_seqid = seq->seqid;
