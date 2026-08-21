Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 2789F30BF70;
	Fri, 21 Aug 2026 04:21:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787286116; cv=none; b=pC3rt5r0zWa5kqWG1eefw0EI3wgkhoqzquzTXXOWMTYumiqFkBJdYkIzVkIAVJVF0PsvdbLyCOUITbQdCEb0g0n/vXRKKmWXA0YwYxUgCqEYO2MjR8VaIBA93IQo0U0cOjDBnYXXSN/K+5PxSdsfwf9DyARU76oAUdKhOfopdvc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787286116; c=relaxed/simple;
	bh=I34vR31HpuX9yQf4CCCk//8sxnSuE5CwojFxgmCYmNA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=LoJHzDGHqZrcPIGWLDFgPR6CiXWwqEFTlTcwnp8yvED9zjCqTcUNmwqbweXu3Re5wVRKCR12WAiZcfURHdYNm7IEoUTq+quYXmPhPy8pCU5nBQxrUVXI6DQ+S4OygLCVCYTcNCryXiGQE+n7utRf19jSN/LWzGuyFKsnTXaTq50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c2dff70000001609-1e-6a87d2577020
Date: Fri, 21 Aug 2026 13:21:43 +0900
From: Byungchul Park <byungchul@sk.com>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: linux-kernel@vger.kernel.org, max.byungchul.park@gmail.com,
	kernel_team@skhynix.com, torvalds@linux-foundation.org,
	damien.lemoal@opensource.wdc.com, linux-ide@vger.kernel.org,
	adilger.kernel@dilger.ca, linux-ext4@vger.kernel.org,
	mingo@redhat.com, peterz@infradead.org, will@kernel.org,
	tglx@linutronix.de, rostedt@goodmis.org, joel@joelfernandes.org,
	sashal@kernel.org, daniel.vetter@ffwll.ch, duyuyang@gmail.com,
	johannes.berg@intel.com, tj@kernel.org, tytso@mit.edu,
	willy@infradead.org, david@fromorbit.com, amir73il@gmail.com,
	gregkh@linuxfoundation.org, kernel-team@lge.com, linux-mm@kvack.org,
	akpm@linux-foundation.org, mhocko@kernel.org, minchan@kernel.org,
	hannes@cmpxchg.org, vdavydov.dev@gmail.com, sj@kernel.org,
	jglisse@redhat.com, dennis@kernel.org, cl@linux.com,
	penberg@kernel.org, rientjes@google.com, vbabka@suse.cz,
	ngupta@vflare.org, linux-block@vger.kernel.org,
	josef@toxicpanda.com, linux-fsdevel@vger.kernel.org, jack@suse.cz,
	jlayton@kernel.org, dan.j.williams@intel.com, hch@infradead.org,
	djwong@kernel.org, dri-devel@lists.freedesktop.org,
	rodrigosiqueiramelo@gmail.com, melissa.srw@gmail.com,
	hamohammed.sa@gmail.com, harry.yoo@oracle.com,
	chris.p.wilson@intel.com, gwan-gyeong.mun@intel.com,
	boqun.feng@gmail.com, longman@redhat.com, yunseong.kim@ericsson.com,
	ysk@kzalloc.com, yeoreum.yun@arm.com, netdev@vger.kernel.org,
	matthew.brost@intel.com, her0gyugyu@gmail.com, corbet@lwn.net,
	catalin.marinas@arm.com, bp@alien8.de, x86@kernel.org,
	hpa@zytor.com, luto@kernel.org, sumit.semwal@linaro.org,
	gustavo@padovan.org, christian.koenig@amd.com,
	andi.shyti@kernel.org, arnd@arndb.de, lorenzo.stoakes@oracle.com,
	Liam.Howlett@oracle.com, rppt@kernel.org, surenb@google.com,
	mcgrof@kernel.org, petr.pavlu@suse.com, da.gomez@kernel.org,
	samitolvanen@google.com, paulmck@kernel.org, frederic@kernel.org,
	neeraj.upadhyay@kernel.org, joelagnelf@nvidia.com,
	josh@joshtriplett.org, urezki@gmail.com,
	mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com,
	qiang.zhang@linux.dev, juri.lelli@redhat.com,
	vincent.guittot@linaro.org, dietmar.eggemann@arm.com,
	bsegall@google.com, mgorman@suse.de, vschneid@redhat.com,
	chuck.lever@oracle.com, neil@brown.name, okorniev@redhat.com,
	Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org,
	anna@kernel.org, kees@kernel.org, bigeasy@linutronix.de,
	clrkwllms@kernel.org, mark.rutland@arm.com, ada.coupriediaz@arm.com,
	kristina.martsenko@arm.com, wangkefeng.wang@huawei.com,
	broonie@kernel.org, kevin.brodsky@arm.com, dwmw@amazon.co.uk,
	shakeel.butt@linux.dev, ast@kernel.org, ziy@nvidia.com,
	yuzhao@google.com, baolin.wang@linux.alibaba.com,
	usamaarif642@gmail.com, joel.granados@kernel.org,
	richard.weiyang@gmail.com, geert+renesas@glider.be,
	tim.c.chen@linux.intel.com, linux@treblig.org,
	alexander.shishkin@linux.intel.com, lillian@star-ark.net,
	chenhuacai@kernel.org, francesco@valla.it,
	guoweikang.kernel@gmail.com, link@vivo.com, jpoimboe@kernel.org,
	masahiroy@kernel.org, brauner@kernel.org,
	thomas.weissschuh@linutronix.de, oleg@redhat.com, mjguzik@gmail.com,
	andrii@kernel.org, wangfushuai@baidu.com, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org,
	linaro-mm-sig@lists.linaro.org, linux-i2c@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-modules@vger.kernel.org,
	rcu@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-rt-devel@lists.linux.dev, 2407018371@qq.com, dakr@kernel.org,
	miguel.ojeda.sandonis@gmail.com, neilb@ownmail.net,
	bagasdotme@gmail.com, wsa+renesas@sang-engineering.com,
	dave.hansen@intel.com, geert@linux-m68k.org, ojeda@kernel.org,
	alex.gaynor@gmail.com, gary@garyguo.net, bjorn3_gh@protonmail.com,
	lossin@kernel.org, a.hindborg@kernel.org, aliceryhl@google.com,
	tmgross@umich.edu, rust-for-linux@vger.kernel.org
