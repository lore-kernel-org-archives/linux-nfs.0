Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99A49433BDD;
	Thu, 16 Jul 2026 14:28:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784212118; cv=none; b=K/hvycsyLgxuLaBeNfd72zunNMCutxWaH4yVADgztZ8+QuUGb9f2Bgx5/bQcNC4ib9kBN46iAUTp8jH+zNi7pJ0q4IzipCJfjJIcFmMsdpxhCBY0Qi3SKdw18oQzZqjUW9AYq3NQqCsCJlDqC9g4NxXF+9DcBdSMUbnLIa5jVK0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784212118; c=relaxed/simple;
	bh=hwJUzulo2tdBNzdbl2CjBt6C990y37p0T4vqVH84/kw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Piwq1XALJLD1y2QQ1ACZlytWU+IBuAzkNGgcJgLAlaBlaWbJ/nxvaPnCoNLMaYdS3ta2NOrgF9na3yko5Io12E9pZsKGSYWwplKbl8mvx7r979fZKuKKxZ9mB7yP28LD8EYTomBxUpx4Ot4YI5r4INhbDBmBowRsaK/BmA8GsCY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SbX20LUb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SbX20LUb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C789D1F00A3E;
	Thu, 16 Jul 2026 14:28:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784212116;
	bh=DpJP5AawPvDEH5gsd8d9aPX/OG6rwcK6YSN83dFj+W8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SbX20LUbw5bGI53q9ZiJFcm+87dZoyMHdV+1mCgB8G38/QN0we7PNdUkthmFbZIoj
	 TkNgmwqn0WNsQTN04u88FDtKiIh+twdKAzPNEMC8WD3A5uAizAXCAe4gOy/tdJhhLH
	 OUuIDB/Xc0ZSXduysIJrMBIolNZKDTR0dJaAmRx4604TZ4UBwx60KlRWOuq90tunF1
	 ln58r2wsYWMdj5Ur27HC1t02tbrdjU+PI0Eauh8Eyi197zAoYeFP5/Bbv5TMoQ/wPH
	 kXc2p15x5mXUeCs3JRUWxY4cS5zUm9EHvrKPe470+Gxy/AnV5lI71Q3VnWk8Hrvq5x
	 0RWMjI3lPRnMQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id CCD8CF4007A;
	Thu, 16 Jul 2026 10:28:34 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 16 Jul 2026 10:28:34 -0400
X-ME-Sender: <xms:kupYarcI0JBUryTW5P0PDhpMfF5JwSX9iqcJLBLW-AQmremocDihjQ>
    <xme:kupYasDzqiZtC5M7jTxNRbWPPTnMM8xdkH2zpNZdYY3sy3WFEQ2r4oNal4-cX5zSD
    -ixS7oc1kTohgAoL_frQiUKrRQ9jquMkxvD6uANLllgi9rGFEGqJ-BO>
X-ME-Proxy-Cause: dmFkZTFPJoi3vlOLDoOqVwVFTIEkC/qdDHc3VQe3HAGiHU7XTHnmyDO5F+G1J5n7NleN7U
    pkO+w01GWWFJEc/meeMKOLata/7PGtgUtOUDiqGAi5t4VRE62C+sOe8vir3wMZTslicXhL
    UWxbUXlDhv+OX+n5p9AGP7NM0O6VPwFqHekmx+rCLIh2E/cvkINFQpu3350Wvow1zwa/to
    k2ta0c7UYvxvpEbJJNGI16ClSa+RWT23+FJijUrQsl8VGb4Bryydtgww9r12JhddSWyjsp
    9EQI8iKMfT+AC7erCMUaU7lP/F2LJPhAQAa+j5PxTSrubPRqDOEBrNqyawD44TgZMZpviG
    KGl5iWi/vkE6XqE8badbFSLiokwgDW4hIct3+KLIkM1L9sC4OvJPtVxzElwUduoW5xI6jD
    nXIrPI/Hz6DavT0nX4yvHnb3fEWBx1BdGd1MnY/k9v1yYrxkBhI9Ix6wvsdGtXgSWZItoA
    /tKaRFjNF5pORIJkz45MQM0ak7bef2R81MdyY/TEjf1syN/hlKu2c4eCqJR4iXTyX5QNCO
    t7kJSry7uYuDBfwl/fJ08WkAKQuY2/oc0QqRa8s+dKWfP5RFw+5OGuRSyFzIsmp7bbwSBx
    hJXpE8dqpX0TxwpjLnrPLxssiF1uR1R7H1EiatN1dJWR1bn2a2tVp7xg6laQ
