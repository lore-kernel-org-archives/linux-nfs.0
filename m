Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 173D6377A9C
	for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 22:10:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789942231; cv=none; b=oegCY8i5Ib3gnKoe7P5dObVkm4uI5EKG+Ti+5GbE9XcZovDeYXj7xvcS4aJRd28Ttz0PnSIJYz7CRk4fDSyTdsFIG6yflyRSer1cmc2ZLruwSJdd5lYfoApAASVShG/w3oKJTHG373vSs5RGVVNXJn/MVI+PrmErvmwvdx71LX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789942231; c=relaxed/simple;
	bh=y454K8lAoTq1KUMWtW4lpcW6vyfPhKFIsWBlKZiH9PE=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=nVCU7FAo4BpmfcY4jA0HjnzFFfWIr82jm6DM8WB9luoz8U9gE67j2UHchbvGQ65oOi0IfBlg/fRbgDbvyiGfcLCev38o8S+04ZlMQCoxvGELMbHViTVfgL+gGNjJY5/eHfuTDOboe0RYa7JQXG2/qAkzS6UpggjX3H2d7ejdO8A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=FPBt/40N; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=TqbHRQDj; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="FPBt/40N";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="TqbHRQDj"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 390761400065;
	Sun, 20 Sep 2026 18:10:28 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Sun, 20 Sep 2026 18:10:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789942228; x=1790028628; bh=z84Uqov7xaoUv/APvfmRMUL8W0ZRN8xuB+q
	isEoazJA=; b=FPBt/40N1OUfouBQDuca7O3lm0fGj36PjNZ6yN/Eyxg9P24X2NQ
	bx9nI0LJeGNIbvdZBwL9EZhA5ll9gdA2BHm7dTJWyLQTh4wqSzj7egJ4yJvx0UMh
	tqBKwHBIG1HHMuP2HbDULt3X8DfjE3i03Rz/Ue5Vpy7rdPbhgjNoX3kMMP9CMSH0
	ZzDBDuK8QcGiKGCpS4PENqtPWd2KrjuWS7sfHQbrDZMtkye3a7suI2D+GmP2XkRa
	690Hn4QPzUzK5pfZ+EClfi5s2lG8QKaO0OB4PIcTwHNpljTPbIUR0L0Bn5eUA1MC
	90fxhkv4yV+WXEIR8J47T5HBMVpe4e+90Gw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789942228; x=
	1790028628; bh=z84Uqov7xaoUv/APvfmRMUL8W0ZRN8xuB+qisEoazJA=; b=T
	qbHRQDjtVQggmQO61zpmSEtERfLY8hgcsc0Jxi4mh5zeG7Uq6cu4Rn71fytCyEtD
	EpBqqCCRdAeiPt+nBvPe9vmoIhJmLSva4FLUb2MUCg0acaYprRQnJMBoLyHgsOnZ
	G5TiUTL78lu0IoGimBPxKtKB+egDTuPuPgRAjxL9nA9Zxb3AKVOicNtdiWxALV5P
	e76C/3eCLJWlD3eOvB6m7IE0QMoMhyaPeBPCLSW8bUosGWeNeo7zsxsbU5WELZNr
	XDammltbbvFCOC5eF1bEARPLhqhFIGs4uhTKs+OvfIO+RN0MTAxgtw7EoKBWNYBb
	VPiOUzWTZ6W8wsF5tvvJA==
X-ME-Sender: <xms:1FmwavaA3ROd7Jwdc-ZugFEp7QPn0lehoD5h2F1Ugb62g7C9tfQORg>
    <xme:1FmwagrxwqxnBGFLPt4p0ZTKG9WEbElRuQoGeOMlG4UPD1wGsz0iytGRBOpNtMfQa
    jMiiVCYyZ6vGQzYOWk2w2hhRSqMOyH-neaDlGqDaZe4Uckwwjs>
