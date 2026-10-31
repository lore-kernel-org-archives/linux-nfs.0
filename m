Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.159
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793483390;
	b=YahGEIJa47ANNYyzKtfxRoPXJgAdlb7AruWwOfS/BHIrUE43DtnijIJvRdU2xxOAKVUg
	 0ooJF5pZomZivKWB2pRtnaoBqRelSo3L7ZDAWW3CnXmuz1HBf4Yv1NZQcqr6IjWAug7wn
	 f0svvS0G9xdKAyZbBO3VcGsowV5btKynJ5vTYcwH5q3ZPr5STWdGL3VXEstrMkw8OpN1I
	 hWD/0VOc50dQuBoSeCnqbnSY5uSJCcCyt8HjN10x1orvQ+6RCXY+tq83jyAL4UuZ+3Qjm
	 egKzGf838oW5PW2DOQ4L7lFySSW/ZQGqf35zTWAoqXCaJv/TwCG1Z94D0a+nQOzYhPg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793483390;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=Dqptpgk/y801BpkwD0flbCVwz21NUliVvaq6MdaCT5I=;
	b=V1DWkvadrOQubuPLuN1E8NJtdhsOp7tkELmkcub36lzVdponb3KY8NhE4Ji9R20SYcfV
	 eDZg8sUd7LwBv63/rfzYcSRz/uA0AE8+p6TzGWBZThnLPw5sIaPEsTbbRHm8pxet+M19B
	 swz6YIzyA/iPXFQQOnTxBZysTL5/Q91aEqJbKvm41i3oFSdzHEHfUa4q95y2Ss93plsQK
	 77vPR7qYyByb26+vrbd9hNOYAIXJKV+UyntYE98rqwULogyctS8Cr+brf0e5okT/79eec
	 Uu7QDtnjvA1tbU6u8xqdubPYWzRiyBjtAytOwBhgms7LA+DsQCZYqMe95EJbbVn7TWQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=IkZ88K3+;
	dkim=temperror header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b="KI/X1V0W";
	arc=none smtp.remote-ip=202.12.124.159
Received: from fhigh-b8-smtp.messagingengine.com (fhigh-b8-smtp.messagingengine.com [202.12.124.159])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39A41606A31A
	for <linux-nfs@vger.kernel.org>; Sat, 31 Oct 2026 21:49:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 39A41606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=IkZ88K3+;
	dkim=temperror header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=KI/X1V0W
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 80D607A00C0
	for <linux-nfs@vger.kernel.org>; Sat, 31 Oct 2026 17:49:48 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Sat, 31 Oct 2026 17:49:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793483388; x=1793569788; bh=Dqptpgk/y801BpkwD0flbCVwz21NUliVvaq
	6MdaCT5I=; b=IkZ88K3+TXbp0L7k9to7D5tpfWlV5bRy7mcMrD6rl+sre9Zox1q
	QCbNBXl+wAg3HJcLbcghlBOJTGLd+BjGDS76+ODnJ/l7+QxaQ2fKiRbxRtBRCyRy
	rY6saNn9ZNWvCRmmJBmH6xjeoQTK9xc9bYRxsyaFHpLPDEgvecOYuxRXWZghVR8p
	hqKxIDuXLqFsr7IuN3CdAe81FlnUnI30uPyZ5KO1iIBEF6ULllAUO/+bLkaRsFwl
	ZLWgsooV5o4sokrNBmqbN98OvaHmQnZ4Q3eLiHoyL0QboxHQicIT1xnxdlFr8TX7
	JSinoP47Y+2O6UuPACN7DHUHEwoXYKeG/qw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793483388; x=
	1793569788; bh=Dqptpgk/y801BpkwD0flbCVwz21NUliVvaq6MdaCT5I=; b=K
	I/X1V0WYcruPn9u0clQ2ESfYmfztqyXyUuN0QTOmjT368S7OmnwyNyMiikmcSqMW
	O+K+Iy9a7O0Pm+JYXkx/INIan5UG2YkYY5JNEK8C/QRH6UP2zHcoa0pT1k6eAM+g
	6OsRm+koYxq/kOXqKvwXk33SI/8MWo8vxX+fiPb2MAQ4nuzfEo+zqwiqU0gaIniJ
	TQW1aF7H9yf2kBPaFqM7b2Fo5NkYgEMC99gbvubiUlY53PcUXjZlrGteeJE8e6hB
	f7+8UiXz3KMx+ZlgrjCKE2TeoTo336smACM4MpoKlaEGDUWAtyNvvZP9tlpeYbpQ
	S6D/1S+zNcOlhctlyuj9g==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793483388; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:BsWr5oJObh9as4hsD1BGKt05/NxRLhGvgU+e2cRWqGiQZRS
	4EjmK9AYCS4yc/uXHR5BmJeKlmFr7B+AowY1/kXRu01t7ZZiboD+fu3v2o+CcCtc
	+AEouCPxITwttAXTb0HlnmdsnnuwyZEYtSurlec2nqp5uAqOwKbFKH/QsyQwXkvb
	hFqCitREfMWxuiBWhb2D5yqiIhDfDrKiJKLdhYDepIhm825LYG3puMqplb5rhE++
	O9Mk2Da85OtDkYmU0xb+TLRjjn53xYhspTB6Fy3UhblBdUn50m0iVC/dIH0fstus
	L/VV1IazPdWoTmAl5zCxsKFhaxCFNLsRy3PKP3Q==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:xjZ38JdK4Ue/7wgJJp2aBnbMI4nnu3fmuT4Nf+KGkc4=:E1SEvAU69AdkxdM4A+CVF4YirlaFtUkMYecNKZnSW2k=;
