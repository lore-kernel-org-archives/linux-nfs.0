Received: from flow-b1-smtp.messagingengine.com (flow-b1-smtp.messagingengine.com [202.12.124.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D266230BE9;
	Mon, 24 Aug 2026 23:38:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.136
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787614713; cv=none; b=f81l4PuBLf1DTWM6S/1jLrYyr2/KQEWz9PJ5natbKwMmf7D2d5MmIqpOfKOIlPKv95Gzb12MDqzEg3cZsNd69/q51m9cCZXV8eAbllPUEpVMmivGHOx/ziZN6DdY8tCB5PLK44MWqDnlBrsKj1LMmjpgFx/uQ7r23ghMGp4iw8E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787614713; c=relaxed/simple;
	bh=zNXZSfRmtwpy/a/iBRxK6ZOuQXHjxvf/jrS/UpDVoZE=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=njbh5i0VGCqizvFVGDDzCpIq/E4hgLzSyWm/tWvgvV0kL/PHx/KyhaNxop+Gpp+F2Dun3faTfehE1hZntGIqzxFg9P0KHiUsJIciBJgnkSuw1O2d/erGVV4/2ba5JThegASeQspcwHBb6Je2Kr/FRvoCyDTkyRerdmKtvFFj7TY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=XBhGMGf0; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=IlzNSJWi; arc=none smtp.client-ip=202.12.124.136
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="XBhGMGf0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="IlzNSJWi"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id 2D1D01300083;
	Mon, 24 Aug 2026 19:38:26 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Mon, 24 Aug 2026 19:38:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787614706; x=1787621906; bh=1ks+pZPsMFw/dX/SaAC+B9uhzl7GasUHVZ9
	HfOG6GYI=; b=XBhGMGf07QdE2qp575VTBn2lqjfeSn8rsfkfLCsM/Oyww79wzpr
	ApE3lQnrKoKXPaR0AbukURBDsEpzjpZweEngjZwwjsdH9qRwACpaeJanhQMFIhCr
	dL3/dlnRNmyY2j2u+W+CipVxCIJb6vhNXP2C4CkNEGyZlipst9/MLs7k5gSRn+SN
	0quDrwjC2k2VRQGqs+zwgB/delGuW8VyU+zGtcxaHB1sn6ywd60as4c7iW0EPzSE
	92xvuUYOrQEshiIW/INtUWY7tI7Bwmm7colbKFqt8Q5QGdrch76Fr7Plgw62Rqyr
	Jv6QgWDRLEDm/DeYpdwqJ+h+XUAg+043sSw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787614706; x=
	1787621906; bh=1ks+pZPsMFw/dX/SaAC+B9uhzl7GasUHVZ9HfOG6GYI=; b=I
	lzNSJWico+svMdus2gBAc3HIZDjiFr3cckIgnsASVB4TdasKY3A7/axRo3a8Dlu8
	UmIPoTkwXXQFiIUQavHV3nTdGVcPGawQ+n+YgCa1oiUwsu1VUziOY7oMW0Lvfa2T
	wmasGsZCKt9ahl1HWHHWhZYKGUMx+a1Fpq8mWL4iBSbnzjAYIsyb/btw0r2MoUh7
	zvLeWL3H2dn7Kz2xakvXBkOQaQ4rZWbWkpTFHaOEJ6bUsKCCuNX2HfvNCC/w40AJ
	kMFcNkAPwwJjPvtCGWrAft+YK2E7UoCvGd1cQjqbOm4YgcGP1sXFBqNBvmEIKRgJ
	cVTPKjQmGCi0BcJWxcFKQ==
X-ME-Sender: <xms:6tWMao3MGXfEgZ2hm2rhJ71A-6ZVub-9zpOsoFZN2tiw6iThTBuwzQ>
    <xme:6tWMaj7LeLQe0L41ggA0tcRjTkl9-GpsxTnxiTGYyYN5yIAzniuLbkD6EQECYCsEK
    7Mzb2xbWmZiJbLOhwCmDXxyCQmmc8ItDh28Twvl1zl3UUIbdA>
X-ME-Received: <xmr:6tWMaq0AmSmgSL256G9_XnlUhr7KJ5Y6VaebmpSrnHeHBRVqGKgfoc5ceuuKsFRFQtRz2tJPuSvfafSrKm5R8VcBJIxJ-dg>
X-ME-Proxy-Cause: dmFkZTFrEmQssS56tdgzvy9yebBt5E0gIk2nhGFkQJdPkBb8h8m7nM4ZqL1LHvw+mehMwh
    SuskV2FjoEkeI+MG8HTwFAriu5Q6OkP/hQVA5ynEUh3wAYbRSBZIsgskB8Fx4Wcz8GJ310
    UDJQteufz/bw/Bw4Zubkj9pGGvYWCVB2usE09lF2iKKwZ51xN7XwzuON1GjKoLgtSooAPS
    Z8k0+xsDpc6+7r0zmKuwWWaa04PYjqkjOaRrvBIcWl6EZWvN462VRhzf4aa4qLvSyuJgiX
    IxiZbGoL6xvgKgowADVQoe0bCo/iQpSX/L/ODuY4BqB3a5cgRS/Pv/It4YpoMEFrrnb4S4
    xaHdANv5XmZhj5jUtQUM+tbBd3v3vyobnvGmKS8r6iIefPGgdZ6m7FkjfOkUwwxardZIBF
    ov3rXrrjWY4LqAMHQGxdQF0tf9e2+LhvSHn4O0tUUhDCb7/X1NX7HV0RpQR4HyUwIb2hST
    /fLf3kKA3KLnmOzPSg1CrvY3neXXPTpIeB4LH2wU8TpCHMiW/VGkYoQvDHsb1+g6V5qAzm
    w2khMNxTKBB0iEhJ5JIuexGlH+74WbRFJbR2/Yo2fV83CG5jiE1w5XKkTwMMd3XsHCynVm
    mj24vQMvXowNJqDWzd2Bq4Pbj4dLEIMXsFcPpSxJimaXGcg56pIfSKtLhp/w
X-ME-Proxy: <xmx:6tWMaufjzla0ip1qs-FrtSacwDRI3EAzO1bOezUmuRVGRnFnBS7RMA>
    <xmx:6tWMaoU519ST5ee1SE38PMgk1GORN1rpC2xttFjtO_OI0yK7o9XM1A>
    <xmx:6tWMaglJLrawf2a_NkBTlQ5UlrLCBmgEBzrfq0Yg3tigyBrWdxQ-eg>
    <xmx:6tWMapZO_qV_XfrR3y1XelcvL6bR7AlBBrT5_bVrVIjnPfrWBW0m0A>
    <xmx:8tWManlmlHzgk4wctTycNwj4xlJ5R-159qG6IeaQBCmxaIJGdyiqoABK>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 24 Aug 2026 19:37:38 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: "Byungchul Park" <byungchul@sk.com>, linux-kernel@vger.kernel.org,
 max.byungchul.park@gmail.com, kernel_team@skhynix.com,
 torvalds@linux-foundation.org, linux-ide@vger.kernel.org,
 adilger.kernel@dilger.ca, linux-ext4@vger.kernel.org, mingo@redhat.com,
 peterz@infradead.org, will@kernel.org, tglx@linutronix.de,
 rostedt@goodmis.org, joel@joelfernandes.org, sashal@kernel.org,
 daniel.vetter@ffwll.ch, duyuyang@gmail.com, johannes.berg@intel.com,
 tj@kernel.org, tytso@mit.edu, willy@infradead.org, david@fromorbit.com,
 amir73il@gmail.com, gregkh@linuxfoundation.org, kernel-team@lge.com,
 linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org,
 minchan@kernel.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
 sj@kernel.org, jglisse@redhat.com, dennis@kernel.org, cl@linux.com,
 penberg@kernel.org, rientjes@google.com, vbabka@suse.cz,
 ngupta@vflare.org, linux-block@vger.kernel.org, josef@toxicpanda.com,
 linux-fsdevel@vger.kernel.org, jack@suse.cz, jlayton@kernel.org,
 hch@infradead.org, djwong@kernel.org, dri-devel@lists.freedesktop.org,
 rodrigosiqueiramelo@gmail.com, melissa.srw@gmail.com,
 hamohammed.sa@gmail.com, harry.yoo@oracle.com, chris.p.wilson@intel.com,
 gwan-gyeong.mun@intel.com, boqun.feng@gmail.com, longman@redhat.com,
 yunseong.kim@ericsson.com, ysk@kzalloc.com, yeoreum.yun@arm.com,
 netdev@vger.kernel.org, matthew.brost@intel.com, her0gyugyu@gmail.com,
 corbet@lwn.net, catalin.marinas@arm.com, bp@alien8.de, x86@kernel.org,
 hpa@zytor.com, luto@kernel.org, sumit.semwal@linaro.org,
 gustavo@padovan.org, christian.koenig@amd.com, andi.shyti@kernel.org,
 arnd@arndb.de, lorenzo.stoakes@oracle.com, Liam.Howlett@oracle.com,
 rppt@kernel.org, surenb@google.com, mcgrof@kernel.org,
 petr.pavlu@suse.com, da.gomez@kernel.org, samitolvanen@google.com,
 paulmck@kernel.org, frederic@kernel.org, neeraj.upadhyay@kernel.org,
 joelagnelf@nvidia.com, josh@joshtriplett.org, urezki@gmail.com,
 mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com,
 qiang.zhang@linux.dev, juri.lelli@redhat.com, vincent.guittot@linaro.org,
 dietmar.eggemann@arm.com, bsegall@google.com, mgorman@suse.de,
 vschneid@redhat.com, chuck.lever@oracle.com, okorniev@redhat.com,
 Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org, anna@kernel.org,
 kees@kernel.org, bigeasy@linutronix.de, clrkwllms@kernel.org,
 mark.rutland@arm.com, ada.coupriediaz@arm.com,
 kristina.martsenko@arm.com, wangkefeng.wang@huawei.com,
 broonie@kernel.org, kevin.brodsky@arm.com, dwmw@amazon.co.uk,
 shakeel.butt@linux.dev, ast@kernel.org, ziy@nvidia.com,
 yuzhao@google.com, baolin.wang@linux.alibaba.com, usamaarif642@gmail.com,
 joel.granados@kernel.org, richard.weiyang@gmail.com,
 geert+renesas@glider.be, tim.c.chen@linux.intel.com, linux@treblig.org,
 alexander.shishkin@linux.intel.com, lillian@star-ark.net,
 chenhuacai@kernel.org, francesco@valla.it, guoweikang.kernel@gmail.com,
 link@vivo.com, jpoimboe@kernel.org, masahiroy@kernel.org,
 brauner@kernel.org, thomas.weissschuh@linutronix.de, oleg@redhat.com,
 mjguzik@gmail.com, andrii@kernel.org, wangfushuai@baidu.com,
 linux-doc@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-media@vger.kernel.org, linaro-mm-sig@lists.linaro.org,
 linux-i2c@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-modules@vger.kernel.org, rcu@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-rt-devel@lists.linux.dev,
 2407018371@qq.com, dakr@kernel.org, miguel.ojeda.sandonis@gmail.com,
 bagasdotme@gmail.com, wsa+renesas@sang-engineering.com,
 dave.hansen@intel.com, geert@linux-m68k.org, ojeda@kernel.org,
 alex.gaynor@gmail.com, gary@garyguo.net, bjorn3_gh@protonmail.com,
 lossin@kernel.org, a.hindborg@kernel.org, aliceryhl@google.com,
 tmgross@umich.edu, rust-for-linux@vger.kernel.org
Subject: Re: [PATCH v19 00/40] DEPT(DEPendency Tracker)
In-reply-to: <3d58eb3c-7a9d-4183-907b-46172664631c@kernel.org>
References: <20260706061928.66713-1-byungchul@sk.com>
  <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
  <20260821042143.GA40890@system.software.com>
  <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
  <178730572084.2852630.7732425311008244683@noble.neil.brown.name>
  <3d58eb3c-7a9d-4183-907b-46172664631c@kernel.org>
Date: Tue, 25 Aug 2026 09:37:34 +1000
Message-id: <178761465493.3510150.12380729360578969391@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 25 Aug 2026, David Hildenbrand (Arm) wrote:
> Hi!
>=20
> >>>
> >>> That's a good news for lockdep.  (And even for DEPT :)
> >>
> >> He :) Where do you currently store the additional per-page information?
> >=20
> > lockdep doesn't need to store per-page information.  Possibly DEPT
> > doesn't either.
>=20
> That would be even better.

A little bit more on this:
 lockdep *does* store per-lock information - a "struct lockdep_map".
 I don't fully understand how it is used, but it seems to be mostly
 for convenience and performance.
 When you lock something, lockdep need to know what class the lock
 belongs to.  The lockdep_map maps from the lock to the class so the
 caller doesn't have to explicitly identify the class every time.
 The lockdep_map also contains a "name" and some wait_types which I
 *think* are only used for more descriptive error messages.
 There is also a "class_cache" which makes it easier (faster) for lockdep to
 find the target class for different subclasses.

 rhashtables "bucket_table" is an existence proof there there doesn't
 need to be a lockdep_map for each lock.  Every bucket has its own
 bit-spin-lock, but there is only one lockdep_map that they all shared.

 You could conceivably put a lockdep_map in each "struct address_space"
 for folio locks (assuming all lockable folios still belong to some
 address_space).

>=20
> [...]
>=20
> >=20
> > maybe you put the folio which is locked on a queue or an lru or
> > whatever.
>=20
> For readahead, I think that queues / lru are not involved. We submit the I/=
O,
> and once the I/O is done, we unlock the folio from interrupt context.

"submit the I/O" means "attach the page to a "struct bio" (or similar)
and attach the struct bio to a transmit queue for the device (or
similar).  So there really is a queue.

>=20
> end_buffer_async_read() / iomap_finish_folio_read() end up calling
> folio_end_read(), where we do the magic
>=20
> 	folio_wake_bit(folio, PG_locked);

Exactly where the lock ownership should be reclaimed is not immediately
clear to me.  bio_endio() might be early enough but there are probably
better points.

A small difficulty here is that a bio has multiple folios and they are
all locked.  I cannot see that lockdep has a concept of holding an
arbitrarily large set of related locks.
We could just tell lockdep=20
  "I have some folios locked"=20
or maybe enhance lockdep to allow
  "I have N folios locked"
or even
  "I have N folios in address-space A with the highest offset being O".

This would allow lockdep to check the validity of locking another folio
- only allowed if the address space is the same and the offset is larger
than the previous largest.

>=20
> It's interesting, that for writeback we never unlock the folio on the I/O p=
ath,
> but instead have the dedicated page flag to tell us when writeback is compl=
ete.

PG_locked and PG_writeback are two different lock-bits with two
different meanings.
When a folio is PG_locked the content is invalid and shouldn't be accessed.
When a folio is in PG_writeback its data is not safe even though
PG_dirty has been cleared (if I remember correctly).

So these are two separate, though related, lock bits that would both
need to be tracked.  lockdep would detect how they are related.

>=20
> >=20
> > There is no way to say "that queue owns this lock".  Maybe that could
> > usefully be added - assuming coherent semantics can be designed.
> >=20
> > Somewhere else some other task takes responsibility for that folio and
> > the lock.  maybe it dequeues a page, or maybe an lru callback gives the
> > locked page to some code.
> > That code then calls
> >    lock_map_acquire_try(&the_lock_map)
>=20
> I'd assume that's what the unlock path would do from interrupt context.

exactly.

>=20
> >=20
> > This says "this task is now holding this lock" (or more accurately "now
> > holding a lock of this class").
> > Note the "_try" - that says that the task didn't have to wait for the
> > lock, it just got it for free, which in fact it did.
> >=20
> > Now if that task takes some other lock, lockdep will see a dependency
> > between the page lock and the new lock, and will accept or reject it as
> > you would expect.
>=20
> I guess on the interrupt path, we primarily unlock the folio lock only. But=
 we
> might take some other spinlocks temporarily indeed, like
> iomap_finish_folio_read() does.

Yes.  It is hard to see there being locking problems in interrupt
handlers as the folio locks are sleeping locks and an interrupt handler
can only take atomic locks, so getting the ordering wrong is likely
impossible.

You would be more likely to see problems in a workqueue which takes the
completely IO and does something with it, maybe verify a checksum or
whatever (it is a long time since I've worked in the block layer).

>=20
>=20
> >  But I'd like to see a coherent
> > explanation of how the functionality offered by DEPT is clearly better.
>=20
> Yes, that's also what I am missing.
>=20
> Stating that lockdep is stable and should not be destabilized is not really=
 a
> good argument.

No it is not.  We change "stable" things all the time.  Replacing one
big thing with another big thing is almost always rejected.
Incremental development is the preferred approach.
So developing something like DEPT to explore and learn and demonstrate
a cool idea is great.  Making it completely separate can give a
developer freedom to innovate.
But the path from there to upstream acceptance is to take the lessons
learned and to apply them one by one to the existing tools.
Yes, that takes longer.  Yes it can be frustrating.  Yes you need to
be able to work with people - not just code - to bring the community
along with you.
But the result is generally much better.

Thanks,
NeilBrown


>=20
> --=20
> Cheers,
>=20
> David
>=20