X-ME-Received: <xmr:1FmwakN5C4CQKBtLEIRDm327gNYkGGzqKUS85oFP-_e4gxXQBPhQwG__Qh5JQD_LiYgEGi-qrdojvbh4UwEkgcMlCzG3tXU>
X-ME-Proxy-Cause: dmFkZTFGpokcgX4lYUWpQJ6LNLnCwfgOuimCQpdu+bJZsc02WM63DfdVkmRq1j942jimXM
    zblGwb6k+8KeMUD4LKb41yQ0FzJMBpJ0P+kdScxIdkDPjglEYfyoQGqYCnnb3sPJ3lxEdx
    hqX0V74whrqMtS3VymaDY3EdFW7HZaKvfN9huwsRi3/cHFI2b3YdFbPIiu94kqIDVOnTqg
    NaCgn7cBsnC6gOP6wsZKcIt15otST4g8Z1yV9rBixroDgo+4M7vQ7lf9ngTU+InmWr8PvZ
    QwyZjWIl2599WTJLdxQGtNiR8tANEtYGEkFkomkcJh9H8P0nCJircaPia2ITtNPNiXG9fU
    AixerQdX73N4eLaLIagrDs73j62BmeLlrYKNc4FStkpuLqpHlu1fAC2RPewA3JbwdPr8Xn
    Q3ojIdniTUqHx4heNqGq2irbUNsbe5QlIHjlTNUnw5XFl8NX/egYIIFSfcdbPkcMdVicqi
    PektoU8U1EpTJt0zcKKfp9ocivYOBYJfO/QpTc9jl7SrHbO3O/tynhKe2YgkOE5M9Cptex
    AEBgH7IjLK++Q2SnMTjPSYA4l0cV5JEkhuaQRtVA33Fms4R57F8ePc3GDUcNVanw+aQmBQ
    jez9jXNknatg/GOXmHv8ma95cPBsOFsw07lLiB8F2UqXhBWC8uxa/tAzoBuw
X-ME-Proxy: <xmx:1FmwarpBSEZPA_8ZLwztsxEJjbNk18-2DhqkUIAzsv70306AZsiXSA>
    <xmx:1Fmwapfs_QKWYXuCWM-UpQbMunRUvFNres33j-x0yji58zZnGH_Yqw>
    <xmx:1FmwahTGLshD7v7r0NJ33Jt0c5FBHp7LdRvPeOIHvOdFI9CpSij02A>
    <xmx:1FmwaiaqKqiC-M98JeMILP7A29mercOYa7L8qjEdDU2yoCYgAipjYg>
    <xmx:1FmwajXzqWaIbFi8xInr25ndld_zDjrJ4IhaeSmHgReMBOvi5EHsqtWf>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 20 Sep 2026 18:10:25 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Subject:
 Re: [PATCH v5 01/11] NFSD: Remove hard cap on duplicate reply cache size
In-reply-to: <5dccb160-8bf5-4a27-a6ab-3dcb47f87c23@slotpi15m67>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
  <20260918-duplicate-reply-cache-v5-1-b6aba9ebf2f4@kernel.org>
  <178977244520.207413.3893450376967484226@noble.neil.brown.name>
  <5dccb160-8bf5-4a27-a6ab-3dcb47f87c23@slotpi15m67>
Date: Mon, 21 Sep 2026 08:10:20 +1000
Message-id: <178994222080.37859.2390008881736730180@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 21 Sep 2026, Chuck Lever wrote:
> On Fri, Sep 18, 2026, at 7:00 PM, NeilBrown wrote:
> > This patch looks good and does what it says on the tin....
> > But that formula at the end (which the patch doesn't change) looks weird.
> >
> > As you note in the table above, 8GB on 4K pages results in 92681 target
> > cache entries.
> > 8GB with 64K pages comes to 370727 cache entries - 4 times as many.
> > That doesn't seem justified.
> >
> > If we made it
> >
> >     32 * int_sqrt(low_pages << (PAGE_SHIFT-10))
> > or even
> >     int_sqrt(low_pages << PAGE_SHIFT)
> >
> > it would be 92681 entries no matter the page size which is what the
> > original table says.
> >
> > Does this need fixing?  Should we fix it now?
> 
> I'll add it as a separate patch ahead of the cap removal, using
> 
>    int_sqrt(low_pages << PAGE_SHIFT)

I worry a bit about overflow.  sqrt() accepts an unsigned long
and low_memory is by definition addresses with a pointer the same size
of an unsigned long.  So the only possible problem is that if there
were 4GB of low pages on a 32bit system.  Then "low_pages << PAGE_SHIFT"
would be zero.
But that isn't possible - for exactly the reason that we can put error
numbers in the two 4096 values uses for addresses.  low memory never
quite reaches the top.
So it can never overflow. (good)

Thanks,
NeilBrown

> 
> The table in the comment then matches on every page size, so the
> "with 4 KB pages" qualifier goes away.
> 
> 
> -- 
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
> 

