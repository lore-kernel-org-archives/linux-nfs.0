Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794471106;
	b=xtNJmQ/jPDiL6P872zi4lerHjmj5JwJIUH7fIjTeDZu4oqP6NBlJNtE+bAqAUmJj7ZYo
	 31cHgpchQA9i1EDiotQrN4fCWkkIxr6W774yrF8EeAAv2La+nllHcy5+vM/HxjDktEVZw
	 +M+OKFFy5HjCLoQJUhd1S3Y6oBmfjZromQ9TA587diszoGGUOlB+A2sp91De+QBam0RoI
	 yvB+htZcD8PTV/5CS/soTyD7CxuHvOGieiobGBk7iy/hZ2K7uHMRv6uG5CFZFcRKNeGeb
	 cmJ7H597iyhpfCJJ0vXWK3uoATYhL1l2h39ytHMAmii/JUxKqDG7RkVyS8L8vYIlp0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794471106;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=5jP3WnmbQtvEPbEed08PResBYIqhTG3VkGD2kJsGtEM=;
	b=kt62fvM+xbQr3KF8sMO4TTkZdmiZH1Tiw8G8h5mYU9eO60dDmM1XGlyrFucB8ErjgSHS
	 aiNImHRunR2rNdtp0d9GCKbJ4VyHKrFuV15Pr8EY+U1loWKZSpe3eqy8SXusJpdXKIIZ6
	 8yWqTdE16oI1tQsgcEXECDltQtdphF7ZkbrIEAhlr+8YSg9o5BAiOlejwwXGkiM+WW4dL
	 OHc1nWOxN61uGMDECxBtkE1/86xvbJzepdzAQXOr08iLeU4kuiysW8WF7+Om3ChOCt3aD
	 Kv+nzrlYsx4PI5IRjE2Y3dIM/EdBAhVFsfYchEC0G9SzVIo1Hhi1o+w8nWxPm2Vm3eQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Mk0LPc76;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 27B36606A332;
	Thu, 12 Nov 2026 08:11:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Mk0LPc76
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 153EC1F00A09;
	Thu, 12 Nov 2026 08:11:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794471105;
	bh=5jP3WnmbQtvEPbEed08PResBYIqhTG3VkGD2kJsGtEM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Mk0LPc76zri3qomSdEor/KlJodEmHosdWQSoHEAciZX8vMb+eOvaKzK5wGyW9mVgy
	 MqJClOk2CH3QeMDjlRnU80SmoDJmrJbem3WUSxeGzStNyNXRHLpOU+3++BbYJtkIkl
	 vxQFhpj5+lq/kIfSa64soEblDiH/Kw7+0jYHk3KVESyuZ4phjVs0HhlfkEkKZRTZ97
	 8NFo0bqadHu0+b2J5mQCYyGFWV9Gd5TQ3AaPWzc+5z8gnlPaJ/VksgY9BgH0S0TCnC
	 pqPFM6LiADtNo3tvGsB6/PvuGUuPsmXpfH3Q928P7go16M7ZK9Deci3agR8FgCjO4k
	 G1UxE2A0msuvQ==
Date: Thu, 12 Nov 2026 10:11:42 +0200
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org, linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>, Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>, Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: Re: [PATCH v6 00/13] KEYS: Sanitize the garbage collector
Message-ID: <avV0vjDNbh8VDk5N@kernel.org>
References: <20261112040242.247168-1-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261112040242.247168-1-jarkko@kernel.org>

On Thu, Nov 12, 2026 at 06:02:29AM +0200, Jarkko Sakkinen wrote:
> <SNIP>

All Sashiko responses show "no issues".

I assumed different because in the past I've received responses only
when it finds something; so I checked them all through.

Br, Jarkko
