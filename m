Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F8ED57267D
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:05:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789063551; cv=none; b=OiGngIaI6UL8eOxIZ8kj7V/BfuL/Nufet+BQoVP7+KXG/JGZ1Zblr7aNWCedSu3KW0spxtIyumJwefJzM4DwNXg1aEtefMmcatDLLeB5NxsTPfXvJbX1YrdeDc1Jpck096T15jif4FwQDri3GCc2aDUK6fC2AQyCbUpduZvcCPs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789063551; c=relaxed/simple;
	bh=zuwpHUUbZtUoSmxarm/ZJQB8SxWyPI+KhvdJfNRjKEo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=AV3fedPsQbSVpQvDsXQylqKYtWT5KbB0j7QEEMTsPNZnZQqJE+s9uSgOmwxq5ygZOtXAAEJEeO06JtuX1RzdPaypHfrOHlwdIyPFTBruuhmaYazBAFpu5zt4JtQUxKCPqwUdHoU+xpbnR/s8YQuYKBfrZcmueNh/9WwlR5Olgjo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Q0to2GXb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Q0to2GXb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9A0BB1F00898;
	Thu, 10 Sep 2026 18:05:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789063548;
	bh=MVA5sD2p0rgqYMhSuiH9kT4M4yVMzOpAZfYuuvn5nL4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Q0to2GXbuNe2qQeZBWyFT0MZNSzu7peyiqGtL7WNCJ9Zf32Zvp/KJpcwV9vKJvHM+
	 PTWASNxqmwF4PmH/eBYqyioxbeVv3wbp+o72IbF+Svxeu3hBpJazFff1eDpmm7Pgqb
	 prI9zrlozyyAPHSFTwkcX+4sx2+EfLsP6GgoU2pqj/oM2lZJSUeo8LVlPXMyuBkVB6
	 uy0y4xefyQEiaLgrXdu4+ltrQKLhkAn3tcC7B7XOW2mMt7T9/h+r/L+EghHDqqGw0s
	 rD3NnRFasGbmPBUvZQsMUoT4YWapBtdazlVZorjC5y8Y4oaOXvrcUR5tCHQ2o2DION
	 vpw9hAa7j51yw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id AC537F40067;
	Thu, 10 Sep 2026 14:05:47 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 10 Sep 2026 14:05:47 -0400
X-ME-Sender: <xms:e_GiauD7TJzvaZGz0_8-xOAETsUgnFpRjmFl4aX4Pkkym9OIhGSxfA>
    <xme:e_GiajVSIQUue72f3VFGB8bhzCqd_k14hVXk1iLDCUtxe8b5QIkHgWFx9HM2Js9Fi
    u-DrrZlKdC3_LMS8ddoUIqNx2iexsUyr-T-rqomWs_Wji2QRdjxXZ0>
X-ME-Proxy-Cause: dmFkZTE1jzOA4bi+zTx2TG+GV6ZosDsRCKGBjogDspvtvTQo2AVR/+O8XQ0eIi6gsALOeY
    BwRo2FqsVu0rAaRLux2uj8eec3h5KfVr7n1wya4iy0MiBiDjrnDj5fRpsOe/fJXilPcA6I
    TznFunCwrjSfW7pi8sGQ4YtTCKeM0Fx5Vj7aIe1f4ya+YFro4C97PKtGNrmWutZbgYcQT3
    QcQp0yWSMQGl9PD7wozGNCVzbwzFQCN8tZ6RMsdYgVUaVVIHzG1ORxj0mwHy5aN97mgs2a
    0S7dxHAEguyM1rEP68Ggkm3zhLBeGJe5Mi6qbXFawjplfu6r6KzUfRZVRuACRud7WEHoCA
    OcXKWLuLTj5G36KEjqGO+8nYbxkvfYXGbEOrVdFtVhAM2fg9BrKwmRGrIec/pIBBKfceNM
    sT9tNnNMP3ybXuO8FIH96vemaUGLUV2cN5LvsNLyo6PrA4xN1mcvZ+4bK7WhYcyPbWCbCn
    cyo4sza+WjWrzSOvxWlyRRIoRq7pWRPOR4xrhwkgWczJ3T7d1AwcW2CY3Pb+S4aq4yzti2
    58GTP2vpSjWdlQOe8Dll+sqa3zLWSJlnB/+E9kqGoDfoEspowbHeh6cxuq2bUvof1KoOTQ
    Tmz93gbvFh2+C8QDSBABxZjs2ciB4m6U5KP6yXAxXDJdeXbmFwqzUUHRByYQ
