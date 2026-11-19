Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795106158;
	b=mjS6UmYa8Ay2x/qEAr2f2XrjK9c1XCjq6xSI0yjk2MhGUd+fqhD4BAzs3veVnTjHvxkR
	 FoO8V0mKTiRJlWSecX0nVuFcX7EFkcMbmjvCbwtRRt/DHhkYeX5x6HWl2rvTw7j/kWEDD
	 l2+ydm4XGRuSVKlyJbeP7tCaRkwly7JLhXBkjc/Zwjrac8qbQXTK6Vn0RSsEvdO+I6whF
	 95UhscPg1UoRG3KRfIkRiZD5Ku8SzbN1GZ9Ru4wZhEEHYXri1/JCzL/8cULUqHWEqGQJW
	 pYByaZ1vmV04PBMxJ6+eHIFbWFnXaLIgR1KJJfDc7Yl05WOT0UBzeoC7sN/yhRXpQdA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795106158;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=vdpT6LJvyJoZU056rFgJK1cgm13iBFK2/AWVWgyfxl0=;
	b=sl1krUtugMx+K3e+KTssrtawfI6wexaOVujC+9bxxqRh+2nWDKV3snjcmx/iy28H/+QY
	 hOz5r1DTdxxixrIf0JjJLYQjigsXZ6MQpm5+KMvCKpMNuoJ3eUNA/uUC/vAqGrtYK4u08
	 RTB3nWKHo/UuAzkLwiKucoCAa+FdPWu+2YfLD02SndFFRJSlhZNnGFf7v57I1Kakg6Qns
	 1ybvU92vYxmt33AhOE/2zoUmpdO4T7Sq+xnqWNIbxo4RLCroTRNT5RIilBDUq40BnSO8n
	 klSCitZbX3+8bSqyIfpH1tlJH7QsrX9PoiwxUv8A1J1LgIr1z/D7od5Zs3/DIcKc3mw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gQYSVpk8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CA86606A324;
	Thu, 19 Nov 2026 16:35:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gQYSVpk8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 511101F000C4;
	Thu, 19 Nov 2026 16:35:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795106158;
	bh=vdpT6LJvyJoZU056rFgJK1cgm13iBFK2/AWVWgyfxl0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=gQYSVpk8Ti3Dz/c09ltm5E6cnoyLoK3hTNLppD3CmR67E27lg38E+/NCiyJoo762q
	 1JxZAcpE2jNuyH7arhdRbACTCBIFV5B499W36m5xUxPglxihcgAMnUl6P1qFnWYZ4A
	 ezd6Xu771igMuOdZ5aggHIRRgwgXfRlWMMFAGf478Zt4qaRiCtizOmkjNT/qvfXO4d
	 2MjjshcGxxPN+92CMQDEpdEjqWE48UfVSvxylXsMxjVHk0GG+Z3S8S5vdgqPqRWYZV
	 DCmzsDYax8vY22yr/uMKPF5oDO7+HGcLKgrnNe476l85h2K5RNG1vW5btEEM7rwpZF
	 YE6t540hluycQ==
Date: Thu, 19 Nov 2026 16:35:52 +0000
From: Simon Horman <horms@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Donald Hunter <donald.hunter@gmail.com>,
	Jakub Kicinski <kuba@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Keith Busch <kbusch@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
	Chaitanya Kulkarni <kch@nvidia.com>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Eric Dumazet <edumazet@kernel.org>,
	kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
	Hannes Reinecke <hare@kernel.org>
Subject: Re: [PATCH net-next v3 00/10] Deliver TLS session tags to
 upper-layer consumers (NFSD)
Message-ID: <20261119163552.GZ860048@horms.kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
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
In-Reply-To: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>

On Fri, Nov 13, 2026 at 02:21:58PM -0500, Chuck Lever wrote:
> NFSD controls remote access to its exports today by IP address and
> hostname. Neither of these are cryptographically secure. For
> instance, a MitM can replace the response to a server's plaintext
> DNS query. As a result, a malicious NFS client can pretend to be a
> client whose hostname matches one that has access to exports it
> would otherwise be denied access to.
> 
> So instead, we want access-control decisions to be based on
> cryptographically-vetted objects such as TLS peer-certificates.
> In-kernel x.509 parsing would duplicate work mature userspace
> libraries already do, so let's make tlshd evaluate peer certificates
> in user space.
> 
> The certificates are evaluated against admin-defined policy, such
> as whether the certificate's Issuer matches a particular string.
> tlshd then marks NFS TLS sessions with those policy matches. Admins
> also provide a set of policy names on each NFSD export (allow_tags).
> Computing the intersection with these per-export tags is quick and
> completely separate from the details of parsing x.509 certificates.
> 
> A yet-to-be-posted patch series introduces tag set support to the
> exportfs command in nfs-utils. tlshd 1.5.0, current as of this
> writing, already implements TLS session tagging.

Hi Chuck, all,

FYI, while looking over this patchset I noticed that CI flags
shadow len variables in ynl generated C code.

I believe this is a bug in ynl-gen and have posted a patch to try to
address it.

- [PATCH net-next] tools: ynl-gen: avoid shadow local variable declarations
  https://lore.kernel.org/netdev/20261119-ynl-scope-v1-1-d3b0c964d4cb@kernel.org/

...