X-ME-Proxy: <xmx:kupYamoXDwiHOf25bnl7EtPK4euJ1UnIQoXOSBUPhxNpHx_p5t2_MA>
    <xmx:kupYaqqrMFi7lmvEeMmPEOjaV_sn5daVYIscOssgmDbGv3H0T-VCCQ>
    <xmx:kupYamA8bIdql4IQzogDJ_UKpNkfst-9Ln9x4Qd-GedL1o1XtMe0UA>
    <xmx:kupYaosFRpJ2cwzcgo1w7HWGg09A1H-afu-lqeNzPsJjowBQ6P_E9Q>
    <xmx:kupYalIAamBotJYAQrgWcUvDijZsBehNCyMXM8T9NMV4vgSVfPaynbtR>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A8C187811BC; Thu, 16 Jul 2026 10:28:34 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 16 Jul 2026 10:28:14 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Steve Dickson" <steved@redhat.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <c7ebc7af-9bb0-4c10-8295-7b60b8507bfd@app.fastmail.com>
In-Reply-To: <4f38f857-8960-4cf6-9141-d133120f06f8@app.fastmail.com>
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
 <20260619-exportd-netlink-v6-3-ddef3499793c@kernel.org>
 <8173debc-96fb-4354-ba11-dff99b772523@app.fastmail.com>
 <4ef6dd5a13bfb51f72452aa30f59c89a54037404.camel@kernel.org>
 <dace51f2-0d20-443b-841a-f8452fdb85e3@app.fastmail.com>
 <8608717db0afb2baee5536caa9cdcc5d4ac85623.camel@kernel.org>
 <4f38f857-8960-4cf6-9141-d133120f06f8@app.fastmail.com>
Subject: Re: [PATCH v6 3/6] nfsd: implement server-stats-get netlink handler
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Thu, Jul 16, 2026, at 10:16 AM, Chuck Lever wrote:
> On Thu, Jul 16, 2026, at 10:12 AM, Jeff Layton wrote:
>> On Thu, 2026-07-16 at 10:04 -0400, Chuck Lever wrote:
>>>=20
>>> On Thu, Jul 16, 2026, at 9:53 AM, Jeff Layton wrote:
>>> > On Fri, 2026-06-19 at 16:40 -0400, Chuck Lever wrote:
>>> > >=20
>>> > > On Fri, Jun 19, 2026, at 11:26 AM, Jeff Layton wrote:
>>>=20
>>> > > > +		/* Per-version procedure counts */
>>> > > > +		if (statp->vs_count) {
>>> > > > +			static const int proc_attrs[] =3D {
>>> > > > +				[2] =3D NFSD_A_SERVER_STATS_PROC2_OPS,
>>> > > > +				[3] =3D NFSD_A_SERVER_STATS_PROC3_OPS,
>>> > > > +				[4] =3D NFSD_A_SERVER_STATS_PROC4_OPS,
>>> > > > +			};
>>> > > > +			unsigned int i;
>>> > > > +
>>> > > > +			for (i =3D 0; i < prog->pg_nvers &&
>>> > > > +			     i < ARRAY_SIZE(proc_attrs); i++) {
>>> > > > +				if (!prog->pg_vers[i] ||
>>> > > > +				    !statp->vs_count[i])
>>> > > > +					continue;
>>> > > > +				if (!proc_attrs[i])
>>> > > > +					continue;
>>> > > > +				if (nfsd_nl_fill_proc_ops(skb,
>>> > > > +						proc_attrs[i],
>>> > > > +						statp->vs_count[i],
>>> > > > +						prog->pg_vers[i]->vs_nproc))
>>> > > > +					goto err_cancel;
>>> > > > +			}
>>> > > > +		}
>>> > > > +
>>> > > > +#ifdef CONFIG_NFSD_V4
>>> > > > +		/* NFSv4 individual operation counts */
>>> > > > +		for (int i =3D 0; i <=3D LAST_NFS4_OP; i++) {
>>> > > > +			struct nlattr *nest;
>>> > > > +			u64 cnt;
>>> > > > +
>>> > > > +			cnt =3D percpu_counter_sum_positive(
>>> > > > +				&nn->counter[NFSD_STATS_NFS4_OP(i)]);
>>> > > > +
>>> > > > +			nest =3D nla_nest_start(skb,
>>> > > > +					NFSD_A_SERVER_STATS_PROC4OPS_OPS);
>>> > > > +			if (!nest)
>>> > > > +				goto err_cancel;
>>> > > > +			if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, i) ||
>>> > > > +			    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
>>> > > > +					      cnt, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
>>> > > > +				nla_nest_cancel(skb, nest);
>>> > > > +				goto err_cancel;
>>> > > > +			}
>>> > > > +			nla_nest_end(skb, nest);
>>> > > > +		}
>>> > > > +#endif
>>> > >=20
>>> > > This loop open-codes the same nest that nfsd_nl_fill_proc_ops() =
builds just
>>> > > above -- nla_nest_start(), nla_put_u32(PROC_ENTRY_OP),
>>> > > nla_put_u64_64bit(PROC_ENTRY_COUNT), nla_nest_end() -- into the =
same
>>> > > NFSD_A_SERVER_STATS_PROC4OPS_OPS attribute.  Could the helper be=
 generalized
