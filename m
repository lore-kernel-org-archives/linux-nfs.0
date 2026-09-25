Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19D9B37189B
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 14:04:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790345100; cv=none; b=f5MgSeNcBfi6j8ns8wtavK2MD27YTVZl/biYI9oLdA8Qe12qwGjjuR6cmsXB6h1QtgD/GFSBvVGRfcXn3TDVE/8EDPOBLCJpzd0Q7vFipasTG0PHnGEvsFQ8pjK6CshvbTXwvqzwd8rwIr5dbVVF7bfFcxhQIDWNPD9JXraeOmc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790345100; c=relaxed/simple;
	bh=EOjq3BwTvKd9rdOTTliRCa/VIxBlR9fR3YJWWvZPqHs=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=oGrB760xZLv9K1umT0w1f19X4Aa8uMSHsfO93ns61OvvtpVNByE+oURcuS90jw7cbGi41aHzP4hvxC3JJa1UUw69fAfApTCB9nODXy+yfolSB3JMKxcIKDMWoCDs/nIOItWsTDmqg1fpsFHWS49NC+NzvTPSWKUTPm0LgM29LlA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kQO7JqlR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kQO7JqlR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 717041F000FF;
	Fri, 25 Sep 2026 14:04:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790345098;
	bh=hOuZIZt94xolSBWGxRAViYHiktt/EC/7yMXc92r4ddc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=kQO7JqlRRwLDqKB2QVft+wYAqKlytAOQgtjSZ1RZmZUXeNaWwmW3eEjqLLwMG0vw2
	 V4uOELQyu9ggpPuUYfDBQvye9autoZtKc/Y/jsjD8KyU2j8udvge39XCv3YVrmCuOO
	 R4eVyjerIj3V+2mSWGblwfAE7wIaWOg/gituOnwxdf8d4U8erOqjVB9xq0XzoJf+VF
	 BpyoA5dyNR5KY8dZpBb2YIc/hhTfylEt6uiC9MfA5QtExeK/7QL3CHXh/JsLB1SWRH
	 wceuCmQB9iExR5nh90QSn5nJuDtc/WLGFfHLbLt31b2Pl6qtFNohAU5WTtwXl+2B5G
	 Cs8WWMxS1rHHw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6C7FAF40066;
	Fri, 25 Sep 2026 10:04:57 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 25 Sep 2026 10:04:57 -0400
X-ME-Sender: <xms:iX-2ajUHYsp0XRjVF7h-2ptk1ITGgZGbb6PB4bM7wUJsEjE7E0RQpw>
    <xme:iX-2amaDobTrYYz-52Otl3xMvWzIDuivp34B7py-LqIuFYru8EdpRgt6bm6P2YPTc
    bb8pZoIpdn0gSqlbdSo7OjjsROVsulE1PvrhKOSbMzwxX0RRx8LvoSs>
X-ME-Proxy-Cause: dmFkZTGjYOOFTeQ0VBW2r7pf+jkfjQ+mBAeS/raId8lZoXj5LtBQDS49yGyOzZ4h3RL/PD
    GD7V/dnke3UoEV4vsuyoOfgVowciSpmAfbDyj/A9sCfqZba6juJ+XZYP+HxBfGOSXB13xb
    IyabC1cQX0GFJJ9QzcnTAfvLZcltuWMJINNBFSEr2g53ED3Woomg7b5i39tP8yKqOExjXE
    kB0GHLLprzkJTP9VCmXHV6RMjory4XhTx6cwf0o9ltSBEa0jV38dYbk01Bl51Ioqrsht6W
    otMAJVnXT9xl2/dyZGj2NCCZ0Hbad/I4yTuBe/v4N/41REWF1FylpJcrQiWO0/ES6a11VI
    /ZkURAQx+mq6pdrVgghO8tB1WJ2NG+4wxnOlJG4T5zKDt2NWoYg65zayOCZCaLZ1ni+h14
    zDalOryKxn6XOH6/sXOZP+JwHWFQNsV2h1SmtkdSyfRt3F+qvHNQNI1nyu8S6HNOQKle2Z
    wyJp3OXuoMMVgqdZsgb7f91yNu27jzmV++qLsXEH6YcU/pv19PaZMSTBmjaUACAZ4CfB6Y
    11gPxg3KFHAVF3fuaj4ejUGMCbd9nWYBdx5IrbndR5J5E/LLo+6n33imwXIAeqSoUJZgzo
    YPdOiULflAQqdLVGOiZqKraDDIEBSW3ZsLq9VkcbUUDUJUYyYeTTdd6xSi7w
