Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 384C5422E10;
	Thu, 16 Jul 2026 14:12:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784211143; cv=none; b=QnAab022BtUFDFzLW1uw9r5K4P0gZcFzxQZyoJUrCRUaZDkUBFJVqtv9ZgSuQsjTmf4T1nB8PTo/rlZVQv/gSszczTdNEBpOLvTdBwoFYbEl5jXoMCtOHkQOCldlwPv7v7U0y/DeYex1L14CuJuWGgRmv8kX0oL2FN9hR4MLQWU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784211143; c=relaxed/simple;
	bh=YBaZsI3PWoDujTVhybi8CPZz1so2cH5goM9p5ta7yi0=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=p6uxM8CqvLddGuQ/owiXu+fLHsQH/scLFREE2xxk4YaQgW1Mhsi6tYjaLTtVnZa8tavuvXPtUjRWBP+NMwln+zdqRmVm4yZ6FguwJT8PBEOfhvibAa4bbWGgINzqsCRvy0phxF9dQp1K+V46Vpjr0crBbUmvRFUD9XHNMy1Fo8w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mpfanqJQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mpfanqJQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3D3001F00A3A;
	Thu, 16 Jul 2026 14:12:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784211142;
	bh=uU9MQuZ+6w1iE0Cg/xZqO8/kbF1zn5ZF3lZRzzUgE2I=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=mpfanqJQ5VKZvgt8/F4GAwQjOzZ7SUPfunAeEii0fkDDFOWFmRTSPFLmEBjR9j4tJ
	 wCBUqi7GWkMVMVcY4IcJtkOUrYAqGM9yBaVzJcyX7HvzCwrSvCTrdwvTp9EAi+RUwY
	 Rpgy8BwqJMiaJwCjDKWMaoG/dG58gF4qhf2GCTEAb/J2KwMsz9tVXBDBpdS1PRXv9s
	 b+3dVwgau7ZAwLal8X3FA4AFmgIlBJfjPgSLXXNf841g0ABuSgzOnOVPhz2IGTTJ3Z
	 PymZCiZjlMfOGy7qWZfUf8+BBomZwqQvg1rM1g65GBE9CjVyguaD3yHNsCp19alU9k
	 PW30BjjYAkzPg==
Message-ID: <8608717db0afb2baee5536caa9cdcc5d4ac85623.camel@kernel.org>
Subject: Re: [PATCH v6 3/6] nfsd: implement server-stats-get netlink handler
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Date: Thu, 16 Jul 2026 10:12:19 -0400
In-Reply-To: <dace51f2-0d20-443b-841a-f8452fdb85e3@app.fastmail.com>
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
	 <20260619-exportd-netlink-v6-3-ddef3499793c@kernel.org>
	 <8173debc-96fb-4354-ba11-dff99b772523@app.fastmail.com>
	 <4ef6dd5a13bfb51f72452aa30f59c89a54037404.camel@kernel.org>
	 <dace51f2-0d20-443b-841a-f8452fdb85e3@app.fastmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-07-16 at 10:04 -0400, Chuck Lever wrote:
