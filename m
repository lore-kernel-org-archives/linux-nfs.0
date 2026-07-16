Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 980DA423EB8;
	Thu, 16 Jul 2026 14:17:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784211433; cv=none; b=XxoMr1cX7BVttBQca1noobfgZNHEJs6TL65mW4aSQvMW3cJj5tTRd4e8L63LtxMnM7A76jxluvWFOubTfns53r/vnEKDn7Vjr2dvRh+j/LHPWRrh1g3lz/jCBet0MDqwZnHFaQRwez2poM8JxLq4hpgswk7TXO2K0E2lJAu7rPw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784211433; c=relaxed/simple;
	bh=9jFntqkhEkUEcYANNUCjh0tiban9bluUK09z5NYxHQ8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=s0MoE7KyLKw/MkjkfYZqvp6HOYHOLxncpiXZM5XyO+nfXUnNOHRIIDY2HNB5p2diiEuprtHXRJQOf4FZojKikQoUMZ4G4mCCFs6juibYtYoNvlbZ8ec0HREwIL+RgHwI76TojR82q2JxyQ0o6U5Cdgu+VnrFeR4NWkxHL0eJDg0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ADYI3dHo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ADYI3dHo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA51E1F00A3A;
	Thu, 16 Jul 2026 14:17:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784211432;
	bh=5F6ZLjZDEiYYe8qFcRuy9ctBaeoK93FewiNLMA5oy2M=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ADYI3dHohpdMkvO9gow572sLvZf7GXY58rpiHPtonFxi6Dd+2Q81gP+TumXtj0B0z
	 N9Qf22jGwMp5pERRDn7jxANgfEwXwPJ6EF8fXYHwh7xQCmGmFgrkiCdWYX7u8QZcYk
	 owNQ5gZWJMMPsZWlcHKhUBKdwuHvGoQwO1J9RDZObxW9VENnydskyUgRb1BEk57PKH
	 XDjNVtxDjxqI2DWFU5B5mfBmrnxsa0IS3eFeaXZYgLK66ZFE6cX6qCw5pDE5mb23hS
	 lwD5XNLMUjT+Z/56fkHXx1NnDtJAl5hmLePei3pG6z0YpCRQOpA9Igvh5zXKRjv4Cb
	 pJQ0zAkOcyHfg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id F0C7BF40068;
	Thu, 16 Jul 2026 10:17:10 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 16 Jul 2026 10:17:10 -0400
X-ME-Sender: <xms:5udYauEeSZ9MMVCEs2O3EWJQcqSfcbgpctK1OZ3wP6GeJ4JWxgyOsQ>
    <xme:5udYaqIf2_QusjE8t23WWyKYO3gQdzEEv-xMnnCQLt1D_KfEnqlRA5QoBceUC4dsg
    VQac0ByIYbFA63VA6X_hi7bXQvrWkrJVUPomBCiZ-TsJIdMaPdIQvU>
X-ME-Proxy-Cause: dmFkZTFQUn4+dJLjyoBzh7y30GCrMU/NZnDcCOxgGCJBQIUoFCCFAYd5+RU5W0Q+FLPGNi
    8lIZfr/LxPh2Y36hYqTW7lTHAoGpDZTJSCxBxDLBkgGKfd++4ePrkCf4d7r5/DbBwPqlty
    S9TAqHINvjn0CkCWU3kIQZgWsa8WBKM5fPC29EnCc8SH39Tl1pIHTL+IwN9s+khInB5KOF
    UsGZntwaB/9Wpd0ZoSOyXWX4FDqbOTIgSjOakb0C8JdWyH9AkJPdmBMgtnDfM1NKvavBas
    Yyl4qQmHG+0cCFyDNXyHFQ6Rc7lPBO9DwaVwK/3uyArjr28Fq3xjh3tSLVGXpX1lOXelYO
    +Shx97CE2XY1u8dkSogwzZYuKY0uHGmHYbT3YMqaYLv6MvIaNQKm30VyDnAAlE3DJpjzlo
    CSAPcurfEyfRyyL0IgKzwh/vU/fshS1Esxwprinib/KzuOsVWvVcgepub1b0LDlL1tibuE
    T9/S8BZiv2jQfQsiqD8MIr/zYVgNfAhX5sCrjUNuVHcw599iWh983i/uNCL/6gd6rkA+gs
    Wli6N/RARsv6kgz/DcA943BBdesrCnt0Sh7PYB0dEXWHJJUIO8q/sjm9pcwiHgX5akycAK
    uteABkYH8WkpRNSFNBvMEDhLZdYuewE3IZC1ANoTYixbtYO8aceBoQx3um2w
