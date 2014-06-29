Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33096 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaF2MOU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 08:14:20 -0400
Date: Sun, 29 Jun 2014 05:14:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 022/117] nfsd: Cache the client that was looked up in
 lookup_clientid()
Message-ID: <20140629121419.GC16150@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-23-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-23-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:12:02PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> We want to use the nfsd4_compound_state to cache the nfs4_client
> in order to optimise away extra lookups of the clid.

Should mention that this is only for 4.0.  Actually, kooking at
"nfsd: Allow struct nfsd4_compound_state to cache the nfs4_client" that
patch seems to mostly be a few random code cleanups that should have
a different title so it might make more sense to move the caching
of the client for 4.1+ to this patch as well.

And please write proper, detailed changelogs :)

> +static __be32 lookup_clientid(clientid_t *clid,
> +		struct nfsd4_compound_state *cstate,
> +		struct nfsd_net *nn)

Now that we don't look up the client idea for the normal case but just
verify it we should probably rename this function to
nfsd4_verify_clientid or something similar.

While it doesn't belong into this patch:  why don't we cache the
nfsd_net in the nfsd4_compound_state

>  {
>  	struct nfs4_client *found;
>  
> +	if (cstate->clp != NULL) {
> +		found = cstate->clp;
> +		if (!same_clid(&found->cl_clientid, clid))
> +			return nfserr_stale_clientid;
> +	} else {
> +		if (STALE_CLIENTID(clid, nn))
> +			return nfserr_stale_clientid;
> +		/*
> +		 * Usually for v4.1+ we get the client in the SEQUENCE op, so

Usually implices there might be a case where we don't get it.  Which
case would that be?

> +		 * if we don't have one cached already then we know this is for
> +		 * is for v4.0 and "sessions" will be false.
> +		 */
> +		found = find_confirmed_client(clid, false, nn);
> +		/* Cache the nfs4_client in cstate! */
> +		if (found) {
> +			cstate->clp = found;
> +			atomic_inc(&found->cl_refcount);
> +		}
> +	}
>  	return found ? nfs_ok : nfserr_expired;

The whole thing could be simplified a little more:

	if (cstate->clp) {
		if (!same_clid(&cstate->clp->cl_clientid, clid))
			return nfserr_stale_clientid;
		retur nfs_ok;
	}

	if (STALE_CLIENTID(clid, nn))
		return nfserr_stale_clientid;

	found = find_confirmed_client(clid, false, nn);
	if (!found)
		return nfserr_expired;

	cstate->clp = found;
	atomic_inc(&found->cl_refcount);
	return nfs_ok;

> +	status = lookup_clientid(&stateid->si_opaque.so_clid, cstate, nn);
>  	if (status == nfserr_stale_clientid) {
> +		if (cstate->session)
>  			return nfserr_bad_stateid;
>  		return nfserr_stale_stateid;
>  	}

Why do we return a different error here for the 4.1+ case?  And why not
in other places using lookup_clientid?