>=20
> On Thu, Jul 16, 2026, at 9:53 AM, Jeff Layton wrote:
> > On Fri, 2026-06-19 at 16:40 -0400, Chuck Lever wrote:
> > >=20
> > > On Fri, Jun 19, 2026, at 11:26 AM, Jeff Layton wrote:
>=20
> > > > +		/* Per-version procedure counts */
> > > > +		if (statp->vs_count) {
> > > > +			static const int proc_attrs[] =3D {
> > > > +				[2] =3D NFSD_A_SERVER_STATS_PROC2_OPS,
> > > > +				[3] =3D NFSD_A_SERVER_STATS_PROC3_OPS,
> > > > +				[4] =3D NFSD_A_SERVER_STATS_PROC4_OPS,
> > > > +			};
> > > > +			unsigned int i;
> > > > +
> > > > +			for (i =3D 0; i < prog->pg_nvers &&
> > > > +			     i < ARRAY_SIZE(proc_attrs); i++) {
> > > > +				if (!prog->pg_vers[i] ||
> > > > +				    !statp->vs_count[i])
> > > > +					continue;
> > > > +				if (!proc_attrs[i])
> > > > +					continue;
> > > > +				if (nfsd_nl_fill_proc_ops(skb,
> > > > +						proc_attrs[i],
> > > > +						statp->vs_count[i],
> > > > +						prog->pg_vers[i]->vs_nproc))
> > > > +					goto err_cancel;
> > > > +			}
> > > > +		}
> > > > +
> > > > +#ifdef CONFIG_NFSD_V4
> > > > +		/* NFSv4 individual operation counts */
> > > > +		for (int i =3D 0; i <=3D LAST_NFS4_OP; i++) {
> > > > +			struct nlattr *nest;
> > > > +			u64 cnt;
> > > > +
> > > > +			cnt =3D percpu_counter_sum_positive(
> > > > +				&nn->counter[NFSD_STATS_NFS4_OP(i)]);
> > > > +
> > > > +			nest =3D nla_nest_start(skb,
> > > > +					NFSD_A_SERVER_STATS_PROC4OPS_OPS);
> > > > +			if (!nest)
> > > > +				goto err_cancel;
> > > > +			if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, i) ||
> > > > +			    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
> > > > +					      cnt, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
> > > > +				nla_nest_cancel(skb, nest);
> > > > +				goto err_cancel;
> > > > +			}
> > > > +			nla_nest_end(skb, nest);
> > > > +		}
> > > > +#endif
> > >=20
> > > This loop open-codes the same nest that nfsd_nl_fill_proc_ops() build=
s just
> > > above -- nla_nest_start(), nla_put_u32(PROC_ENTRY_OP),
> > > nla_put_u64_64bit(PROC_ENTRY_COUNT), nla_nest_end() -- into the same
> > > NFSD_A_SERVER_STATS_PROC4OPS_OPS attribute.  Could the helper be gene=
ralized
> > > to take the per-op counter source so this is not a second copy of the=
 same
> > > code?
> > >=20
> > > The per-version block above skips empty versions:
> > >=20
> > > 	if (!prog->pg_vers[i] || !statp->vs_count[i])
> > > 		continue;
> > >=20
> > > but this loop emits an entry for every op 0..LAST_NFS4_OP, zero-count=
 ops
> > > included.  Is that difference intentional?  Skipping zero counts here=
 would
> > > also trim the worst-case message size above.
> > >=20
> > > There is also a counter that this dump does not emit.  /proc/net/rpc/=
nfsd
> > > prints a wdeleg_getattr line after proc4ops:
> > >=20
> > > 	seq_printf(seq, "\nwdeleg_getattr %lld",
> > > 		percpu_counter_sum_positive(&nn->counter[NFSD_STATS_WDELEG_GETATTR]=
));
> > >=20
> > > incremented by nfsd_stats_wdeleg_getattr_inc().  Since the goal is to=
 expose
> > > the statistics currently available via /proc/net/rpc/nfsd, should
> > > wdeleg_getattr get an attribute here too, so nfsstat over netlink doe=
s not
> > > drop it relative to the procfs path?
> > >=20
> >=20
> > The only thing in this review that is not addressed in my current
> > series is the above comment, and I think we had agreed in an earlier
> > email thread that this was approximately the same value as the counter
> > for CB_GETATTR calls and so it's good enough for this purpose.
> >=20
> > Are you still ok with this approach?
>=20
> In spite of the email quoting, I=E2=80=99ve still forgotten most of the c=
ontext
> of that conversation.
>=20
> Looking at this now, I think someone later could get an urge to add the
> wdeleg_getattr statistic to netlink=E2=80=A6 for symmetry, because it sme=
lls like
> technical debt, or it might actually be useful for something.
>=20
> IMHO we should include it now.
>=20

IDGI: what's the point of collecting that stat separately when we have
stats for CB_GETATTR already? I'd prefer to avoid perpetuating
wdeleg_getattr as a stat here, since it's not directly tied to the
protocol in the same way as the others are.

The only difference between the two is that if another client does a
GETATTR for the fh while there is already a CB_GETATTR in flight,
wdeleg_getattr gets bumped today, whereas CB_GETATTR counter does not
(since there is only a single CB_GETATTR for that).

Is that difference relevant? I think Dai added wdeleg_getattr
originally, so I'd really like to hear his opinion on this.
--=20
Jeff Layton <jlayton@kernel.org>
