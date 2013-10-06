Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60756 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066Ab3JFP3R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 11:29:17 -0400
Date: Sun, 6 Oct 2013 08:29:16 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] SQUASHME: pnfsd: nfs4_find_create_layout_stateid
Message-ID: <20131006152916.GA8801@infradead.org>
References: <5251140B.4000203@primarydata.com>
 <1381045468-30670-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381045468-30670-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> + * If the layout state was found in cache, grab a reference count on it;
> + * otherwise, allocate a new layout state if "do_alloc" is set.

There is no do_alloc parameter to the function.

> + *
> + * Called with the state_lock held
> + * Returns zero and the layout state in *lsp, or error.
> + */
> +static __be32
> +nfs4_find_create_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
> +				stateid_t *stateid, unsigned char typemask,
> +				struct nfs4_layout_state **lsp)
> +{
> +	struct nfs4_layout_state *ls = NULL;
> +	__be32 status = 0;
> +	struct nfs4_stid *stid;
> +
> +	dprintk("--> %s clp %p fp %p operation stateid=" STATEID_FMT "\n",
> +		__func__, clp, fp, STATEID_VAL(stateid));
> +
> +	nfs4_assert_state_locked();
> +	status = nfsd4_lookup_stateid(stateid, typemask, &stid, true,
> +				      net_generic(clp->net, nfsd_net_id));
> +	if (status)
> +		goto out;
> +
> +	/* Is this the first use of this layout ? */
> +	if (stid->sc_type != NFS4_LAYOUT_STID) {
> +		ls = alloc_init_layout_state(clp, fp, stateid);
> +		if (!ls) {
> +			status = nfserr_jukebox;
> +			goto out;
> +		}
> +	} else {
> +		ls = container_of(stid, struct nfs4_layout_state, ls_stid);
> +
> +		/* BAD STATEID */
> +		if (stateid->si_generation > ls->ls_stid.sc_stateid.si_generation) {
> +			status = nfserr_bad_stateid;
> +			goto out;
> +		}
> +		get_layout_state(ls);
> +	}
> +	status = 0;
> +
> +	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
> +		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));
> +
> +	*lsp = ls;
> +out:
> +	dprintk("<-- %s status %d\n", __func__, htonl(status));
> +
> +	return status;
> +}

Shouldn't there be a corresponding removal of the alloc code from
nfs4_process_layout_stateid?

