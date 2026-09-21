Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 276734A260E;
	Mon, 21 Sep 2026 13:46:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789998370; cv=none; b=drM8yk/mBoWGSLuN/eWRA3A9fqEWritT6VQVWuxs6ZcSL8XTcHoHDCxm7rlc2S95K4vMypmxd3KjXDxSgWdeksWbKky53wLHH/AjH0bb78E4nrGBU+1Y1it6CeqNjWwgt3mODn0m2NKq6ov229XZnqQS6bRdnivkGfWERRtlt1Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789998370; c=relaxed/simple;
	bh=y/aXfGyHuUvIJFQnIbLmsfviT91sj/iyYYR8um8uuw4=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=PsR1M9XG0KSNd4edFBklQiwv/OZwxJxY9k0+eYwM34ILuZwrh+aAK3SSVa4iBEzc1csvYpntzN/iinEJlfmM6sAtmAnLzCCUWIb1oO5/z9MCDuY7DIwCHlJ+kcenPj1nP444+giE0BLxO70LlzQwQz3XJv3YWu8U2mFbtkEPQ2M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F7P/2e17; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F7P/2e17"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6EA741F000FF;
	Mon, 21 Sep 2026 13:46:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789998368;
	bh=eZAHnRnQC+OsupV1rST31zrb4zF5a1Jmk+ZWxkErKLM=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=F7P/2e17GBgxg1KHVUQ6yfEu2It3FRz38BAu0Eu/89Mr+wVwxTTdvZP8xRWrrlOFq
	 pCcKmzPV8V3/H70sRMAu8SuGK9Y0vfiT5eIGAuITtidoGY4rKZos80kIKDs5Kb87tn
	 v6BiuK3W9/O1voH8cllMKracdPQxl9pOPoJcLGWLC8BA+eiIcyL+/UuV/cvv1OhOye
	 J9Dd/ddQB9wjJ2KTNFahCkCmJfJfbxXqTzsaWp3ZJccvmJBMmgmSG5InnLoEnXLGjS
	 2gLa+vM82YlmuXGeVI1Ol3bFYCeXHzbana/lnaP/Rip7AclEUitLLaG/hsMJpj7bpT
	 B+zpTnCqOqjgg==
Message-ID: <ddab3a7be440dcd860b254bcd2dc213c1a3cc538.camel@kernel.org>
Subject: Re: [PATCH] SUNRPC: use assign_bit() where applicable
From: Jeff Layton <jlayton@kernel.org>
To: Peng Fan <peng.fan@oss.nxp.com>, Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
 <trondmy@kernel.org>,  Anna Schumaker	 <anna@kernel.org>, "David S. Miller"
 <davem@davemloft.net>, Eric Dumazet	 <edumazet@google.com>, Jakub Kicinski
 <kuba@kernel.org>, Paolo Abeni	 <pabeni@redhat.com>, Simon Horman
 <horms@kernel.org>, 	linux-kernel@vger.kernel.org, Peng Fan
 <peng.fan@nxp.com>, 	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Date: Mon, 21 Sep 2026 09:46:05 -0400
In-Reply-To: <arB/ixTLqjuyrSUr@shlinux89>
References: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
	 <7c7d7b6a-38a9-477e-9bcd-1f9c53a160c5@app.fastmail.com>
	 <arB/ixTLqjuyrSUr@shlinux89>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-09-21 at 08:51 +0800, Peng Fan wrote:
> On Sun, Sep 20, 2026 at 01:22:00PM -0400, Chuck Lever wrote:
> >=20
> >=20
> > On Sat, Sep 19, 2026, at 10:27 PM, Peng Fan (OSS) wrote:
> > > From: Peng Fan <peng.fan@nxp.com>
> > >=20
> > > Convert open-coded if/else with set_bit/clear_bit the assign_bit API.
> >=20
> > The above sentence explains the same thing that the diff body shows me,
> > so it does not add value.
> >=20
> > But I don't have any context here: why is this being done? Is there som=
e
> > kind of tree-wide clean-up underway so that a new feature can be added,
> > or is this patch just a one-off change?
>=20
> It is just a one-off change. I don't group other patches to use assign_bi=
t()
> into a large patchset, just separate patches.
>=20
> Free to drop if it does not make sense to you.
>=20
>=20

