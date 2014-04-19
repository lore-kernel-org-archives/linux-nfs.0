Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59452 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaDSOu1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Apr 2014 10:50:27 -0400
Date: Sat, 19 Apr 2014 07:50:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 36/70] NFSd: Add reference counting to find_stateid
Message-ID: <20140419145026.GE25682@infradead.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +static void nfs4_put_stateid(struct nfs4_stid *s)
> +{
> +	if (s == NULL)
> +		return;
> +	switch (s->sc_type) {
> +	case NFS4_OPEN_STID:
> +	case NFS4_LOCK_STID:
> +	case NFS4_CLOSED_STID:
> +		put_generic_stateid(openlockstateid(s));
> +		break;
> +	case NFS4_DELEG_STID:
> +	case NFS4_REVOKED_DELEG_STID:
> +	case NFS4_CLOSED_DELEG_STID:
> +		nfs4_put_delegation(delegstateid(s));
> +	}
> +}

I really don't like the way the inheritance for the stateids works,
a pure put operation shouldn't need this.  I think all this can be
fixed by adding a ->free function pointer to struct nfs4_stid.  At this
point the braindamage of passing a kmem_cache pointer to various
function can be removed (similar to how nfs4_alloc_stid should be
replaced with a nfs4_init_stid that takes an already allocated stid),
and nothing in the normal refcounting path should need these switches.

> @@ -3804,26 +3823,33 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
>  		return nfserr_bad_stateid;
>  	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
>  	if (status)
> -		return status;
> +		goto out_put_stid;
>  	switch (s->sc_type) {
>  	case NFS4_DELEG_STID:
> -		return nfs_ok;
> +		status = nfs_ok;
> +		break;
>  	case NFS4_REVOKED_DELEG_STID:
> -		return nfserr_deleg_revoked;
> +		status = nfserr_deleg_revoked;
> +		break;
>  	case NFS4_OPEN_STID:
>  	case NFS4_LOCK_STID:
>  		ols = openlockstateid(s);
>  		if (ols->st_stateowner->so_is_open_owner
>  	    			&& !(openowner(ols->st_stateowner)->oo_flags
>  						& NFS4_OO_CONFIRMED))
> -			return nfserr_bad_stateid;
> -		return nfs_ok;
> +			status = nfserr_bad_stateid;
> +		else
> +			status = nfs_ok;
> +		break;

Not quite as urgent as for the refcounting, but I think moving more
of these switches on the type into proper methods would improve the
stateid code a lot.

