Received: from flow-b5-smtp.messagingengine.com (flow-b5-smtp.messagingengine.com [202.12.124.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 435E730EF89;
	Sun, 30 Aug 2026 23:10:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788131422; cv=none; b=DlSpe2/hSBv2/iDsx5PUP/uHvyac5slQpDC8zxlLERIIP71lJv2dv+wWz1xm4MFl9e5d196ii8YwRIRQiqw3ZxtzLy70GPofdimYQ64Q0HukMBQRHsvANz5+mMgNfgeW8s2qjXE5hJkJZbJm3+9QmpCFdtiIbcm580J7SCOI1+w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788131422; c=relaxed/simple;
	bh=Ntb372e/rWIeBr1J4NjUE3vuIDUZz1AUEM6kRXEBLvA=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=DNxN6ZRXTSRF6BSj5LSnd/NMQIHjoi8xch+9yUq/o0n2KyPhvW5M8k6q16VvuFcd+ifjHo6+ol92jEd2yWs+UJKRQAxbmWjw4YyyTLEY6Gjg2VykBeihmk/VuvU+n2LwW1+Qg5XLk7YufASniVqzEaQ8O4H6wJlp41yQpJ6hHGY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Qo6ieQvu; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=VPm/7Fhe; arc=none smtp.client-ip=202.12.124.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Qo6ieQvu";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VPm/7Fhe"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id E9FB813001B0;
	Sun, 30 Aug 2026 19:10:14 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Sun, 30 Aug 2026 19:10:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1788131414; x=1788138614; bh=zEc5hZJIk8YRnx+J+eo4+Y3sVspDxogbjvE
	EZwuJ7rQ=; b=Qo6ieQvuNCpEAFNGUhEaIGd1tM2qenglCvyZhQAtLYcKgEz5uZv
	VBkmAHxWVjh7GITNYGQRuizAhYS66fu/QSC2e7UCmgPz4kXTk5AkzcfuRQnlVFRP
	obCI4MlwXEShM2SHCHkmDlPo5XISgTzwCrpLP/3SjKxujKlWi9nqvG6db9p/iXJV
	OpWFgdf4BeBSzTD8k+jOmUwdbzP/2FzRQ2JsA+NRYO/Wb8e+aEbOrBj5DJeqKV4F
	mo0lR8bF74G8iO9YI3oa5e0UEi/LrPdRcv9f2BM5MbieoQLkdq9lj0/U9rjqixab
	TWu+hSlLYlUN95axFhjHuP3dfSYVVt6XzGA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1788131414; x=
	1788138614; bh=zEc5hZJIk8YRnx+J+eo4+Y3sVspDxogbjvEEZwuJ7rQ=; b=V
	Pm/7FheSQWTuf0BTxlWwZtt+3pYz2nhduLw4e4y8za/QfTSzRWzNLT9xWYuPmAIc
	u2iScyJLSttTa87WeCPnCZXn/Gl2gPZabiNI/TusdTrg2rxoLAc/VMFiqpkhoR6S
	LQ0iKTcxz3hk+DwmEohzGehsn/5Wh1AzucxvOgw+WnDShRgf/uBTnxZEvQeejUv4
	uiy25ACTvijKoXphHgt82oizR4gYVdqyJePgq/uKO/Q8l7aBEXKtFaecz0P2KuDW
	NPFfEanh10Tr4PIAw9/Ttp6lzVA7Tw5SgfgV5/JqbWCARVUi3EaZbxN01GMjB+kI
	lCRwskirVvl7AMPYTRbWw==
X-ME-Sender: <xms:UbiUap_MtTSeFpMNORlr4wTWDVh0aA6ScnON58j3rpFyccMpDXHIBQ>
    <xme:UbiUahH2TNeUk63s7BMkgYDKvmxeqjrvmkBoHgCp0p_iRIhMT_WV7fRvdL5DfgV9Z
    xV8KqlrCQaK0hplET15otnZI5BE2coA-O7f7PR3q4bp8VG_>
X-ME-Received: <xmr:UbiUagJhhsp10jRM39PBdQWH_D435G2njFRNXy8dKyREtIAZmuZC2LqatWjo_-5YIsgSO4CAuvUBwdlLl9RmrRBi5dPRqwg>
X-ME-Proxy-Cause: dmFkZTFOIUHJLQqborIagOgmNN+pPcupbVotrH4sXk/9BxNtfHYUJG+jOdd9lP23wPqSUQ
    AUFqozauDGsFj2Fcxtj3sABYHvl0ph+0UXejznX6q1Xr1Xg/U0V2IT+Tk94c9p2xCxdGcm
    a9fTqsnIiGGjKyH3aovg7Hbw39SYODzd4xSmoty3roVPn9gC8PR9IGrItxoJJkl5Z9SeqL
    qN1gQzMRLAf1DVi5pqAy+RVGbsxy3biNw6Ht0LFpwq7yHA4P1bo1DCXcT6AbluvZMKn1Ad
    6oUtTqY8wpxkXvPNqdcZVzXrArQI+dyTirjeQU9xaq2PAci/BLvZmkKdn6HOgCF/wiNDR5
    9ypjS27kIioFVXtCK3cYVV4EX87YiMJFRv1YmG81V/CBOpPEVGlHijee21VZbsDPuWUWT2
    eIkpdBbOecXlENZwKR/2eekW+LLYVEGcUat3eiQbHa7r5NCiXFUSvoh9n0m66Cfn6MPY8F
    nn+/UAVo+bSz0lZ0FMnWAjcbwosDDLMUFcjHtb2oWyUdokurmOw1uyWf9PuZC23xX1bhno
    M6fmT9hcOCYeC8ptuK39TgThobX4Z06It4CZvTdsheRb100K9ulRUQKwJiTqPv3ZqMrr5g
    wtS1gF+w0PemKcSEjYqBuy5LHyuHib4TgEnaucnWv4jXuwuB92nJE5Nsi6mg
X-ME-Proxy: <xmx:UbiUah47CBbO19kbrhNmEsPxHAHgpefoYPnpR5z-_ohOrh1cCgC-Dg>
    <xmx:UbiUalPzSFg1nYeOw2R5sG3wTQxx6Y0zUwyNG3X2kHwPHQNKUtVYuw>
    <xmx:UbiUaprYVwmp1o7kh4B5Ol26B9junaQQXQMqO5xX3y2ZMifwxkjWAA>
    <xmx:UbiUaseNryne3JEtbfGoTy-pA0krO1YyMhJ9fCu36NsZC9i9Dd6f2g>
    <xmx:VriUatkHi2UuWhglcFHVNe1ttc7HDvYZlla8FaR0rvxatg4WTOf727px>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 30 Aug 2026 19:09:27 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Byungchul Park" <byungchul@sk.com>
Cc: "David Hildenbrand (Arm)" <david@kernel.org>,
 linux-kernel@vger.kernel.org, max.byungchul.park@gmail.com,
 kernel_team@skhynix.com, torvalds@linux-foundation.org,
 damien.lemoal@opensource.wdc.com, linux-ide@vger.kernel.org,
 adilger.kernel@dilger.ca, linux-ext4@vger.kernel.org, mingo@redhat.com,
 peterz@infradead.org, will@kernel.org, tglx@linutronix.de,
 rostedt@goodmis.org, joel@joelfernandes.org, sashal@kernel.org,
 daniel.vetter@ffwll.ch, duyuyang@gmail.com, johannes.berg@intel.com,
 tj@kernel.org, tytso@mit.edu, willy@infradead.org, david@fromorbit.com,
 amir73il@gmail.com, gregkh@linuxfoundation.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, mhocko@kernel.org, minchan@kernel.org,
 hannes@cmpxchg.org, vdavydov.dev@gmail.com, sj@kernel.org,
 jglisse@redhat.com, dennis@kernel.org, cl@linux.com, penberg@kernel.org,
 rientjes@google.com, vbabka@suse.cz, ngupta@vflare.org,
 linux-block@vger.kernel.org, josef@toxicpanda.com,
 linux-fsdevel@vger.kernel.org, jack@suse.cz, jlayton@kernel.org,
 dan.j.williams@intel.com, hch@infradead.org, djwong@kernel.org,
 dri-devel@lists.freedesktop.org, rodrigosiqueiramelo@gmail.com,
 melissa.srw@gmail.com, hamohammed.sa@gmail.com, chris.p.wilson@intel.com,
 gwan-gyeong.mun@intel.com, boqun.feng@gmail.com, longman@redhat.com,
 yunseong.kim@ericsson.com, ysk@kzalloc.com, yeoreum.yun@arm.com,
 netdev@vger.kernel.org, matthew.brost@intel.com, her0gyugyu@gmail.com,
 corbet@lwn.net, catalin.marinas@arm.com, bp@alien8.de, x86@kernel.org,
 hpa@zytor.com, luto@kernel.org, sumit.semwal@linaro.org,
 gustavo@padovan.org, christian.koenig@amd.com, andi.shyti@kernel.org,
 arnd@arndb.de,  Liam.Howlett@oracle.com, rppt@kernel.org,
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
 linux-doc@vger.kernel.org, linux-media@vger.kernel.org,
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
In-reply-to: <20260825130843.GB23086@system.software.com>
References: <20260706061928.66713-1-byungchul@sk.com>
  <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
  <20260821042143.GA40890@system.software.com>
  <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
  <178730572084.2852630.7732425311008244683@noble.neil.brown.name>
  <20260825130843.GB23086@system.software.com>
Date: Mon, 31 Aug 2026 09:09:23 +1000
Message-id: <178813136354.3510150.4730256876703029797@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 25 Aug 2026, Byungchul Park wrote:
> On Fri, Aug 21, 2026 at 07:48:40PM +1000, NeilBrown wrote:
> > On Fri, 21 Aug 2026, David Hildenbrand (Arm) wrote:
> > > [...]
> > >
> > > > Exactly.  That's why we use classification e.g. lock class - DEPT also
> > > > makes use of the concept.
> > > >
> > > > DEPT doesn't use a full map in each page but uses a minimum space for=
 a
> > > > timestamp in each to track when each starts to wait so as to use the
> > > > recorded timestamp when the event occurs e.g. folio_unlock().
> > >
> > > Thanks for that information!
> > >
> > > >
> > > >> Given that lockdep is a debug feature, and we will at some point all=
ocate struct
> > > >> folio separately, I assume we could just squeeze a "struct lockdep_m=
ap" in there
> > > >> in such debug configs and the world would not collapse.
> > > >
> > > > That's a good news for lockdep.  (And even for DEPT :)
> > >
> > > He :) Where do you currently store the additional per-page information?
> >=20
> > lockdep doesn't need to store per-page information.  Possibly DEPT
> > doesn't either.
>=20
> Class can be stored in global map, but DEPT needs to keep a timestamp
> in each page to track when a potential-wait e.g. folio_lock() has been
> started and to refer to the information on its event e.g. folio_unlock().

A timestamp?  What does that do?
There is a lot of detail in your cover letter, but I think there is a
lot missing too.  I would like to understand how DEPT works, but I don't
want to dig too hard.  The document in patch 25/40 helps a bit, but it
is still a bit vague.
Where is the document which would explain at a level that would help me
understand this timestamp?

>=20
> > lockdep needs one lockdep_map for each lock class.  It would make sense
> > for all folio locks to use the same global lockdep_map.
>=20
> Exactly.  Only considering classes, you are right.
>=20
> > Each specific lock is known to lockdep as a task which holds the lock, a
> > lockdep_map which represents the class of locks, and subclass number
> > which allows a given task to hold multiple locks of the same class
> > providing it declare (e.g. with spin_lock_nested() etc).
>=20
> Right, lockdep works that way.
>=20
> > > >> Doing that today (one "struct lockdep_map" in each "struct page") wo=
uldn't work
> > > >> as mm_zero_struct_page() would not expect such large "struct page". =
But
> > > >> conceptually, for a debug kernel with a special CONFIG_LOCKDEP_PAGE_=
LOCK, maybe
> > > >> that would already be ok and we could just do that (and optimize it =
as we
> > > >> allocate folios separately).
> > > >
> > > > Sounds great.
> > > >
> > > >> Not that it's ideal, but for a debug feature to at least check PG_lo=
ck, probably
> > > >> an easier way to achieve it than some completely new infrastructure.
> > > >
> > > > I understand what you are going to tell.
> > > >
> > > > However, it's worth noting that lockdep tracks dependencies basically
> > > > based on **lock acqusition orders** in the system.  To make it track
> > > > even rwlock and general synchronization mechanism as well, lockdep has
> > > > no choice but to get more complicated.
> > >
> > > Well, yes, sure :)
> > >
> > > >
> > > > Focusing on only the dependency checking, the most parts of lockdep a=
re
> > > > for the tricky things, so the reusable parts are not that big.
> > > >
> > > >> Now, Willy said "locking rules don't really apply to individual foli=
os", I
> > > >> wonder if that could just help to also let lockdep check PG_lock wit=
h less
> > > >> metadata? (didn't fully wrap my head around the implications)
> > > >
> > > > That's what DEPT did and what brought external wgen introduced in DEP=
T.
> > > > I was considering the exactly same thing :)
> > > >
> > > > Again, lockdep that tracks lock acquisition orders can't do that.
> > > >
> > > >> [1]
> > > >> https://lore.kernel.org/all/aR3WHf9QZ_dizNun@casper.infradead.org/?u=
tm_source=3Dchatgpt.com
> > > >>
> > > >>
> > > >> It's your guiding example, that's why I mention it. You do mention o=
ther wait
> > > >> cases here, I don't know anything about them, but for folios it's re=
ally just
> > > >> "we used a single bit so far" AFAIKs.
> > > >
> > > > It doesn't matter whether it's implemented using bit or not.  folio l=
ock
> > > > is quite special since it's allowed to be released other than the
> > > > acquisition context that makes lockdep impossible to track them.
> > >
> > > Does that really make lockdep *impossible* to track them? IOW, there is=
 no way
