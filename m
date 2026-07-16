Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C5C43161AD
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 14:04:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784210685; cv=none; b=qJUCP+8zdOiQaltzRN0bSfmcpALXTE0vIbo9NGNE7zO8ZNbvS2rGIrFFGCYAlojBSGgSCLaa5H9ZqS8UvaB5nIEVHQnIrAhu5oUETDyZdiUrbdB+hMj1NsM6JqopQFNuwzNCybu7kvDo2sFR4NOeskCwulP60eXVlYYaW+CnRrk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784210685; c=relaxed/simple;
	bh=6Qm0O+xqm7U/oe0ZPzZTh6qAVv0WhW35laLiU0SfnaE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=UAf1mnR1S9BALzMCN8gIguxguPEjbmPS3beTZ/ugVEzYf+ET4zTZGHRjXWz/g9dYKDv4XcTIeqpxGqjTq8w57ZfqG/t2HHhGAv+tl51H33BjgRBeuM2PRgCt7FBWdzVuyXD/oDYviGNaCiR9sLJj1cYNnA9D//aLQMjL0FT9zXM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DMlak1Fc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DMlak1Fc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 40AA71F00A3D
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 14:04:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784210684;
	bh=xYmfJQYKFoTUy+J4IxZJVxs4HoFhpTlM8KB39ZYaJ4Y=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=DMlak1Fckd9Qj15OABEs7FRyZRnhv5UGebtBobSxuWFu63zCq8oA3HY0F01RXB2A4
	 KESapotSNirZO6FGo4/HWX7nN5NKEwlQ3MdHDxyx3zN564eryoNSgI3FBEkehtY9Bs
	 z57Mjh5Rk0YjVcGSBN9v/8JDdilGEjVi9hYWBTgs3X6S4STeql8mVu8IvOJH/POnK7
	 q90lg1/RKY0lELxvPs0xIN52LxP04RIq5U8/eq7iaJQvimlFcUbY/cqJtOFLRO4Nf8
	 IG84sy0dKvyL81k5dSvaLdqDtBh6I/Q7fFLMYRJQcxcklb8KX3PnoKQ/QoNzP6qm/C
	 awQbljQT+LHPQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 428DBF4006B;
	Thu, 16 Jul 2026 10:04:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 16 Jul 2026 10:04:43 -0400
X-ME-Sender: <xms:--RYanBoUinfjGuIHQ63W1aZk-NpFVZrotM1-F-WLe0rrS048BwpWg>
    <xme:--RYaoXrueS8pvVqRVoeNjc4fMM9R_XXyzd8VFw8q-nlPJdVwQ9r-xej4ED1zVYfC
    vF1ICMZlc1t78JL7BBhxsCg-Ce_IVG4ooO5SO5xWWTS9WZ0qm4RfcE>
X-ME-Proxy-Cause: dmFkZTG0K/DzoCiqdSuMMIbUt+6FXjUstlG3uwLksnBQHfvn8hYDRhbjG2i+ylG8yPysMw
    +UX13Crue+PUmbwdjOvw019VNVp7KnTP2xPaEHilzDcFTovTGKr+aXMzAG4qB7aHc8SUZI
    ozS8bMijM8R2l6QF3sbsPqrpC+2W5tIQTZF8XOLD5XV3xAeMvFgiwECGu0Wqug5GkUzJP5
    I5DI+sPbbnkuMpCAURd6eb43GLwtd2d5ss0A6UAeCAoQlx7YxuHI93PX3TNkG8e41VskrV
    XzTR4HIb/a8/R5iSkb6ybVGwW08Dyhtl9z+YaOwRBI++HMFi+cjlQhsDs1DnoEiFhe2zVq
    PggNslCLK96KyTLeCQBhUbr3YBZ66CUfDQMDmpUKaaeo8USpfa/lW6eeiEYWG7lCFoWUcj
    3gAPdOkoEm96exdI/BCvZ85fv5GU8ikK1p94g6u/0TuxfKrgBVlblxxqIW9lpcyXWcsENe
    srY6wK7ZZk9gwHIm0wjTtJ+OWTfXcw5eQkHL7fu1+GwxzIQkxEVIV52RAe7RdVyhT4Whve
    IADg+E6h4GJ9W9pLi61TH69m5bv+0Gb6vja7eQNPQjDVSUbL/pUn4YPvAn/++Rs6NhYv5L
    zPo05LcsJeFSfYE1X8KCIARvsRP2exvTIteEYwroLmiqK7z+Q5kVYTM8g5Iw
X-ME-Proxy: <xmx:--RYakvdm-KAcgGlky9o9o1_cyG2Fraw1xNhQLCsYx0DbVwGKO2x5w>
    <xmx:--RYancSVWltrHw48Ws46d4aplIV7EJycpC3eKz1QiRcJ9X_5ZiguA>
    <xmx:--RYaqkvRBNCQI0uFp2NRNMB-kToix5N1TQSHOZYDc8CFVQ62Rx5lw>
    <xmx:--RYaqAxGLcjHk8M9jC9-F6FLzS8ttJqrIzPO6MdakawBD0h-Ixtgg>
    <xmx:--RYakOj3bpSre4J3C0QYu196k1At9A2C0vUogi33y3zw58W6-hGzHHn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1C6FA7811BC; Thu, 16 Jul 2026 10:04:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 16 Jul 2026 10:04:21 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Steve Dickson" <steved@redhat.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <dace51f2-0d20-443b-841a-f8452fdb85e3@app.fastmail.com>
