Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794698936;
	b=CgMw6Bg2Gs3DHldM0eoXwqZuC1eh0VLt8y9QM3F5I5LMKZecT0YhCtCzqholNo9COmE6
	 q+lFhOoabbGfwd/cIUT44MSS1H6SIHP8BcYVOw4uEJ2iK3Sq5RWdhE8TyuRYgJqTxb4Vv
	 taVcKMxOxcnhlqAdg8b0h89YCWOE/Wix/p6v6sH+zL8Cct2jlPgdhVjLlwZoW/uXwCb5w
	 cviGlprwLfV9A4Yrcf8btj6cNq22I3Y53m60QhpQBIWNKM/6ftDp5Z3w/8MQfp1M7FHJa
	 zlR3zMdp2JUh48ifXorUcMILzjTlzd2gmHFYYnxC06zoz7SiV37uX+n4y1b65UrVK/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794698936;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=QxgbBTCWsStn71Jsz05WFHT8X6vz351Ef2Am8WUTxSc=;
	b=mS0Lh5pNNzAcOQOopLEgj/bb5AAeonTuXsHKjuuisEepKQuuXUZvemK/fmouZti0Ybri
	 NGeVxuxiWPvNW/BWTF2ieJaIzfcj+s0M+3l2p+6eki1bhEN7pKRHCguV7FReCC4ffmheK
	 fPKTUXiEf4CbJ8agOsHDOHItSZVM/ERfEXnMIDqlHu3QuX5TE9giO7cGOpfayA0pFUISI
	 +/NsHrE69lKoAarDU7ba/v59O9lUgEvolcWZqH7PewpQsHDqT4Dc1RWPYMuAZJCEjF3su
	 XEAru4eC+kMY7N4+ysLF9YZaUMQMx5x0vRtrAHK6OfVIe8NT9/sJ7/pAE8+ehrxJk8A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CcueqTvJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id C9758606A329;
	Sat, 14 Nov 2026 23:28:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CcueqTvJ
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id A66691F000C4;
	Sat, 14 Nov 2026 23:28:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794698936;
	bh=QxgbBTCWsStn71Jsz05WFHT8X6vz351Ef2Am8WUTxSc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=CcueqTvJTGbepbaXa6N2hDzZ1Z3g3dEoia+l6XBVumHg3wnH5cZOI2Ax9aWKES13Z
	 h6YaDY3dlt98ceXOzmF+KuXTPYAyyg3vmDfAj91SBWq3NTwJhyT6ZEF1KwcANZCvog
	 hwwPLwHEocMzdNBaRLUMv/GolT4R3O5XVi5nwjW+p3c3caHWauTYQ+ZQ/sUZAdol9W
	 b/7jI4hZJGKRo6phO/tkyJIrQK4ZQkx3Ul39qeLqBdhAKSQEsKEnhS589d5rl8wfHJ
	 4n6IYPzGEb2ZqrhGzYp+r1QmdY2U59IfRpIUXj9Q/ICOO0rELmrmuRlNPYjBAQRvia
	 zvpTNZoKShgUw==
Date: Sun, 15 Nov 2026 01:28:52 +0200
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
Message-ID: <avjutAro2-Q5VPvx@kernel.org>
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
> 1. Replace key_type_dead retyping with module reference pinning so live
>    keys and restrictions keep their backing key_type module loaded until
>    key_gc_unused_keys() or keyring_destroy() completes.
> 2. Process serial-tree scans and graveyard destruction in fixed 64-key
>    chunks to a bound workqueue execution latency without hurting overall
>    throughput for a significant amount.
> 
> The first part has a user-space visible effect: rmmod returns -EBUSY while
> keys or keyring restrictions still pin the backing module.
> 
> Internal key caches or transport state bottlenecks are addressed by either
> clearing their private caches on last-client teardown or splitting key
> types into dedicated provider modules.

This passes bot+bpf-ci@kernel.org and Sashiko other than the remark
about inline comment.

I'll update the inline comment, and make the commits available at
-next.

I'll leave S390 fixes out as they are out-of-band. They can be
picked from this patch set; or I can later on send a separate
patch set.

Br, Jarkko