Subject: Re: [PATCH v19 00/40] DEPT(DEPendency Tracker)
Message-ID: <20260821042143.GA40890@system.software.com>
References: <20260706061928.66713-1-byungchul@sk.com>
 <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Brightmail-Tracker: H4sIAAAAAAAAA02Sa0ybZRiG835nmhU+6nTvtkRN52JggTGzxCeZmxpN/NRtMZnGZfvhmvEF
	OsrBwjhojJzXAWrBUaTNCIxROtptUmAHEMdwDAgHC1mgcsyAtTYFWbBAwFJsS4z8eXPlvt88
	1/Pj4UhZE7OHUyalieokhUrOSCjJwo5rUaeHL12I8XnCQFPwLYzkdFCw7NFQsGG4y4LGWklD
	z2guBav/GEgouL9JgW6ojARLcw4Bf//sY2DRWIJA7zCw4Or6ADYnnQSMrswjMM75CJjruIRg
	Q5cAbt1zBirKbQjaTbkMPNO2kPBkeZGB3vJiBqpz22kY6ncjuGooQ5BXe5uBIbeXgAldGQFm
	6wmYNjoo6NNeI6DCxYCucRcYKvII//MnAeU32whYMzaw0F87QYExez/MmPQseJ8egs3qZHhs
	drLQOzVCg9tRxsB0dyEN1j+6EHiePCXAUuIgwTrrb9vHDkBN4XUKKqsmGNBseBBMWTZpyDas
	0mDr6KNh2Gzzb/G4h4LxgR9Y+L31Jv1OrLBa8D0lWKosSPhtfpEU8psyhLq+eUa4fnmdEEoH
	ooT7+klWyP91jBWqrReF/EcLtNBkihRqf3ERQs3SMi2MuY8K1obLzCdRZyRvxYoqZbqoPnjs
	nCR+1jnKpnQdzTRdsRPZqPxgEQrhMH8Y67W3iSLEBflBzueBmOL341mXhgoww7+O7fY1MsA7
	+Rjs7Mn1f5dwJG9+GV+Z7mYDxQv8m7h5opgJsJQHfGt9PMgyXomvPjCjrTwc91bOBYeS/qHe
	qmEy4CX5vbjex23Fr+C8FkPQFcIfw7NFz4P8Ir8Pd9zpJrZWXgrBaz9+vcW78UOTndKicP02
	g36bQf+/Qb/NUI2oBiRTJqUnKpSqw9HxWUnKzOjzyYlW5D9l4zfes/fQku1UJ+I5JN8hjZkq
	vCCjFempWYmdCHOkfKf0lsYfSWMVWV+J6uQv1BdVYmon2stR8l3SN1YyYmV8nCJNTBDFFFH9
	X0twIXuykeqe69xrssjBd5/VeeJCc8arLKdfeji+El7smM9otg1GFNSHNn4c8WrYzNmIn8JO
	ffpZypftxz8adIeVJJxfP6mwEJXvR88MGNtaD2T6Ss2ljYJ34Ui0vX/wZNvxqPfevvNdXULN
	SKnzUf3dNPZE5r7dG/QoO8nEJfbeCG058mFrj/YvOZUarzgUSapTFf8Cx7i0xsYDAAA=
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxTVxjHc865Pb00q1xrpzeyuKRzMSER2aLxWXBmbjHezGj0w4ZhS2aV
	m1He1NYxMNm0dJ2lugUbW7QVRZRqLCJrgY2ZDgIDYWoEVOgUKIRCR0BBVmSUt7WYZXw5+Z3/
	8zy/53w4LFFY6WpWk31U1GarM1VUxsh2JxnWJ3ecTE+89mANmIzHodsfkECnvp6ByZCJgQu3
	yinMOX6Wgsl9XgItXfkMtFW4EPgnTQimZhwEjLULDMxZmqUQmn4qBasewYK3GYGt3ULA11ZH
	oLxKj+HvynkKI40TCKz9AQpFw3oGxpynEdiHHFIYbtoBz/y3JbDQE8TQ9XIUgTMwjyFQfxLB
	nC0DLpV6IuO2cQoz9x8QKLK2Ibjc30NgYrgPQVVzL4JgdRiB93o+hcHCagIPA8vg0eQYhVbr
	KQrP2i9geF5JoSTfK4H2eyMIih0WBENPvBgMV25RsBW7Gajt+1UK7SOzGLptFgwu9y7wO4cY
	uFtYiiNvjnT9tAocRQYcOf7CYL15G3/gRMKU8UdGuOGpwYKxY44K5RfLkTATtiAhVGYggrEw
	cm0cHSPCd56vhbK7o1QITz6mgvdlCSP8UcoLVwvCWDhzf71Qa++R7tmWItuSKmZqckTthq37
	ZWkDwS7p4ab3c6+f9eETyLrBjFiW5zbydfpkM4phGe5tfmDYxESZcut4n2+aRFnJJfLBlnxs
	RjKWcK41/Fn/HWm0sILbzFd1n6JRlnPAV4SfLrKC0/DFdS70Kl/Ot54PLEpJRDp7sYNE9xIu
	jr82z76K3+QN1Y7FXTHcVn7APL7Ir3Nv8fU1d3AhWmZfYrIvMdn/N9mXmEoQcwMpNdk5WWpN
	5qYEXUZaXrYmN+HgoSw3inxW5zezZ35BoYc7GhDHItVr8sTe79MVEnWOLi+rAfEsUSnlFaZI
	JE9V5x0TtYe+0H6VKeoaUBzLqFbJP04W9yu4L9VHxQxRPCxq/6tiNmb1CaQekR9R/pCymaQ8
	173ojB/d7hsvOLLTHJrX1aZubDwQ/LbrvbV9sZ+sdW3rv/JCGbviXNPlhgKPO6Z1i+nzeIXq
	sz+f9ApJ3dvLht4tbdk7uG/itOq3jsrfafrYYPOHcf8sJIaKOh+/8em56eWKhKapWNmx4+59
	nqAv6aOVuTXpN8db96oYXZr6nXii1an/BXiILQioAwAA
