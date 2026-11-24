Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795480499;
	b=HpTq6aUj7O+3aKwStYJ3VZIVktK3bx6mDuM87oTCKpe5gKMG+rmy8dnYwyrDq14MGwaK
	 dn590PrFvT3pArMcUo27/obrLORYTTlnnQXNcMQB1+R56Ont24etqypU+4DT0PlK6qKYH
	 yUyOimz90D4moIU6dvOy4XXG6+ZY3WLlLgZR5dDNNZVqYzfecb1uAl1nFaJ7wiDvqEHpS
	 ZKt1Dub6uYn9GfFqLxzi3Xdq6sgxsvwtvLLxlyCSOItG8mERBoPo7ORewhzcFy7UKYKhD
	 WXqRjIqFr1xS91fPffEudpUQNGwTONEo8xZKcW8r60kb84JuqMkpDlUFZC8vWEJQlaQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795480499;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=kiBFVYpJZV/z1Y7/aNci/WiL++vzCEQVBpC2tTo5b5c=;
	b=ZMcbU9mIi57PRz5+yWsxTAzUBHzUyb95ZXXeANnTnhN1UBzpRszaY7U2DIdRutPi812M
	 OLOjGqDrXCwMN6flclHhzIw8HTeZ3vRROt0A2tsJ0wUOGO/z/sHNxixZ5z7hGbRce9df4
	 r2ytTmVVyU7lc3/hlTVDAB8hCLj2Q1BAUB3o1QMOM3pepsD392PNj9d+Q1g2oqEMMySJI
	 esWBDP5eThI/m1sB0GWbzlCneYKQMzSLBPI/bIerdgVXQarwEGPzGTDoJ4rWhW+/kVQZC
	 AoqWagOHRnzlvn8xObZnDkX6rWZOXv7g57UxVsNqIB/3HTyT+OsBErhDD2VryDutAyA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gdjFd6yl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6FDD606A31E;
	Tue, 24 Nov 2026 00:34:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gdjFd6yl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 91D1E1F000C6;
	Tue, 24 Nov 2026 00:34:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795480499;
	bh=kiBFVYpJZV/z1Y7/aNci/WiL++vzCEQVBpC2tTo5b5c=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=gdjFd6ylCYe3WifuWcTq7DnflOd7Jwq7O+OcWvLD36AlMDYuySmHI8EySL92MHbCr
	 OsJiA15ujNPK73U0NqMS57S9LcOg5nNHXOHRCe07btshprhyAFRyEuL30JIpau9n1Z
	 Bybni3PAips7Yfb3rWbATw3O+TQZaYapMJEqCrelsj+9wlder87puNluvBRuUYCN/k
	 WwOZUzN/4ZNwmaF7b59AIOXrTMWE5zPmC2pjxMpCPYCux7tHxXiA6eOghcZHVhUVRo
	 EIJmx+vsfGVELo1uYUxB8VBqnPIdyD3r9fVKagby+B/eVwgVjQS3q4sG1gM1pcNKXY
	 KET9Kc+RrEKhw==
Date: Mon, 23 Nov 2026 16:34:57 -0800
From: Jakub Kicinski <kuba@kernel.org>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Donald Hunter" <donald.hunter@gmail.com>, "David S. Miller"
 <davem@davemloft.net>, "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman"
 <horms@kernel.org>, "John Fastabend" <john.fastabend@gmail.com>, "Sabrina
 Dubroca" <sd@queasysnail.net>, "Keith Busch" <kbusch@kernel.org>, "Jens
 Axboe" <axboe@kernel.dk>, "Christoph Hellwig" <hch@lst.de>, "Sagi Grimberg"
 <sagi@grimberg.me>, "Chaitanya Kulkarni" <kch@nvidia.com>, "Jeff Layton"
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, "Olga Kornievskaia"
 <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey"
 <tom@talpey.com>, "Eric Dumazet" <edumazet@kernel.org>,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, "Hannes
 Reinecke" <hare@kernel.org>
Subject: Re: [PATCH net-next v3 00/10] Deliver TLS session tags to
 upper-layer consumers (NFSD)
Message-ID: <20261123155242.49d87894@kernel.org>
In-Reply-To: <7a0695c2-bf7a-4394-8cfe-a92deeba51e3@app.fastmail.com>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
	<20261121161302.69f202c8@kernel.org>
	<7a0695c2-bf7a-4394-8cfe-a92deeba51e3@app.fastmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, 22 Nov 2026 16:27:08 -0800 Chuck Lever wrote:
> On Sat, Nov 21, 2026, at 4:13 PM, Jakub Kicinski wrote:
> > Naively I'd think it creates unnecessarily wide API on both ends
> > (handshake and server). My knee jerk design would be to populate
> > the full policy in the server, and only carry some "policy ID"
> > thru the handshake. Number of policy IDs would equal to the number
> > of tag combinations (which result in different behavior). =20
>=20
> How is a tag much different than a policy ID?
>=20
> It wouldn=E2=80=99t be impossible to impose another layer here that makes
> a specific set of tags into a single policy, but I=E2=80=99m not seeing
> that doing such adds a lot of value.

My thinking was that we have two user space components (TLS handshake
handler and the storage server stack) which are required to render
their decision in the language of tags, and upload the result
to the kernel via independent APIs. The policy ID limits the kernel
to mechanical enforcement. The components resolve all decisions in user
space, and give the kernel full list of policy ID -> allowed resources.

Could be purely a subjective preference, I won't insist. Tho an ack
from someone experienced with building kernel (security?) policies
would be awesome.

BTW someone marked the patches as changes requested, so repost will be
needed.
