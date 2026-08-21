Received: from flow-b3-smtp.messagingengine.com (flow-b3-smtp.messagingengine.com [202.12.124.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6947470E85;
	Fri, 21 Aug 2026 09:49:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.138
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787305788; cv=none; b=PK7cLHmjCESPqEvQ/iOWRDXYJ0v8XVATY/kkoEZm7daP524lvXeSGdxOGCSJdfOFObVGkp7vxkz2TJ2Hsm6NefBgTd0ey+trxVfj8JjLLH1MaSL18nQ4PTrovGzMJqmRbTnCNr53WpRMZwMAVWufhWYL2S7NYCakI13oKainrOY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787305788; c=relaxed/simple;
	bh=IrOnRU7YvMCe0BoU6uVgRl5JaiZ2kfQjdkmbuhOrw1A=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=X0NHjyoLJzacjnxmvvSUs2pYR0ry7yNPGePfUokrw9b3yrO/sR7UcO293igrf0+SC9jrDTh6SxCSQKvrpWS5/zwT4BCN/5ih18tJObV7xgH05A8Vll0nVPmoCrAwIPrWzvKk+E73Ss+CJXA+yg0/PIm6Rhpa9j9MMI/MsReWw8w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=TQgYGvEA; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=AVx2q5aB; arc=none smtp.client-ip=202.12.124.138
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="TQgYGvEA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="AVx2q5aB"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailflow.stl.internal (Postfix) with ESMTP id 365B51300097;
	Fri, 21 Aug 2026 05:49:34 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Fri, 21 Aug 2026 05:49:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787305774; x=1787312974; bh=LZN3dRb6O4n1DGanxgPGM96/L4jGpv+x2YP
	/J0/Rxx0=; b=TQgYGvEASDkb8prssEbYw4aE6jWw8kbTTMWT/DSLzpwVoWwd07g
	z2Te+ay6O/F7+lIQlunHmXBKO9HR+BB0dZGWW1G3B4Urb1l2YtJO/EgYiBQz7DZq
	ra0NleT7KIZv8A4wbefogWHmIJNIy/M878CJdxzDk+l+WI6geq2zU9Ylq7A37aJP
	5LpPfQtFaqEAdz+5FRBR2wDj1D1+tAJyIeZsRrMzApNzBeY5ErzZFH2TSrgtDI9i
	Wtq43rMkhGmzQfJFDWIsBbYWYF6T/9d9GsCizy0w9k7g5PbCf88Pr+z1yz5HBwFP
	Gns8kJqFIst/cekqcA+BR9R/FIbPMR3Z2vA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787305774; x=
	1787312974; bh=LZN3dRb6O4n1DGanxgPGM96/L4jGpv+x2YP/J0/Rxx0=; b=A
	Vx2q5aB2HoAph1TG77q9ZVmuJ76sAoWHob9Xqt/M23MGoTs834OczlotaLGn4g3H
	wD01vyUtk10r5bfS4z2Xrm/PpudoGo+5Y0iA63Upqd6rQtO6j2lSzpd9gvDEP9Yb
	l9RJOd2luneFA0gzGTWYKAIlzAvxX8oHQLE/celBhS8L9JIdAyJIBCwhYRU1iebO
	QfuxeFTWtzypAhw+i3Gzg9Rc5UrKrwt1pNnxGpmwIU6tnY/gdfU548td9AzbKL0K
	HjxPc4y4jbKUPpXJhoKGwK0m7JTLivG2LKRajbwoH5tcgnCyoEe3u0I0zsnfbfVm
	er3EQKefxJ7M+zdvrjF+w==
X-ME-Sender: <xms:KB-Ias7GcYORlk0h-K1Fnhi7hf1dHmDgHLxfgMlvfiF56u7eeTVolQ>
    <xme:KB-IanHF6Qx-UrqE6eO2Al3eAyQUPeFY-FnHy_gI86t0cjuGtrCkldHtmZFh-rTR4
    v4aaW7DqvlqUm512mSaPs2PxXLKZtSqECZ-U4tl49Lobbbrdg>
X-ME-Received: <xmr:KB-IagDxcGvbEa3W34gbgoowtf-BRKaRIsTwj51q7A_53YqPsPsN3WcWwHIWT62zr5F6icne32yyvk3dTYPzL-5Xz2tVLD8>
X-ME-Proxy-Cause: dmFkZTFeSKFYHiJq4UWC4aDuB8q+QTKUGTKsTWyXZx75ppwbCfO+Em+gmuTLp/uT/vsLX8
    R40CrvBGJHn6Z0PhtpUuW7xwr/8UnMo+lGV9fArWvYo8dDAS/BlySRUm7I6sX4713vD9bQ
    3z40r8nzxvuhOv3b4w2G11oaM0hHZuIwVuixEoVqAQgcxRgOMHXICYSpR2CpttRr+BdW+X
    tk9ighUyrbCqxcsrWrRqPfa8lTX4lyOF077NMVazBrdLInyMtTlmW/mBru8VIf8lDsvlba
    lGzBMkNbQe6eTlRiAbnikqUb5YjT/ikxbITh9yb6dmuxK/ACAYGMf2kUmjY8u58KGWV5TI
    +AuRAUrHq8VTLtipX4nu9hy6X3I2ElJlUoZpxAoSw5/Qd1F+tl6Y1rXYDBEaiImqr/sb83
    HVmroG1dMHhheiYZm/nIix4f49UD8clhm2DhI/ntDpEnVutlgCB/brjeurlqg1oIV4lFQu
    E+E8B34FX/62ft8/kiJhXk07B0FTyn/WRXxO8dJSd4xHs1161GY27ViXsF6mesd50wjFz1
    1ulzLV5An51Apg9CNqS3bpRWhkZFfzLT3fr7ovYXyk6LW0BtxRvAcM5txgBbwLs1YFUAGe
    bF66cROShtu9+RgJG5+1la+Q2fizk2x6IqVq1nBe05/tomjxVaxKizFdRJfg
X-ME-Proxy: <xmx:KB-IaiT4VSmlgKHPem5z79dLXELMfVvt9BTPPO0I08vWb5qF-Vq6RA>
    <xmx:KR-Ian5vxKM-dAx9mqgRKs5RJ8sVwPmleMD1IvPRoHPL9_yjH2JQDQ>
    <xmx:KR-Iaqln5zR4zsXKLtxToQ1wS7QeKa6hnAKWr5SW5kpdBiiuLsTuYw>
    <xmx:KR-Iaq4AUMCaanV3L-pPEd2je7wDv-EX-KHWhtGOw-MKJo_obx9OuQ>
    <xmx:Lh-IanlWRF41RYo5QKQb68muEG3GPSp1FO6Vvhb751LWSw8vAUZ9VRWu>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 21 Aug 2026 05:48:45 -0400 (EDT)
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
 torvalds@linux-foundation.org, damien.lemoal@opensource.wdc.com,
 linux-ide@vger.kernel.org, adilger.kernel@dilger.ca,
 linux-ext4@vger.kernel.org, mingo@redhat.com, peterz@infradead.org,
 will@kernel.org, tglx@linutronix.de, rostedt@goodmis.org,
 joel@joelfernandes.org, sashal@kernel.org, daniel.vetter@ffwll.ch,
 duyuyang@gmail.com, johannes.berg@intel.com, tj@kernel.org,
 tytso@mit.edu, willy@infradead.org, david@fromorbit.com,
 amir73il@gmail.com, gregkh@linuxfoundation.org, kernel-team@lge.com,
 linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org,
 minchan@kernel.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
 sj@kernel.org, jglisse@redhat.com, dennis@kernel.org, cl@linux.com,
 penberg@kernel.org, rientjes@google.com, vbabka@suse.cz,
 ngupta@vflare.org, linux-block@vger.kernel.org, josef@toxicpanda.com,
 linux-fsdevel@vger.kernel.org, jack@suse.cz, jlayton@kernel.org,
 dan.j.williams@intel.com, hch@infradead.org, djwong@kernel.org,
 dri-devel@lists.freedesktop.org, rodrigosiqueiramelo@gmail.com,
 melissa.srw@gmail.com, hamohammed.sa@gmail.com, harry.yoo@oracle.com,
 chris.p.wilson@intel.com, gwan-gyeong.mun@intel.com,
 boqun.feng@gmail.com, longman@redhat.com, yunseong.kim@ericsson.com,
 ysk@kzalloc.com, yeoreum.yun@arm.com, netdev@vger.kernel.org,
 matthew.brost@intel.com, her0gyugyu@gmail.com, corbet@lwn.net,
 catalin.marinas@arm.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com,
 luto@kernel.org, sumit.semwal@linaro.org, gustavo@padovan.org,
 christian.koenig@amd.com, andi.shyti@kernel.org, arnd@arndb.de,
 lorenzo.stoakes@oracle.com, Liam.Howlett@oracle.com, rppt@kernel.org,
 surenb@google.com, mcgrof@kernel.org, petr.pavlu@suse.com,
 da.gomez@kernel.org, samitolvanen@google.com, paulmck@kernel.org,
 frederic@kernel.org, neeraj.upadhyay@kernel.org, joelagnelf@nvidia.com,
 josh@joshtriplett.org, urezki@gmail.com, mathieu.desnoyers@efficios.com,
 jiangshanlai@gmail.com, qiang.zhang@linux.dev, juri.lelli@redhat.com,
 vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com,
 mgorman@suse.de, vschneid@redhat.com, chuck.lever@oracle.com,
 okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
 trondmy@kernel.org, anna@kernel.org, kees@kernel.org,
 bigeasy@linutronix.de, clrkwllms@kernel.org, mark.rutland@arm.com,
 ada.coupriediaz@arm.com, kristina.martsenko@arm.com,
 wangkefeng.wang@huawei.com, broonie@kernel.org, kevin.brodsky@arm.com,
 dwmw@amazon.co.uk, shakeel.butt@linux.dev, ast@kernel.org,
 ziy@nvidia.com, yuzhao@google.com, baolin.wang@linux.alibaba.com,
 usamaarif642@gmail.com, joel.granados@kernel.org,
 richard.weiyang@gmail.com, geert+renesas@glider.be,
 tim.c.chen@linux.intel.com, linux@treblig.org,
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
In-reply-to: <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
References: <20260706061928.66713-1-byungchul@sk.com>
  <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
  <20260821042143.GA40890@system.software.com>
  <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
Date: Fri, 21 Aug 2026 19:48:40 +1000
Message-id: <178730572084.2852630.7732425311008244683@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 21 Aug 2026, David Hildenbrand (Arm) wrote:
> [...]
>=20
> > Exactly.  That's why we use classification e.g. lock class - DEPT also
> > makes use of the concept.
> >=20
> > DEPT doesn't use a full map in each page but uses a minimum space for a
> > timestamp in each to track when each starts to wait so as to use the
> > recorded timestamp when the event occurs e.g. folio_unlock().
>=20
> Thanks for that information!
>=20
> >=20
> >> Given that lockdep is a debug feature, and we will at some point allocat=
e struct
> >> folio separately, I assume we could just squeeze a "struct lockdep_map" =
in there
> >> in such debug configs and the world would not collapse.
> >=20
> > That's a good news for lockdep.  (And even for DEPT :)
>=20
> He :) Where do you currently store the additional per-page information?

lockdep doesn't need to store per-page information.  Possibly DEPT
doesn't either.

lockdep needs one lockdep_map for each lock class.  It would make sense
for all folio locks to use the same global lockdep_map.

Each specific lock is known to lockdep as a task which holds the lock, a
lockdep_map which represents the class of locks, and subclass number
which allows a given task to hold multiple locks of the same class
providing it declare (e.g. with spin_lock_nested() etc).

>=20
> >=20
> >> Doing that today (one "struct lockdep_map" in each "struct page") wouldn=
't work
> >> as mm_zero_struct_page() would not expect such large "struct page". But
> >> conceptually, for a debug kernel with a special CONFIG_LOCKDEP_PAGE_LOCK=
, maybe
> >> that would already be ok and we could just do that (and optimize it as we
> >> allocate folios separately).
> >=20
> > Sounds great.
> >=20
> >> Not that it's ideal, but for a debug feature to at least check PG_lock, =
probably
> >> an easier way to achieve it than some completely new infrastructure.
> >=20
> > I understand what you are going to tell.
> >=20
> > However, it's worth noting that lockdep tracks dependencies basically
> > based on **lock acqusition orders** in the system.  To make it track
> > even rwlock and general synchronization mechanism as well, lockdep has
> > no choice but to get more complicated.
>=20
> Well, yes, sure :)
>=20
> >=20
> > Focusing on only the dependency checking, the most parts of lockdep are
> > for the tricky things, so the reusable parts are not that big.
> >=20
> >> Now, Willy said "locking rules don't really apply to individual folios",=
 I