X-CFilter-Loop: Reflected

On Thu, Aug 20, 2026 at 07:16:05PM +0200, David Hildenbrand (Arm) wrote:
> On 7/6/26 08:18, Byungchul Park wrote:
> > Hi Linus and folks,
> 
> Hi,

Hi,

> I think there was plenty of feedback from locking maintainers in the past. One
> question and a comment below.
> 
> >
> > DEPT(DEPendency Tracker) is a runtime deadlock detection framework that
> > sees what lockdep cannot.
> >
> > I'm thrilled to share that DEPT has moved beyond theory and is now
> > catching real deadlocks in the wild:
> >
> >    https://lore.kernel.org/lkml/6383cde5-cf4b-facf-6e07-1378a485657d@I-love.SAKURA.ne.jp/
> >    https://lore.kernel.org/lkml/1674268856-31807-1-git-send-email-byungchul.park@lge.com/
> >    https://lore.kernel.org/all/b6e00e77-4a8c-4e05-ab79-266bf05fcc2d@igalia.com/
> >
> > I've added comprehensive documentation explaining DEPT's design and usage.
> > Getting started is as simple as enabling CONFIG_DEPT and watching dmesg.
> >
> > THE PROBLEM LOCKDEP CANNOT SOLVE
> > --------------------------------
> >
> > Lockdep has been our trusted deadlock detector for two decades, but it
> > has a fundamental blind spot: it tracks lock acquisition order, not the
> > actual waits and events that cause deadlocks. This means lockdep misses:
> >
> >   * Deadlocks involving folio locks (not released within the context)
> >   * Cross-context synchronization like wait_for_completion()/complete()
> >   * DMA fence waits, RCU waits, and general waitqueue patterns
> >   * Any synchronization primitive outside the classic lock/unlock model
> >
> > Consider this real deadlock pattern that lockdep cannot detect:
> >
> >    context X              context Y              context Z
> >
> >                           mutex_lock A
> >    folio_lock B
> >                           folio_lock B <- DEADLOCK
> >                                                  mutex_lock A <- DEADLOCK
> >                                                  folio_unlock B
> >                           folio_unlock B
> >                           mutex_unlock A
> >                                                  mutex_unlock A
> 
> But that really just boils down to folio lock being implemented as a PG_lock +
> some advanced wait mechanism. And we must do that because of lack of bits in
> struct page.
> 
> Willy mentioned in a previous version [1]: "I don't think it makes sense to
> track lock state in the page (nor folio).  Partly because there's just so many
> of them, but also because the locking rules don't really apply to individual
> folios so much as they do to the mappings (or anon_vmas) that contain folios."