> > > to extend lockdep to support lock release in different context?
> >=20
> > Yes and no....
> >=20
> > lockdep has no knowledge of control flows moving across threads in the
> > way that I assume DEPT does.  But it should be possible to tell it.
> >=20
> > If you have some code that takes a lock and then hands it off to
> > another thread, at the hand-off point you call
> >    lock_map_release(&the_lock_map)
> >=20
> > This says "no task owns this lock any more".
> >=20
> > maybe you put the folio which is locked on a queue or an lru or
> > whatever.
> >=20
> > There is no way to say "that queue owns this lock".  Maybe that could
> > usefully be added - assuming coherent semantics can be designed.
>=20
> It's certainly useful to track who owns the lock, but the essence, when
> it comes to deadlock detection, lies elsewhere.  DEPT is based on the
> essence, that is, a deadlock comes from waits that are never awakened.

I disagree.
The "essence" of deadlock detection involves the interplay of ownership
and waiting.
In your cover letter "THE DEPT APPROACH" talks about [S] where and
event context begins, and [E] where the even occurs.  This S-E section
is exactly ownership.  During that time something "owns" the event.
Maybe the terminology is different, but the concept is the same.

>=20
> > Somewhere else some other task takes responsibility for that folio and
> > the lock.  maybe it dequeues a page, or maybe an lru callback gives the
> > locked page to some code.
> > That code then calls
> >    lock_map_acquire_try(&the_lock_map)
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
> It's an interesting approach if your goal is to track the owenership,
> but if the goal is for tracking dependencies.. well.. I'm not sure.

I am sure.  Dependencies are between waiters and owners.

A strong theme in your cover letter is the need to add comprehensive
annotation for DEPT to work.
My position is that most of what we need for LOCKDEP to be able to
detect exactly the same things is appropriate annotation.
We need to annotate when ownership is handed off to another thread, and
when the other thread takes on ownership.

So what does your scheme provide that is clearly better?  Is the
annotation easier?  Is some of it automatic?  Does if give better error
reports?=20

I had a look through dept.rst and it seems that if a lock is released by
a different thread than the one which took the lock, then DEPT can
detect that and do something useful.  That might be interesting.
But how does it know when it first took ownership of that lock?  Or you
use your terminology: how does it know when that lock first entered the
context in that thread?

Maybe when you see an "unlock", you assume the lock has been owned since
the last time the context didn't hold hold any locks.  Would that be
right?=20
Surely it wouldn't the too hard to teach lockdep about that.
i.e.  when a lock, which is allowed to migrate across threads, is
released though it wasn't held - insert this lock at the top of the
current context and re-assess all the wait points.

How do you decide that a lock that was taken is no longer part of the
current context?


NeilBrown
