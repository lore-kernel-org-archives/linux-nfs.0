Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E52233F54B6;
	Thu, 16 Jul 2026 13:53:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784210012; cv=none; b=sFKqpEHT2eqiU4n3wIpiI9GXAX/AbyMn5GqqySzumQ3+E8uOtu37lcV1VOaohz8KKeWx/XGt7dNuhHosMAbYa9xJdBtu1HGl3qX+op2OoOq23OiBt/R35AxjlhGZ5dPbqfH3zaBAFM8hmYBBQ6LWpTc33gtJsD5pUe05WCKPOvw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784210012; c=relaxed/simple;
	bh=o2FMYpRHS+zhsw2qdQBfeWS5YsMyIw7aMRtPcXZRFCA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=G8QsFYgmmlNRSRKzAjdgyiiVeWmXaQ4XLvkso5Eomabc8AdXTlOQDKN3SAj8gN6a0CeN+sukYfewzEiuxZOv7TGjlY4HS38kxWG/9ofFr7l+cLBgximBt6pA7U21pB8eHn5nJX6jBZnLQdiEncfAmcIaB1LglBIt75fwcnLKwQY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BTTAgX1w; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BTTAgX1w"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F41F91F00A3A;
	Thu, 16 Jul 2026 13:53:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784210010;
	bh=eEtiy5RcvunMEYeq/F+MrWWi428oKufCgwRjxTU2YSA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=BTTAgX1wPqLgVJJm5aBSv/z1nAgbGfYrKOAhshHz790K8xr2F5LTEfNv5ceohjAfv
	 QfQq2T7354fXt93IQemu2UiMdVIvUF8QYeJToD+iSxGmykNftt5q98Xp+yyyMmJuR9
	 64uccJ2ACZfqd+cfuoJlGNpYnF+6D7yZ1KIVUUkY5OYlDs0eBaD/a9q/vBgSQ23PjY
	 +SWPaT3My3tt9GQlVYiNZLFwOpgssaYTLjxbXnyLlGy/YWIGIjV/KGKkS45ct4YwEz
	 +kEQZKpe2MAQOOPrmwbo6zpv9aK15Lf4N12VEfILN1wfVNpgacMYyXvyFkCZoWiJrn
	 6yXyLkBBw+Q5A==
Message-ID: <4ef6dd5a13bfb51f72452aa30f59c89a54037404.camel@kernel.org>
Subject: Re: [PATCH v6 3/6] nfsd: implement server-stats-get netlink handler
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Date: Thu, 16 Jul 2026 09:53:28 -0400
In-Reply-To: <8173debc-96fb-4354-ba11-dff99b772523@app.fastmail.com>
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
	 <20260619-exportd-netlink-v6-3-ddef3499793c@kernel.org>
	 <8173debc-96fb-4354-ba11-dff99b772523@app.fastmail.com>
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

On Fri, 2026-06-19 at 16:40 -0400, Chuck Lever wrote:
>=20
> On Fri, Jun 19, 2026, at 11:26 AM, Jeff Layton wrote:
> > Implement nfsd_nl_server_stats_get_dumpit() which exposes the
> > NFS server statistics currently available via /proc/net/rpc/nfsd
> > through the nfsd generic netlink family.
>=20
> A couple of questions on the dump design and one on the commit message,
> then some smaller items.
>=20
> The commit message says:
>=20
> >   - First message: all scalar stats (reply cache, filehandle,
> >     IO, network, RPC) plus per-version procedure counts
> >     (proc2/3/4-ops) using per-netns vs_count arrays.
> >=20
> >   - Subsequent messages: NFSv4 per-operation counts
> >     (proc4ops-ops), one entry per message, using cb->args[0]
> >     to track the current operation index across dump calls.
>=20
> The code does not stream across subsequent messages.  The proc4ops-ops
> nests are emitted in the first message, inside the same "if (start =3D=3D=
 0)"