In-Reply-To: <4ef6dd5a13bfb51f72452aa30f59c89a54037404.camel@kernel.org>
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
 <20260619-exportd-netlink-v6-3-ddef3499793c@kernel.org>
 <8173debc-96fb-4354-ba11-dff99b772523@app.fastmail.com>
 <4ef6dd5a13bfb51f72452aa30f59c89a54037404.camel@kernel.org>
Subject: Re: [PATCH v6 3/6] nfsd: implement server-stats-get netlink handler
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Thu, Jul 16, 2026, at 9:53 AM, Jeff Layton wrote:
> On Fri, 2026-06-19 at 16:40 -0400, Chuck Lever wrote:
>>=20
>> On Fri, Jun 19, 2026, at 11:26 AM, Jeff Layton wrote:

>> > +		/* Per-version procedure counts */
>> > +		if (statp->vs_count) {
>> > +			static const int proc_attrs[] =3D {
>> > +				[2] =3D NFSD_A_SERVER_STATS_PROC2_OPS,
>> > +				[3] =3D NFSD_A_SERVER_STATS_PROC3_OPS,
>> > +				[4] =3D NFSD_A_SERVER_STATS_PROC4_OPS,
>> > +			};
>> > +			unsigned int i;
>> > +
>> > +			for (i =3D 0; i < prog->pg_nvers &&
>> > +			     i < ARRAY_SIZE(proc_attrs); i++) {
>> > +				if (!prog->pg_vers[i] ||
>> > +				    !statp->vs_count[i])
>> > +					continue;
>> > +				if (!proc_attrs[i])
>> > +					continue;
>> > +				if (nfsd_nl_fill_proc_ops(skb,
>> > +						proc_attrs[i],
>> > +						statp->vs_count[i],
>> > +						prog->pg_vers[i]->vs_nproc))
>> > +					goto err_cancel;
>> > +			}
>> > +		}
>> > +
>> > +#ifdef CONFIG_NFSD_V4
>> > +		/* NFSv4 individual operation counts */
>> > +		for (int i =3D 0; i <=3D LAST_NFS4_OP; i++) {
>> > +			struct nlattr *nest;
>> > +			u64 cnt;
>> > +
>> > +			cnt =3D percpu_counter_sum_positive(
>> > +				&nn->counter[NFSD_STATS_NFS4_OP(i)]);
>> > +
>> > +			nest =3D nla_nest_start(skb,
>> > +					NFSD_A_SERVER_STATS_PROC4OPS_OPS);
>> > +			if (!nest)
>> > +				goto err_cancel;
>> > +			if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, i) ||
>> > +			    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
>> > +					      cnt, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
>> > +				nla_nest_cancel(skb, nest);
>> > +				goto err_cancel;
>> > +			}
>> > +			nla_nest_end(skb, nest);
>> > +		}
>> > +#endif
>>=20
>> This loop open-codes the same nest that nfsd_nl_fill_proc_ops() build=
s just
>> above -- nla_nest_start(), nla_put_u32(PROC_ENTRY_OP),
>> nla_put_u64_64bit(PROC_ENTRY_COUNT), nla_nest_end() -- into the same
>> NFSD_A_SERVER_STATS_PROC4OPS_OPS attribute.  Could the helper be gene=
ralized
>> to take the per-op counter source so this is not a second copy of the=
 same
>> code?
>>=20
>> The per-version block above skips empty versions:
>>=20
>> 	if (!prog->pg_vers[i] || !statp->vs_count[i])
>> 		continue;
>>=20
>> but this loop emits an entry for every op 0..LAST_NFS4_OP, zero-count=
 ops
>> included.  Is that difference intentional?  Skipping zero counts here=
 would
>> also trim the worst-case message size above.
>>=20
>> There is also a counter that this dump does not emit.  /proc/net/rpc/=
nfsd
>> prints a wdeleg_getattr line after proc4ops:
>>=20
>> 	seq_printf(seq, "\nwdeleg_getattr %lld",
>> 		percpu_counter_sum_positive(&nn->counter[NFSD_STATS_WDELEG_GETATTR]=
));
>>=20
>> incremented by nfsd_stats_wdeleg_getattr_inc().  Since the goal is to=
 expose
>> the statistics currently available via /proc/net/rpc/nfsd, should
>> wdeleg_getattr get an attribute here too, so nfsstat over netlink doe=
s not
>> drop it relative to the procfs path?
>>=20
>
> The only thing in this review that is not addressed in my current
> series is the above comment, and I think we had agreed in an earlier
> email thread that this was approximately the same value as the counter
> for CB_GETATTR calls and so it's good enough for this purpose.
>
> Are you still ok with this approach?

In spite of the email quoting, I=E2=80=99ve still forgotten most of the =
context
of that conversation.

Looking at this now, I think someone later could get an urge to add the
wdeleg_getattr statistic to netlink=E2=80=A6 for symmetry, because it sm=
ells like
technical debt, or it might actually be useful for something.

IMHO we should include it now.


--=20
Chuck Lever
