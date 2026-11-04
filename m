Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793759607;
	b=l4JAwV6S9sOW/4lC9vyI7ACb47Y5owv2nlGEmrBWpVwua13/rd8yDH3Alf6Mk8a2mmO3
	 iqYRJ//nUBYa444HWSrAFci+QvVcdIy18vKtCFEMwPQSnV78ekSsjnEaIL+No+6gB82wT
	 zRWR/pVA6qB7VRgPcyuPhP3HQqiMSEjuhYm+TOqsuetwVL1zYMgUIftiv6bjCp+pwBxJ0
	 NKipulgIm8EBxk4hUsPFqqzOMvYMijabbXsiyWcf/5qULGEU+hHh6qXJmIeuC/cMTjpZp
	 MlIUwhaSxSZJOG0MdaJmwd5z+8Kb9aKoCRq7jDZ6ed3etM9i1mbmFIOkwJe8aHVOLRg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793759607;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=Z9zRtXHe/J1k/4/9wAeq1n+PwAt+ioXmV3zyjSNrjDw=;
	b=yGAu4bUlURQrD0XuN1Ny4grXvTBoae2KWveDChWzKvvVxrp2VDHP/TNG73XhF98Eu0hj
	 Yd8vM6DQ01o/PgFZ2jmo2y49lccN+z2iEAujt3Z3TJeQ5zZOmD/0LlhZpA8DensseUZ/P
	 3CZ68P4kjAjX8oftDhGkR3cbE3Sornas0MzHHS01Z1Qg1kRUTYWpWYPQnavUHdk6BFwjp
	 lctLHemwBjhZqEbnmqu5zhykH4XHI4vj7GdfSbTpyiCpxU2KEH1PDEP4l+rcAK59UTJUw
	 cWgA39frtZXUSISGK5OjYDWhGK0UucUU6RC7MWPL9FbPOcG2LiRm2pPJ0z575YQgrqg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UB2YMEpU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97165606A32D;
	Wed,  4 Nov 2026 02:33:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UB2YMEpU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B1A81F00919;
	Wed,  4 Nov 2026 02:33:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793759607;
	bh=Z9zRtXHe/J1k/4/9wAeq1n+PwAt+ioXmV3zyjSNrjDw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UB2YMEpUuyI1KCpBjTumG+uB6e5xZHzsP0Y8Wn5pBntqxdzrfad7dFiNus9DAX884
	 xURV+LXKgVz4soi6tl4ts8sH+jlB/w1/IoYadpvho/L8odhcy1PlFzI2VEOZarUMeK
	 +QmlTuJ17Wzn7jpor+bdNHbC4lROz+dOeD3eo6Masb3c+/iAJDrCqLNKlNxuy/h/ZU
	 JWFwFpXOqGdjdX3b2ZbE7WHKQTthDdDiihVJyTeSkzHBf8QtenJOIHjThamlo+5wt/
	 FU32TDdk6p+Imw+403UhUSKmQaglry6An5eBVT1ngRIy2Y0W0AAeaC2kgJY+U3Cg4i
	 We4waxGcagT7A==
From: netdev-bot+sinfo@kernel.org
To: Wentao Liang <vulab@iscas.ac.cn>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org
Subject: 
 Re: [PATCH] svcrdma: drop the extra reference on the backchannel transport
Date: Wed, 04 Nov 2026 02:33:25 +0000
Message-ID: <179375960574.488859.7834588984022893784@kernel.org>
In-Reply-To: <20261104022813.1484267-1-vulab@iscas.ac.cn>
References: <20261104022813.1484267-1-vulab@iscas.ac.cn>
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
