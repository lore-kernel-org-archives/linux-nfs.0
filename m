Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1F57524AF1
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 16:59:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789059568; cv=none; b=YSKtKcn7CVHXIiQteXwgvn7KC2utE1OHEDdeQKVgxEpu6yqAdgWxxkExEEypgl3/04kzu8iVc1g4qTkQLPTm8BHqF+dTw3sCE77rNJGMq7pUNXUj6HHTYP9SzYYA2NKnDwy62zstBSFWUPFvacaDvOGUYZdBg/Ps2z0z4fI8m2Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789059568; c=relaxed/simple;
	bh=lhB32S0LBg4AjlNBmkDq0m+rOhc7Svr7nscr01Ts9qM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=KpW0Ad2TCU/1eApZclfcOBJS4obTZQp2u6kPb0MQIqBpkIy3M1jcg9qpNYDpBe67x44NCDlT0evRURXa6qOOoHoseZWoF4sd8U7WhVjq4ExC8SBx03wsnUPqvK3zlYlvzfujGYwAsd8+AGExcD11PgoLyST+mOCjg3/tdUhhfsM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nuzWlr9c; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nuzWlr9c"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 378391F000FF;
	Thu, 10 Sep 2026 16:59:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789059559;
	bh=plkd5PwZIY8N63q1wDj2AOmda4D46EWB8wfyAbkZPh8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nuzWlr9cLmJDZnFVLePLPHz0BeSsbiyGBxFGziaBzXNVv5gJpX9jU7YqPEoOnoyqh
	 MXgnTB+xRtD6Zi9ncvP6ku8Uk9z2u5yCVDG3EDUQZlB7G9PSzDF/n5K+WtaUVVORhZ
	 KLcEYr6rHb82pI9v6HXZ9zGRyrDBHxYvrNx0DSsjJidCPUdrYMtffU6kkk1P34FJ/e
	 p+1W8doA2md/aq58Jx4aD1LWKL12VQcxw5QNVKcpYLLwo5m9JnW82j1uJs8fd6D4II
	 +05aBzHSwtJeZ+MPDlVb9amaeTOPp+DURoplsaMp8hN7JgGcgDKNW7dVqnS0T3CdEs
	 Rd0jUIPl1rsEA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 45F20F40066;
	Thu, 10 Sep 2026 12:59:18 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 10 Sep 2026 12:59:18 -0400
X-ME-Sender: <xms:5uGiaruSK55lXR2ifdNM-mj7H9E6G8dgZh0XZYismpn-8lg4KNPwgQ>
    <xme:5uGianRPVMi2gzpcxY857ZvU0820XMYLq--_FWAI8hXV5xCylPKZTwVGfcqQI4FFc
    7RDP3CxDsqbc3e45xaak2o9oxOUNOL-eTgmMGONikeWxr9UrWHPHtw>
X-ME-Proxy-Cause: dmFkZTEgS13n5Llb4ggrpj7LX4lv0VIpYLaXSoP85a3yt8bbUACgGJ8ZqorKGfZLzZwplh
    rwwMbIl20TOP6HGy5nMa03PuteRcq1U4pWSMHVtLVInR57Kr0cHuO73wIcytjBpf+lbi6P
    E8xqwI5YFGeD2LhLobNvIgHlkF/AHNKbOMsF7dcZwPo9vPPzlbPQ8s5DcoVXmRm1QwAZhA
    dIiiEYwxQ03zaIUYX8oWiaEaYzbhZ02d794WXNerxCvhBMCsNEx2+epSrwxl/KLLO00iPF
    De1fxCt6NKQvbwn8I2vNoA/Epgc+H7wkxyuztVypmy4bUs3S5xMV66HgHeuzOVukV1RBNs
    6VgGbhvwgQmzWv90CowgRpPdfHNXazWNCpYolE95+wAuVU/iZUPvQatNbyeoAdPsdyT5lJ
    FIRuZPW1OTDenQ9MbKGJdfrVVLhao4Dax7lSABGwOPvvgQw16WsMHZpzTbKD02g8XyiHkl
    GOPWJnZbO6ESCPmMFoTod7MEJu6pujNjZ2PkIFJS7SjPCF7qHJsBQFJg48JQqmSHaVeQse
    T3uc+OvKdfSCJ5yY2V1pcW6bF8UvVZuqMzv18Atz0Wy3V0B6iIaP25jrTrDvqbExv6JDJq
    ZCXYaJNg7t138paDz1AYrYOjApWq8Y/k98FFZdqUXyP3hSgvGrpFs55qK0ow
