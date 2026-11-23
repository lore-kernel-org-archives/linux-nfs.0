Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795393650;
	b=QRNbPkCfhxVLD6bhhGPp9MjOwXcnbhrKF8j7X7cPskLVADV7VrxiDd8X2Rbyk1FV3lkM
	 Yt4cuB/m4eAu5JJPJAYhknNV8MjZ2gX3FUYAsk0Nw33a5ykgUgHE1t6bEAjuxeBKTZLMu
	 1CTvlWFJu8ccYxwPgwGb+dL8D5PeENTlmh6xlARVK43WRMhNQZ70rQoFbzQ+h9OV4tzA4
	 HVXtcUdwQvK3JVj8jFWCuDgLtb5J134QyzoZiPSYPWSnPVzW59M3Likh86lw4+uyZe6m5
	 szHv9JBBoqRzgeC1IDIMIAXVCymSSowep89z68L8qV+ota3ba1LfMNftc8BI4f9fFcA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795393650;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type:Content-Transfer-Encoding;
	bh=PkKnr84vpTas1dxQ/9EryoZeNGAcz35NUAFuOFP6ksc=;
	b=yfEWq1NhUfpAj22rIGs6Orhe3eNfwAM1wN3VZvHlpXaorgleUBq3qhjPblUjPufKvKln
	 Zbl1JpHFgT6EERU94EZxCqqaeaYQQKTJXuyDgV+8axxSdBlupOo2czexmrHxC7BVxXvey
	 aBe+mt+1pk/ncgtounY9mDYLUH/zzP2s1McmcXr6+qj4FNlCYCQvYlJ861msOC7z5EnpF
	 cCdI4vfKr8zyGmfnmhy7VSfN9aajFIk+8dm9GYNh2COTveat07EqFYKPsOzXxbVLc3FHn
	 k455eikoHqwvotnEJDGXvJtFTdt8euLBL9HWAopdEhbAGTJ2b58FmdwwCaHR4Rs1sWg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=frOKJ8sU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8C8B606A31A;
	Mon, 23 Nov 2026 00:27:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=frOKJ8sU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 40CA81F000D0;
	Mon, 23 Nov 2026 00:27:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795393650;
	bh=PkKnr84vpTas1dxQ/9EryoZeNGAcz35NUAFuOFP6ksc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=frOKJ8sUS9R2sQYpw9OeaQnXPBTZJcQAFNyPKLst9pJ9rU0Wy4kxTidq8Y8EvySaA
	 I+vY8iyv1CiGLvFiXvcirf20rNN7xZCOlIbq6BSduQ912VSQ/FVNLAvXRUzinHdK4T
	 Bw1P9S4J3IusAbbkVpp5yRW8SyrnD6Py/wUrfTsjzEKqsa6zyHYlSwKj1y+FO4d5w9
	 J06pnpm3UPWeIVuwMlrm6/T3KyRi2oeL9in3/qohJE2PogPA8dUlvhRwssIYC1ykHf
	 ROdPJ7V3YV8DmEKoy3a1YpF211T7PO9/3gw1eALXuZ/Li32XfdVYlg0AsFqSmPCiR/
	 +2OgmSgNyGk6g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5B952F40066;
	Sun, 22 Nov 2026 19:27:28 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 22 Nov 2026 19:27:28 -0500
X-ME-Sender: <xms:cIgDa5vMAPpezm0mKPgjbhZsgKBcE6nFthBzZd-AKaFEJVRpGTq3lw>
    <xme:cIgDa9QznQ4vGlve13D2BATrEZX2vme5NZHoSJkl8aFmuBwWEAvJfSQDlfo2vHRpd
    P2pLYc5Qlz1yGr_NuvV9uFwbeDL6AvoRhySe2jJ9Pu4Xw_CSAGbIM0>
