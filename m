Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792933517;
	b=BHfNgLFNAJjN1+T3p70Yp5t+cYQMEZ0L3HeMLNgyjP4NIRCAM2iSleVk3NFmvN/ab0lI
	 q6FerMF/AXG+BNTxcVHeUfer+zXlBoT5eUOZ0cLyIZaHvH+54MnvohS4tJC9ud8LSUol6
	 hpSyZ712oQCWAuuTEbNGojze7dkJFBmqgaeAcD7T30V67qsFMoqn57/qZSyNOBXcxaNKw
	 mPq/eWURC5bL0i2EYmgqDt/ZGXIvUbcGSn2CvyV9XENDAeLowvyy4VdYOSxDs1J6gB2py
	 VS9NcZb4BZC/PM8dc6RxM8VPucINc9PqIVUms6+dQy2usNpqCptrRuHRscMOEQ+iffg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792933517;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=Z9zRtXHe/J1k/4/9wAeq1n+PwAt+ioXmV3zyjSNrjDw=;
	b=FBZtesjxYW1KGbMfvDIei2Wc924no/RUknvLTbkyRUFP6xOkSWylt0ai52kCGNY29D81
	 0xVisF6kVlAGK2TO3M2odIlQ0ak1BWNqYKk6YfQyTAf2xKWbFJAoOQsBOrMLiyTjDysuF
	 ShtRDyzza2qGzF6zcslyt9NetK0N59sYtTcL6z+lTQOHewHvSdxlfWozCytlYeAQ+eAeD
	 12mIVON9Y6ILFFaBXzD7jQWNYLxmGVYQYANJ7WebmL6Y0vrZ+m3Sls2FlJ+2QLzhiPZ1D
	 Xb54UIPBbrh1J7TyohRHsgOJSuxF5asfPzrhLur1s/AK850y4CeegcLarfX8M4R7kGw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RTmSiKcY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8028A606A31B;
	Sun, 25 Oct 2026 13:05:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RTmSiKcY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AE8F31F01825;
	Sun, 25 Oct 2026 13:05:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792933517;
	bh=Z9zRtXHe/J1k/4/9wAeq1n+PwAt+ioXmV3zyjSNrjDw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RTmSiKcY/7I1yl7oTMBf+ppCBHkj/0RemZ1XV79s0XosguJi90dj16S1zpuia6JAW
	 gDPsisRpWsrGllM4TswPL77xdoB7HvEH+vaG/r+GHq163rR3SVTfOTRP7VQJJpDUL/
	 5RhfcHHSr2S4HlBURFCypmRirAg7KN4i90OsYUlgnepJdS8rsbQvBAbDXAGer8dftB
	 hJgTk1ZXoFogRqFZx2AOmMCwvyo//FcSSLKAokTeO4GsVfd8fNsI8Dnqhsbb1VbN3w
	 SrBliUsbxDRbQ9T0wVxMc42JXoXBgkwJnNh9CbZxSck8YZhxooJ00C+kjiHVp499hS
	 yreYVkXqU6GOQ==
From: netdev-bot+sinfo@kernel.org
To: Avi Weiss <thnkslprpt@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Balance switch queue length on transport removal
Date: Sun, 25 Oct 2026 13:05:16 +0000
Message-ID: <179293351625.3327.4180499096337252277@kernel.org>
In-Reply-To: <20261025125923.2221205-2-thnkslprpt@gmail.com>
References: <20261025125923.2221205-2-thnkslprpt@gmail.com>
Auto-Submitted: auto-generated
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

Hi!

This is an automated message. This series looks like a fix, but its
commit messages seem to be missing some information:

 - How the issue was discovered, e.g. hit in production, hit during
   development, syzbot report, manual code inspection, LLM or static
   analysis tool scan.

 - Whether the issue was actually triggered, or is only theoretical
   (e.g. found by code inspection). If it was triggered please include
   the symptoms, like the stack trace or error messages.

Please do not repost the series just to address the above. Instead,
reply to this email with the missing information, so that reviewers
can take it into account. If the series needs another revision for
other reasons, please include the information in the commit messages
then.

The evaluation is done by an LLM so it may be wrong, if you think
that is the case please reply and explain.