X-ME-Proxy: <xmx:e_Giam6j9aYTmSNsl9jyu5G-2z2drmVCpmbtKsvIk69uvbYwIzOJEA>
    <xmx:e_GiagnYgmMVnn0E6GKW350dzxIL5kv5YjudzVoZKV_S6AJ2bEAp9g>
    <xmx:e_Giajrmzip7Uxnj0AfLBe5xQDUUScbLq5hqTdrStL6Hi04dqvz3jA>
    <xmx:e_GianuCtfiJb3-79_Owpd2pAEqnvYZ7gZX_shkTEOAeLF8Qj7eMrg>
    <xmx:e_GiagFswV9Tym3M-B4QT8ZSOsjlG9DYPGkUJu_Yixt5skeAj_wnKsyg>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8596AB6006F; Thu, 10 Sep 2026 14:05:47 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AYX8IyvXV9bc
Date: Thu, 10 Sep 2026 14:05:27 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 "Jonathan Curley" <jcurley@purestorage.com>,
 "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Junrui Luo" <moonafterrain@outlook.com>
Message-Id: <951d0a1a-61f8-4da7-b7bb-228ddbea8dc7@app.fastmail.com>
In-Reply-To: <8E0D2ECA-5BB5-4440-90BE-E9486F159CB4@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
 <e23b6124f8236b2f71976507e140b33df5918b7c.1788530385.git.bcodding@hammerspace.com>
 <fdea855d-9921-44ef-9e0a-e7e253696c91@app.fastmail.com>
 <8E0D2ECA-5BB5-4440-90BE-E9486F159CB4@hammerspace.com>
