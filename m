Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A37BD39B48D
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 17:24:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789061076; cv=none; b=TeAh7HmBSlzuDlBcQy0tNsoUZoFQZFbd1Uj1760ndNzvNbXBkEHqKaPalGz05waVKBw8bXeDgkqBoiGs2w7OIGlVhviJyK7C9t2mux0BQgRDKMZzIbRkUXfgKV4H1yBwcv5c/HjwsZY/4ivTzhufSGc1WCJ99KS/KR3CBvswvYE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789061076; c=relaxed/simple;
	bh=vB3mtokjRG7HZ44lkJTGjffE0vo/UJOrpT46CTxsVZU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=lN2zHlLFRV8uMEYmC4cybfghTBEHtFP5bfHpYH4ZXmRFu+3UXy45lVIBFv5qwjWuy61vzN/oUhUHti/S8Oe3+1rlDiB5TjbcvPmTfEVFFQPx8ILE7J7UJ7/aN0epK4ytp0V0km3r0kKCspZiWYgiE7i5vC3ukesu3rNipEaPj9Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=SX/yDt/f; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="SX/yDt/f"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4b3a61bdf22so24010b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 10:24:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789061049; x=1789665849; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=2O6OTqYys9DViIcXLIrs2B7MzcsSL45loi3orUvptDY=;
        b=SX/yDt/f/DQa259d/FQeOJkHXFmfD2XFTg2o1uXvaJNqbhH8fL51TKQcGoGuW8t7kN
         +D+G1Zj52AC1vRbY/O9NplZgiXlUIfo6Jcw0Exj2Jq54UIgQr2PriZ6HL5T0bIdPYi4o
         JezxCEYOz37sL3ctyRAnGO9GrgI49PwUM+pIxzWqIl9nnjbyOyJvEWVO4ggTM9pDksU2
         1ooUEKl6hZlI2Pi4RIVLnaGmKW4hakvPO6oUiuseA+Vs9HcMPfckXcIKcZTON8cMswnO
         QsX1RMpXRn714FYe6ECvHeTW3rsv2T7T6UvaUKRbZsYTCfpus9BADDkyoknai4XU93Li
         cLyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789061049; x=1789665849;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=2O6OTqYys9DViIcXLIrs2B7MzcsSL45loi3orUvptDY=;
        b=gUrYHCXFECAxsOlQzeVmK42RQ1M52XxrBZQLbtmw1ohQBxDkKnCgAOyFET0rFEkWFn
         kE834pe4z0rtrdQhz53Vyi2M6iOg3VV1Femsm/q074sS9o+2Cd13AVIrK7NbV4ta7dCy
         eRzc5mrmD1dCsM4VNyJRgdpYr7u7KX7pJ+A/vy6YuqqkfGsHdZ3mIbzAa6L08Ca8xNfL
         TPY07DTej9TuEgpIzO1MwxSrHHltiFZG+tl1swm38DDQRN3ZYS9jmx62CwPo8IWb/9go
         D+H4woIB4jqBjs1fEPE7gWYoAjCdXwoa2JHpwyen1QEVY7BPXPVJ/iaoFMgXLqreFeB6
         I7sg==
X-Forwarded-Encrypted: i=1; AKwUvBz6hRXVG/wP4iISKaUqhbCvX4IxS2MV4o55HrJNnEnC+ZEii+dyTtdFzqelyc9tY/8tVV7BaASv1aQ=@vger.kernel.org
X-Gm-Message-State: AFuF++nC7vQsCn7Yy9D85kCdoEMEiOY86gKP8sUnlI/EaAsMp4QwLGn6
	en3RrvEwq60LNiVd/FoLynYI6Lm14BEbdJmXQbnLgdFl/YblIyjJnOINGeUOqWTcRvM=
X-Gm-Gg: AYBFou0bMPAloWTtB+VenlmOyJOle3gUYzmIvEPBopNuyioHbuQdoQEwa+lPe/8uw30
	S4hBshRot6jjRV4VAK7E4bRTelhH6URvbSMnHVCVmzc3nlgRkZVenfzCDhCAUwv6ki+BZSxof4X
	bnzJiU/s/nJ0GxrcLh2T2WWXvC4HN4CLtcf3Uxsz1teOCL4krj65WedbMu61R58ZEUjTHirkbZz
	9Piiny8vb3lDJ6MwauFidhEeRaAvrou5ETG1rg8WI1u/qy1dCBvdHxvHC093H2q6I/y8UslPljZ
	J7LsFN6uhikF0vdN7xYuK+YAZIYSn07C7cUjenkN3wumP36kXz1z3RP+PstbvbRVvamFLwX6fFA
	vwfc9qL4djDBcN+3gzjdNATmW7cxG9nDxyxHcUuUnCfPtQBtUADgbxAoJ8AVXqtZh5sq61mHJka
	y7D+cwLnLRdW2flM4CTvCibg7InyEK0g3j4NnohrjZ/VnlI4DbfJb/mdrQt7rHaf8Wm+PrtmbUV
	L2N0D68H15+SlcDE2SnRgjCvUiLyQ==
