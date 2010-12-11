Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756378Ab0LKAOR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 19:14:17 -0500
Date: Fri, 10 Dec 2010 19:14:14 -0500
To: Benny Halevy <bhalevy@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd4: fix mixed 4.0/4.1 handling, 4.1 reboot
Message-ID: <20101211001413.GD18141@fieldses.org>
References: <1291680566-13980-1-git-send-email-bfields@redhat.com>
 <1291680566-13980-3-git-send-email-bfields@redhat.com>
 <4D00DBA7.7020603@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D00DBA7.7020603@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 09, 2010 at 03:37:43PM +0200, Benny Halevy wrote:
> On 2010-12-07 02:09, J. Bruce Fields wrote:
> > Instead of failing to find client entries which don't match the
> > minorversion, we should be finding them, then either erroring out or
> > expiring them as appropriate.
> > 
> > This also fixes a problem which would cause the 4.1 server to fail to
> > recognize clients after a second reboot.
> > 
> > Reported-by: Casey Bodley <cbodley@citi.umich.edu>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4recover.c |    1 -
> >  fs/nfsd/nfs4state.c   |   37 +++++++++++++++++--------------------
> >  2 files changed, 17 insertions(+), 21 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > index 7e26caa..ffb59ef 100644
> > --- a/fs/nfsd/nfs4recover.c
> > +++ b/fs/nfsd/nfs4recover.c
> > @@ -302,7 +302,6 @@ purge_old(struct dentry *parent, struct dentry *child)
> >  {
> >  	int status;
> >  
> > -	/* note: we currently use this path only for minorversion 0 */
> >  	if (nfs4_has_reclaimed_state(child->d_name.name, false))
> >  		return 0;
> >  
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index febb283..d1e37ba 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1134,39 +1134,30 @@ find_unconfirmed_client(clientid_t *clid)
> >  	return NULL;
> >  }
> >  
> > -/*
> > - * FIXME: we need to unify the clientid namespaces for nfsv4.x
> > - * and correctly deal with client upgrade/downgrade in EXCHANGE_ID
> > - * and SET_CLIENTID{,_CONFIRM}
> > - */
> >  static bool clp_used_exchangeid(struct nfs4_client *clp)
> >  {
> >  	return clp->cl_exchange_flags != 0;
> > -}
> > +} 
> 
> nit: looks like this line adds a trailing space character...

Whoops, thanks.

> >  static struct nfs4_client *
> > -find_confirmed_client_by_str(const char *dname, unsigned int hashval,
> > -			     bool use_exchange_id)
> > +find_confirmed_client_by_str(const char *dname, unsigned int hashval)
> >  {
> >  	struct nfs4_client *clp;
> >  
> >  	list_for_each_entry(clp, &conf_str_hashtbl[hashval], cl_strhash) {
> > -		if (same_name(clp->cl_recdir, dname) &&
> > -		    clp_used_exchangeid(clp) == use_exchange_id)
> > +		if (same_name(clp->cl_recdir, dname))
> >  			return clp;
> >  	}
> >  	return NULL;
> >  }
> >  
> >  static struct nfs4_client *
> > -find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
> > -			       bool use_exchange_id)
> > +find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
> >  {
> >  	struct nfs4_client *clp;
> >  
> >  	list_for_each_entry(clp, &unconf_str_hashtbl[hashval], cl_strhash) {
> > -		if (same_name(clp->cl_recdir, dname) &&
> > -		    clp_used_exchangeid(clp) == use_exchange_id)
> > +		if (same_name(clp->cl_recdir, dname))
> >  			return clp;
> >  	}
> >  	return NULL;
> > @@ -1357,8 +1348,12 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
> >  	nfs4_lock_state();
> >  	status = nfs_ok;
> >  
> > -	conf = find_confirmed_client_by_str(dname, strhashval, true);
> > +	conf = find_confirmed_client_by_str(dname, strhashval);
> >  	if (conf) {
> > +		if (!clp_used_exchangeid(conf)) {
> > +			status = nfserr_clid_inuse; /* XXX: ? */
> > +			goto out;
> > +		}
> 
> So if a client host wants to mount a server both over v4.0 and v4.1
> it should use different client names?

I believe so.

> Just wondering, is that required by RFC5661?

Section 2.4.1 permits a server to compare the 4.0 nfs_clientid_4 with
the 4.1 client_owner4 in an exchanged_id.  That wouldn't work if a
client could expect the server to treat the two as independent clients.

Thanks for the review!

--b.

> 
> Benny
> 
> >  		if (!same_verf(&verf, &conf->cl_verifier)) {
> >  			/* 18.35.4 case 8 */
> >  			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
> > @@ -1399,7 +1394,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
> >  		goto out;
> >  	}
> >  
> > -	unconf  = find_unconfirmed_client_by_str(dname, strhashval, true);
> > +	unconf  = find_unconfirmed_client_by_str(dname, strhashval);
> >  	if (unconf) {
> >  		/*
> >  		 * Possible retry or client restart.  Per 18.35.4 case 4,
> > @@ -1799,10 +1794,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	strhashval = clientstr_hashval(dname);
> >  
> >  	nfs4_lock_state();
> > -	conf = find_confirmed_client_by_str(dname, strhashval, false);
> > +	conf = find_confirmed_client_by_str(dname, strhashval);
> >  	if (conf) {
> >  		/* RFC 3530 14.2.33 CASE 0: */
> >  		status = nfserr_clid_inuse;
> > +		if (clp_used_exchangeid(conf))
> > +			goto out;
> >  		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
> >  			char addr_str[INET6_ADDRSTRLEN];
> >  			rpc_ntop((struct sockaddr *) &conf->cl_addr, addr_str,
> > @@ -1817,7 +1814,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	 * has a description of SETCLIENTID request processing consisting
> >  	 * of 5 bullet points, labeled as CASE0 - CASE4 below.
> >  	 */
> > -	unconf = find_unconfirmed_client_by_str(dname, strhashval, false);
> > +	unconf = find_unconfirmed_client_by_str(dname, strhashval);
> >  	status = nfserr_resource;
> >  	if (!conf) {
> >  		/*
> > @@ -1962,7 +1959,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
> >  			unsigned int hash =
> >  				clientstr_hashval(unconf->cl_recdir);
> >  			conf = find_confirmed_client_by_str(unconf->cl_recdir,
> > -							    hash, false);
> > +							    hash);
> >  			if (conf) {
> >  				nfsd4_remove_clid_dir(conf);
> >  				expire_client(conf);
> > @@ -4106,7 +4103,7 @@ nfs4_has_reclaimed_state(const char *name, bool use_exchange_id)
> >  	unsigned int strhashval = clientstr_hashval(name);
> >  	struct nfs4_client *clp;
> >  
> > -	clp = find_confirmed_client_by_str(name, strhashval, use_exchange_id);
> > +	clp = find_confirmed_client_by_str(name, strhashval);
> >  	return clp ? 1 : 0;
> >  }
> >  