>>> > > to take the per-op counter source so this is not a second copy o=
f the same
>>> > > code?
>>> > >=20
>>> > > The per-version block above skips empty versions:
>>> > >=20
>>> > > 	if (!prog->pg_vers[i] || !statp->vs_count[i])
>>> > > 		continue;
>>> > >=20
>>> > > but this loop emits an entry for every op 0..LAST_NFS4_OP, zero-=
count ops
>>> > > included.  Is that difference intentional?  Skipping zero counts=
 here would
>>> > > also trim the worst-case message size above.
>>> > >=20
>>> > > There is also a counter that this dump does not emit.  /proc/net=
/rpc/nfsd
>>> > > prints a wdeleg_getattr line after proc4ops:
>>> > >=20
>>> > > 	seq_printf(seq, "\nwdeleg_getattr %lld",
>>> > > 		percpu_counter_sum_positive(&nn->counter[NFSD_STATS_WDELEG_GET=
ATTR]));
>>> > >=20
>>> > > incremented by nfsd_stats_wdeleg_getattr_inc().  Since the goal =
is to expose
>>> > > the statistics currently available via /proc/net/rpc/nfsd, should
>>> > > wdeleg_getattr get an attribute here too, so nfsstat over netlin=
k does not
>>> > > drop it relative to the procfs path?
>>> > >=20
>>> >=20
>>> > The only thing in this review that is not addressed in my current
>>> > series is the above comment, and I think we had agreed in an earli=
er
>>> > email thread that this was approximately the same value as the cou=
nter
>>> > for CB_GETATTR calls and so it's good enough for this purpose.
>>> >=20
>>> > Are you still ok with this approach?
>>>=20
>>> In spite of the email quoting, I=E2=80=99ve still forgotten most of =
the context
>>> of that conversation.
>>>=20
>>> Looking at this now, I think someone later could get an urge to add =
the
>>> wdeleg_getattr statistic to netlink=E2=80=A6 for symmetry, because i=
t smells like
>>> technical debt, or it might actually be useful for something.
>>>=20
>>> IMHO we should include it now.
>>>=20
>>
>> IDGI: what's the point of collecting that stat separately when we have
>> stats for CB_GETATTR already? I'd prefer to avoid perpetuating
>> wdeleg_getattr as a stat here, since it's not directly tied to the
>> protocol in the same way as the others are.
>>
>> The only difference between the two is that if another client does a
>> GETATTR for the fh while there is already a CB_GETATTR in flight,
>> wdeleg_getattr gets bumped today, whereas CB_GETATTR counter does not
>> (since there is only a single CB_GETATTR for that).
>>
>> Is that difference relevant? I think Dai added wdeleg_getattr
>> originally, so I'd really like to hear his opinion on this.
>
> OK, so you are actually re-litigating whether the stat should exist
> at all. I confess I had forgotten that context.
>
> I=E2=80=99m arguing only that the netlink and procfs APIs should remain
> equivalent, at least initially. Deleting the stat entirely probably
> has no consequences right now, but let=E2=80=99s hear from Dai when th=
e US
> west coast wakes up.

Another option is to keep the stat but report it some other way.
It is arguable whether nfsstat is the proper mechanism to report
the different reasons for sending a CB_GETATTR.


--=20
Chuck Lever