I think the problem is that you haven't explained the benefit of using
assign_bit() here. It's now 2 lines instead of 4, but that doesn't seem
like a substantive change. Does this create better assembly or
something?=20

Without a clear benefit, this seems like pointless churn.

> > Including a URL that points to an explainer, or making this patch part
> > of a series would help orient reviewers.
> >=20
> >=20
> > > Done with Coccinelle semantic patch:
> > >     // set_bit -> clear_bit =3D> assign_bit
> > >=20
> > >     @@
> > >     expression cond, bit, addr;
> > >     @@
> > >=20
> > >     -if (cond)
> > >     -        set_bit(bit, addr);
> > >     -else
> > >     -        clear_bit(bit, addr);
> > >     +assign_bit(bit, addr, cond);
> > >=20
> > >     @@
> > >     expression cond, bit, addr;
> > >     @@
> > >=20
> > >     -if (cond)
> > >     -        clear_bit(bit, addr);
> > >     -else
> > >     -        set_bit(bit, addr);
> > >     +assign_bit(bit, addr, !cond);
> > >=20
> > > Signed-off-by: Peng Fan <peng.fan@nxp.com>
> > > ---
> > >  net/sunrpc/svcsock.c | 18 ++++++------------
> > >  1 file changed, 6 insertions(+), 12 deletions(-)
> > >=20
> > > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > > index ef7ac080fcd3..d7fa0d1de3ef 100644
> > > --- a/net/sunrpc/svcsock.c
> > > +++ b/net/sunrpc/svcsock.c
> > > @@ -352,10 +352,8 @@ static void svc_sock_setbufsize(struct svc_sock=
=20
> > > *svsk, unsigned int nreqs)
> > >=20
> > >  static void svc_sock_secure_port(struct svc_rqst *rqstp)
> > >  {
> > > -	if (svc_port_is_privileged(svc_addr(rqstp)))
> > > -		set_bit(RQ_SECURE, &rqstp->rq_flags);
> > > -	else
> > > -		clear_bit(RQ_SECURE, &rqstp->rq_flags);
> > > +	assign_bit(RQ_SECURE, &rqstp->rq_flags,
> > > +		   svc_port_is_privileged(svc_addr(rqstp)));
> > >  }
> > >=20
> > >  /*
> > > @@ -941,10 +939,8 @@ static struct svc_xprt *svc_tcp_accept(struct=
=20
> > > svc_xprt *xprt)
> > >  		slen =3D offsetof(struct sockaddr, sa_data);
> > >  	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
> > >=20
> > > -	if (sock_is_loopback(newsock->sk))
> > > -		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> > > -	else
> > > -		clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> > > +	assign_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags,
> > > +		   sock_is_loopback(newsock->sk));
> > >  	if (serv->sv_stats)
> > >  		serv->sv_stats->nettcpconn++;
> > >=20
> > > @@ -1290,10 +1286,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *r=
qstp)
> > >=20
> > >  	rqstp->rq_xprt_ctxt   =3D NULL;
> > >  	rqstp->rq_prot	      =3D IPPROTO_TCP;
> > > -	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
> > > -		set_bit(RQ_LOCAL, &rqstp->rq_flags);
> > > -	else
> > > -		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
> > > +	assign_bit(RQ_LOCAL, &rqstp->rq_flags,
> > > +		   test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags));
> > >=20
> > >  	/* Completing one message stops ->read_sock with whatever
> > >  	 * follows still queued, and no path from here re-arms XPT_DATA.
> > > --=20
> > > 2.51.0
> >=20
> > --=20
> > Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
> >=20
> >=20

--=20
Jeff Layton <jlayton@kernel.org>
