Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:65475 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaDUPhr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 11:37:47 -0400
Received: by mail-ig0-f175.google.com with SMTP id h3so1897455igd.8
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 08:37:46 -0700 (PDT)
Message-ID: <1398094663.2891.22.camel@leira.trondhjem.org>
Subject: Re: [PATCH 36/70] NFSd: Add reference counting to find_stateid
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 21 Apr 2014 11:37:43 -0400
In-Reply-To: <20140419145026.GE25682@infradead.org>
References: <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
	 <20140419145026.GE25682@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-04-19 at 07:50 -0700, Christoph Hellwig wrote:
> > +static void nfs4_put_stateid(struct nfs4_stid *s)
> > +{
> > +	if (s == NULL)
> > +		return;
> > +	switch (s->sc_type) {
> > +	case NFS4_OPEN_STID:
> > +	case NFS4_LOCK_STID:
> > +	case NFS4_CLOSED_STID:
> > +		put_generic_stateid(openlockstateid(s));
> > +		break;
> > +	case NFS4_DELEG_STID:
> > +	case NFS4_REVOKED_DELEG_STID:
> > +	case NFS4_CLOSED_DELEG_STID:
> > +		nfs4_put_delegation(delegstateid(s));
> > +	}
> > +}
> 
> I really don't like the way the inheritance for the stateids works,
> a pure put operation shouldn't need this.  I think all this can be
> fixed by adding a ->free function pointer to struct nfs4_stid.  At this
> point the braindamage of passing a kmem_cache pointer to various
> function can be removed (similar to how nfs4_alloc_stid should be
> replaced with a nfs4_init_stid that takes an already allocated stid),
> and nothing in the normal refcounting path should need these switches.

Ack. I've added a free() pointer to nfs4_stid.

> > @@ -3804,26 +3823,33 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> >  		return nfserr_bad_stateid;
> >  	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
> >  	if (status)
> > -		return status;
> > +		goto out_put_stid;
> >  	switch (s->sc_type) {
> >  	case NFS4_DELEG_STID:
> > -		return nfs_ok;
> > +		status = nfs_ok;
> > +		break;
> >  	case NFS4_REVOKED_DELEG_STID:
> > -		return nfserr_deleg_revoked;
> > +		status = nfserr_deleg_revoked;
> > +		break;
> >  	case NFS4_OPEN_STID:
> >  	case NFS4_LOCK_STID:
> >  		ols = openlockstateid(s);
> >  		if (ols->st_stateowner->so_is_open_owner
> >  	    			&& !(openowner(ols->st_stateowner)->oo_flags
> >  						& NFS4_OO_CONFIRMED))
> > -			return nfserr_bad_stateid;
> > -		return nfs_ok;
> > +			status = nfserr_bad_stateid;
> > +		else
> > +			status = nfs_ok;
> > +		break;
> 
> Not quite as urgent as for the refcounting, but I think moving more
> of these switches on the type into proper methods would improve the
> stateid code a lot.

Agreed, but I'm leaving that as an exercise for the reader (at least as
far as this patch series is concerned).

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