X-ME-Sender: <xms:e2LmalSIxTQ82Wa-O7omUf7cpUASoddBIGQsG-OPSzlMHerUQccIHg>
    <xme:e2LmagSup_vUYJmguAKtwpADF93ijr8kEKKGWn0d72sSf-LIaPPqFbNWMraiNRao7
    U8v9XcUG3RTe3aEJKypieFSlPdWvjZWTXo1muofmCSMSxhfk_8>
X-ME-Received: <xmr:e2Lmaq5sguXaRpGs5KOg87p4e98EN0oxWcRWgMgXuey8COT-zPZHf7U0D3d0NiJpZ5h3IxXo6JgEaG6WVGMAySXWgBkTGcM>
X-ME-Proxy-Cause: dmFkZTE2LiUPb/ID0mHqgShd3s/VNy+MkggIzMwmBVkban68WO6kPnLOVHVnoMzsODhJdx
    ACjYPiJ8xQlrCyS6plUxyvvg3QOVJZWv22taoUBC9kpnl77t5yACruRxBVeGyGhFf7jqUa
    HubwA4T7B+RmDLH+bJgnYMwy4iwyjoCdochxhPLq80cOYjJCAKZRdHTvTAyNGKERVnPyw1
    OmPCie5n2usuzPBrLchKOzaHx08wd17GjxAhbZek+TY12bN5vEHlrvB2vfAf/jXSLDZiM8
    9yE9GZ6Q3AgiLlKu1zwM4EWcRY0Yu8uB6fd3nul/dF+vs11Z13nsn5FkwOO8eG+GWQXUA+
    9cvLiog4HfHB++NpdNX7B+S1cSloIA9ar9bUIX/a6v5sirqv2JPP5hba3KYNiz5ESuUWG5
    Mm3r+lsh8OT1SCouJPUqZ1pYGfecMQmQUC4WmCOwEALOzzlSbuK141skivyg5F55QlJMgx
    GoCzIMTHTU7xBPPuvsWDqCg4JliQpesLWGqp172YpiWdu/etNe3sDsPfR1Bq7UVanKaL4+
    ipGp44Nek+FMVI/FSRi7tnS4J/A8D/Ii1hZUnO9dLr9+QtZOYcYSR8AmVCBwzlxSDrNUYt
    qJuR0lLLXnidUU0gVioL5jYB/RYVX1/McsTrkSqDkXRd/dVuXM3o6SwPH2QA