Exactly.  That's why we use classification e.g. lock class - DEPT also
makes use of the concept.

DEPT doesn't use a full map in each page but uses a minimum space for a
timestamp in each to track when each starts to wait so as to use the
recorded timestamp when the event occurs e.g. folio_unlock().

> Given that lockdep is a debug feature, and we will at some point allocate struct
> folio separately, I assume we could just squeeze a "struct lockdep_map" in there
> in such debug configs and the world would not collapse.

That's a good news for lockdep.  (And even for DEPT :)

> Doing that today (one "struct lockdep_map" in each "struct page") wouldn't work
> as mm_zero_struct_page() would not expect such large "struct page". But
> conceptually, for a debug kernel with a special CONFIG_LOCKDEP_PAGE_LOCK, maybe
> that would already be ok and we could just do that (and optimize it as we
> allocate folios separately).

Sounds great.

> Not that it's ideal, but for a debug feature to at least check PG_lock, probably
> an easier way to achieve it than some completely new infrastructure.

I understand what you are going to tell.

However, it's worth noting that lockdep tracks dependencies basically
based on **lock acqusition orders** in the system.  To make it track
even rwlock and general synchronization mechanism as well, lockdep has
no choice but to get more complicated.

Focusing on only the dependency checking, the most parts of lockdep are
for the tricky things, so the reusable parts are not that big.

