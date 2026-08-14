Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23AB946C844;
	Fri, 14 Aug 2026 15:28:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786721323; cv=none; b=HWqKYAe26pKys1R4Pz64ktVV92VKqVsTwJjOAJzGrVK7ZUefiprGPCnEsUfVM69jqeHqCKN/skrU7kmtO5340BBY1aypiFUSHGf6ctb+ETvIlUYWy9y0I76ynhDRT3F4BzIT+7rozBE3pgTt9as4mJZWd3Jdp5H5zfgESasDJzQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786721323; c=relaxed/simple;
	bh=nM2KpLAD+dQ4Lc9S8GqnM/gjeb+efgIynIrAPZqM9Bk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=aMJxCxELIlsbvOfrcQTyjEbCeZymLN1HRPiGIQ6MvOTro/4AvVG1s9sxmIDoDwUd+wu7AyaaE4q9KheGuCUs/6GmTV5sVVvwFC994J9oSZe44fQ0OntjIkmzBquz4d4UMEz++IVEqdGGCtLqHn2idUnRIhNIPY7slkzeOLCNO9w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GLqgq6Fg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GLqgq6Fg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C4CE1F00A3A;
	Fri, 14 Aug 2026 15:28:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786721321;
	bh=KitOUslk+18qH3Fpmqr2kv9IYMnx8rgJ/awcl8hCp38=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=GLqgq6FgjleJZrv/0WD+jXDedrNVZ6uzo1BN4AjyGbxKeJBMXbxYtpLBLC5TaRnl0
	 gOi7bTv3T7DolDqm7NaT8uyXcx4k4IkePEQNQA4E9rLAZRnXYqf6nNS1t4T3WsomHJ
	 xSRaEpggt6SdBn+/NFIT4M9ii4lIXZSFDpnR1Ag16dfPGNSQwddGnSZ7tgdn9Ujv+h
	 YVMIfIO+2V+EzbHU80c+qxTjg5Zc7BKX/Z15te/NHV4qMGdtthYzqDy6ovzqYRsSns
	 I7BzQkb6wjlitagN09CuC3ZkJXDNn43AuTFHeMdxLFuwyXG7gtaTnujGGKyLxzkGU7
	 ZkjfOFp06yP3w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 55858F4006B;
	Fri, 14 Aug 2026 11:28:40 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 14 Aug 2026 11:28:40 -0400
X-ME-Sender: <xms:KDR_agih36I9vX1bg8KhMnC9qpSpApSxNSt1N0lUuDrULj6NeclTRQ>
    <xme:KDR_aj2U04JPrni11F1cOcFDR-ZZm4x9MmrqHNjwW81ijlkhptYcCakaWMFLYfMvo
    62gJh4V907Af0FYuCLzEOa_XZs7DqqebBSOdWQUTT4vpkQWUI6Hfc4a>
X-ME-Proxy-Cause: dmFkZTEGStmNNX26DAxDIcjkyicgJ1tisH3i7jCTFxIriRsENLcLDfFwm35RsshH3i7m24
    9rNg7ApoXWaNiQrVA0Nbw6RBpIYzLVwv8O95ks12I8jLDG2yXWmRCPZukUox0O65+o2W7b
    O+pQTdMu+6TXOmWt7k7NsAZHcenVbcd4afn/pi2im5yxTIMTTOWz+0JigG4tGQORGjmRgK
    3k14CR2zxuERiDQjf8CuWF96H80skMEOFyNQULD7m9vB6ECO0MhXp1ESiZCAR7JD+3vsy0
    rl0zIT6vn05s59S8W7vacK/RVSGq9w3iQqBCYitxdOcBm3P3dg9wmBjaMgHQ8nXf1A8PRi
    TxQOwap/SQtHBe91A6+X+pjvtkxQXFmUpnlxuHI04XnRo/MN3Ivpehv8B7klgHbuB01sXP
    Qkp3HSDV1AARXL2ocoHfETcYGThYRO3TFUuLWplhZPVnO93prYzNcR2d0VLN2AsOBrdRFg
    Xr1HDLzpY3D9ctvIOKbx1v1ulcGtbeNJ/JhMFJBXltMBaRnKL7tuLpWr4LwmejeY5bLwuW
    9NC8yDimzFST1RTvRUbaMMdZoVXNqrWVXA9jD7JT5B5QUjnx5gHqPRT0wFd56v9AJtHI33
    fiy1zDQBwNkrQ8fhbArqjPBEBYOgVPJ52Lbo8tsbzneEmJOTo02qFOJv6S2g
X-ME-Proxy: <xmx:KDR_aoRXc_F1yjO5AScwdica1xhpeuMS5wspOXn6ow2a91II2-tXLQ>
    <xmx:KDR_aq7Py65iwuXISfcB5cAGFe78eIxGLpnaI7OmmRPlp7DIc8DbJA>
    <xmx:KDR_aoyYl178X7ozW28irZzYWeG2ZuAM4NYseOzU3RnUin26oF2i3w>
    <xmx:KDR_aiAE9rUg60aB-qv385KDa-W-8sjd63rtdzDLXjQhfxaQudgTsQ>
    <xmx:KDR_aobQ9-pWhwctq5qs7FcakZ62r7kyRVOO83qUWgBLlgyDgWYq0ORY>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2E3897811F0; Fri, 14 Aug 2026 11:28:40 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A4afRqWdro9F
Date: Fri, 14 Aug 2026 11:28:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "J. Bruce Fields" <bfields@fieldses.org>, "Shuah Khan" <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, "Trond Myklebust" <trondmy@gmail.com>,
 linux-kselftest@vger.kernel.org
Message-Id: <a33c928b-d579-47c5-8a54-714277398f05@app.fastmail.com>
In-Reply-To: <a8f5840cf3f2cbf71de7a1f3957f70d9897adfa2.camel@kernel.org>
References: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
 <20260811-nfsd-nl-hang-v2-4-c0c92b3953c3@kernel.org>
 <e1706a70-d9f8-423e-9462-2d77b2e444b1@app.fastmail.com>
 <26486c88075a0b1e3c1cb088fe97d39e0051b5d3.camel@kernel.org>
 <572f0269-9bf4-4a80-8e9c-3c4614d45f7e@app.fastmail.com>
 <a8f5840cf3f2cbf71de7a1f3957f70d9897adfa2.camel@kernel.org>
Subject: Re: [PATCH v2 4/8] SUNRPC: undo partial rpcbind registrations when
 svc_register() fails
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Fri, Aug 14, 2026, at 7:01 AM, Jeff Layton wrote:
> I still think the best solution of all would be to just say
> "henceforth, rpcbind registration is non-fatal".

Fair enough, let's go with that.


> Right now, I'm really unclear on what sort of changes you want to see
> here as a final patchset. What would make this mergeable for you?

Sorry for the ambiguity. For the re-roll:

- 1, 2, 3 and 5 don't need change.

- Let's drop patch 4/8.

- Make registration failure non-fatal for NFSv2 and NFSv3, as
  proposed.
  
- Extend the extack in 6/8 to report a listener that came up without
  registering. dmesg is the only channel write_ports() has. Perhaps
  the netlink path can do better?

- Fix the netns leak in 8/8.

- Ensure that any test that asserts the unwind or the abort is moved
  over to the new failure policy.

HTH.

-- 
Chuck Lever
