Received: from fout-a1-smtp.messagingengine.com (fout-a1-smtp.messagingengine.com [103.168.172.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B7142FD696
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 06:25:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789453543; cv=none; b=KBT8rsDDrqGczdTPjHNW4td+4wLxDyXppLuPL0gytbl1giJoTEmGNtG8hEgJTBC3Yh9iHfbH1Bi7iP1HPaAEWkOlsFRehDZbCwFgfGo0RRFSLSQa9kfuQxseqFRw3ODQScdLxkDjh/fV6UTFyBZ/Oc1xDg/kM5KBMSsNeC8Homk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789453543; c=relaxed/simple;
	bh=K2bdjT65hPmQJjWSsx/eDmlHvOTRmx3czpHXqccw734=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=uc6hnOtEopot2IBi4yQbVwMF022m/uzGfJpd0koNp8hno8kzDFulXlDdg5Q2XBIggM01+BLA5vOSenizd4ND2suTvpUlflmHY/EOoLXAluyOE2eSMHpU3IYNZNjNqUZFI2Zw6opknmJXXXsE8WXwhWRy8/qeErTMOqqPj4oqaj4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=hTLNWsuZ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=XjoMm44+; arc=none smtp.client-ip=103.168.172.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="hTLNWsuZ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XjoMm44+"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.phl.internal (Postfix) with ESMTP id 2CABAEC0624;
	Tue, 15 Sep 2026 02:25:40 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Tue, 15 Sep 2026 02:25:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789453540; x=1789539940; bh=QDIAeYMpU7akuld3Frbqg27Bc6K0EQ8VFW7
	giypyN1g=; b=hTLNWsuZtXStPIxjsmDWS/4AYXBFNkYauJ5LUovH0YdLXYCO3mM
	et3+hlRsU+lAMgv8BAXfEflK9g1/Syu6cjggcnsYLSEm/uJbYWfsn2zBxrJHtbyO
	qf0XOz6P4pSmtl9H0D4OdMvf7UV4lyavj2hM5mgrtm6vyXHHzjq4YK4N0qQdRXNt
	ScQSWnnBjeZtgZ3vmbXOmNxnJRA51/nHkzn48bJ0FhKMRQuut9zbTs317AGfNMEx
	/cY4nlLMmRIsCdz6oGvyCMpykgYuKPMNTCliG8R+mqgtymBsUeHL7qcqDQed7En5
	NDJuBF1qfqAVftR4O1Vui7P0rw3eUc+3kew==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789453540; x=
	1789539940; bh=QDIAeYMpU7akuld3Frbqg27Bc6K0EQ8VFW7giypyN1g=; b=X
	joMm44+YAwbua8Qjk0B3S1a3mL8ApeveyeThGwVMSXImITZQkTPn/gDdGZJmwObJ
	2Mwvmk5k5eXiAe0Jj+7KWyssxeKqnFtWHsrrZuMkRPQ1j+r7n35J7YuC95YU7pp6
	Jmg+uJUc1y+zYJBe1d8fxC1V95ATy90gM7osA0CCOZwRiQfFAeqF+KNLSmbYRIe8
	eKgM5HrinzqARHvTTK/f1vnvVloMSwR1zLlerKWPpJaEoFQIc4zQSSovdR0ijjKn
	nftv+uIENDH02uLd0PVOTRAoXMdcFnoBIPDE0FEQIRq8dtTzWHe1nZWs6SxMYfFG
	whVHdi6Q7t0lgHcltjJdg==
X-ME-Sender: <xms:4-Soaj1tBXnmng0muNp39PVjNzxyR3XLowFDq6_m1nIzjMTsnZwz1A>
    <xme:4-SoakVVfgD-V8NJvpHmANWRLH5OSYoz-uZje4ONCCSdM_vgt4C8gETJGZKylu6mc
    GtIFVklTWlvZsk_tn8XHeSD08Fa2KdgMkr8mLH-NCJOkRPxXg>
X-ME-Received: <xmr:4-SoamIoRhMOaDq6U5zvHc7bLuVwCUuDrDvLXFHM6e3Wu5BkRKwkpRT_hl_UKqJKz4thGC0t8A4hzq9UTcGOEWJPdNC0spo>
X-ME-Proxy-Cause: dmFkZTFSeYhjWJ/+TQLV554rA6XCqgJ62p87gTUMQ9P81v38/0RSGOwWUyo+LbCHroGGvF
    01/1MWpZpk+GT3cPWvkNaMGqL+ZjbjarV2tEVV+2ULenh0G5SdKIK7oy7cHg4+KDmNPF3x
    sePn+vfZhNVTTcGwWsKuw6fN2Lc4hwCxgDKAskEPW9TOY4ZzI/NsK+XsC6QbCKZTDWgbZM
    oXET5q2yH3K6Pv2G/oaV8J/ZOy334pdFtytc9rbYbwgEtddsW2w/B8+1Yt/MEW78URqPxz
    CfQo79RWT6KHzGRfSJ1mEle3L2vcLqcWUxAgGmLCNHW3s2e91BP3x5bcKR3v85R3nPXoXV
    XIz/nRGrKFSclQ9qaL5KFr/PkrO9q8+yxBGM0KxD9JuiLajPtwGLFmmy72jG3Jh2wJSYvb
    fw3A8ngLRH7bWa/cqEkQvYjF1OOoW21ySKSnVXu5tRz3QsDlNkIJFQ4yZX1RubVeLGiBRq
    vKvcZDUMRpcSSA67+arkeAR2PFqEizL9bu5joKz5706VCQI2Q2XC3R8G3fwGKY+R5w5rSw
    wmIcvlcyCSe+nxgDzsAQHmpDJKFLnRiPDBuUE7Y8yuGVMDjdEBvMBJgAOFv1VIzi16gN/S
    JiP+iba1Bh4pGe0Qu4K56OzEAWAIr3mrlGQIoLDuO7TXv0uHWPzYdttNnHeA
X-ME-Proxy: <xmx:4-Soau2rLgKVD6R4kD5-pPcI4p0lIjdVPcIE6fEARSR9qllDolNKUA>
    <xmx:4-Soak72hijKpL97d4EZhSr39BClciJonrhRx5wi7Ln5P_HCpvbIuA>
    <xmx:4-Soav9S9ojxgvFBcwFFhTN5d2BB8kUbmLvoKOUGoYOARxGp1sIBHg>
    <xmx:4-SoajXMYLgv0RwAWYjoHALdjd99wMB8NGzGodWKuLpfjpfnOOuG-w>
    <xmx:5OSoaojmRJ0kagXWbVD1g75FnnwsCuRDtXuSiqH1XmnWE6bJrgN_xu3m>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 15 Sep 2026 02:25:37 -0400 (EDT)
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
 linux-nfs@vger.kernel.org, "Chuck Lever" <cel@kernel.org>
Subject: Re: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
In-reply-to: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
Date: Tue, 15 Sep 2026 16:25:33 +1000
Message-id: <178945353329.207413.1555757673936041397@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 15 Sep 2026, Chuck Lever wrote:
> A completed DRC entry currently stays in its bucket for 120 seconds
> whether or not the client already holds the reply. On a busy server
> those entries lengthen every bucket walk, and under pressure they
> crowd out entries a retransmit could still hit.

120 seconds .... that isn't very long.
The linux NFS client configures a TCP connection to give up after about
180 seconds.  So by the time NFS has decided the connection is broken,
closes it, and attempts a new connection, the DRC will already be empty.

TCP connection can hang around for an arbitrarily long time.  Default
configurations seems to be the order of an hour.  Linux/NFS deliberately
sets the timeout much shorter.

This happened in 
Commit: 7f260e8575bf ("SUNRPC: Enable the keepalive option for TCP sockets")

with a justification that it was needed for NFSv4.  This is because
NFSv4 never retransmits on the same connection.  I think the purpose of
this is to detect a server restart quickly.  The restarted server won't
report RST for an unknown TCP connection if it isn't getting any traffic
on it.  So keep-alives with associated timeouts were added.  Adding
keep-alives is sensible to trigger an early RST.  I'm not sure the low
total timeout is justified...

In any case, There is zero chance an NFS server will get a
retransmission of an NFS request over TCP within 120 seconds unless the
admin has significantly reduced the timeo / retrans options.
So maybe there is no point caching these at all???

Or maybe once we get this more efficient pruning working, we can extend
the lifetime for cached TCP replies to something potentially useful,
like 15 minutes.  Or more.

I lean towards not caching them, and guiding admins to choose a large
retrans time, or possibly negotiating with client maintainers to allow
more missed keep-alives (tcp_sock_set_keepcnt()) before closing the
connection, so that the TCP send buffer on the server serves as the
reply cache.

NeilBrown