X-ME-Proxy: <xmx:iX-2ah0tfsOENHuIxdfglhdZR1O4hwcCEhk6cPL37HmvdmnE5XK4nw>
    <xmx:iX-2akFBtTbDQQIwIxZslZQRJEXQlC9sabcCcl4o-vCIYAYpGpFyPw>
    <xmx:iX-2akF_fCy9k4kLWWnVfF9jff-bFhUDEaYGNkUdyZbJh7cIvJOuUw>
    <xmx:iX-2av509qvzFfCSkH4RkNypNdgVTU7TrJtQbmTnBO9NQEcGuo7dBA>
    <xmx:iX-2ahzZUUr_rF1XYlQF8xCM9u2_wj_hAWgQ5VPBEV4ylNAs72aH9ujg>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5029C780070; Fri, 25 Sep 2026 10:04:57 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ADGD3fXOw9Ro
Date: Fri, 25 Sep 2026 10:04:36 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Jeff Layton" <jlayton@kernel.org>
Cc: "Calum Mackay" <calum.mackay@oracle.com>,
 "Chuck Lever" <chuck.lever@vger.kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Message-Id: <1e80f5e8-4523-4cbc-812a-bab72172cc43@app.fastmail.com>
In-Reply-To: <179028637100.37859.2606126591365573312@noble.neil.brown.name>
References: <20260923-rply14-v1-1-f653557909af@kernel.org>
 <179028637100.37859.2606126591365573312@noble.neil.brown.name>
Subject: Re: [PATCH pynfs] RPLY14: reconnect before retransmitting the call
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Sep 24, 2026, at 5:46 PM, NeilBrown wrote:
> On Thu, 24 Sep 2026, Jeff Layton wrote:
>> This test recently started failing with a change to the Linux kernel,
>> but we believe that the test is wrong. This test replays the same call
>> with the same XID over the same socket without reconnecting in between.
>> 
>> There is language in RFC1813 that implies that a reconnect is necessary
>> on a retransmit on a reliable transport like TCP. Change the test to
>> reconnect the socket before retransmitting.
>
> I don't think this is a sufficient fix.
>
> In the test, the client receives the first reply.  This means the server
> will have seen a TCP ACK and will have marked the reply a acked, so it
> can be cleaned up at any time.
>
> Currently the cleaning of acked replies is minimal.  We need a per-xprt
> LRU for that to be effective, and I believe Chuck has plans for that.
>
> Currently the reply is still in cache even though it has been acked.  So
> when a new request comes on the same connection, the request is
> deliberately dropped because it cannot possibly be useful.  When
> a new request comes on a different connection, the cached reply is found
> and returned.
> But once we have a per-xprt lru, the cached reply will almost certainly
> have been cleaned so it won't be found and the request will be repeated.
>
> To properly test the DRC over TCP with the new tcp-ack detection, we
> would need to ensure the client doesn't see the first reply, or at least
> doesn't send a tcp-ack.  I can only imagine doing this with an iptables
> rule which blocks the ack.  This would allow the client to see the
> reply, then abort the connection and retry and confirm the same response.

Following up on Neil's remarks: pynfs is supposed to check XDR and
spec compliance. DRC behavior is not specified in any RFC, compared
with NFSv4.1 sessions, which is fully specified.

Perhaps the better course of action is to retire RPLY14.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