X-ME-Proxy-Cause: dmFkZTGBzbpFALi7VXyuO7iXSGdiC5cVfu8R0twhtOTSHwRjw5TxVu743bHB+o9oojSSss
    IoMmPHT5dQBP/F6La/sEIZq6mV6j9BQAaQ6m/gUlOzbPbQrvrfgHf5Hy0qOHcjEOCUJMGi
    KlBUMH9zRJYV4m3sIvnwbZTprB0xuCNYaZbeMKB5Erm24xPvW52Wns9PhkHIwtlQV7bSjb
    cqRrIeEN3YuRJv5gS+hIfsuw4PIrvberQXNRp1garvvBis6VSp6UgxiO3faHRRtzeGdQrR
    sigXruVHs3s2BJvSp3MkXtWPCB4hW/F2/BqTSuKvncKEeN+Ivf9xfYkJtaBI70XTmnAScE
    aBHip7HtcoQ1Fx5rXdRfwtxpKZC7rUsPFHQRn6b9VdJsQqCp5SC8LJc0DJGQIS7Gj8oKvf
    0WIr8aaVCG7KWRw0jtOUO44lF8Trxt+l09FMAclIuQkayJiXqGh4GNTtYxOh9Xb9rdRVhw
    uiXPzZ/cVpE7Ach84hZTySbyVIGWKqgBrxCM82r0D7krvJcnUas+63M65hcAYGSqUVAEVl
    YyS6MXzE4gOI2NA8GUUw54ewwR0jNjy6R66UTS5JTNIM0K2AIziIeFhLCWpgnm0uGuormr
    R8l56vwijEYP9QLbG+BfUY2JFtnFalzTKA2Ih+yTcw3Poc5sv65QcyZPTDuA
X-ME-Proxy: <xmx:cIgDa-trtieGhi7Qf6ncjN3rU-l0kMPF--30_uVOHLk8dvOz-uxUrw>
    <xmx:cIgDa4UIlhZz0x0F-JMnizPCidqqZeyTRzaPhaKNHXnM7ger_QO8_w>
    <xmx:cIgDa3UvUfKLnGTZ5k6TYQMu-fCV-xFvUmMMxFeK3EVvD2kJYH2kWA>
    <xmx:cIgDa7Qis19F_S2LonET0D1rWQjGLlAGc1H8DIjdtkQurtuglo2Xng>
    <xmx:cIgDa-HXq2Jx9uAhdEd4vNxAR-iDXeXjwmA8GDfGmhE08YMU-jW24tfp>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 357E8780070; Sun, 22 Nov 2026 19:27:28 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Date: Sun, 22 Nov 2026 16:27:08 -0800
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>
Cc: "Donald Hunter" <donald.hunter@gmail.com>,
 "David S. Miller" <davem@davemloft.net>, "Paolo Abeni" <pabeni@redhat.com>,
 "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Keith Busch" <kbusch@kernel.org>,
 "Jens Axboe" <axboe@kernel.dk>, "Christoph Hellwig" <hch@lst.de>,
 "Sagi Grimberg" <sagi@grimberg.me>, "Chaitanya Kulkarni" <kch@nvidia.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Eric Dumazet" <edumazet@kernel.org>,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
 "Hannes Reinecke" <hare@kernel.org>
Message-Id: <7a0695c2-bf7a-4394-8cfe-a92deeba51e3@app.fastmail.com>
In-Reply-To: <20261121161302.69f202c8@kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
 <20261121161302.69f202c8@kernel.org>
Subject: Re: [PATCH net-next v3 00/10] Deliver TLS session tags to upper-layer
 consumers (NFSD)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Sat, Nov 21, 2026, at 4:13 PM, Jakub Kicinski wrote:
> Naively I'd think it creates unnecessarily wide API on both ends
> (handshake and server). My knee jerk design would be to populate
> the full policy in the server, and only carry some "policy ID"
> thru the handshake. Number of policy IDs would equal to the number
> of tag combinations (which result in different behavior).

How is a tag much different than a policy ID?

It wouldn=E2=80=99t be impossible to impose another layer here that makes
a specific set of tags into a single policy, but I=E2=80=99m not seeing
that doing such adds a lot of value.


--=20
Chuck Lever