X-ME-Proxy: <xmx:5udYaqScrdTmoh8H3dOokTX2ibF6xUlp6rJeSHVF_ftK9aP1N2ulrA>
    <xmx:5udYalyB2QBj7l7rmXwV4vlR9TY2JvU6SNEsq-rPTCn3JToDP8-0dA>
    <xmx:5udYaiolZWPXzF4GXmDg33U0YDOlkYILeaxOa4ok_SZEHixkmWXRKg>
    <xmx:5udYao2fnqLW5Vd2Uj56fmCHrMaXTuRsUMvdqpvJmQCfPLkSAlDvYw>
    <xmx:5udYaixfWabjGyOX_RAGD7zNelr5Q4cS9jagHGVDMW__TqCRx9D4Vsx2>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C8CE57811BC; Thu, 16 Jul 2026 10:17:10 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 16 Jul 2026 10:16:50 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Steve Dickson" <steved@redhat.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <4f38f857-8960-4cf6-9141-d133120f06f8@app.fastmail.com>
In-Reply-To: <8608717db0afb2baee5536caa9cdcc5d4ac85623.camel@kernel.org>
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
 <20260619-exportd-netlink-v6-3-ddef3499793c@kernel.org>
 <8173debc-96fb-4354-ba11-dff99b772523@app.fastmail.com>
 <4ef6dd5a13bfb51f72452aa30f59c89a54037404.camel@kernel.org>
 <dace51f2-0d20-443b-841a-f8452fdb85e3@app.fastmail.com>
 <8608717db0afb2baee5536caa9cdcc5d4ac85623.camel@kernel.org>
Subject: Re: [PATCH v6 3/6] nfsd: implement server-stats-get netlink handler
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Thu, Jul 16, 2026, at 10:12 AM, Jeff Layton wrote:
> On Thu, 2026-07-16 at 10:04 -0400, Chuck Lever wrote:
>>=20
>> On Thu, Jul 16, 2026, at 9:53 AM, Jeff Layton wrote:
>> > On Fri, 2026-06-19 at 16:40 -0400, Chuck Lever wrote:
>> > >=20
>> > > On Fri, Jun 19, 2026, at 11:26 AM, Jeff Layton wrote:
>>=20
>> > > > +		/* Per-version procedure counts */
>> > > > +		if (statp->vs_count) {
>> > > > +			static const int proc_attrs[] =3D {
>> > > > +				[2] =3D NFSD_A_SERVER_STATS_PROC2_OPS,
>> > > > +				[3] =3D NFSD_A_SERVER_STATS_PROC3_OPS,
>> > > > +				[4] =3D NFSD_A_SERVER_STATS_PROC4_OPS,
>> > > > +			};
>> > > > +			unsigned int i;
>> > > > +
>> > > > +			for (i =3D 0; i < prog->pg_nvers &&
>> > > > +			     i < ARRAY_SIZE(proc_attrs); i++) {
>> > > > +				if (!prog->pg_vers[i] ||
>> > > > +				    !statp->vs_count[i])
>> > > > +					continue;
>> > > > +				if (!proc_attrs[i])
>> > > > +					continue;
>> > > > +				if (nfsd_nl_fill_proc_ops(skb,
>> > > > +						proc_attrs[i],
>> > > > +						statp->vs_count[i],
>> > > > +						prog->pg_vers[i]->vs_nproc))
>> > > > +					goto err_cancel;
>> > > > +			}
>> > > > +		}
>> > > > +
>> > > > +#ifdef CONFIG_NFSD_V4
>> > > > +		/* NFSv4 individual operation counts */
>> > > > +		for (int i =3D 0; i <=3D LAST_NFS4_OP; i++) {
>> > > > +			struct nlattr *nest;
>> > > > +			u64 cnt;
>> > > > +
>> > > > +			cnt =3D percpu_counter_sum_positive(
>> > > > +				&nn->counter[NFSD_STATS_NFS4_OP(i)]);
>> > > > +
>> > > > +			nest =3D nla_nest_start(skb,
>> > > > +					NFSD_A_SERVER_STATS_PROC4OPS_OPS);
>> > > > +			if (!nest)
>> > > > +				goto err_cancel;
>> > > > +			if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, i) ||
>> > > > +			    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
>> > > > +					      cnt, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
>> > > > +				nla_nest_cancel(skb, nest);
>> > > > +				goto err_cancel;
>> > > > +			}
>> > > > +			nla_nest_end(skb, nest);
>> > > > +		}
>> > > > +#endif
>> > >=20
>> > > This loop open-codes the same nest that nfsd_nl_fill_proc_ops() b=
uilds just
>> > > above -- nla_nest_start(), nla_put_u32(PROC_ENTRY_OP),
>> > > nla_put_u64_64bit(PROC_ENTRY_COUNT), nla_nest_end() -- into the s=
ame
>> > > NFSD_A_SERVER_STATS_PROC4OPS_OPS attribute.  Could the helper be =
generalized
>> > > to take the per-op counter source so this is not a second copy of=
 the same
