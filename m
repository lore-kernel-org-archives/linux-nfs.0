Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5D003D1A81
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 18:27:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790706447; cv=none; b=ZiNqnuK8oNSiekNTJfQYuIYBa7drOlg2/UIIk+Ei4WIik0GTUvW+bn8wEEBqgf17Es9CTXQo94iZI2rr6sypXKDU4q9tfj1Eanxfkuj94yUmOi1GfXVuyQoNxNdpur+vzNockaQPcC/635vFvPuBCQlPrEeMrj7YAVz3q22sc3o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790706447; c=relaxed/simple;
	bh=bBTfSgtjuqrjZ2YyzAmD3arRb59uwDPQx/bFQ0YwDTE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=V9brbJ9NcbDzU33t2q6L7Hr0K2rPLP7tFW70BGIBqNJ2lOdDfJkgEQ8fHxZMNrGVqiQTG/+aS1mVdsXUjazEz8nDOfGACk8ocm0mrbUzAM5D/sCOs7Oe2CsvBWEEtRwU8+JjW0juohpxT9qm6Gno3wXUisTdU+xeVgEBRqivY3w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nw183c5S; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nw183c5S"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 712D41F000FF
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 18:27:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790706446;
	bh=n0tAbiOkp5rao9H3r0DhINi4EREw9WaOkqY4jzPmEvY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nw183c5St2FxLBGIDa6NHDcIqd5AcA6rI+PygbgNQuT+xLwIbJoovf+9sGBum9I8p
	 sUjT22HjMjgZRhj4I2VEgnUZUd/T3PCvhRWJdml4wQE5zkxhv30mtzmYFx4FHc6IU5
	 eE7RyzcK9yZepEY4bS/xj3zoIKK10ymsB3D9gm1/Ln83UBFg9wPZXWbU2b8cs6bH6v
	 qtbuYH2+UCwu6dqflewT5Doiyxauhsn+cQvCm2W0zB5BTaax6QD3hOmEDjs+MJMfG/
	 1Wk4fOAu4co+RbvO5dQRuT8vQjzH8BahCing1C4xNpLKTAVdvY3sy8l1K+mYT5xeNw
	 DzpnoNrnb1RVQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 789EAF40067;
	Tue, 29 Sep 2026 14:27:25 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 29 Sep 2026 14:27:25 -0400
X-ME-Sender: <xms:DQO8aizkL9GYyykejkJZkPsE2hIdEEdwRMMaCP8cfxEYJMIVXIl5dQ>
    <xme:DQO8apGCgnSoUhf7su3gTd949fir4uSYaOPGhrpVlXEoSEp98PPG9FKHUDlX2sHEF
    lRBpFy8M4SAYuM__tvWgTsI_xoGUmhFQ5nlfkVns_qiEgkbPb5_PgZ9>
X-ME-Proxy-Cause: dmFkZTGG9pGv8N4k4efFk4P2K9l+dbZ9QDEByEASYMZleiaXMVJKFFP2goWXALxgYP7A7V
    hAZQrpa1zEjqLY35vAKWYr6/eJmZMo+Kl4476AMngdFkKwvBI73VeOb1A9YIPF3BHwBy0Q
    QQ2cEmqWcBRAmmLKmnN+TLlUl7CLhKLAWrN29vlfQOpV8os01xW6oUNcWlApVK2hMy/4Ss
    x5knN9e/XrBpa+TqG4va23QRFE7QQGSwYgt4sdVjE3W70aqwfUAixjTJPweHZd2x4LhJG2
    iP4Q8jwXgTeomDyykwgotrghFzkOwwNrNaF1qE9Yi1CnLgNhiiMvlwbOme0y5Hl71z+0nU
    pgGPVXOIry/jGUtNlYGVvQ6ZQgdGlTE9NlciWWnC4kMQfeF95e9fWqIyoQhg9CtKCKb4HN
    MNqnYGNVpRm9pb3Il7sdTXTtrt5stoOxi8Ql0B2gvW1STPatEDC57fU9v+dgfl79MZzpUp
    uQVxXsQQHs9zIcMueEbfx5VGo38Oj6oWNnwXrTf36YYF8GgzHkgzTdSV3k9obW+CeE9EpW
    P0eNuypOq1NlyXWTCbqvwWMHr0/L5SUDloT/BEu6PhM8jfRuQaON2lCzkJWU5qEj8yI0fb
    KEBqgqTzIC2Cyxj30rXwCca4CtzqBhI0Ek0cIkhUTtA9+QhSVzrWkwwXO5bg
