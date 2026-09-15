Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D5714A4413
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 17:30:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789493408; cv=none; b=rpvX2xaxhBZUR8Qp24h8MtaLZX/WWoEtEYogcnEyLodlRC1ipOmxU9x5TKWJmhcC51Q183uvoKLy8jgXOY9ys35QwNRUrj0I6RbgD/5OIwL3QvQTBvMZDJQogPPGgAMx2zGhf4pKIMkvkIRYDRGOmqoG1cUQbjpyo5nnimBRvoQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789493408; c=relaxed/simple;
	bh=22iV3pgmTpfFmHkwzGyyha0eRrjW4KKS7l+8F5rU/n8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=nTYQ5hmrWtvaIZVcRVpyklS744ajdjVglB9QhhT8WUxKcVPK4QK4Fsm3qMxUt46fSvcrRuKe+AU1u3vFHqFmcAKeKWLrj8CLlQgySUGE6tGe1x9RpxEjN2t8M7wrR5flt6Je3sYOvsqBv0zI5Fa8nE/U9yXjNbstvpg9t8mTGmw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DiEJKGM2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DiEJKGM2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 784371F00893;
	Tue, 15 Sep 2026 17:30:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789493405;
	bh=HgkRgyzAbDgPKR8WZJ99oi3V2I/fpp7TfML0IqA7ixI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=DiEJKGM2YfP8aiLZm3UpeXglhs77bSl3gCgw1qD5c31Wnnx04TF/76ap5tYTDtj+Z
	 /JaRAgL1P3QNwV+UyDw116E5uZONOBeJsc46aX1G6TLewv7aw+CaZ63U3rC0LG0Hvg
	 kERE8ypJoUUBYQaMc/e1L+ldShaDg4pm9RlSGtTiY5jgNdy3wWL5kZmIx7hJ4T7vKT
	 K+1LpjfcaOvJcvRjotP6IfF0zEZ1LEnJocEwCuH83JHjpsHh53YNsm1OLX8GyrFALS
	 3P90Wrwot+8rDF3Qj5wHGoAdZW0maT3/wKU1Nxlp4aefIsaTeZv8r53ESAHLkmn8gB
	 qMSQkJOk0syiw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 8D3D3F4006B;
	Tue, 15 Sep 2026 13:30:04 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 15 Sep 2026 13:30:04 -0400
X-ME-Sender: <xms:nICpagZ6TDmDKT_HxCYyS9J6w7kXV_mlqJJQHuL-Q2o6OLqC6k6Wng>
    <xme:nICpamMsSKgZrnMv0nd_WOTwU4Gd8RsaEWtdRM4DzFrG4Uaf3KXU8H6BwYzw9IQwj
    WlEiQZINd_9WeECUVij2HvcybYA-Uy28esBaGr0qb4ye-rQU_K_nb6f>
X-ME-Proxy-Cause: dmFkZTEMtq0xipwbd8Z3VIVNuuuibyTVjlAW8ErOTu/Uwx50NfKD8sJWbUqV0sMth1v8pe
    C2HAYTT5nIfSwDF0k0OJmjauBkMOMQBIDa6hm4ROazzYGsbvqHSyc9XH2Il1zzAmaTsg1t
    cXnuN0yRleWdDLmHCSMM6p4ECdkPq7yCWPQcIqeWm4B3sL29B81hnimRz/xphN7GrUyApS
    TNLok+Df3aQvAftCBWEConmoIsHQ3S8E//W4uooV02mEyt4nZ0Kx7UW8d5Kn3K/IIY9Zhm
    gxyk/Vbr3ku2eQd2BdbZpqZC1aUX50bFdUnc4sr6nlnFjJAt3lQrMPUpowm40Wpsqwb3dz
    hme25iR9hRzWW8+mwWpClF3AUXG6SjnR1z6FJES3/lnoLGU3rHHV0CLGCyopmFpwlDnV0E
    KSyCcTnv+5Z5obzPcT4f28qplvDf6H+UMR7qh62FcgqXSCs5smJnpCKNYFSJZfg/0cAbrP
    +GL3izlnJTJLez66nKotz62q9VlCNNKi1aX+5eetT+rzwAiMrHALWKcepQ0Y53QyJrzQrR
    Q8rG7aUu9eny6kHYlaf5RIjvxF+nRixnNxTHZIkP8+/P1bkeUtfYG525pP62w3d3bDS3u3
    2Jbbk3niQ/HtjiVKDSvO5YA8kwkwume+7ULY5yM834rd3Vbu+rXa1xhFWnTw