> block as the scalars, and cb->args[0] only ever holds 0 or -1, never an
> operation index.  The function's own kerneldoc agrees: "The entire
> server-stats object is emitted in a single netlink message on the first
> invocation."
>=20
> Should the commit message be reworded to match the code, or should the co=
de
> move to the streaming design the message describes?  That second option t=
ies
> into the next question.
>=20
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 601301e34fc7..f0514d8149cd 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -2329,6 +2329,185 @@ int nfsd_nl_cache_flush_doit(struct sk_buff *sk=
b, struct genl_info *info)
> >  	return 0;
> >  }
> >=20
> > +static int nfsd_nl_fill_proc_ops(struct sk_buff *skb, int attr,
> > +				 unsigned long __percpu *counts,
> > +				 unsigned int nproc)
> > +{
> > +	struct nlattr *nest;
> > +	unsigned int j;
> > +	int k;
> > +
> > +	for (j =3D 0; j < nproc; j++) {
> > +		unsigned long count =3D 0;
> > +
> > +		for_each_possible_cpu(k)
> > +			count +=3D per_cpu(counts[j], k);
> > +
> > +		nest =3D nla_nest_start(skb, attr);
> > +		if (!nest)
> > +			return -EMSGSIZE;
> > +		if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, j) ||
> > +		    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
> > +				      count, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
> > +			nla_nest_cancel(skb, nest);
> > +			return -EMSGSIZE;
> > +		}
> > +		nla_nest_end(skb, nest);
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +/**
> > + * nfsd_nl_server_stats_get_dumpit - dump NFS server statistics
> > + * @skb: reply buffer
> > + * @cb: netlink metadata and command arguments
> > + *
> > + * The entire server-stats object is emitted in a single netlink messa=
ge on
> > + * the first invocation. cb->args[0] is set to -1 afterwards so that t=
he next
> > + * invocation terminates the dump.
> > + *
> > + * Returns the size of the reply or a negative errno.
> > + */
> > +int nfsd_nl_server_stats_get_dumpit(struct sk_buff *skb,
> > +				    struct netlink_callback *cb)
> > +{
> > +	struct net *net =3D sock_net(skb->sk);
> > +	struct nfsd_net *nn =3D net_generic(net, nfsd_net_id);
> > +	struct svc_stat *statp =3D &nn->nfsd_svcstats;
> > +	struct svc_program *prog =3D statp->program;
> > +	int start =3D cb->args[0];
> > +	void *hdr;
> > +
> > +	/*
> > +	 * cb->args[0] =3D=3D 0: first call, emit the full server-stats objec=
t
> > +	 * cb->args[0] < 0: dump already complete
> > +	 */
> > +	if (start < 0)
> > +		return 0;
> > +
> > +	if (start =3D=3D 0) {
> > +		hdr =3D genlmsg_put(skb, NETLINK_CB(cb->skb).portid,
> > +				  cb->nlh->nlmsg_seq, &nfsd_nl_family,
> > +				  NLM_F_MULTI, NFSD_CMD_SERVER_STATS_GET);
> > +		if (!hdr)
> > +			return -ENOBUFS;
> > +
>=20
> This handler assembles the entire server-stats object -- all scalars, the
> proc2/3/4-ops nests, and one proc4ops-ops nest per NFSv4 operation -- in =
one
> message under "if (start =3D=3D 0)", then sets cb->args[0] =3D -1 so the =
next call
> ends the dump.
>=20
> Does that hold up once the assembled message no longer fits the dump buff=
er?
> A dump skb is allocated at max(cb->min_dump_alloc, NLMSG_GOODSIZE), and t=
his
> handler sets neither cb->min_dump_alloc nor a .start callback, so the flo=
or
> is NLMSG_GOODSIZE, which is SKB_WITH_OVERHEAD(PAGE_SIZE), roughly 3.7k on=
 a
> 4k-page host.  A larger skb is allocated only when userspace has previous=
ly
> grown its receive buffer.
>=20
> With LAST_NFS4_OP at 75, the proc4ops-ops loop alone emits 76 nests of ab=
out
> 28 bytes each (~2.1k); the proc2 and proc3 nests plus the scalar block br=
ing
> the total to roughly 3.5k -- already within a few hundred bytes of the fl=
oor,
> and growing by one nest for every NFSv4 operation added later.
>=20
> [ ... scalar puts for reply cache, fh, io, net, rpc snipped ... ]
>=20
> > +		/* Per-version procedure counts */
> > +		if (statp->vs_count) {
> > +			static const int proc_attrs[] =3D {
> > +				[2] =3D NFSD_A_SERVER_STATS_PROC2_OPS,
> > +				[3] =3D NFSD_A_SERVER_STATS_PROC3_OPS,
> > +				[4] =3D NFSD_A_SERVER_STATS_PROC4_OPS,
> > +			};
> > +			unsigned int i;
> > +
> > +			for (i =3D 0; i < prog->pg_nvers &&
> > +			     i < ARRAY_SIZE(proc_attrs); i++) {
> > +				if (!prog->pg_vers[i] ||
> > +				    !statp->vs_count[i])
> > +					continue;
> > +				if (!proc_attrs[i])
> > +					continue;
> > +				if (nfsd_nl_fill_proc_ops(skb,
> > +						proc_attrs[i],
> > +						statp->vs_count[i],
> > +						prog->pg_vers[i]->vs_nproc))
> > +					goto err_cancel;
> > +			}
> > +		}
> > +
> > +#ifdef CONFIG_NFSD_V4
> > +		/* NFSv4 individual operation counts */
> > +		for (int i =3D 0; i <=3D LAST_NFS4_OP; i++) {
> > +			struct nlattr *nest;
> > +			u64 cnt;
> > +
> > +			cnt =3D percpu_counter_sum_positive(
> > +				&nn->counter[NFSD_STATS_NFS4_OP(i)]);
> > +
> > +			nest =3D nla_nest_start(skb,
> > +					NFSD_A_SERVER_STATS_PROC4OPS_OPS);
> > +			if (!nest)
> > +				goto err_cancel;
> > +			if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, i) ||
> > +			    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
> > +					      cnt, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
> > +				nla_nest_cancel(skb, nest);
> > +				goto err_cancel;
> > +			}
> > +			nla_nest_end(skb, nest);
> > +		}
> > +#endif
>=20
> This loop open-codes the same nest that nfsd_nl_fill_proc_ops() builds ju=
st
> above -- nla_nest_start(), nla_put_u32(PROC_ENTRY_OP),
> nla_put_u64_64bit(PROC_ENTRY_COUNT), nla_nest_end() -- into the same
> NFSD_A_SERVER_STATS_PROC4OPS_OPS attribute.  Could the helper be generali=
zed
> to take the per-op counter source so this is not a second copy of the sam=
e
> code?
>=20
> The per-version block above skips empty versions:
>=20
> 	if (!prog->pg_vers[i] || !statp->vs_count[i])
> 		continue;
>=20
> but this loop emits an entry for every op 0..LAST_NFS4_OP, zero-count ops
> included.  Is that difference intentional?  Skipping zero counts here wou=
ld
> also trim the worst-case message size above.
>=20
> There is also a counter that this dump does not emit.  /proc/net/rpc/nfsd
> prints a wdeleg_getattr line after proc4ops:
>=20
> 	seq_printf(seq, "\nwdeleg_getattr %lld",
> 		percpu_counter_sum_positive(&nn->counter[NFSD_STATS_WDELEG_GETATTR]));
>=20
> incremented by nfsd_stats_wdeleg_getattr_inc().  Since the goal is to exp=
ose
> the statistics currently available via /proc/net/rpc/nfsd, should
> wdeleg_getattr get an attribute here too, so nfsstat over netlink does no=
t
> drop it relative to the procfs path?
>=20

The only thing in this review that is not addressed in my current
series is the above comment, and I think we had agreed in an earlier
email thread that this was approximately the same value as the counter
for CB_GETATTR calls and so it's good enough for this purpose.

Are you still ok with this approach?
--=20
Jeff Layton <jlayton@kernel.org>
