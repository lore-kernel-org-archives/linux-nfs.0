Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795306384;
	b=pGuRA8bbILmYO2TjXlV2dhmhHDnFzMYgckd+dJfxS/ppDuG2LsREDuzyTUWgGFxoEybu
	 kBK1lmIegVbjg0ZKhsCVDtT2jB8aSgxwC73h6eo67IGIDw8Md7X0L0NiWW6ylPBVaWbDE
	 4JDM+dwOqCTwf5ibOB3K/tvx7l1i8dXbTJBorDkVJL4dr0aEzhpbRn9sXb6D1CsXwscGH
	 H/UGtZbJjBajeqOFiQSnT2AMtQry7S01bArVOX6oaZGpxK5CNveBTJH89t8VmFRm4+mMv
	 0DjJlUiCe56aoscQmsfmJmw23oHjZ62/kPjox/YEi+EbWvOrSUm6I2S6JNruYSwyJJg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795306384;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=Wme/Jw65vekSkLxpWIsP9GgAmvy1/VZB1ZbshkHKAZw=;
	b=Uu0V896PQtiDXxz1itY2NbFYr78sGZOA68X7v+YonCCWAWXYDkt1Hvp6JfKo5dUFBb9K
	 DWd4ET6meo+e7Vafb2Z1gShl3BkRnmKe3q6o6vhXaSa71P3gJclvlgfzkSZrZS8C/8kT2
	 z0o69LygWNBkouUb+SE/osMq6uWtT6WEiaLdT1GDpOa8apDmZ3Qg6jV2XOGC48qZ3ORVG
	 NWU8ATlHGn6Sg90yAvz2n8SWQwpJd+SmFmMChf/tlPcNbaVvwrCDizrANP3DW/lzJFB2j
	 RZP89kNeEQ5n7A2g+UXhIiR+9hZGwHF2bK5vW+lZ66mCbaqGxykE1rGwc4a3zfpBloA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=X3nYg85n;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 892D7606A320;
	Sun, 22 Nov 2026 00:13:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=X3nYg85n
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AF7C71F000C0;
	Sun, 22 Nov 2026 00:13:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795306384;
	bh=Wme/Jw65vekSkLxpWIsP9GgAmvy1/VZB1ZbshkHKAZw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=X3nYg85nYhldkdDOD6+IzCzfE+ghiyyrey1IreSL8rUp6l2H08RQeBZGRKYeo9qst
	 Ny3CaPnleLhvnutoO5GS6D+KPDlYLp/1M2Bbz0beGB1rdV+/yNFjtoA/JXlxKfVe9I
	 XEG356y+Ut88rKRHvt5Ff7c3qAClO7cQrW0b8Kcr1Nlao9oD+sN5A2M7u4HVLPY2ed
	 oHilj/rEtoc1tTuPLPjqP/6HU+nTZ7BkqmKFuakpR5FfBPS3l1wMFLwU8pSQvw1qVQ
	 BmHok3z4HQNQDMuygC7xfEIMMYsTs5WiekDFnKTjKTLhzASQOCqGW2va0jGvgIscRo
	 7flK77N6TyExw==
Date: Sat, 21 Nov 2026 16:13:02 -0800
From: Jakub Kicinski <kuba@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Donald Hunter <donald.hunter@gmail.com>, "David S. Miller"
 <davem@davemloft.net>, Paolo Abeni <pabeni@redhat.com>, Simon Horman
 <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, Sabrina
 Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, Jens Axboe
 <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, Sagi Grimberg
 <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, Jeff Layton
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga Kornievskaia
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
 <tom@talpey.com>, Eric Dumazet <edumazet@kernel.org>,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, Hannes Reinecke
 <hare@kernel.org>
Subject: Re: [PATCH net-next v3 00/10] Deliver TLS session tags to
 upper-layer consumers (NFSD)
Message-ID: <20261121161302.69f202c8@kernel.org>
In-Reply-To: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
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
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 13 Nov 2026 14:21:58 -0500 Chuck Lever wrote:
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

I submitted this for AI review now, I think due to the problem
Simon flagged CI didn't just gobble it up automatically.
The AI review will not be emailed to the list automatically but
hopefully it will be ready here by the time you read this:
https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261113-tls-session-tags-v3-3-91271964cdb0@kernel.org

The patches look reasonable to me, overall. At a high level tho - 
I don't have any familiarity with "tag" based policies.
Are you confident it's flexible and convenient enough to survive
as uAPI?

Naively I'd think it creates unnecessarily wide API on both ends
(handshake and server). My knee jerk design would be to populate
the full policy in the server, and only carry some "policy ID"
thru the handshake. Number of policy IDs would equal to the number
of tag combinations (which result in different behavior).

Any examples of APIs like the one you're adding working well?
Anyone willing to review this series, please??