X-ME-Proxy: <xmx:nICpaiSc9djj6PcIUIpVPQsOTPTo7oNmHQyTju3COPa9dt42Cvze1A>
    <xmx:nICpaodBu8JDzXbQxf9nS3pR5ziSZSoxxyPrS8dU-bKyFewJzk5OHw>
    <xmx:nICpauAEw-g2zQngDl7sDjPYD9raNGZW0ePkriU5-yzH0C3XmBAGvA>
    <xmx:nICpaimzN2JQP1GpZEDXM3S87v-nuPlqDfR30y5Og0t8nJlLPFDzsg>
    <xmx:nICpahd6VAg4Wip7GngM5eNvE5Q0gqu8xXegO0IAdUvNPQdjKH5tQuca>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5AE83B6006E; Tue, 15 Sep 2026 13:30:04 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A6a0J3mWMfhJ
Date: Tue, 15 Sep 2026 13:29:44 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Jonathan Curley" <jcurley@purestorage.com>,
 "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Junrui Luo" <moonafterrain@outlook.com>
Message-Id: <44832269-c734-4734-8e53-2ca7c846d1cc@app.fastmail.com>
In-Reply-To: 
 <657aa7a3a78899efdaedb0acfd9ad17d075d133a.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
 <657aa7a3a78899efdaedb0acfd9ad17d075d133a.1789474702.git.bcodding@hammerspace.com>
