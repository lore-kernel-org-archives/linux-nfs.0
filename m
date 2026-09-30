Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1B7D282F2A;
	Wed, 30 Sep 2026 01:59:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790733594; cv=none; b=ZkvpXrQeofqXryqhWibGLPcsO7ZLWG1pHsOLPoFQEDgBeJzLIhrFIwdWXOmJ9vTSnKPubP9QPCuG7gwhxGepJM4TpTyC3Tt1r2pRd61tfS5eMf2ZDnJ6H8Z/w2AR1qAW2rJv7yi9ogWARYxr9DsEaynuwMpeic0kP6PKAsVJFW8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790733594; c=relaxed/simple;
	bh=1XZfKocU/lN5GfPuRrDk1+Frer+DxmS5rdeBz68W3/4=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=M8iRlLN4SbH19AbPui6B/x7sCHntBq1/a1v6Ue8lFquWiEN4T0faOO2zjy60TpQB+avn1bnG63o3ZpUz4DnuCPq4qZWHgVa1t/39gapGq1sSlaGvC5Wc6Gwlq2qJXHmz8MHVnd1JAiYMlVN+4AgI/CbBjixYynOMz3sCizcF5G4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=O1welR2X; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="O1welR2X"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 530171F000FF;
	Wed, 30 Sep 2026 01:59:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790733593;
	bh=DX9g4ivFVPNTKG/kBEx/zUz96+yiO19hM2X9UAqzp0o=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=O1welR2XYxDBYcQMymrp8H6LU8yzVjVEsXTqj+hE3Y6d384E20FR9whrky/Hlyvq8
	 PJBgrnmt0uwt8QYwPmssrtdWFnj9TlvpkUOcLju5O3FJ9+ZO1qq4A3RQp9kbPSJ3JI
	 AQvB1zRp2pyQRux8QZ6NS1/NHs7TRz8Ec101/R5TwolVHbJdIOa6AehLEpMX9RzcYp
	 0/12MShIxqBagJhTZ5n1HD9WpixNqk7ruvokk+tWP/ZJLFstOnlRPsEKrX2BtUpdlO
	 JsTn+twh2/J6S5QCngwhB61nx+6Ifhk+jqBTPr//Obogdmns5GmWCsQY5R9XKfbPgj
	 PklpO8bvU1b8g==
Message-ID: <3453cad85b6ec1d3b36398ba7565d053163a5929.camel@kernel.org>
Subject: Re: [PATCH v3 net-next 4/9] rds: use sk_set_nospace()
From: Allison Henderson <achender@kernel.org>
To: Eric Dumazet <edumazet@kernel.org>, "David S . Miller"
 <davem@davemloft.net>,  Jakub Kicinski <kuba@kernel.org>, Paolo Abeni
 <pabeni@redhat.com>
Cc: Simon Horman <horms@kernel.org>, Neal Cardwell <ncardwell@google.com>, 
 Kuniyuki Iwashima <kuniyu@google.com>, edumazet@google.com,
 netdev@vger.kernel.org, Alexander Aring <aahringo@redhat.com>, David
 Teigland <teigland@redhat.com>,  gfs2@lists.linux.dev, John Fastabend
 <john.fastabend@gmail.com>, Jakub Sitnicki <jakub@cloudflare.com>, Sabrina
 Dubroca <sd@queasysnail.net>, Jiayuan Chen <jiayuan.chen@linux.dev>,
 Matthieu Baerts <matttbe@kernel.org>, Mat Martineau <martineau@kernel.org>,
 Geliang Tang <geliang@kernel.org>,  mptcp@lists.linux.dev, Wen Gu
 <guwen@linux.alibaba.com>, Dust Li <dust.li@linux.alibaba.com>, "D. Wythe"
 <alibuda@linux.alibaba.com>, Chuck Lever <cel@kernel.org>, Jeff Layton
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga Kornievskaia
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
 <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
 <anna@kernel.org>, linux-nfs@vger.kernel.org,  rds-devel@oss.oracle.com,
 Philipp Reisner <philipp.reisner@linbit.com>, Lars Ellenberg
 <lars.ellenberg@linbit.com>, Christoph =?ISO-8859-1?Q?B=F6hmwalder?=
 <christoph.boehmwalder@linbit.com>, Jens Axboe <axboe@kernel.dk>, 
 drbd-dev@lists.linux.dev, Keith Busch <kbusch@kernel.org>, Christoph
 Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni
 <kch@nvidia.com>, linux-nvme@lists.infradead.org, Ilya Dryomov
 <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, Viacheslav
 Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org
Date: Tue, 29 Sep 2026 18:59:50 -0700
In-Reply-To: <20260929071743.23624-5-edumazet@kernel.org>
References: <20260929071743.23624-1-edumazet@kernel.org>
	 <20260929071743.23624-5-edumazet@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.52.3-0ubuntu1.1 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Tue, 2026-09-29 at 07:17 +0000, Eric Dumazet wrote:
> Use the new helpers instead of open coding the SOCK_NOSPACE
> manipulation, so that TCP can later maintain a cheaper private
> copy of this bit.
>=20
> No functional change intended.
>=20
> Reviewed-by: Kuniyuki Iwashima <kuniyu@google.com>
> Signed-off-by: Eric Dumazet <edumazet@kernel.org>

Thank you!
Acked-by: Allison Henderson <achender@kernel.org>

> ---
>  net/rds/tcp_send.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
> index 7c52acc749cf4d4003c749a2646c2b4f87f207fe..824222c475119d91e333123c5=
afc9291005a8696 100644
> --- a/net/rds/tcp_send.c
> +++ b/net/rds/tcp_send.c
> @@ -100,7 +100,7 @@ int rds_tcp_xmit(struct rds_connection *conn, struct =
rds_message *rm,
> =20
>  	if (hdr_off < sizeof(struct rds_header)) {
>  		/* see rds_tcp_write_space() */
> -		set_bit(SOCK_NOSPACE, &tc->t_sock->sk->sk_socket->flags);
> +		sk_set_nospace(tc->t_sock->sk);
> =20
>  		ret =3D rds_tcp_sendmsg(tc->t_sock,
>  				      (void *)&rm->m_inc.i_hdr + hdr_off,
> @@ -221,6 +221,5 @@ void rds_tcp_write_space(struct sock *sk)
>  	 */
>  	write_space(sk);
> =20
> -	if (sk->sk_socket)
> -		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
> +	sk_set_nospace(sk);
>  }