> >> wonder if that could just help to also let lockdep check PG_lock with le=
ss
> >> metadata? (didn't fully wrap my head around the implications)
> >=20
> > That's what DEPT did and what brought external wgen introduced in DEPT.
> > I was considering the exactly same thing :)
> >=20
> > Again, lockdep that tracks lock acquisition orders can't do that.
> >=20
> >> [1]
> >> https://lore.kernel.org/all/aR3WHf9QZ_dizNun@casper.infradead.org/?utm_s=
ource=3Dchatgpt.com
> >>
> >>
> >> It's your guiding example, that's why I mention it. You do mention other=
 wait
> >> cases here, I don't know anything about them, but for folios it's really=
 just
> >> "we used a single bit so far" AFAIKs.
> >=20
> > It doesn't matter whether it's implemented using bit or not.  folio lock
> > is quite special since it's allowed to be released other than the
> > acquisition context that makes lockdep impossible to track them.
>=20
> Does that really make lockdep *impossible* to track them? IOW, there is no =
way
> to extend lockdep to support lock release in different context?

Yes and no....

lockdep has no knowledge of control flows moving across threads in the
way that I assume DEPT does.  But it should be possible to tell it.

If you have some code that takes a lock and then hands it off to
another thread, at the hand-off point you call
   lock_map_release(&the_lock_map)