X-ME-Proxy: <xmx:DQO8aiNbfPlstrlj2JReGxI7Qjme1v8fngYMZJvKWjlajrD6BfnM2A>
    <xmx:DQO8aovD4jq6fQ5MGDPNnGCYtrmsbGwpRGiK0Zq_RpeQ2LSKGBx6UQ>
    <xmx:DQO8asWfwQZiChscpYslu_ZG4vBWgAD2oMXrgTTLWyqANhODKMIgGw>
    <xmx:DQO8aguGKQAvDFlQ8xk6PEnqz6t06EQIi-C-umiuj0i46mAk2llB9Q>
    <xmx:DQO8aoX-Eur2lmpMdsv6zwbRna_6kr92LLAI_Bhb91Vt9VY2KlBWtt3N>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 56FB9780070; Tue, 29 Sep 2026 14:27:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A77Ixbv5qpj3
Date: Tue, 29 Sep 2026 11:27:05 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@hammerspace.com>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <37625d4e-9d86-4651-bbc8-73c1c589942d@app.fastmail.com>
In-Reply-To: <20260929173423.16149-2-snitzer@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
 <20260929173423.16149-2-snitzer@kernel.org>
Subject: Re: [PATCH 01/10] NFSD: interlock the use of NFSD_IO_DIRECT for NFS READ and
 WRITE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, Sep 29, 2026, at 10:34 AM, Mike Snitzer wrote:
> Now that NFSD supports NFSD_IO_DIRECT for both READ and WRITE it is
> much safer to avoid needless buffered vs direct contention if/when
> only one of them has been configured to use NFSD_IO_DIRECT.
>
> Mixing direct and buffered I/O to the same file causes needless page
> cache invalidation and writeback, so although io_cache_read and
> io_cache_write remain separate interfaces, writing either one adjusts
> the other so that READ and WRITE are never left on opposite sides of
> the buffered/direct divide:

Jeff and I have been discussing making DIRECT the default for WRITEs and
BUFFERED the default for READs. This patch takes us in the opposite
direction.

Nothing here convinces me that mixing the modes is a bad thing to do.
"Needless page cache invalidation" needs some demonstration, and it
needs to show why the right thing to do is make it impossible to mix
modes rather than explore the issue as one or more bugs that can be
fixed. Or... why not let admins explore this for themselves? Where is
the hazard and why does it need to be forbidden by the admin UI?

Later patches in the series assume DONTCACHE is the fallback for
certain cases. Jeff has measured substantial performance deficits for
that mode, and maybe removing DONTCACHE would be a better direction
to take.

The patch that reports the actual stability of a WRITE was dropped
because it broke something (although I don't remember what). As I
recall, even a direct WRITE needs a subsequent COMMIT. Have you
demonstrated that the client COMMIT is a latency problem or that
the memory that is pinned on the client has a noticeable impact?
We suspect that it might, but every time I've measured, avoiding
COMMIT with NFSD has shown no impact on throughput, which is why
NFSD doesn't already do this optimization.

So even if these patches apply mechanically and benefit your workloads,
it would be helpful if we could step back and understand what you are
trying to achieve and how it should coordinate/align with where Jeff
and I want to see this mechanism go. Can we start with that
conversation?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