X-Received: by 2002:a05:6808:2e46:b0:4b9:a88b:888d with SMTP id 5614622812f47-4c31c725778mr23918b6e.35.1789061048611;
        Thu, 10 Sep 2026 10:24:08 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b971c8ed6asm19701168b6e.17.2026.09.10.10.24.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 10 Sep 2026 10:24:08 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 Jonathan Curley <jcurley@purestorage.com>, Mike Snitzer <snitzer@kernel.org>,
 Jeff Layton <jlayton@kernel.org>, Junrui Luo <moonafterrain@outlook.com>
Subject: Re: [PATCH v3 17/24] pNFS: Add deviceid reference query and
 collection walkers
Date: Thu, 10 Sep 2026 13:24:05 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <8E0D2ECA-5BB5-4440-90BE-E9486F159CB4@hammerspace.com>
In-Reply-To: <fdea855d-9921-44ef-9e0a-e7e253696c91@app.fastmail.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
 <e23b6124f8236b2f71976507e140b33df5918b7c.1788530385.git.bcodding@hammerspace.com>
 <fdea855d-9921-44ef-9e0a-e7e253696c91@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 10 Sep 2026, at 12:58, Anna Schumaker wrote:

> Hi Ben,
>
> On Fri, Sep 4, 2026, at 12:53 PM, Benjamin Coddington wrote:
>> The CB_NOTIFY_DEVICEID DELETE race recovery (RFC 8881 Section
>> 18.40.4) needs to ask whether any live layout still references a
>> deviceID, and to enumerate those layouts for TEST_STATEID.  Add a
>> layout_references_deviceid hook (sibling of reresolve_deviceid; the
>> flexfiles implementation memcmps each mirror stripe's decoded devid,
>> valid independent of the pinned device node) and two walkers over
>> the byserver pattern:
>>
>> - pnfs_layout_deviceid_referenced_byclid(): boolean existence query,
>>   early-stopping, entirely under i_lock.
>> - pnfs_layout_collect_deviceid_refs(): collects each matching layout
>>   with the hdr pinned, the inode grabbed with its superblock active
>>   (a pinned hdr does not hold its inode -- same discipline as the
>>   bulk-destroy walker), and the layout stateid and cred snapshotted
>>   under i_lock, so the caller can issue sleeping RPCs against the
>>   collection.
>>
>> The collection walker pins each matching header with a plain
>> pnfs_get_layout_hdr(), which cannot resurrect a dying header because
>> the walker holds i_lock and has checked NFS_I()->layout == lo.
>> pnfs_put_layout_hdr() drops the last reference under i_lock --
>> refcount_dec_and_lock() only decrements one to zero once it holds the
>> lock -- and clears NFS_I()->layout in that same critical section,
>> before it unlocks and frees.  So a header still installed on its inode
>> cannot have reached a zero refcount.
>>
>> That argument deliberately does not rest on NFS_LAYOUT_INVALID_STID.
>> A header can reach its final put while still valid: a full
>> LAYOUTRETURN ends in pnfs_layoutreturn_free_lsegs(), which resets the
>> layout stateid rather than invalidating it, and that is the ordinary
>> end of life for a return-on-close layout.  The validity check the
>> walkers do apply is a policy filter, not a lifetime guarantee.
>>
>> Because pnfs_put_layout_hdr() can send a layoutreturn and sleep, a
>> header pinned for a layout whose inode can no longer be grabbed is put
>> after the RCU read-side critical section, not within it.
>>
>> Both ways the walk can end early report it.  A GFP_ATOMIC allocation
>> failure aborts with -ENOMEM, and an inode that can no longer be
>> grabbed -- igrab() fails from I_FREEING on, while the layout may still
>> be valid and still name the deviceID -- aborts with -EAGAIN.  Either
>> way the caller is told the collection is partial instead of receiving
>> a short list it would read as "no references".
>>
>> No callers yet; no behavior change.
>>
>> Assisted-by: Claude:claude-fable-5
>> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
>> ---
>>  fs/nfs/flexfilelayout/flexfilelayout.c |  17 +++
>>  fs/nfs/pnfs.c                          | 164 +++++++++++++++++++++++++
>>  fs/nfs/pnfs.h                          |  29 +++++
>>  3 files changed, 210 insertions(+)
>>
>> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
>> b/fs/nfs/flexfilelayout/flexfilelayout.c
>> index 9caf4b3b45ae..12b7be95a9c3 100644
>> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
>> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
>> @@ -2527,6 +2527,22 @@ static void ff_layout_cancel_io(struct
>> pnfs_layout_segment *lseg)
>>  	}
>>  }
>>
>> +/* Called under @lo's inode i_lock. */
>> +static bool ff_layout_references_deviceid(struct pnfs_layout_hdr *lo,
>> +					  const struct nfs4_deviceid *id)
>> +{
>> +	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
>> +	struct nfs4_ff_layout_mirror *mirror;
>> +	u32 dss_id;
>> +
>> +	list_for_each_entry(mirror, &flo->mirrors, mirrors)
>> +		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++)
>> +			if (memcmp(&mirror->dss[dss_id].devid, id,
>> +				   sizeof(*id)) == 0)
>> +				return true;
>> +	return false;
>> +}
>> +
>>  /*
>>   * Un-pin every stripe node resolved from @id: in-flight I/O drains on
>> the
>>   * old node through its own reference, the next I/O re-resolves.
>> @@ -3155,6 +3171,7 @@ static struct pnfs_layoutdriver_type
>> flexfilelayout_type = {
>>  	.get_ds_info		= ff_layout_get_ds_info,
>>  	.free_deviceid_node	= ff_layout_free_deviceid_node,
>>  	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
>> +	.layout_references_deviceid = ff_layout_references_deviceid,
>>  	.read_pagelist		= ff_layout_read_pagelist,
>>  	.write_pagelist		= ff_layout_write_pagelist,
>>  	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 2f54b22d0e21..23f12eec99d7 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -2937,6 +2937,170 @@ pnfs_layout_reresolve_deviceid_byclid(struct
>> nfs_client *clp,
>>  	}
>>  }
>>
>> +struct pnfs_deviceid_ref_args {
>> +	const struct pnfs_layoutdriver_type *ld;
>> +	const struct nfs4_deviceid *id;
>> +	struct list_head *result;
>> +	bool found;
>> +};
>> +
>> +static int pnfs_layout_deviceid_referenced_byserver(
>> +		struct nfs_server *server, void *data)
>> +{
>> +	struct pnfs_deviceid_ref_args *args = data;
>> +	struct pnfs_layout_hdr *lo;
>> +	struct inode *inode;
>> +
>> +	if (server->pnfs_curr_ld != args->ld)
>> +		return 0;
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(lo, &server->layouts, plh_layouts) {
>> +		inode = lo->plh_inode;
>> +		if (!inode)
>> +			continue;
>> +		spin_lock(&inode->i_lock);
>> +		if (NFS_I(inode)->layout == lo && pnfs_layout_is_valid(lo) &&
>> +		    args->ld->layout_references_deviceid(lo, args->id))
>> +			args->found = true;
>> +		spin_unlock(&inode->i_lock);
>> +		if (args->found)
>> +			break;
>> +	}
>> +	rcu_read_unlock();
>> +	return args->found;
>> +}
>> +
>> +/*
>> + * pnfs_layout_deviceid_referenced_byclid - does any live layout of
>> + * @clp's servers using @ld still reference deviceid @id?
>> + */
>> +bool
>> +pnfs_layout_deviceid_referenced_byclid(struct nfs_client *clp,
>> +				const struct pnfs_layoutdriver_type *ld,
>> +				const struct nfs4_deviceid *id)
>> +{
>> +	struct pnfs_deviceid_ref_args args = {
>> +		.ld = ld,
>> +		.id = id,
>> +	};
>
> I was wondering if we could go with different names for the members
> of this struct? "ld" and "id" look very similar, and at first glance
> I thought you were assigning the same values twice here.

Sure we can.. there's precedent for "ld" being used to refer to
pnfs_layoutdriver_type.  Should we change them all?  Happy to reversion and
resend, or let you re-write it as well.  Let me know what's most helpful.

Ben