Subject: Re: [PATCH v4 17/24] pNFS: Add deviceid reference query and collection walkers
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Sep 15, 2026, at 8:22 AM, Benjamin Coddington wrote:
> The CB_NOTIFY_DEVICEID DELETE race recovery (RFC 8881 Section
> 18.40.4) needs to ask whether any live layout still references a
> deviceID, and to enumerate those layouts for TEST_STATEID.  Add a
> layout_references_deviceid hook (sibling of reresolve_deviceid; the
> flexfiles implementation memcmps each mirror stripe's decoded devid,
> valid independent of the pinned device node) and two walkers over
> the byserver pattern:
>
> - pnfs_layout_deviceid_referenced_byclid(): boolean existence query,
>   early-stopping, entirely under i_lock.
> - pnfs_layout_collect_deviceid_refs(): collects each matching layout
>   with the hdr pinned, the inode grabbed with its superblock active
>   (a pinned hdr does not hold its inode -- same discipline as the
>   bulk-destroy walker), and the layout stateid and cred snapshotted
>   under i_lock, so the caller can issue sleeping RPCs against the
>   collection.
>
> The collection walker pins each matching header with a plain
> pnfs_get_layout_hdr(), which cannot resurrect a dying header because
> the walker holds i_lock and has checked NFS_I()->layout == lo.
> pnfs_put_layout_hdr() drops the last reference under i_lock --
> refcount_dec_and_lock() only decrements one to zero once it holds the
> lock -- and clears NFS_I()->layout in that same critical section,
> before it unlocks and frees.  So a header still installed on its inode
> cannot have reached a zero refcount.
>
> That argument deliberately does not rest on NFS_LAYOUT_INVALID_STID.
> A header can reach its final put while still valid: a full
> LAYOUTRETURN ends in pnfs_layoutreturn_free_lsegs(), which resets the
> layout stateid rather than invalidating it, and that is the ordinary
> end of life for a return-on-close layout.  The validity check the
> walkers do apply is a policy filter, not a lifetime guarantee.
>
> Because pnfs_put_layout_hdr() can send a layoutreturn and sleep, a
> header pinned for a layout whose inode can no longer be grabbed is put
> after the RCU read-side critical section, not within it.
>
> Both ways the walk can end early report it.  A GFP_ATOMIC allocation
> failure aborts with -ENOMEM, and an inode that can no longer be
> grabbed -- igrab() fails from I_FREEING on, while the layout may still
> be valid and still name the deviceID -- aborts with -EAGAIN.  Either
> way the caller is told the collection is partial instead of receiving
> a short list it would read as "no references".
>
> No callers yet; no behavior change.
>
> Assisted-by: Claude:claude-fable-5
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c |  17 +++
>  fs/nfs/pnfs.c                          | 164 +++++++++++++++++++++++++
>  fs/nfs/pnfs.h                          |  29 +++++
>  3 files changed, 210 insertions(+)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 9caf4b3b45ae..12b7be95a9c3 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -2527,6 +2527,22 @@ static void ff_layout_cancel_io(struct 
> pnfs_layout_segment *lseg)
>  	}
>  }
> 
> +/* Called under @lo's inode i_lock. */
> +static bool ff_layout_references_deviceid(struct pnfs_layout_hdr *lo,
> +					  const struct nfs4_deviceid *id)
> +{
> +	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
> +	struct nfs4_ff_layout_mirror *mirror;
> +	u32 dss_id;
> +
> +	list_for_each_entry(mirror, &flo->mirrors, mirrors)
> +		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++)
> +			if (memcmp(&mirror->dss[dss_id].devid, id,
> +				   sizeof(*id)) == 0)
> +				return true;
> +	return false;
> +}
> +
>  /*
>   * Un-pin every stripe node resolved from @id: in-flight I/O drains on 
> the
>   * old node through its own reference, the next I/O re-resolves.
> @@ -3155,6 +3171,7 @@ static struct pnfs_layoutdriver_type 
> flexfilelayout_type = {
>  	.get_ds_info		= ff_layout_get_ds_info,
>  	.free_deviceid_node	= ff_layout_free_deviceid_node,
>  	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
> +	.layout_references_deviceid = ff_layout_references_deviceid,
>  	.read_pagelist		= ff_layout_read_pagelist,
>  	.write_pagelist		= ff_layout_write_pagelist,
>  	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d9a181ed1eae..5ddc57b7db57 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2937,6 +2937,170 @@ pnfs_layout_reresolve_deviceid_byclid(struct 
> nfs_client *clp,
>  	}
>  }
> 
> +struct pnfs_deviceid_ref_args {
> +	const struct pnfs_layoutdriver_type *ld;
> +	const struct nfs4_deviceid *devid;
> +	struct list_head *result;
> +	bool found;
> +};
> +
> +static int pnfs_layout_deviceid_referenced_byserver(
> +		struct nfs_server *server, void *data)
> +{
> +	struct pnfs_deviceid_ref_args *args = data;
> +	struct pnfs_layout_hdr *lo;
> +	struct inode *inode;
> +
> +	if (server->pnfs_curr_ld != args->ld)
> +		return 0;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(lo, &server->layouts, plh_layouts) {
> +		inode = lo->plh_inode;
> +		if (!inode)
> +			continue;
> +		spin_lock(&inode->i_lock);
> +		if (NFS_I(inode)->layout == lo && pnfs_layout_is_valid(lo) &&
> +		    args->ld->layout_references_deviceid(lo, args->devid))
> +			args->found = true;
> +		spin_unlock(&inode->i_lock);
> +		if (args->found)
> +			break;
> +	}
> +	rcu_read_unlock();
> +	return args->found;
> +}
> +
> +/*
> + * pnfs_layout_deviceid_referenced_byclid - does any live layout of
> + * @clp's servers using @ld still reference deviceid @devid?
> + */
> +bool
> +pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld,
> +				const struct nfs4_deviceid *devid)
> +{
> +	struct pnfs_deviceid_ref_args args = {
> +		.ld = ld,
> +		.devid = devid,
> +	};

I like how this looks much better. Thanks for changing it!

Anna

> +
> +	if (!ld->layout_references_deviceid)
> +		return false;
> +
> +	nfs_client_for_each_server(clp,
> +			pnfs_layout_deviceid_referenced_byserver, &args);
> +	return args.found;
> +}
> +
> +static int pnfs_layout_collect_deviceid_refs_byserver(
> +		struct nfs_server *server, void *data)
> +{
> +	struct pnfs_deviceid_ref_args *args = data;
> +	struct nfs4_deviceid_ref *ref, *tmp;
> +	struct pnfs_layout_hdr *lo;
> +	struct inode *inode;
> +	LIST_HEAD(putme);
> +	bool matched;
> +	int ret = 0;
> +
> +	if (server->pnfs_curr_ld != args->ld)
> +		return 0;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(lo, &server->layouts, plh_layouts) {
> +		inode = lo->plh_inode;
> +		if (!inode)
> +			continue;
> +
> +		spin_lock(&inode->i_lock);
> +		matched = NFS_I(inode)->layout == lo &&
> +			  pnfs_layout_is_valid(lo) &&
> +			  args->ld->layout_references_deviceid(lo, args->devid);
> +		if (!matched) {
> +			spin_unlock(&inode->i_lock);
> +			continue;
> +		}
> +		ref = kzalloc_obj(*ref, GFP_ATOMIC);
> +		if (!ref) {
> +			spin_unlock(&inode->i_lock);
> +			ret = -ENOMEM;
> +			break;
> +		}
> +		/* NFS_I()->layout == lo under i_lock means the refcount has
> +		 * not reached zero: pnfs_put_layout_hdr() decrements to zero
> +		 * and detaches in the same critical section.
> +		 */
> +		pnfs_get_layout_hdr(lo);
> +		ref->lo = lo;
> +		nfs4_stateid_copy(&ref->stateid, &lo->plh_stateid);
> +		ref->cred = get_cred(lo->plh_lc_cred);
> +		spin_unlock(&inode->i_lock);
> +
> +		/* the pinned hdr does not hold the inode: grab it (and
> +		 * keep the superblock active) for use across RPCs
> +		 */
> +		ref->inode = nfs_igrab_and_active(inode);
> +		if (!ref->inode) {
> +			/* The layout may still name the deviceID, so report a
> +			 * partial list rather than silently shortening it.
> +			 * Defer the put: it can layoutreturn and sleep.
> +			 */
> +			list_add(&ref->node, &putme);
> +			ret = -EAGAIN;
> +			break;
> +		}
> +		list_add_tail(&ref->node, args->result);
> +	}
> +	rcu_read_unlock();
> +
> +	list_for_each_entry_safe(ref, tmp, &putme, node) {
> +		list_del(&ref->node);
> +		pnfs_put_layout_hdr(ref->lo);
> +		put_cred(ref->cred);
> +		kfree(ref);
> +	}
> +	return ret;
> +}
> +
> +/*
> + * Collect @clp's layouts referencing @devid onto @result as entries usable
> + * across sleeping RPCs; release with pnfs_layout_put_deviceid_refs().
> + * A negative return means @result is only a partial set.
> + */
> +int
> +pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld,
> +				const struct nfs4_deviceid *devid,
> +				struct list_head *result)
> +{
> +	struct pnfs_deviceid_ref_args args = {
> +		.ld = ld,
> +		.devid = devid,
> +		.result = result,
> +	};
> +
> +	if (!ld->layout_references_deviceid)
> +		return 0;
> +
> +	return nfs_client_for_each_server(clp,
> +			pnfs_layout_collect_deviceid_refs_byserver, &args);
> +}
> +
> +void
> +pnfs_layout_put_deviceid_refs(struct list_head *result)
> +{
> +	struct nfs4_deviceid_ref *ref, *tmp;
> +
> +	list_for_each_entry_safe(ref, tmp, result, node) {
> +		list_del(&ref->node);
> +		put_cred(ref->cred);
> +		pnfs_put_layout_hdr(ref->lo);
> +		nfs_iput_and_deactive(ref->inode);
> +		kfree(ref);
> +	}
> +}
> +
>  /* Check if we have we have a valid layout but if there isn't an intersection
>   * between the request and the pgio->pg_lseg, put this pgio->pg_lseg away.
>   */
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 9a5b8070f595..8dd892d875e3 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -184,6 +184,12 @@ struct pnfs_layoutdriver_type {
>  				   const struct nfs4_deviceid *id,
>  				   bool immediate,
>  				   struct list_head *put_list);
> +	/*
> +	 * Does @lo hold any reference to deviceid @id?  Called under
> +	 * @lo's inode i_lock; must not sleep.
> +	 */
> +	bool (*layout_references_deviceid)(struct pnfs_layout_hdr *lo,
> +					   const struct nfs4_deviceid *id);
> 
>  	int (*prepare_layoutreturn) (struct nfs4_layoutreturn_args *);
> 
> @@ -371,6 +377,29 @@ void pnfs_layout_reresolve_deviceid_byclid(struct 
> nfs_client *clp,
>  				const struct pnfs_layoutdriver_type *ld,
>  				const struct nfs4_deviceid *devid,
>  				bool immediate);
> +bool pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld,
> +				const struct nfs4_deviceid *devid);
> +
> +/*
> + * One live layout referencing a deviceID, collected for the
> + * CB_NOTIFY_DEVICEID DELETE recovery: the hdr is pinned, the inode
> + * igrab'd with its superblock active, and the layout stateid and
> + * cred snapshotted for TEST_STATEID.
> + */
> +struct nfs4_deviceid_ref {
> +	struct list_head node;
> +	struct pnfs_layout_hdr *lo;
> +	struct inode *inode;
> +	nfs4_stateid stateid;
> +	const struct cred *cred;
> +};
> +
> +int pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld,
> +				const struct nfs4_deviceid *devid,
> +				struct list_head *result);
> +void pnfs_layout_put_deviceid_refs(struct list_head *result);
>  int pnfs_layout_handle_reboot(struct nfs_client *clp);
> 
>  /* nfs4_deviceid_flags */
> -- 
> 2.53.0