>> > > code?
>> > >=20
>> > > The per-version block above skips empty versions:
>> > >=20
>> > > 	if (!prog->pg_vers[i] || !statp->vs_count[i])
>> > > 		continue;
>> > >=20
>> > > but this loop emits an entry for every op 0..LAST_NFS4_OP, zero-c=
ount ops
>> > > included.  Is that difference intentional?  Skipping zero counts =
here would
>> > > also trim the worst-case message size above.
>> > >=20
>> > > There is also a counter that this dump does not emit.  /proc/net/=
rpc/nfsd
>> > > prints a wdeleg_getattr line after proc4ops:
>> > >=20
>> > > 	seq_printf(seq, "\nwdeleg_getattr %lld",
>> > > 		percpu_counter_sum_positive(&nn->counter[NFSD_STATS_WDELEG_GETA=
TTR]));
>> > >=20
>> > > incremented by nfsd_stats_wdeleg_getattr_inc().  Since the goal i=
s to expose
>> > > the statistics currently available via /proc/net/rpc/nfsd, should
>> > > wdeleg_getattr get an attribute here too, so nfsstat over netlink=
 does not
>> > > drop it relative to the procfs path?
>> > >=20
>> >=20
>> > The only thing in this review that is not addressed in my current
>> > series is the above comment, and I think we had agreed in an earlier
>> > email thread that this was approximately the same value as the coun=
ter
>> > for CB_GETATTR calls and so it's good enough for this purpose.
>> >=20
>> > Are you still ok with this approach?
>>=20
>> In spite of the email quoting, I=E2=80=99ve still forgotten most of t=
he context
>> of that conversation.
>>=20
>> Looking at this now, I think someone later could get an urge to add t=
he
>> wdeleg_getattr statistic to netlink=E2=80=A6 for symmetry, because it=
 smells like
>> technical debt, or it might actually be useful for something.
>>=20
>> IMHO we should include it now.
>>=20
>
> IDGI: what's the point of collecting that stat separately when we have
> stats for CB_GETATTR already? I'd prefer to avoid perpetuating
> wdeleg_getattr as a stat here, since it's not directly tied to the
> protocol in the same way as the others are.
>
> The only difference between the two is that if another client does a
> GETATTR for the fh while there is already a CB_GETATTR in flight,
> wdeleg_getattr gets bumped today, whereas CB_GETATTR counter does not
> (since there is only a single CB_GETATTR for that).
>
> Is that difference relevant? I think Dai added wdeleg_getattr
> originally, so I'd really like to hear his opinion on this.

OK, so you are actually re-litigating whether the stat should exist
at all. I confess I had forgotten that context.

I=E2=80=99m arguing only that the netlink and procfs APIs should remain
equivalent, at least initially. Deleting the stat entirely probably
has no consequences right now, but let=E2=80=99s hear from Dai when the =
US
west coast wakes up.


--=20
Chuck Lever
