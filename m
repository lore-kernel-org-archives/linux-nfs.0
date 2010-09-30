Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45177 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150Ab0I3Vi7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 17:38:59 -0400
Date: Thu, 30 Sep 2010 17:38:45 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/16] nfsd4: keep per-session list of connections
Message-ID: <20100930213845.GF15207@fieldses.org>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
 <1285863553-8945-12-git-send-email-bfields@redhat.com>
 <4CA4FF6E.3030907@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA4FF6E.3030907@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 11:21:50PM +0200, Benny Halevy wrote:
> On 2010-09-30 18:19, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > The spec requires us in various places to keep track of the connections
> > associated with each session.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  fs/nfsd/nfs4state.c  |   69 +++++++++++++++++++++++++++++++++++++++-----------
> >  fs/nfsd/state.h      |    8 ++++++
> >  include/linux/nfs4.h |    3 ++
> >  3 files changed, 65 insertions(+), 15 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index f86476c..c7c1a7a 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -625,11 +625,58 @@ static void init_forechannel_attrs(struct nfsd4_channel_attrs *new, struct nfsd4
> >  	new->maxops = min_t(u32, req->maxops, NFSD_MAX_OPS_PER_COMPOUND);
> >  }
> >  
> > +
> > +static void free_conn(struct nfsd4_conn *c)
> > +{
> > +	svc_xprt_put(c->cn_xprt);
> > +	kfree(c);
> > +}
> > +
> > +void free_session(struct kref *kref)
> > +{
> > +	struct nfsd4_session *ses;
> > +	int mem;
> > +
> > +	ses = container_of(kref, struct nfsd4_session, se_ref);
> > +	while (!list_empty(&ses->se_conns)) {
> > +		struct nfsd4_conn *c;
> > +		c = list_first_entry(&ses->se_conns, struct nfsd4_conn, cn_persession);
> > +		list_del(&c->cn_persession);
> > +		free_conn(c);
> > +	}
> > +	spin_lock(&nfsd_drc_lock);
> > +	mem = ses->se_fchannel.maxreqs * slot_bytes(&ses->se_fchannel);
> > +	nfsd_drc_mem_used -= mem;
> > +	spin_unlock(&nfsd_drc_lock);
> > +	free_session_slots(ses);
> > +	kfree(ses);
> > +}
> > +
> > +
> >  static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
> >  {
> >  	struct nfsd4_session *new;
> >  	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
> >  	int numslots, slotsize;
> > +	int status;
> >  	int idx;
> >  
> >  	/*
> > @@ -654,6 +701,8 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
> >  	memcpy(clp->cl_sessionid.data, new->se_sessionid.data,
> >  	       NFS4_MAX_SESSIONID_LEN);
> >  
> > +	INIT_LIST_HEAD(&new->se_conns);
> > +
> >  	new->se_flags = cses->flags;
> >  	kref_init(&new->se_ref);
> >  	idx = hash_sessionid(&new->se_sessionid);
> > @@ -662,6 +711,11 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
> >  	list_add(&new->se_perclnt, &clp->cl_sessions);
> >  	spin_unlock(&client_lock);
> >  
> > +	status = nfsd4_new_conn(rqstp, new);
> > +	if (status) {
> > +		free_session(&new->se_ref);
> > +		return nfserr_jukebox;
> 
> why not return status?

The status is sort of bogus; all that can really happen is an allocation
failure:

> > +static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
> > +{
> > +	struct nfs4_client *clp = ses->se_client;
> > +	struct nfsd4_conn *conn;
> > +
> > +	conn = kmalloc(sizeof(struct nfsd4_conn), GFP_KERNEL);
> > +	if (!conn)
> > +		return nfserr_jukebox;
> > +	conn->cn_flags = NFS4_CDFC4_FORE;
> > +	svc_xprt_get(rqstp->rq_xprt);
> > +	conn->cn_xprt = rqstp->rq_xprt;
> > +
> > +	spin_lock(&clp->cl_lock);
> > +	list_add(&conn->cn_persession, &ses->se_conns);
> > +	spin_unlock(&clp->cl_lock);
> > +
> > +	return nfs_ok;
> > +}

I'd actually rather change alloc_init_session() to return NULL or the
new session.  But, yeah, it grates a bit to have a status return that's
ignored.  Hm.

> > diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> > index 07e40c6..79b15fb 100644
> > --- a/include/linux/nfs4.h
> > +++ b/include/linux/nfs4.h
> > @@ -61,6 +61,9 @@
> >  #define NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL	0x10000
> >  #define NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED		0x20000
> >  
> > +#define NFS4_CDFC4_FORE	0x1
> > +#define NFS4_CDFC4_BACK 0x2
> > +
> 
> nit: I think that defining flags shifted bits is clearer, e.g.:
> 
> enum nfsd4_channel_dir {
> 	NFS4_CDFC4_FORE	 = 1 << 0,
> 	NFS4_CDFC4_BACK = 1 << 1,

I see what you mean.

I was just taking the definitions from the spec.  And I should add
FORE_OR_BOTH and BACK_OR_BOTH some time, neither powers of two.  I
dunno.

--b.

> };
> 
> Benny
> 
> >  #define NFS4_SET_TO_SERVER_TIME	0
> >  #define NFS4_SET_TO_CLIENT_TIME	1
> >  
> 