X-ME-Proxy: <xmx:e2Lmas3zkP5IzQQVR2VRaM3-XrZDheu4592077VzDOno4vH6CXVCUQ>
    <xmx:e2LmalBE93uxGm4iE_BYzoZbKeRsM7ri-Yu8xrgsq8TZ5GVyX71ENQ>
    <xmx:e2LmanM32UA1DBFVCDYPlK7E1m48usxoU_BIHzqX01I-C6_Y_ZzYcg>
    <xmx:e2LmaqZIFeUNlNhT_xg8YQCsHrEbQ7RdvwW2GzCOviduq4lMLVy2Vw>
    <xmx:fGLmajg9Zvs7rNMJNcz8RQ75PAMPD-oGnR6Xti4wGhZfa7Dt7BqXLOg6>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 31 Oct 2026 17:49:45 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Hillf Danton" <hdanton@sina.com>
Cc: "Kal Cutter Conley" <kalcutterc@nvidia.com>,
 "Chuck Lever" <cel@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: fix lost wakeups when stopping service threads
In-reply-to: <20261031004657.251-1-hdanton@sina.com>
References: <>, <20261031004657.251-1-hdanton@sina.com>
Date: Sun, 01 Nov 2026 08:49:42 +1100
Message-id: <179348338213.447095.12525891242476966502@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 31 Oct 2026, Hillf Danton wrote:
> On Sat, 31 Oct 2026 09:45:39 +1100 NeilBrown wrote:
> > On Sat, 31 Oct 2026, Kal Cutter Conley wrote:
> > > Stopping NFS can leave rpc.nfsd 0 in an uninterruptible wait with
> > > this stack:
> > >=20
> > >   svc_stop_kthreads [sunrpc]
> > >   svc_set_num_threads [sunrpc]
> > >   nfsd_svc [nfsd]
> > >   write_threads [nfsd]
> > >   nfsctl_transaction_write [nfsd]
> > >=20
> > > SP_NEED_VICTIM and SP_VICTIM_REMAINS remain set while all remaining
> > > nfsd threads sleep in svc_recv() and none has RQ_VICTIM set.
> > >=20
> > > The stop request is published with unordered set_bit() operations.
> > > svc_pool_wake_idle_thread() checks the idle list and task state before
> > > calling wake_up_process(). If it sees an empty list or TASK_RUNNING,
> > > it skips the wakeup and its memory barrier. The requester can therefore
> > > miss a sleeping worker while that worker misses the stop request.
> > >=20
> > > Order work publication before both lockless checks, even when no
> > > wakeup occurs. Pair with set_current_state() and llist_add() in
> > > svc_thread_wait_for_work(), so the worker observes the pending work or
> > > the requester observes the idle worker and wakes it.
> > >=20
> > > Fixes: 60749cbe3d8a ("sunrpc: change sp_nrthreads from atomic_t to unsi=
gned int.")
> > > Signed-off-by: Kal Cutter Conley <kalcutterc@nvidia.com>
> > > ---
> > >  net/sunrpc/svc.c | 9 +++++++++
> > >  1 file changed, 9 insertions(+)
> > >=20
> > > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > > index af8d87c1de83..f3cc63acc5e1 100644
> > > --- a/net/sunrpc/svc.c
> > > +++ b/net/sunrpc/svc.c
> > > @@ -29,6 +29,8 @@
> > >  #include <linux/sunrpc/clnt.h>
> > >  #include <linux/sunrpc/bc_xprt.h>
> > > =20
> > > +#include <asm/barrier.h>
> > > +
> > >  #include <trace/events/sunrpc.h>
> > > =20
> > >  #include "fail.h"
> > > @@ -693,6 +695,13 @@ void svc_pool_wake_idle_thread(struct svc_pool *po=
ol)
> > >  	struct svc_rqst	*rqstp;
> > >  	struct llist_node *ln;
> > > =20
> > > +	/*
> > > +	 * Order work publication before the idle-list and task-state checks,
> > > +	 * even when wake_up_process() is skipped. Pairs with the barriers in
> > > +	 * set_current_state() and llist_add() in svc_thread_wait_for_work().
> > > +	 */
> > > +	smp_mb();
> > > +
> >=20
> > I don't like this.  Stand-alone barriers are, I think, harder to read
> > than barriers combined with operations, like smp_load_acquire() or
> > similar.  And this one seems quite detached from anything.
> >=20
> > If I understand correctly, the possible race is between
> > svc_thread_wait_for_work which includes:
> >=20
> > 		llist_add(&rqstp->rq_idle, &pool->sp_idle_threads);
> > 		if (likely(svc_thread_should_sleep(rqstp)))
> >=20
> > and svc_stop_kthread which includes:
> >=20
> > 		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
> > 		svc_pool_wake_idle_thread(pool);
> >=20
> > The first sets ->sp_idle_threads.first and then checks SP_NEED_VICTIM
> > and the second sets SP_NEED_VICTIM and then checks
> > ->sp_idle_threads.first.
> >=20
> > So we need barriers to ensure the values are seen is the expected order.
> > Have I missed anything?
> >=20
> > llist_add() always calls try_cmpxchg() which is fully ordered, so no
> > extra barriers are needed there.
> >=20
> > There is no barrier between the set_bit)( and the READ_ONCE() in
> > svc_pool_wake_idle_thread(), so you added one.  I agree that is correct
> > and solves the problem.
> > But it is only this call to svc_pool_wake_idle_thread() that needs a
> > barrier, not all calls.  So I would prefer the barrier went in
> > svc_stop_kthreads().   Do you have a reason for not including it there?
> >=20
> > We do need a full memory barrier - a "release" on the set_bit and an
> > "acquire" on the test of ->sp_idle_threads.first
> >=20
> > I would be happy with smp_load_acquire(->sp_idle_threads_first) in
> > svc_pool_wake_idle_thread().  I'm not sure it is needed though.
> >=20
> > I would like set_bit_release(SP_NEED_VICTIM) in svc_stop_kthreads()
> > but we don't have that.
>=20
> It is on the way [11].
>=20
> [11] Subject: [PATCH 1/2] asm-generic/bitops: Add set_bit_release()
> https://lore.kernel.org/lkml/20261021095512.1345191-3-phasta@kernel.org/

Thanks for that pointer.  It helped me realise that I was wrong about
the sort of barriers needed.  A set_bit_release() would not help.
And an acquire on the subsequent read of sp_idle_threads also wouldn't
help.

A release is between two writes:
T1:
  foo =3D 1
  smp_store_release(&bar, 2)
puts a write barrier between the two.

An acquire is between two reads.
T2:
  y =3D smp_load_acquire(&bar);
  x =3D foo

These ensure that if T2 sees '2' in bar, it will definitely see '1' in foo.

But we don't have two reads or two writes, we have a write-then-read,
and that requires a full memory barrier.

So we would want set_bit_mb() (corresponding to smp_store_mb()).
As we don't have that,
   set_bit()
   smp_mb__after_atomic()

is the right way to fix this - acquire/release barriers would not be
effective.=20

As I noted, this is needed in both svc_wake_up() and
svc_stop_kthreads().

Thanks,
NeilBrown

=20
> > We could do
> >    atomic_long_fetch_or_release(BIT(SP_NEED_VICTIM), (atomic_long_t*)&poo=
l->sp_flags)
> > but that is ugly.
> >=20
> > So I think the best solution is
> >=20
> > 		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
> > 		/* Order SP_NEED_VICTIM before testing sp_idle_threads,
> >                  * matching svc_thread_wait_for_work() which orders
> >                  * setting sp_idle_threads before testing the bit
> > 		 */
> > +               smp_mb__after_atomic();
> > 		svc_pool_wake_idle_thread(pool);
> >=20
> > We probably need the same in svc_wake_up() after the set_bit().
> >=20
> > Does this make the barriers easier to understand?
> >=20
> > Thoughts?
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
> > >  	rcu_read_lock();
> > >  	ln =3D READ_ONCE(pool->sp_idle_threads.first);
> > >  	if (ln) {
> > >=20
> > > base-commit: b803428098f6fcd584db9f0499217b80e465bb34
> > > --=20
> > > 2.53.0
>=20

