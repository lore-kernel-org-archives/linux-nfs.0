Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793098715;
	b=pZfE+PcvthCBlYwI4j0yJ20cBycjwFhzDP/+r5hwxtbAM9fNHYlub/Yb+2ckxPRFjQUw
	 4KR3Wk74ngxDMt8HIgS7KpEam6jEAZdkFEKVDB7KX7TNKdbMCqf5IWNhUnRdArPQNHffc
	 9DTiOBW+/J22Rj27xNf3voiijGJBj708buo4KBvnJKAjfh6bi/HtMXlSpSJaMvfhGZucg
	 y4tR87hzIlHclvueae4LiHLJ1k9Ob52S06JbJF/phd3pH5k/xGamlJ6ykUdeAfOq1MNIK
	 y/cap/3o1tV6TDasgP/WTzOZvWFlKsh+DYsroDom9ctu9vsWswpK6qqC/4Sp35YVlbQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793098715;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=NvyIA+aWyz4S5FPVdXSTLrggEVJP8b3aFjTgPX2tYCc=;
	b=vendOjue6HMTGSGGoWdCR2INyFc4cnU52bt+JaeyuFPBa2ir0JMijtSZAeiiqcr0MQyX
	 tPBrKO5rQvJwB+HpwrOyfVKQ1XgUXSDpusQRrwLM8SBmIKNFdNbXuxcG+TpYit25g5Hnm
	 KgJoZgxajImylL6TYfnhOSxHuxshPPo2qKWH6AxPXTcPrw26qewCWa5Zz1SX8Iz8vMwrh
	 w9nSy8ryQTgMaCW1JigGIpAiv+be4u8pMmkT4rjZ6vgKWyTnS0XFLklxfNb+N701ZWtBc
	 iX6UYtdvHQMUYTtfetEt27GpBT+0y/DxW9iQLt78OtNHkM9jUxAFOUAbJyjm2bpxgnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q96Yy3I7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC8A0606A31A;
	Tue, 27 Oct 2026 10:58:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q96Yy3I7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 733F61F01825;
	Tue, 27 Oct 2026 10:58:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793098714;
	bh=NvyIA+aWyz4S5FPVdXSTLrggEVJP8b3aFjTgPX2tYCc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Q96Yy3I7bW+2W4Oe+RN1HBOY5feEQ/ihLXuXj8lrejsRMde5f3/V97SCWtUgbqXMH
	 uOZGjkB4HuKQamFfEi4elfCLPvBTGLoavMZ7SLyOnZZMQBitK14ErvEelWaCWH2fxO
	 1UXUITOEfwn7sLup1aYTxhp+67ND5UvUV9uXqjAnFgdLJ1WYRIymH9NcoVlkLEbYnz
	 nfQTY9ju8Myjt5sZRXgpOJlrq5UzrHj0YEZ96sLqms3orji7iQKAFgsBrSUw6BHukV
	 HRAoxJglzBzqp0fSgEfPh9/n5s7pkNcZURmOEmAzVRNcTGAkf1T15bhCWewqpln5JH
	 Cr5l3jsqGMzug==
Message-ID: <715d2efa3fd7abe8ce9a42f365bac9f88912b6ad.camel@kernel.org>
Subject: Re: [PATCH] nfsd: pin client reference across async copy reaper
 cleanup
From: Jeff Layton <jlayton@kernel.org>
To: Tristan Madani <tristmd@gmail.com>, Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 linux-nfs@vger.kernel.org, 	linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, 	tristan@talencesecurity.com
Date: Tue, 27 Oct 2026 06:58:30 -0400
In-Reply-To: <20261026230151.2474608-1-tristan@talencesecurity.com>
References: <20261026230151.2474608-1-tristan@talencesecurity.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Mon, 2026-10-26 at 23:01 +0000, Tristan Madani wrote:
> nfsd4_async_copy_reaper() detaches completed async copies from the
> client list and later calls cleanup_async_copy(), which eventually
> drops the stid reference via nfs4_put_stid().  That path accesses
> stid->sc_client unconditionally, but the client is not pinned during
> the cleanup phase.
>=20
> A concurrent expire_client() or force_expire_client() can free the
> client between the nn->client_lock drop and the cleanup loop, leaving
> nfs4_put_stid() with a stale sc_client pointer.
>=20
> This is the same missed pattern that Chuck Lever addressed in seven
> other nfsd4_laundromat() paths with cl_rpc_users pinning (v7.3-rc2).
> The async copy reaper was not covered by that series.
>=20
> Fix this by:
>   1. Skipping expired clients (cl_time =3D=3D 0) during iteration.
>   2. Taking a cl_rpc_users reference before moving the copy to the
>      reaplist.
>   3. Dropping the reference with put_client_no_renew() after
>      cleanup_async_copy().
>=20
> Export put_client_no_renew() so it is accessible from nfs4proc.c.
>=20
> Fixes: ac0514f4d198 ("NFSD: Add a laundromat reaper for async copy state"=
)
> Cc: stable@vger.kernel.org
> Signed-off-by: Tristan Madani <tristan@talencesecurity.com>
> ---
>  fs/nfsd/nfs4proc.c  | 5 +++++
>  fs/nfsd/nfs4state.c | 2 +-
>  fs/nfsd/state.h     | 1 +
>  3 files changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 50c07561e31f3..1f36afceb1fe1 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1501,6 +1501,9 @@ void nfsd4_async_copy_reaper(struct nfsd_net *nn)
>  			if (test_bit(NFSD4_COPY_F_OFFLOAD_DONE,
>  				     &copy->cp_copy.cp_flags)) {
>  				if (!--copy->cp_ttl) {
> +					if (clp->cl_time =3D=3D 0)
> +						continue;
> +					atomic_inc(&clp->cl_rpc_users);
>  					list_del_init(&copy->copies);
>  					list_add(&copy->copies, &reaplist);
>  				}
> @@ -1513,8 +1516,10 @@ void nfsd4_async_copy_reaper(struct nfsd_net *nn)
>  	while (!list_empty(&reaplist)) {
>  		copy =3D list_first_entry(&reaplist, struct nfsd4_async_copy,
>  					copies);
> +		clp =3D copy->cp_stid.sc_client;
>  		list_del_init(&copy->copies);
>  		cleanup_async_copy(copy);
> +		put_client_no_renew(clp);
>  	}
>  }
> =20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9c4adf3110aea..10e864ca7407a 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -252,7 +252,7 @@ static void put_client_no_renew_locked(struct nfs4_cl=
ient *clp)
>  		__put_client_locked(clp, false);
>  }
> =20
> -static void put_client_no_renew(struct nfs4_client *clp)
> +void put_client_no_renew(struct nfs4_client *clp)
>  {
>  	struct nfsd_net *nn =3D net_generic(clp->net, nfsd_net_id);
> =20
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 2d00a411c6634..1d3a7e35bb9ff 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -918,6 +918,7 @@ extern void nfsd4_shutdown_callback(struct nfs4_clien=
t *);
>  extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
>  void nfsd4_put_client(struct nfs4_client *clp);
>  void nfsd4_async_copy_reaper(struct nfsd_net *nn);
> +void put_client_no_renew(struct nfs4_client *clp);
>  bool nfsd4_has_active_async_copies(struct nfs4_client *clp);
>  void nfsd_update_cmtime_attr(struct file *f, unsigned int flags);
>  extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(struct xdr_net=
obj name,

Reviewed-by: Jeff Layton <jlayton@kernel.org>