This says "no task owns this lock any more".

maybe you put the folio which is locked on a queue or an lru or
whatever.

There is no way to say "that queue owns this lock".  Maybe that could
usefully be added - assuming coherent semantics can be designed.

Somewhere else some other task takes responsibility for that folio and
the lock.  maybe it dequeues a page, or maybe an lru callback gives the
locked page to some code.
That code then calls
   lock_map_acquire_try(&the_lock_map)

This says "this task is now holding this lock" (or more accurately "now
holding a lock of this class").
Note the "_try" - that says that the task didn't have to wait for the
lock, it just got it for free, which in fact it did.

Now if that task takes some other lock, lockdep will see a dependency
between the page lock and the new lock, and will accept or reject it as
you would expect.

So you definitely *can* send lock dependency information between tasks
with lockdep.  I have only tried it in extremely simple cases where a
single object is being locked by one task and unlocked by another - no
queues or lists.
There may be - and probably are - more complexities involved with
locking folios and passing them around.  Maybe it is so complex that you
need all the support that DEPT provides.  But I'd like to see a coherent
explanation of how the functionality offered by DEPT is clearly better.

NeilBrown

>=20
> I guess there is a way, but the question is at which price (I seriously hav=
e no
> idea, maybe this was already discussed and people have a pointer for me).
>=20
> >=20
> >> [...]
> >>
> >>>
> >>> Q. Why not build DEPT into lockdep?
> >>>
> >>> A. Lockdep is stable, battle-tested code. I chose separation because
> >>>    while DEPT borrows BFS and hashing ideas, the wait/event model
> >>>    requires rebuilding from scratch. Lockdep was designed for lock
> >>>    acquisition order =E2=80=94 retrofitting it would risk its stability.
> >>
> >> Why can't this just be some configurable extension to lockdep
> >> (CONFIG_LOCKDEP_XYZ) until the feature is stable and can unconditionally=
 be
> >> enabled along with it?
> >=20
> > Answered?
>=20
> Not quite. I don't understand why this must be a completely separate machin=
ery,
> even if, conceptually, it would do more than traditional lockdep.
>=20
> Is it either DEPT or LOCKDEP in current configurations? Can both run at the=
 same
> time?
>=20
> >=20
> >> I don't quite buy the "would risk its stability" argument. A lot of stuf=
f we do
> >> "risks stability", every day :)
> >=20
> > That's awsome anyway :)
> >=20
> >> Is there another good reason (incompatible with X, dangerous with Y, cin=
fusing
> >> Z) why this really must be a separate thing?
> >=20
> > Roughly:
> >=20
> >    1. Similar or less effort is needed for the new one - retrofitting
> >       lockdep is not easy and big changes are required since the
> >       reusable parts are not that big.
> >=20
> >    2. Even though you didn't agree, retrofitting it would risk its
> >       stability.
>=20
> Well, I don't buy the stability argument, really :)
>=20
> Retrofitting effort for lockdep is an interesting point, though. Lockdep
> maintainers would have to make the call here regarding direction and feasib=
ility.
>=20
> [...]
>=20
> >> But I am not a locking maintainer. I think there was plenty of discussio=
n in the
> >> past, so I might just be raising points that were already discussed in t=
he past,
> >> but I really just read some random pieces of earlier discussions. (ideal=
ly
> >> previous discussions would be summarized here)
> >>
> >> Long story short: we are now in v19 and I think there was pushback in th=
e past.
> >> Did the opinion of locking maintainers change, or is there a way forward=
 to
