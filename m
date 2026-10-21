Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792614647;
	b=LhWcvoQBGWIDNqDE35jQ8Cqe8InUNqy4+2hAxxw2lc0xL06aqoP/dXEgYzJNf9jow+vy
	 udHZXxcPNDibtycFTSJ/nApN4JEJ4+6YU2mTuxT/24tBawPm8afEhKyU5JDLpGl0Yx5+u
	 ESkotWWT9+LnWxW9NOPH8LzQEblArR7jZD1ZtuZd1X79ve5zsEgswFuvpeaRP5fCFnYrZ
	 VpjV2xtLEX5bOp73kpov1YzqaOPdnZIw4aCMRWnFp9uBXyNFNcpuAVRx7VbiHfkzSEpSf
	 pfpVwhypmg3/k2y+t/TBFjlpEWLhG0k293Vqsl2kfWmnb35tYNWibrLUjzHAynRCLjw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792614647;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=Z06VJ2f4a73dNOr/RC4E8wz2dI7mQrbd5zBtJK2O47E=;
	b=GQ9N5vNYF/sxFKkueInOTFKIabnDle5MOUmVTmgDX0cKxaeXpO+KW302xG2x2BkyERwF
	 LfY9zN3ozFVebbmdZcvNLa9D6sbxUXuKaFdOzjSI8APgWiDpk1iIdj2mtpyfZysu+gdpw
	 52e4YsKhcxiuwNWJf3M7PDxaP9hlLxW8VhgjFxSnfA1trE7TGA4tBYYl654nhutVlJyrU
	 g1jGFtlQ1qwmOO9NaHm0ha0fYO3zX9RQzSGp8XzVt78zs4xkXYoh87ZaH32MmbzeLugSn
	 SVaUEgUBtVmI5GsuZibUnpJs+GsZ4/Rd4RNPIeHugBdJ6T2s4YCVwqtdobDAyU/TtrA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jFWWyBse;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82999606A31A;
	Wed, 21 Oct 2026 20:30:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jFWWyBse
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FECB1F000C1;
	Wed, 21 Oct 2026 20:30:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792614647;
	bh=Z06VJ2f4a73dNOr/RC4E8wz2dI7mQrbd5zBtJK2O47E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jFWWyBseeOGFsyJZp1cNc1ZvuV1CxVl879SXQFruXJmh6K6gqvWnkmrYajD9vFFbT
	 s5HNx94zi6AukAoyGly85pAgr1wdJJ4ILK6YHd67xIMi//csKKBJbJuU7zRs5TAW4s
	 LNneABIAyxYLOdAtXf5do81s/XqWreahLg53tv78DbM+LUFCp+bmlsSN67KpzqNXDR
	 /I+vb3Q4JbFs/jYRNPxyxqbYpFGFacqsS4PTRUVpM+f1Eb7Nzsvb+yM/omoXDLdhPK
	 oOSZngZuygQTdIe6ItRflp+Y+0lTE/DD4kHMj3MKzmuvK4PGxZIrfaWJACsFuRNrSU
	 XiwqIwt+b16Jg==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	trondmy@kernel.org,
	anna@kernel.org,
	davem@davemloft.net,
	edumazet@kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	Deepanshu Kartikey <kartikey406@gmail.com>
Cc: bfields@fieldses.org,
	skinsbursky@parallels.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Subject: Re: [PATCH v3] nfsd: store net in svc_serv instead of deriving it from sv_permsocks
Date: Wed, 21 Oct 2026 16:30:42 -0400
Message-ID: <179261463691.2314857.10594741466584262166.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261021124213.6288-1-kartikey406@gmail.com>
References: <20261021124213.6288-1-kartikey406@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 21 Oct 2026 18:12:13 +0530, Deepanshu Kartikey wrote:
> nfsd() derives its struct net from the first entry of
> serv->sv_permsocks using list_entry() without checking that the list
> is non-empty. If the list is empty, list_entry() returns a bogus
> svc_xprt computed from the list head embedded in struct svc_serv, and
> the following perm_sock->xpt_net load reads past the end of the
> svc_serv allocation:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: store net in svc_serv instead of deriving it from sv_permsocks
      commit: 764ffa45f3f2189cd86ec6d46d248fc0440507b6

--
Chuck Lever