Subject: Re: [PATCH v3 17/24] pNFS: Add deviceid reference query and collection walkers
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Sep 10, 2026, at 1:24 PM, Benjamin Coddington wrote:
> On 10 Sep 2026, at 12:58, Anna Schumaker wrote:
>
>> Hi Ben,
>>
>> On Fri, Sep 4, 2026, at 12:53 PM, Benjamin Coddington wrote:
>>> The CB_NOTIFY_DEVICEID DELETE race recovery (RFC 8881 Section
>>> 18.40.4) needs to ask whether any live layout still references a
>>> deviceID, and to enumerate those layouts for TEST_STATEID.  Add a
>>> layout_references_deviceid hook (sibling of reresolve_deviceid; the
>>> flexfiles implementation memcmps each mirror stripe's decoded devid,
>>> valid independent of the pinned device node) and two walkers over
>>> the byserver pattern:
>>>
>>> - pnfs_layout_deviceid_referenced_byclid(): boolean existence query,
>>>   early-stopping, entirely under i_lock.
>>> - pnfs_layout_collect_deviceid_refs(): collects each matching layout
>>>   with the hdr pinned, the inode grabbed with its superblock active
>>>   (a pinned hdr does not hold its inode -- same discipline as the
>>>   bulk-destroy walker), and the layout stateid and cred snapshotted
>>>   under i_lock, so the caller can issue sleeping RPCs against the
>>>   collection.
>>>
>>> The collection walker pins each matching header with a plain
>>> pnfs_get_layout_hdr(), which cannot resurrect a dying header because
>>> the walker holds i_lock and has checked NFS_I()->layout == lo.
>>> pnfs_put_layout_hdr() drops the last reference under i_lock --
>>> refcount_dec_and_lock() only decrements one to zero once it holds the
>>> lock -- and clears NFS_I()->layout in that same critical section,
>>> before it unlocks and frees.  So a header still installed on its inode
>>> cannot have reached a zero refcount.
>>>
>>> That argument deliberately does not rest on NFS_LAYOUT_INVALID_STID.
>>> A header can reach its final put while still valid: a full
>>> LAYOUTRETURN ends in pnfs_layoutreturn_free_lsegs(), which resets the
>>> layout stateid rather than invalidating it, and that is the ordinary
>>> end of life for a return-on-close layout.  The validity check the
>>> walkers do apply is a policy filter, not a lifetime guarantee.
>>>
>>> Because pnfs_put_layout_hdr() can send a layoutreturn and sleep, a
>>> header pinned for a layout whose inode can no longer be grabbed is put
>>> after the RCU read-side critical section, not within it.
>>>
>>> Both ways the walk can end early report it.  A GFP_ATOMIC allocation
>>> failure aborts with -ENOMEM, and an inode that can no longer be
>>> grabbed -- igrab() fails from I_FREEING on, while the layout may still
>>> be valid and still name the deviceID -- aborts with -EAGAIN.  Either
>>> way the caller is told the collection is partial instead of receiving
>>> a short list it would read as "no references".
>>>
>>> No callers yet; no behavior change.
>>>
>>> Assisted-by: Claude:claude-fable-5
>>> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
>>> ---
>>>  fs/nfs/flexfilelayout/flexfilelayout.c |  17 +++
>>>  fs/nfs/pnfs.c                          | 164 +++++++++++++++++++++++++
>>>  fs/nfs/pnfs.h                          |  29 +++++
>>>  3 files changed, 210 insertions(+)
>>>
>>> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
>>> b/fs/nfs/flexfilelayout/flexfilelayout.c
>>> index 9caf4b3b45ae..12b7be95a9c3 100644
>>> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
>>> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
>>> @@ -2527,6 +2527,22 @@ static void ff_layout_cancel_io(struct
>>> pnfs_layout_segment *lseg)
>>>  	}
>>>  }
>>>
>>> +/* Called under @lo's inode i_lock. */
>>> +static bool ff_layout_references_deviceid(struct pnfs_layout_hdr *lo,
>>> +					  const struct nfs4_deviceid *id)
>>> +{
>>> +	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
>>> +	struct nfs4_ff_layout_mirror *mirror;
>>> +	u32 dss_id;
>>> +
>>> +	list_for_each_entry(mirror, &flo->mirrors, mirrors)
>>> +		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++)
>>> +			if (memcmp(&mirror->dss[dss_id].devid, id,
>>> +				   sizeof(*id)) == 0)
>>> +				return true;
>>> +	return false;
>>> +}
>>> +
>>>  /*
>>>   * Un-pin every stripe node resolved from @id: in-flight I/O drains on
>>> the
>>>   * old node through its own reference, the next I/O re-resolves.
>>> @@ -3155,6 +3171,7 @@ static struct pnfs_layoutdriver_type
>>> flexfilelayout_type = {
>>>  	.get_ds_info		= ff_layout_get_ds_info,
>>>  	.free_deviceid_node	= ff_layout_free_deviceid_node,
>>>  	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
>>> +	.layout_references_deviceid = ff_layout_references_deviceid,
>>>  	.read_pagelist		= ff_layout_read_pagelist,
>>>  	.write_pagelist		= ff_layout_write_pagelist,
>>>  	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 2f54b22d0e21..23f12eec99d7 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -2937,6 +2937,170 @@ pnfs_layout_reresolve_deviceid_byclid(struct
>>> nfs_client *clp,
>>>  	}
>>>  }
>>>
>>> +struct pnfs_deviceid_ref_args {
>>> +	const struct pnfs_layoutdriver_type *ld;
>>> +	const struct nfs4_deviceid *id;
>>> +	struct list_head *result;
>>> +	bool found;
>>> +};
>>> +
>>> +static int pnfs_layout_deviceid_referenced_byserver(
>>> +		struct nfs_server *server, void *data)
>>> +{
>>> +	struct pnfs_deviceid_ref_args *args = data;
>>> +	struct pnfs_layout_hdr *lo;
>>> +	struct inode *inode;
>>> +
>>> +	if (server->pnfs_curr_ld != args->ld)
>>> +		return 0;
>>> +
>>> +	rcu_read_lock();
>>> +	list_for_each_entry_rcu(lo, &server->layouts, plh_layouts) {
>>> +		inode = lo->plh_inode;
>>> +		if (!inode)
>>> +			continue;
>>> +		spin_lock(&inode->i_lock);
>>> +		if (NFS_I(inode)->layout == lo && pnfs_layout_is_valid(lo) &&
>>> +		    args->ld->layout_references_deviceid(lo, args->id))
>>> +			args->found = true;
>>> +		spin_unlock(&inode->i_lock);
>>> +		if (args->found)
>>> +			break;
>>> +	}
>>> +	rcu_read_unlock();
>>> +	return args->found;
>>> +}
>>> +
>>> +/*
>>> + * pnfs_layout_deviceid_referenced_byclid - does any live layout of
>>> + * @clp's servers using @ld still reference deviceid @id?
>>> + */
>>> +bool
>>> +pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
>>> +				const struct pnfs_layoutdriver_type *ld,
>>> +				const struct nfs4_deviceid *id)
>>> +{
>>> +	struct pnfs_deviceid_ref_args args = {
>>> +		.ld = ld,
>>> +		.id = id,
>>> +	};
>>
>> I was wondering if we could go with different names for the members
>> of this struct? "ld" and "id" look very similar, and at first glance
>> I thought you were assigning the same values twice here.
>
> Sure we can.. there's precedent for "ld" being used to refer to
> pnfs_layoutdriver_type.  Should we change them all?  Happy to reversion and
> resend, or let you re-write it as well.  Let me know what's most helpful.

I think just adjusting the naming in this patch is enough. You could even
leave "ld" alone and change "id" to something like "devid" and I'd be happy.

Anna

>
> Ben
