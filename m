Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D67F3CC7D3;
	Wed, 29 Jul 2026 23:31:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785367905; cv=none; b=sbP2LXpOJJCDtbzAq3wbPWaghlcGx3DNvTm2RGNfhX5KftOqBhChMHgiZMdznfRfhsYsG/6mKq5uvA6r2mvIqUZgMkLdNjVsgZhaHH9gwifJRd5tvjeUE0NGX2l+Ub0ke+IL0LUOUvMegEkJ5iGEWHAK/TJ1R+1AgBNb7fGDhTY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785367905; c=relaxed/simple;
	bh=8spdBQhYwS6d6Jzd4KhZCfbBTMjGBkrC6O7dHZRyBFk=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=T7ZWsWlFIA7jqnAB/P2QdiHpACak1jIo74L2vz5z8+nk+lfsemv2DcBbDAphWSXA+q3vsKwKHmjE+lRTzCdZSlvmiaw0Fkml4gsFr94X9ir4GxRrT4E1dEUDy07wvC0jGYnJSRIBlG5ACgEY4jpyezIlt6CQrrHEWHTzGBIlI0c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CR3CCCZB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CR3CCCZB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 20D8B1F000E9;
	Wed, 29 Jul 2026 23:31:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785367903;
	bh=8spdBQhYwS6d6Jzd4KhZCfbBTMjGBkrC6O7dHZRyBFk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=CR3CCCZBMwogRfc29BDwNhFdetnBYDi+Z/ktKZTTqOi6DpnzqdnH4jZ9chS7UiF5o
	 C+O/vTdYUXiOegeUqc66i9oi5h4SVs92tM9As0jJPobHFqKYgJUbGMrnNzKYYBYixW
	 Dc3+nkk8FlS8pDWDtwBzdfltk6CmYV25/OF+D//m6AaixXgFM0rSFlTfV/+53oGac7
	 5EL0NxdbML/qQSzmObTb8pdP4jD3mdE2jngMH8ctOARGP63rp4fXmuqpBOoL8HfFIr
	 9+FsXjoJwkDAVL7wnfDKJYl9BSgEGNgY5mvqv+6njMAF4CTh+cqJaCKP6DhOyRakx5
	 oYe6N/jc81hwg==
Date: Wed, 29 Jul 2026 16:31:42 -0700
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
Message-ID: <20260729163142.4f41484f@kernel.org>
In-Reply-To: <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
	<20260728185124.72e421c8@kernel.org>
	<480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
	<20260728193058.7f6b453b@kernel.org>
	<a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 28 Jul 2026 22:51:30 -0400 Chuck Lever wrote:
> >> It=E2=80=99s not about LOC. It=E2=80=99s about not cluttering the norm=
al I/O
> >> path with a lot of exception processing to handle TLS Alert
> >> records. The CMSG API is very difficult to use and leaks the
> >> alert messages into I/O buffers (which for in-kernel consumers
> >> are page cache pages). It=E2=80=99s piss-poor API design. =20
> >
> > I'm not arguing that it's amazing. Doesn't mean we will YOLO
> > a special proto callback for every protocol stacking :/ =20
>=20
> No-one is asking you to roll over. Review means you get to steer
> us in the right direction, and I promise to do the leg work. Terse
> rejection doesn=E2=80=99t move the discussion forward. It stops it cold.

With LLMs tho, the entire human effort is in finding the right design,
rather than the code. So asking maintainers to hand hold everyone thru
their features is unrealistic.

Off the top of my head I think a setsockopt which pre-seeds the content
type so that the read returns an errno if the queued content type is
different could be a simple fix. You'd configure that on your sockets
to DATA and once you see a EWHATEVER you'd assume that some special
record arrived and the socket has to be handed back over to the TLS
control path. This is literally the first thing that comes to mind,
IDK how ugly it will look in reality so no promises.
