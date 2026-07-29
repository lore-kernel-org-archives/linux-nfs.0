Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8ABB1EED8;
	Wed, 29 Jul 2026 02:30:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785292260; cv=none; b=iQHyfY6jZAM3cBmQgNjL/oL+rLI4PG22HtA4x8Z1Cx/UWtoEHF1vgwExTno1n8z2P7eDv1AvW6qjwENZLa4URnits37m2n+BPNoxSVragfO2BRqGNu8AmSWQRD7VO0TBjx9QGP5Y5XHDnG4MJj6cUOMc9B5V6CH8NRPUhrp/RS0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785292260; c=relaxed/simple;
	bh=V/jgh3B65jBgD0Vc+Ac/aIGiX8zbLBjecLFYenU0w3A=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=HDBFFl6yyBix7u1NEJlgvcz4D+dW1pTXo77vr4eVX4kBPh+24HGAOlFfMQRivCvDWc3hA27weyKbMugK7IaV5d3Q7XB5Q1NSnjxBUDIeORZEibvsDJ343f5iyFVH5V2rThLj/pHOtccMaoIbvSM7CPhfI0jJ7Q2y+akmhHJXDlU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=L385pEnq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="L385pEnq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFA6D1F000E9;
	Wed, 29 Jul 2026 02:30:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785292259;
	bh=V/jgh3B65jBgD0Vc+Ac/aIGiX8zbLBjecLFYenU0w3A=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=L385pEnqMskkWtBUYtPyD3KdYKAB1tHjWc0rxiElT+0DxybBQK2UuPXQNiFvRP9jT
	 Bi8Zcii6jhbVtTbUoxp0gqonMTlCIl49oux6h0z6Q9/iBYgB4aZ0jDDkzwxUyHCSOX
	 MdBmAwXpEJH/hWl+NXaxLljy996LZbHfrgfU+yPGu3R4n0PhkFkjwp8j8+QY2DCurk
	 8L1q0yGMhut/GQS6s80DGh5q/emy4QO3evVXOIX/4KTzxxeqDVJbpeEiifZQm31Lw8
	 IUIPB8DOr2yjz5ey8LARcghD2h7Kl82Ig8IeWtfGYg3mTQQpVKF3/XolxwtjfIyPdK
	 k5NUI6lww0T+Q==
Date: Tue, 28 Jul 2026 19:30:58 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>, "Sabrina Dubroca"
 <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, "Olga Kornievskaia"
 <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey"
 <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype
 proto_ops for control record delivery
Message-ID: <20260728193058.7f6b453b@kernel.org>
In-Reply-To: <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
	<20260728185124.72e421c8@kernel.org>
	<480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 28 Jul 2026 21:57:21 -0400 Chuck Lever wrote:
> > To me this is an ugly one-off workaround that doesn't fit into=20
> > the proto_ops (only TLS will use it). And you seem to net out
> > to the same LOC on SUNRPC side with and without this? =20
>=20
> It=E2=80=99s not about LOC. It=E2=80=99s about not cluttering the normal =
I/O
> path with a lot of exception processing to handle TLS Alert
> records. The CMSG API is very difficult to use and leaks the
> alert messages into I/O buffers (which for in-kernel consumers
> are page cache pages). It=E2=80=99s piss-poor API design.

I'm not arguing that it's amazing. Doesn't mean we will YOLO
a special proto callback for every protocol stacking :/

> > There needs to be a very strong reason for us to add APIs for
> > in kernel consumers. =20
>=20
> This is not a helpful position. Your objection is the same
> every time, treating the in-kernel users as second-class
> citizens.

No, it's not a second class citizen. But kernel consumers have a
tendency to break all abstractions and insert hacks all over the place
just because they are not forced to go via uAPI boundary which forces
people to think about the API design.

You just need to try a little harder to produce a better solution.
Rework or augment existing callbacks to let your achieve the behavior
you want.

> You haven=E2=80=99t provided a single alternative to address
> our concerns, and you have not explained why an additional API
> is a problem.
>=20
> Please put down your hostility and elaborate. You seem to be
> the only one who has a problem with any of this.

True. We should remove maintainers and just commit obvious LLM slop.
