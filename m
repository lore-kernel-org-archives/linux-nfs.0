Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E13A43C3F41;
	Thu, 30 Jul 2026 21:35:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785447358; cv=none; b=rGM8UGj9aTDhdEcyVQ4keujLukYB2HvxC1c20ooJbHsn8yAiqwhZI1Hcb4YAde1gSWMJgliwizsuVpXR1m83XcYYCmXMzeiBdMj/iPuLtz0MgEl4hByM8cKsFN8cdWPVr5/lMj+G6u1CiqjaaJ9medbPPhoKE3VGg4cTny9J6zU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785447358; c=relaxed/simple;
	bh=hmbJwvv+QHJ2/b0lqV0NNCRelbFPAL1DmeomnFkAZPw=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PNt+j0oWMRqrWO5Uw93e729/ULV2DVDdG8ojOFOCB90CYh2tQ0CXGE0QipOKUbtP8z2wZXDApvR0/MKfwWUm7R9WVIMywmfWP+YB0fk3xSDRCQv9w2aJDbUxtYAac0WoNdtrufJ+5cWwqZekPGnH4agsX53muCGCbbksI0fnMM8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=S1WazX2n; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="S1WazX2n"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98A921F000E9;
	Thu, 30 Jul 2026 21:35:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785447357;
	bh=hmbJwvv+QHJ2/b0lqV0NNCRelbFPAL1DmeomnFkAZPw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=S1WazX2ne1KdpkwWes3A2jNnXPqOLM8XZ8JF9ymxYz0hNmskk1pnuysL1UZ+g8h7E
	 FW2mFjjJqxpqalABdPr2XTh16dAYYs2/TNAb86VBfqvr7lYQOmeM9SIR2xQuKW/so+
	 2FcIpudgAQ/I7A9Qh26qtBzJLCdev7a8BtB2XvDWNOlvadrrmPfWoneSJFTW3FYMW9
	 MioDklS89c6OrbSYRxSlgpGbjYenDrmOghULzqXqD9yZDNARBdP1EX6E/JPAYUuekr
	 YxqAynPm9A9nVqhDa70KeJES4C/U5ohWdm+FiRQlArAXk7d+015cOR3FocjjueQhcF
	 rKzNPKjJZvxfQ==
Date: Thu, 30 Jul 2026 14:35:56 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Cc: Chuck Lever <cel@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon
 Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, Shuah
 Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype
 proto_ops for control record delivery
Message-ID: <20260730143556.4a8463fd@kernel.org>
In-Reply-To: <amtcwSO24GGq_qd0@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
	<20260728185124.72e421c8@kernel.org>
	<480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
	<20260728193058.7f6b453b@kernel.org>
	<a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
	<20260729163142.4f41484f@kernel.org>
	<amtcwSO24GGq_qd0@krikkit>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 30 Jul 2026 16:16:33 +0200 Sabrina Dubroca wrote:
> 2026-07-29, 16:31:42 -0700, Jakub Kicinski wrote:
> > On Tue, 28 Jul 2026 22:51:30 -0400 Chuck Lever wrote: =20
> > > No-one is asking you to roll over. Review means you get to steer
> > > us in the right direction, and I promise to do the leg work. Terse
> > > rejection doesn=E2=80=99t move the discussion forward. It stops it co=
ld. =20
> >=20
> > With LLMs tho, the entire human effort is in finding the right design,
> > rather than the code. So asking maintainers to hand hold everyone thru
> > their features is unrealistic.
> >=20
> > Off the top of my head I think a setsockopt which pre-seeds the content
> > type so that the read returns an errno if the queued content type is
> > different could be a simple fix. You'd configure that on your sockets
> > to DATA and once you see a EWHATEVER you'd assume that some special
> > record arrived and the socket has to be handed back over to the TLS
> > control path. This is literally the first thing that comes to mind,
> > IDK how ugly it will look in reality so no promises. =20
>=20
> But then you're back to "read_sock stopped, caller has to take some
> special action to handle the next bit of payload". It's not better
> than "read_sock, and do a recvmsg when read_sock says it's not DATA".

My bad, I replied without looking at the code.
We already constrain control records in the way I proposed.
rcvmsg (w/o cmsg) and read_sock will error out if the next
record is control.

I guess I don't understand what Chuck meant when he said that
he has control data leaking into page cache ;/
