Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAF3C30568B
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 16:37:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791736647; cv=none; b=nl784TstUej30KvU9pcbUAM20oMYcXuai+Q4n6EZInHo3ArzCjLEgGqp338UqAqR2Aui2IA3g2jUvpYxN86DR3q3ofVKiRCHdV989T0FMcfX1gLp7evUKA99JJeRYg9sGDUvlBdTMsgKDWdPCtNNyuTV2141Iw8ZUiG7XYpFFRQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791736647; c=relaxed/simple;
	bh=eK0ytF8jaWRCK7KWG6xNJVmLvDkh9sA6S8uy2I2pOJ8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=VaP4Nap4YtJAdiY+utHk6Q/FRHDyW11pzlFAdMNWUPtvCSJdLR2jSrYnEZ6GjZgxGhf1ixfDPUzvU9laVBYqvmuacbJnPPi27wzKXFECVMq1wrhFFMtWvWUFEMe4bASBGmW1imYjalz+WMyKzV+a+kcy+1WOuQvDTJxgZL6iPlg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KyX14BzY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KyX14BzY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2860A1F0089C
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 16:37:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791736646;
	bh=eK0ytF8jaWRCK7KWG6xNJVmLvDkh9sA6S8uy2I2pOJ8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=KyX14BzYbKKllVGZfLtPp0oEkTsJrfpiY8TjJgi/DQXKMVaMO5HWQp3zRMf90PEHC
	 14TqUTMCjmrNOQ4ag7NicxJbnGgce0aGbz0iagaYeA78O5Pueozldlf3dZTX5V4GkV
	 IdPPv9WB8SSV1eWY4PZr7YcIuJbACHnJJZFo2aD3zfkD8vPJiJp/aDVlpmSjUYUxgS
	 R0JXlKBBna/SuvVNPmJPbgZ5WVN7aygy8SwjHS4LHENPBRFCXzBcmYLBwIdrQBJpt6
	 eGZYS9UV7k80v3SmDJKTgk0GAaACd/6b2ZnZatgoAeSL3UgK4G3xcsZC17ov7RndR5
	 d+GyRN018B1gg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 66F76F40066;
	Sun, 11 Oct 2026 12:37:25 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 11 Oct 2026 12:37:25 -0400
X-ME-Sender: <xms:RbvLaqCF-PTi2eEPFhVWFA1MmNfqua9U-9zFw5ZJ7GoraDKNrK4dPw>
    <xme:RbvLavV47WDcKo45vUNVDfVGyGyamv52VLm1iwLbHTNEya_Sm9VvXvm4LgX-lMqKH
    gNw0M8SlV-ff6l_WoQETKXRnxs8QhCBvjVrBbUwTLeDuHxAEuhkAHgHAw>
X-ME-Proxy-Cause: dmFkZTFYDLDuvn9H3TMBcdPQhU/qDk9fydUlhdg8FRsQGgmXg0JCM/P182tHepQWmpsngd
    N+/Lp3W0FiHfedtv52gQlLmATXe6+DInHdT8+bOY5XFyS80Vl9KIYJgedZhOBglG6wKHwU
    ysFvwzAtRizykUaSWLWSioIqBJHXO3uA516Z0YfI7TlMqvh0QI7sha6CJoPHJtlGJNdpog
    0Cb0FUBXx0D2qFoWb8yRad4x8Bbizj2TxvOBuo/yCu/k6mJaN8Fd8Y1ppBkiwXSN6Fhpvj
    h+h2rMUXJY7C3MDVRdWSWDLqjQBF/1kBAnd9FAYUVgwDZdiR21kXYsKPBOdKKzqPy7JrWz
    7kLwoajnMA+41AmRW9yvZu0q3YpduFSw8N4q7sw+8AImNVSscy4oYbOexPWM3/Yp9DPC6u
    Fk8/JbHekNnCrHOHsFQHfWS471laMCZvj1peXAnxUG6YvV2FKAcR1U8ebse8wOzeu2cZAj
    uTV1Az0GhwrFvLeOTqpDr4ExaxiYp44CgbT7Aeju8Oc/1tC4Roygw6w9YQxBt9r8Rotn01
    5y6XBNFaGWBZQpQSoFzSiUGYKTlGAumqIhpOHYgszzbhsnAPSHHvKx/6dYb9hJEjnF/i6b
    GfgszwcgRjadMNzGF4cxYf0tMUqyseQa1ZcSJ2djpPG6wXt+febq8QPI0GIQ
X-ME-Proxy: <xmx:RbvLavctcf3cFiF5Zx489TL69LwoVA4p1l-4cF2XioEpTHn3htlpBA>
    <xmx:RbvLas__-hLoLNP_mZXD6_imSppWD3yxmbtWXE03WfeZ-p7-Igue-g>
    <xmx:RbvLarlg6FUS77a6sFEUNPxlywxfcrGPv_r0IYCrMeOyDgDksbWMrg>
    <xmx:RbvLau_l9P0dpoemcTFzeV6fF_Yslac8gbLB6tmPQcQ7lSbrqBhKJA>
    <xmx:RbvLapmqAdBHicOyiaM9mCG7TJ0oY8uAe2O0mhcMgUzAHRsWzbfRRkHM>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 45782782654; Sun, 11 Oct 2026 12:37:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A7Qpu3LgJ76B
Date: Sun, 11 Oct 2026 12:37:05 -0400
From: "Chuck Lever" <cel@kernel.org>
To: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Cc: "Calum Mackay" <calum.mackay@oracle.com>, linux-nfs@vger.kernel.org
Message-Id: <dc1342d1-3c6f-4ebe-a093-2c2f876d32dc@app.fastmail.com>
In-Reply-To: 
 <CA+1jF5pyuVULzoAjbfCLDjwwOwHQP7sG29G-dkG9ZSOdVShHWg@mail.gmail.com>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
 <20261009-acl-mode-v3-8-ba487c5e66e0@kernel.org>
 <CA+1jF5pyuVULzoAjbfCLDjwwOwHQP7sG29G-dkG9ZSOdVShHWg@mail.gmail.com>
Subject: Re: [PATCH pynfs v3 8/9] Add tests for SETATTR with MODE and ACL
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Sun, Oct 11, 2026, at 5:40 AM, Aur=C3=A9lien Couderc wrote:
> What about testing FATTR4_MODE_SET_MASKED too? IMO this is a better
> way to set the mode, because it is atomic and might fit better with
> ACLs because it only sets intended mode bits.

So, this thread is a repost of last year's pynfs ACL+MODE tests. I was
trying to include only fixes and clean-ups.

To be clear, are you asking for an additional pynfs test, or for
additional logic in the Linux in-kernel NFS server? Or both?


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
