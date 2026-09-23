Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0DA353358B
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 16:36:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790181417; cv=none; b=el/ikrypMlBc7PfgqlG+2xWI8kho8FxIKCN4N2pfQommuWB0y0F8+TLVB7Upvk6/n3n4Sq2YCStqk3La8gjQXLo/jeQhqvzNEUl8A369nGVdnVZO5w+MTda7IAana8ZPUHiC7fWxytIWzjmWon8BmaiWtfG+Wy7wBYP+adkAAVo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790181417; c=relaxed/simple;
	bh=vw8ZNIYJtOxi67CJ1k1/pM7IzoevyLZ7eswOxbCZ0Us=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=qsWaea9jL0mOTKF6tBG3TJkDBvu6K/r68q93c2p4Yb5BCktZQm1GBvFrKbXzZsaH69on1/WWSfPZQfUc1Hlw5Jw9Yb5cC237EMMJDcgNL7VeNHHXDCxGEDBb1Sa7y1MpuEElKuJdZHEMT2duLDqAtY3zPNVIUv6rMVU7xKeRj+E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A8TG7xgF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A8TG7xgF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 548451F00893;
	Wed, 23 Sep 2026 16:36:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790181407;
	bh=lvsxqVk3+mh7SA2rvPxbMnYFCrC4Cf2k5HVFqa/dl0A=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=A8TG7xgF7+odyZ5SIcXp/6Cgi4mUQhNLy6w8H0elOHWRaS2/7Db5fp6dyBrF2KQ3I
	 WqPdGlrtMkVnMkJm+75+aWsUTEvt12fQpaWzhGw8GnYBAElNssiHECvZao4MiOjmTK
	 7EW88FWKs1J0ktaUhQ27U6IfDx7Ni7mO2RUOU5NusBw41y4q7Zx6hVT3fbHdcaCBJ1
	 DqvEfonpupuWmuSdCX/36d5WFPYwZ42l4bL9KDsCQsI4HfJkTqB/RPUYqT4m2Pjc4P
	 V7p7G/jHxb6aXXjmgXRsE0gBigIHvESerr8iyYIVrJMg8xiC30GzfroXnPSrZmmGXh
	 BXo7IXAd8wO8w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 77C46F40069;
	Wed, 23 Sep 2026 12:36:46 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 23 Sep 2026 12:36:46 -0400
X-ME-Sender: <xms:HgC0auwLQiI-suGqs2DPX31fc8Og8e9UT0ZfxdEV5q6VwC0JSfY_tg>
    <xme:HgC0alHv820yGNiwAeuo_ENLuSZOcxm7u9xE_gZWk1bhKjs4OVb6cupLIOwrCueE4
    yTOC8_2whm8m-LRGC67MtjWiqss9Rb7JMpS0hftTdVmUTcikTubAMcp>
X-ME-Proxy-Cause: dmFkZTEhifEaMmmYtreIJS7bxxzG/v5Z55yS+/h4rhbdFzEswlvT9fthotZ27xX5aTW5PP
    5WGo1UWVw8Ca1IUi2CmnMle7Qorc+a/8NZ6RrAvZRBveQeH16+UFZ5A0DwP2QBsEJzATDs
    Xo5PhQanvg0dkcEVI6uPj1p6Bi4vDsBJFg5CwDkhzRLC4GPluPwZvBpCXIahqdGoFhHU18
    K0IXQqL436R8Wqg0w68cZRypp+zzYzD0PF+ghZJyCBGOaTb5MgPw5PGcoKGCNeVOrkvhBG
    ksfDJkkNwSR0CDQBITzMXIRueIxolHODvbKUpcgVAfzb3WrlXeXGQLM5rDym1CCeBxcsDD
    62o8vfagbFRt+TadyMeqmN/ML8r1wypBjzCG+huQjqrrnJTU8vvTEI4EzrmUpbdugh/I6i
    dPee/i4KfuF7/+2uQUt7sGoKuwvy7fMXJoWK12LkNxNPwnPifYFVUV8THrSO/BT56hwNws
    QuNvSnAVTidb+W5e3JXN4Dh2T1bXkqwRvkqvRdDFOHt/gjpsKL20Bjunpl1HM+y1ONuf2/
    +WnH7rzFmJgjbHkPf1AGiuAgohAmHI3p1GUeLJwtO91Dhu0b/pTgd2KN6QhyOAbvfcdnBm
    DNnlbnSnrCA+KEqyaIWDfRmsGzBakbEtZGOfJ8zPmhJBpPy+f4Xc4bc6KdFA