X-ME-Proxy: <xmx:5uGialGGy9mRel8Cn6kMd--oFUtqqv6ehy38gixtQhgmAGpW_IOoXQ>
    <xmx:5uGiarBksDVI2MR9EoA05oiHIFwJhHnX4p63WNN38oN0-HrdczuSYQ>
    <xmx:5uGialXThRBjxlsQNx2rHEcfZup5ZGCfTNK-qXx4-nKI_qykeL3gAg>
    <xmx:5uGiavq4gh8OZNlhPk62UKnLFSaMhdCd-07aiv0aSxZgC1pEvC7f8Q>
    <xmx:5uGiahS6K6OYu-62ZX8WcM0exaq-EdyOsLP9OOkhRooEaIz7ca2FNwnr>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1506DB6006E; Thu, 10 Sep 2026 12:59:18 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AYX8IyvXV9bc
Date: Thu, 10 Sep 2026 12:58:57 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Jonathan Curley" <jcurley@purestorage.com>,
 "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Junrui Luo" <moonafterrain@outlook.com>
Message-Id: <fdea855d-9921-44ef-9e0a-e7e253696c91@app.fastmail.com>
In-Reply-To: 
 <e23b6124f8236b2f71976507e140b33df5918b7c.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
 <e23b6124f8236b2f71976507e140b33df5918b7c.1788530385.git.bcodding@hammerspace.com>
Subject: Re: [PATCH v3 17/24] pNFS: Add deviceid reference query and collection walkers
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Ben,

On Fri, Sep 4, 2026, at 12:53 PM, Benjamin Coddington wrote:
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
> index 2f54b22d0e21..23f12eec99d7 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2937,6 +2937,170 @@ pnfs_layout_reresolve_deviceid_byclid(struct 
> nfs_client *clp,
>  	}
>  }
> 
> +struct pnfs_deviceid_ref_args {
> +	const struct pnfs_layoutdriver_type *ld;
> +	const struct nfs4_deviceid *id;
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
> +		    args->ld->layout_references_deviceid(lo, args->id))
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
> + * @clp's servers using @ld still reference deviceid @id?
> + */
> +bool
> +pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld,
> +				const struct nfs4_deviceid *id)
> +{
> +	struct pnfs_deviceid_ref_args args = {
> +		.ld = ld,
> +		.id = id,
> +	};

I was wondering if we could go with different names for the members
of this struct? "ld" and "id" look very similar, and at first glance
I thought you were assigning the same values twice here.

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
> +			  args->ld->layout_references_deviceid(lo, args->id);
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
> + * Collect @clp's layouts referencing @id onto @result as entries usable
> + * across sleeping RPCs; release with pnfs_layout_put_deviceid_refs().
> + * A negative return means @result is only a partial set.
> + */
> +int
> +pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld,
> +				const struct nfs4_deviceid *id,
> +				struct list_head *result)
> +{
> +	struct pnfs_deviceid_ref_args args = {
> +		.ld = ld,
> +		.id = id,
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
> index 2c0f5d4d38ab..d1bc4d1d8d4c 100644
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
>  				const struct nfs4_deviceid *id,
>  				bool immediate);
> +bool pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
> +				const struct pnfs_layoutdriver_type *ld,
> +				const struct nfs4_deviceid *id);
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
> +				const struct nfs4_deviceid *id,
> +				struct list_head *result);
> +void pnfs_layout_put_deviceid_refs(struct list_head *result);
>  int pnfs_layout_handle_reboot(struct nfs_client *clp);
> 
>  /* nfs4_deviceid_flags */
> -- 
> 2.53.0
