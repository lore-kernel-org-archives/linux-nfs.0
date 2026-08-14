Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A76133936B
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 20:02:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786737766; cv=none; b=SJ0j2d9Ftu0N+nYcXyjvdfKaELxD5vabM9wfht4SKbOY4n/nNsQdZ8mlVzGPw9DJsneYPWR8XoZY8/PvdK1p31NUBqUr3LoKXDWPZIPVF41Ozquy4/OmR7ra74GbxAFxbW8OAHLCwmQWlzF7e9ZQrbnj4l4DuOueLIdgkkOT7zY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786737766; c=relaxed/simple;
	bh=QfyIYPwQVMYJcsskvqlheennBV7yshFkdCV4SiXJtxE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=usKMsMTRnmzsxQLtkeb4mxFdKS30u2tdsAhd0W2HCEIS8oE/m8Z391HsrhokLcP41RsI1IrfyFs4pIzbZNPyyaVbb5IQFD2Yh+gdFeWv9tTyVazXaHHx0KfvUFuhCMOhEhM3y5vulzRyTSF5ScfZtWZVQwjp3BTiDyD21KUM980=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SesYUFna; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SesYUFna"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DBF7A1F00A3D;
	Fri, 14 Aug 2026 20:02:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786737765;
	bh=h1T1/tR/yszN/xC8azMp+NmBJB4NiWwGbykeyZLMJRA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SesYUFnaK6wPwC/VMA02bwQwmOccSKyHjYd5uwHJcK/nrKm5pAVtkEfesRTXvtckP
	 8fMCmVsNOE8jB/oiVg4K46n8jptzdWHWxDhkkfkWh2wYArVnlOTVJlAIDCSgvBoZts
	 nyK0s0r7A6PvJagGiZcUikjun2UQ2lZPFBTMH2AXF6vXFedjYvQz/S2OqEt6olRzyo
	 Jqq7FVsJ5SL9eU+tpcOKEmP4A9+KGdUNsWkM8BnDWzwIq2mOb1v/9XIxX8o9QRBn7J
	 UKudN0kzq3hxIBXmmPxKnHjUhxw/2SDxmYoHq6epWGy8DSYWNZiyciXd0IBP5/dzs2
	 +ECIhOkDrOejg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id EA674F4006F;
	Fri, 14 Aug 2026 16:02:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 14 Aug 2026 16:02:43 -0400
X-ME-Sender: <xms:Y3R_agulNs68hB_6K4b8XxVO3K_tliyEXy1eFrfqiTVh6D3kWnsOpQ>
    <xme:Y3R_aoT7PnEpQMf2vx2A5FCEucIBmKHdyH8o2I-drt4TeonjxmqJubU7S6ag97hDY
    vJ7a2wEi8TH79WHGPhCj_GHMzCDyQmtoeFLA9tNi6yv0MiJj6FnQo4>
X-ME-Proxy-Cause: dmFkZTFWzNV8Cvui3TwmJmesG6QbKTWtwdOqiRVHyr72N/VHPiYL+6VXIO29Vtm4p78JlL
    KaheeJ9/sd15jeA7rceET4QhfhMQq9YU8lgN+cPl7YzhxN7JAY7MQv7rbXgU3Q/MbQWsiE
    Jldcd+n8weGIaoaefPXV0Z+Z4syk2KbRBDE3Hwn25CjSoPJFu93Z4jgCh3R4fHt010KsZk
    zt4Sxs6JFNhBVKIrg9ytcCAA6P2Q5Ilxq5SwjqEo6c+PuoFJUdpYo3ZF5HwtykhhO7YOXS
    eCsDfXv5UGuuS1FDDvKng2SjO+kalK6VGyZRZKTWYiP8JQNpmQXoqfUk8qu1qLLPzaZJjj
    tl1A3llCbAIG492nfzR/RjYB3Xpqm1XoL4YD0YtLOw/B8XGq5srdNvzWMMOtephSpzS/3W
    7Fru/jECLzIMkY28Ru39dqKZZ1CjdHsMZGd+49Pu1r++xdnQQ4HaoH+IcDP9JoK3QPOWVF
    9htZ1i+/J5Z2f28cjJUy8tx2Net1euuOE1cmZGHH5bB/kYa4jHviantNRybEZ1lQWqLEta
    7bRZckAEp4ZVOqbGVhBKUAF46fBHotsG7ycVOfKmBWlQfRVKiANV6BR5IigERT8OnYSE3L
    yRwpHzdF0M8jx6Oo8apMPRDG/sJJUIJOqo6d2+78EfA8V0ZFEoh85fayFMVw
X-ME-Proxy: <xmx:Y3R_at4R3ojv7uAf_OKUXD5U5coo7y8cdiGudnTZn7SP5L-BoxA4hw>
    <xmx:Y3R_ag6HRaA6qqG5oMbbuA8EEPaV1UJzixVhDJIYEitzpSnfs8P9AA>
    <xmx:Y3R_avR9me0ijjjiX9DbpImChWHjt5_hVxN3GOBPQxQ0tVDqTMIHwQ>
    <xmx:Y3R_ao_p5Yjv0jn5LzASJ7v5dvlEClXLtn7OgIB1zMm4rgki9wFngA>
    <xmx:Y3R_agauCbU4ccI4dW04fcp9pya3HKdL7BNXMyEqEPo93gzBgDLKlGAE>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C95087811F0; Fri, 14 Aug 2026 16:02:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AEl4SWtoThqF
Date: Fri, 14 Aug 2026 16:02:23 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Ameer Hamza" <ameer.hamza@truenas.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 alexander.motin@truenas.com, caleb.stjohn@truenas.com
Message-Id: <032eae35-e958-4c87-9185-3896250eb7e1@app.fastmail.com>
In-Reply-To: <20260814172507.1474519-1-ameer.hamza@truenas.com>
References: <20260814172507.1474519-1-ameer.hamza@truenas.com>
Subject: Re: [PATCH] sunrpc: treat empty auth.unix.gid replies as negative entries
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 14, 2026, at 1:25 PM, Ameer Hamza wrote:
> When rpc.mountd cannot resolve a uid (getpwuid() or getgrouplist()
> failure, e.g. while winbind or sssd is briefly unreachable), it
> answers the auth.unix.gid upcall with zero groups. unix_gid_parse()
> installs that as a valid positive entry, and svcauth_unix_set_client()
> then replaces the credential's group list with the empty one on
> every request, RPCSEC_GSS included via svcauth_gss_set_client().
> One failed lookup strips that uid of all supplementary groups on
> every export for up to mountd's configured TTL (30 minutes by
> default), long after the NSS backend has recovered.
>
> mountd cannot send an empty list for a successful lookup, since
> getgrouplist(3) always includes at least the user's primary group,
> so a zero-group reply can only mean the lookup failed. Record it as
> a negative entry: unix_gid_find() then returns -ENOENT and
> svcauth_unix_set_client() keeps the groups the RPC credential
> already carries. This is the fallback that
> commit 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a
> gid list when using AUTH_UNIX authentication") promised when no
> answer is available, and the same state try_to_negate_entry()
> already creates when no listener holds the channel open.
>
> Fixes: 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a gid 
> list when using AUTH_UNIX authentication")
> Assisted-by: Claude:claude-fable-5
> Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>

Looks like the same bug exists for the new mountd netlink
mechanism. Since that instance of the bug arrived in a
different commit, that fix needs to be a separate patch
with its own Fixes: tag.

Can you make this a two-patch series?


-- 
Chuck Lever