X-ME-Proxy: <xmx:HgC0apriy-HN2SZ8-BHSZcQNdhMk6vVSEVnBdvSHlhqpPiPXLvH1vg>
    <xmx:HgC0asVFDVJlCTaK0rLi3goueYKKmsMAzm1iWGAzi7BjknOcpowFUQ>
    <xmx:HgC0akaHpktFumqeEwaQ9esBb-B3zx98-eJ4DIyPp52riAqxuCsOug>
    <xmx:HgC0apfcRY5HLDs5woIPeU4Dc3JO_icBNn0L3YxhIGvS568y7woX5A>
    <xmx:HgC0au3x_Bjq81KBg9b4iLSt4IxVMZgyTLIcAdPIwRXZ0tP4hyWBCDpu>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5BA8A780070; Wed, 23 Sep 2026 12:36:46 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AKn7rkj4-gHR
Date: Wed, 23 Sep 2026 12:36:15 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: "Rick Macklem" <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Message-Id: <9592daa8-4fe4-4e42-8baf-18899480da3a@app.fastmail.com>
In-Reply-To: <4fe822079c7154ba9f712ca9f7432d345dbc0783.camel@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
 <20260921-duplicate-reply-cache-v6-12-db5e13fd9944@kernel.org>
 <4fe822079c7154ba9f712ca9f7432d345dbc0783.camel@kernel.org>
Subject: Re: [PATCH v6 12/12] NFSD: Remove DRC checksum and payload_misses stat
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Wed, Sep 23, 2026, at 10:56 AM, Jeff Layton wrote:
> On Mon, 2026-09-21 at 09:22 -0400, Chuck Lever wrote:
>> nfsd_cache_csum() costs CPU on every non-idempotent request. It also
>> prevents the use of zero-copy RDMA receives for WRITE and SYMLINK
>> because the payload must be in the server's memory before the DRC
>> lookup can run.
>> 
>> Commit 01a7decf7593 ("nfsd: keep a checksum of the first 256 bytes
>> of request") added the checksum when a growing cache made XID
>> collisions easier to hit. It is the only guard against a reused
>> XID: two calls with the same procedure and equal-length arguments
>> match on every other key field.
>> 
>> Acknowledgment-based eviction retires a TCP or RDMA entry once the
>> transport confirms delivery and a later request from the same
>> connection visits its bucket. Three kinds of entry outlast that: the
>> entries a connection has issued since it last visited each bucket,
>> entries from a connection the client has since closed, which no
>> later request can evict because their transport is gone, and UDP
>> entries. Those wait out RC_EXPIRE. A collision needs the same XID
>> from the same address and port within that window. The Linux NFS
>> client's XIDs are sequential from a seed drawn with
>> get_random_u32(), so an XID recurs only after 2^32 calls, and a
>> rebooted client does not replay its previous sequence. A client that
>> restarts its sequence from a fixed value and rebinds its previous
>> source port within RC_EXPIRE is unguarded, but a client that repeats
>> a live XID cannot reliably match replies to its own calls anyway.
>> 
>> A call whose XID matches an entry sent on the same connection is
>> therefore a retransmit. TCP and RDMA deliver the queued reply or
>> drop the connection, so drop the call as though the entry were
>> still in progress rather than replaying it. A match from another
>> connection, or from UDP, is replayed as before.
>> 
>> Remove the checksum, the nfsd_drc_mismatch tracepoint, and the
>> payload_misses stat that counted checksum-detected collisions.
>> nfsd_dispatch() no longer snapshots the argument stream before
>> decoding, and with k_csum gone, struct nfsd_cacherep shrinks to 136
>> bytes.
>> 
>> The "payload misses" line disappears from
>> /proc/fs/nfsd/reply_cache_stats. No known userspace tool parses it.
>> 
>> Assisted-by: LLM
>> Signed-off-by: Chuck Lever <cel@kernel.org>

>> @@ -561,6 +492,13 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
>>  	if (rp->c_state == RC_INPROG)
>>  		goto out_trace;
>>  
>> +	/*
>> +	 * The connection that carried the reply delivers it, so a
>> +	 * retransmit on that connection needs no replay.
>> +	 */
>> +	if (rp->c_pos && rp->c_xprt == rqstp->rq_xprt->xpt_id)
>> +		goto out_trace;
>> +
>
> This patch seems to break pynfs RPLY14, which does a mkdir and then a
> replay of it later.

Note: The replay is on the same connection.


> The test is arguably broken though, since it does the replay over the
> same connection as the original request. I'm looking into fixing that
> (and will check for others that might be similarly problematic).

The new NFSD behavior is by design, suggested by Neil. Any client
that reuses an XID on the same connection is either broken or has
sent 4 billion requests in 120 seconds. Clients are supposed to
send retransmits on a different connection.

So, it's possible the test is wrong, but we need to think hard
about whether this new behavior will be a problem for existing
NFSv4.0 clients.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