> Now, Willy said "locking rules don't really apply to individual folios", I
> wonder if that could just help to also let lockdep check PG_lock with less
> metadata? (didn't fully wrap my head around the implications)

That's what DEPT did and what brought external wgen introduced in DEPT.
I was considering the exactly same thing :)

Again, lockdep that tracks lock acquisition orders can't do that.

> [1]
> https://lore.kernel.org/all/aR3WHf9QZ_dizNun@casper.infradead.org/?utm_source=chatgpt.com
> 
> 
> It's your guiding example, that's why I mention it. You do mention other wait
> cases here, I don't know anything about them, but for folios it's really just
> "we used a single bit so far" AFAIKs.

It doesn't matter whether it's implemented using bit or not.  folio lock
is quite special since it's allowed to be released other than the
acquisition context that makes lockdep impossible to track them.

> [...]
> 
> >
> > Q. Why not build DEPT into lockdep?
> >
> > A. Lockdep is stable, battle-tested code. I chose separation because
> >    while DEPT borrows BFS and hashing ideas, the wait/event model
> >    requires rebuilding from scratch. Lockdep was designed for lock
> >    acquisition order — retrofitting it would risk its stability.
> 
> Why can't this just be some configurable extension to lockdep
> (CONFIG_LOCKDEP_XYZ) until the feature is stable and can unconditionally be
> enabled along with it?

Answered?

> I don't quite buy the "would risk its stability" argument. A lot of stuff we do
> "risks stability", every day :)

That's awsome anyway :)

> Is there another good reason (incompatible with X, dangerous with Y, cinfusing
> Z) why this really must be a separate thing?

Roughly:

   1. Similar or less effort is needed for the new one - retrofitting
      lockdep is not easy and big changes are required since the
      reusable parts are not that big.

   2. Even though you didn't agree, retrofitting it would risk its
      stability.

> >
> > Q. Will DEPT replace lockdep?
> >
> > A. No. Lockdep validates correct lock usage — that's not going away.
> >    DEPT supersedes only the dependency-checking logic when mature.
> 
> It's quite unfortunate that we'd end up with another similar-but-different
> mechanism, that will just end up confusing people.

I meant, at least dependency checking engine should be altered, but you
make sense.  Worth thinking it more.

> But I am not a locking maintainer. I think there was plenty of discussion in the
> past, so I might just be raising points that were already discussed in the past,
> but I really just read some random pieces of earlier discussions. (ideally
> previous discussions would be summarized here)
> 
> Long story short: we are now in v19 and I think there was pushback in the past.
> Did the opinion of locking maintainers change, or is there a way forward to
> integrate this in a way that would make locking maintainers accept this?

One of locking maintainers who I met in an LPC told me that he agrees
with the direction of DEPT and supports DEPT, not officially tho.

What he and other people are concerning w.r.t DEPT the most is, false
positives, which is the most important issue for now.

At the same time, I think the most important thing is to make DEPT
useful in practice especially with folio locks involved.  Actually, I'm
planning to share DEPT's true reports periodically to LKML and work with
people who believe DEPT can make things better.

Any advices will be welcome.  Thanks for your opinions.

	Byungchul
> --
> Cheers,
> 
> David