> >> integrate this in a way that would make locking maintainers accept this?
> >=20
> > One of locking maintainers who I met in an LPC told me that he agrees
> > with the direction of DEPT and supports DEPT, not officially tho.
>=20
> Hm.
>=20
> >=20
> > What he and other people are concerning w.r.t DEPT the most is, false
> > positives, which is the most important issue for now.
>=20
> Thanks for highlighting that. What's the main reason for false positives? I=
s it
> something conceptual that is mostly impossible to solve, or rather just
> implementation work to cover all edge cases?
>=20
> >=20
> > At the same time, I think the most important thing is to make DEPT
> > useful in practice especially with folio locks involved.  Actually, I'm
> > planning to share DEPT's true reports periodically to LKML and work with
> > people who believe DEPT can make things better.
> >=20
> > Any advices will be welcome.  Thanks for your opinions.
>=20
> I think we must come to some conclusion on how to proceed with DEPT. I see =
the
> following options:
>=20
> (1) Don't merge it and carry it OOT. Shame if it delivers real value.
>=20
> (2) Merge it (after proper review and acks from relevant maintainers ;) ),
>     keeping it entirely separate from lockdep.
>=20
> (3) Integrate it with lockdep on a high level, giving us a single locking
>     dependency checker, but mostly letting dept have a separate implementat=
ion.
>     Look into possible merging afterwards.
>=20
> (4) Retrofit and extend lockdep to really have one mechanism.
>=20
> As the saying goes, it's hard to teach old dogs new tricks, but in the end
> taking care of two dogs is likely harder than only a single dog? :)
>=20
> I tend to favor (4) (or 3 with possible future work to achieve 4), but I am=
 not
> a locking maintainer, so really they have to voice what to do.
>=20
> I do see value in DEPT (even if the folio lock might be handled differently=
).
>=20
> --=20
> Cheers,
>=20
> David
>=20

