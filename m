Received: from flow-b1-smtp.messagingengine.com (flow-b1-smtp.messagingengine.com [202.12.124.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8C7E35AC31;
	Sat, 15 Aug 2026 06:12:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.136
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786774366; cv=none; b=TJJPGgkAr1YvQpY2vX8H8WbXcc4kebJVYV0ZE4kPhTtyrTq/8CPZwnlvzQKptK0R6IvumujzMYvysyBVaupDnooMuHe/sdpz80XyY4VYUE4ZtM88ZDvSZHxteUl7BNiHb8EZi415hWSZ3eMHZxKCxtczLxtWQLHyvAhhFNXw+Sc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786774366; c=relaxed/simple;
	bh=LhR8c0uJD5vmMKPpq5fql3lKVodiEGpDUK8AVSpjA0c=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=h1V0thmUKFBAGkNovMCz1nP5luFivh+TIUbvL6Wn5tJLKZ4l3GOKXBYkUxMxlUgK9czXf0iXoG7vqseBJwmXu5rb6yX5Aaf8/C9a3O1miNY+mqVeq4LduR31UMDcDaTsS+41pOtkBl1TmASstt7PW8b9nlE3Z6/hJgehwLp0wtA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=AoR3GT7I; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=d+EuxqqD; arc=none smtp.client-ip=202.12.124.136
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="AoR3GT7I";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="d+EuxqqD"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailflow.stl.internal (Postfix) with ESMTP id 6254F13000ED;
	Sat, 15 Aug 2026 02:12:42 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Sat, 15 Aug 2026 02:12:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1786774362; x=1786781562; bh=WBr2XP+Ggu7nfQw/zua8SNhqER6HppbkA/I
	vUH9mkV4=; b=AoR3GT7I1dMZZPfTubFRsVBd9vGIaQ1iNul1hYLIVm8n7N3fhVF
	KA1FgrFT+8yyylKG8J6zlzGHO9mRJJE3oRWi/hrX8abGUZVsc3JoDK7k0krEpaby
	5r2cVs9lB+vryegkD/f0Txb42w4XfP7QwvQKzoMkGWc7IUhJwrMqpf++5+zZvt2W
	NPyfAcPi/0hG3j7e7E7dwqBlFuHGJcYbiSmLBf0bt07RqSig0R1YXhvtWurhXSpS
	y3lnfu9Nnp876yAPYpKGzcbIXFTFxZCcEC+2dzSZWT5F5WbmL+Gc+M+uAAvQe9/v
	u2zExmyox8sV/kjy5U7ZmKqSTTtftL4DtNA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786774362; x=
	1786781562; bh=WBr2XP+Ggu7nfQw/zua8SNhqER6HppbkA/IvUH9mkV4=; b=d
	+EuxqqDj73EBdT8xu4CNjp7VjlJAgCK61c7qSL7mTeMmVUkAMYZRsELfDPhHlXKZ
	yUYWe4ko4YA2x7+hWPfsN5ho1RvhoXm8he83eFCHOaWiJ+c7v9/QL5LoHtG2K3B4
	19SP+OYjJNkKUSRVrOGU7A01aGV4ESmGscEH8kPhNDKFF6SpGUVV4oPuj7BkRaNo
	TmMgbooYho5ZDgBrxdBukPOg9m1KdbqRXVOYmHWKs5jwZF8PNLsLr6NvlER9ftzo
	/rdGLoigzjWCha2d+WY63jZHeVLhnFmTpiQzlsZ29Volp8foCfScos9OEh4euXuQ
	nY5yvjwIQvQ5GRl0/CbsA==
X-ME-Sender: <xms:WQOAavGqAxn0hVty_ITGuq_aqxNdvu-HfvXjvjcs_WOWXeeBIuR1eg>
    <xme:WQOAakihGFVLZU3hT7GXXFk6OOLb8gw-N8BQbzX4TfA-Wkwr_GcZ7csKcidB171Dq
    gPXVSw0oIy_okgvUPB8lSA8z7Bcd0nM4LxfM1y8_tuKA5jr3Q>
X-ME-Received: <xmr:WQOAaodtDHoXrw__IN6oEqckYWnMvmtJx7csvT09tbvBAyKOFpII2FmNNaK5lvDpsg>
X-ME-Proxy-Cause: dmFkZTGcVa8oZUmAjRAYaPlE2MCRxkGJAUeAlJ7oHbJNJQURdJcPicT3Om5bmSixY6NZQR
    u/SKB+M7i7oHP5J66i5dtKkBRSyhjgFu0m8s9NacgIDgXryDpPjxLO0A1H2d5peJksnLTo
    wLutXQMP9d+vnZFBS1R7y3o5RmNLOr+7m8aaaCwhKVYdx0gQD9YWHXW8D77ovXcit2pc/i
    QXrDarhjquGazofB7b+4om2pfapZThFcN41BY64tM4JDBIw3AD181p09ojXeIN+RTRXah8
    Xh2e9yy3HL2YrgBFZZfsxS7pDV8kwrclLhSwzQO7aYkk5WlR0jtShJJuev+XImjq9H14j5
    QZudvwuXUFyvsZcazyY/KIzUYbyph+iSaMhXLPlP2BIG3Sxy8guDQLNXekPa2+1Ju649Go
    2Ynlu/sRRmMs2wVlCHubyQYV83LyOovzwHT9bOrOJ/ACq1krcAfRaRz8tl5VdU37Nshc6U
    mY1GzSMIUtrOMZV1iZOtkpyKBk/SGHuunli0En9xLstzFlzdaphqJ4wKTZI+8ZXU987S0p
    VfeWm6osTIc0LmfdVduLC2/Ye2o9q/8jkc5qWDL8lNjjgFEBn7PhtsaQpbw/usCxNf56n/
    WwERDbaBWbkMEv2558k6gKbALxOFVe3IVB5qrmtAVrkrb/ZQDaxjf4xWW/9A
X-ME-Proxy: <xmx:WQOAaqwSF3zhLo0qRwzBW-r9xWYhkILsO70CL4_dmfI7a8_kuYMExA>
    <xmx:WQOAaiaqy0estSrOoecUvEEYVAvEbF3tyo709ZnBhR1O0sxSilSxVg>
    <xmx:WQOAaoLi54PXFoU_wRYPGy9pNa6A0eS3E71P6Wr_Q_OMsQ-v6UmSlg>
    <xmx:WQOAap3YcJ4cOejTaojJbtMTOHtuv0ZDPw7f6Onrt96OblvobWeUoQ>
    <xmx:WgOAasnmT-FsGjo9ozFQdxA0K6sBKBsVKgBTWyuuSv7-sox2fhlyuPuq>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 02:12:35 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Al Viro" <viro@zeniv.linux.org.uk>
Cc: "Ian Kent" <raven@themaw.net>, "Chuck Lever" <cel@kernel.org>,
 "Jake Edge" <jake@lwn.net>, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Christian Brauner" <brauner@kernel.org>,
 "Jan Kara" <jack@suse.cz>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Amir Goldstein" <amir73il@gmail.com>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>, autofs@vger.kernel.org,
 linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
 codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject:
 Re: [PATCH RFC/RFT v2 00/18] Fix easy bits of the negative dentry problem
In-reply-to: <20260815050349.GR2636677@ZenIV>
References: <20260815042707.2535717-1-neilb@ownmail.net>
  <20260815050349.GR2636677@ZenIV>
Date: Sat, 15 Aug 2026 16:12:31 +1000
Message-id: <178677435166.2852630.7605780254213805860@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 15 Aug 2026, Al Viro wrote:
> On Sat, Aug 15, 2026 at 02:21:17PM +1000, NeilBrown wrote:
> 
> > Most of d_walk() already schedules as needed, but I
> >  think there is still room for improvement, but that can come later.
> 
> How the hell could it possibly schedule, when it might very well have
> grabbed rename_lock?  Confused...

I should have said:
  Most d_walk() instances abort when there is a need to schedule()
  so the caller can do that and retry.

That really only applies to shrink_dcache_tree() which it is a bit of
stretch to call "most", but apart from path_has_submounts() the others
are all called only after shrink_dcache_tree() has done its work, so
there won't be many (any?) negative dentries any more, so they won't need
to schedule().

I think path_has_submounts() could be changed to search mounts for
descendants, rather than searching descendant for mounts.
Maybe something like:

int path_has_submounts(const struct path *parent)
{
	struct mount *m;

	guard(mount_locked_reader)();
	list_for_each_entry(m, &real_mount(parent->mnt)->mnt_mounts, mnt_child)
		if (is_subdir(m->mnt_mountpoint, parent->dentry))
			return 1;

	return 0;
}

As it is only used by autofs which could have lots of mounts that might
be slower in the common case.  But it isn't clear there is problem here
that needs fixing.  autofs certainly *could* collect lots of negative
dentries, but does it?

> 
> Al, getting through the piles of mail at the moment (sick for a month)...
> 

My condolences.  Thanks for having a look at this series.

NeilBrown

