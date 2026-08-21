Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 3231136212C;
	Fri, 21 Aug 2026 04:51:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787287899; cv=none; b=Hm5j6irGtEDy1ZMnqTcUppvS5jmcMXzO5LffHZFgN2Jt3me6Na/r10LzEpBagBej7wA0jK8+n59gmMbNOfB4t03/Ca8SI3v/48VN+lkJ9HpHt4WgMA0+1phKug4nKVPMM/V59Bu/AKewLneeGMy/sH1rJuhMK21ZMEgcyyc4I0s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787287899; c=relaxed/simple;
	bh=MCk5UadZzYwpRzEiH271nGsphiwFj3ArZsaZHv4RckE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XEZ44j3OCrROkE2Ju3niC2aRpM7HbfcOSQshjMkXesvDWVU9T11Ikow/r657un3x5yiy80v5gRA9jyek4ZI2M2EvHxppcsh1tChNn5R05wl0Wz8rsmCknEXorUyHFcgW6Ya/+LZILljClJVUz8q8Byq2/E95xa9Pj15eGw/d5F4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c45ff70000001609-f3-6a87d954323f
Date: Fri, 21 Aug 2026 13:51:32 +0900
From: Byungchul Park <byungchul@sk.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: "David Hildenbrand (Arm)" <david@kernel.org>,
	linux-kernel@vger.kernel.org, max.byungchul.park@gmail.com,
	kernel_team@skhynix.com, torvalds@linux-foundation.org,
	damien.lemoal@opensource.wdc.com, linux-ide@vger.kernel.org,
	adilger.kernel@dilger.ca, linux-ext4@vger.kernel.org,
	mingo@redhat.com, peterz@infradead.org, will@kernel.org,
	tglx@linutronix.de, rostedt@goodmis.org, joel@joelfernandes.org,
	sashal@kernel.org, daniel.vetter@ffwll.ch, duyuyang@gmail.com,
	johannes.berg@intel.com, tj@kernel.org, tytso@mit.edu,
	david@fromorbit.com, amir73il@gmail.com, gregkh@linuxfoundation.org,
	kernel-team@lge.com, linux-mm@kvack.org, akpm@linux-foundation.org,
	mhocko@kernel.org, minchan@kernel.org, hannes@cmpxchg.org,
	vdavydov.dev@gmail.com, sj@kernel.org, jglisse@redhat.com,
	dennis@kernel.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, vbabka@suse.cz, ngupta@vflare.org,
	linux-block@vger.kernel.org, josef@toxicpanda.com,
	linux-fsdevel@vger.kernel.org, jack@suse.cz, jlayton@kernel.org,
	dan.j.williams@intel.com, hch@infradead.org, djwong@kernel.org,
	dri-devel@lists.freedesktop.org, rodrigosiqueiramelo@gmail.com,
	melissa.srw@gmail.com, hamohammed.sa@gmail.com,
	harry.yoo@oracle.com, chris.p.wilson@intel.com,
	gwan-gyeong.mun@intel.com, boqun.feng@gmail.com, longman@redhat.com,
	yunseong.kim@ericsson.com, ysk@kzalloc.com, yeoreum.yun@arm.com,
	netdev@vger.kernel.org, matthew.brost@intel.com,
	her0gyugyu@gmail.com, corbet@lwn.net, catalin.marinas@arm.com,
	bp@alien8.de, x86@kernel.org, hpa@zytor.com, luto@kernel.org,
	sumit.semwal@linaro.org, gustavo@padovan.org,
	christian.koenig@amd.com, andi.shyti@kernel.org, arnd@arndb.de,
	lorenzo.stoakes@oracle.com, Liam.Howlett@oracle.com,
	rppt@kernel.org, surenb@google.com, mcgrof@kernel.org,
	petr.pavlu@suse.com, da.gomez@kernel.org, samitolvanen@google.com,
	paulmck@kernel.org, frederic@kernel.org, neeraj.upadhyay@kernel.org,
	joelagnelf@nvidia.com, josh@joshtriplett.org, urezki@gmail.com,
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
Message-ID: <20260821045132.GB40890@system.software.com>
References: <20260706061928.66713-1-byungchul@sk.com>
 <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
 <aoc-jJ10op62jXFK@casper.infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aoc-jJ10op62jXFK@casper.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Brightmail-Tracker: H4sIAAAAAAAAA02Sb0xbVRiHPffcnnupa7xWll2Z2YfOPwTDZGyJr3Ex4mK8xsSYLAbFRFfk
	ZnQrsJTBVhMVxLHabdJ0aTfKHIU51kELWCij2CZItk4YZOgEy0Zhha6sGbhIKAZYwV4W4749
	5/f+8pw3J4fFynqSxmqKD4m6YrVWReS0fG5DQ+aHY8f2Z80NPAWjlb00xBcMNJxtcxJI1F1m
	wOCulcFwawuCybgBwT8rdRiOetdoSJgDDCws3WbAUolgzR9AYP3NjMESjhA4HaukIXb1HVgL
	zVDw5+IsgqbIKgWR3mMIEtYDUN/YQWBl6AaGhnAIw3zsDoLOwAQCv+MbAndNHgx/xB8Q6Lcc
	J/BXO4HoLT8FVefbCFh/cNPgvdPDwLjVTMF1UyOVvC+Z/7QJ6k5XUbDU1MzAlMPGwMPwdgi0
	zDAQqrHQcD9qJjB5rVoG7rGrCJwnohjc06MyaKj+kYbac+MEfP5+GgyJBQSB7ikKbvacJXCi
	3SODCeda8hl6r8vg95ZhGvptl2i4PVTDwI0el+zNAsF5zomElWUzEhYuVGHhqCl5/LbjsLAc
	HyGCf9FOCwONvOC1hRjB7i4TOhwZwnlfjBLczd8RwT1vZoSGlXtYGB/1kQ8y8+S7CkStplzU
	vfLGXnmh628PddD1/JGTlfdlFWg2zYhSWJ7bybsmZ7ARsev8/a95UkxzL/Btp+qQxIR7iQ8G
	l9YrqVw6P9uZbURyFnNXtvBjyx4sdZ7hXuU7x48TiRUc8L57Q0QqKblTiB/p66IfDZ7m+2sj
	64y5DD64GqMkKeY28xdXWQlTkitMzQhSYyO3le/tukZJGp6LpvADFd3Uo5Wf5X9xBGkT4myP
	WW2PWW3/W+0INyOlpri8SK3R7txWqC/WHNn2eUmRGyW/bdOXDz/pRvPDe/oQxyLVBkXWRPV+
	pUxdXqov6kM8i1WpilZDMlIUqPVfiLqSz3RlWrG0D21madUmRfbi4QIlt099SDwgigdF3X9T
	ik1Jq0C7qQsjysTP7Zc3npEH96Xn33oy6Pn0o65Bx+sjvpOWwRp7TlduSVSf0+p9bnf918aP
	v9pzV2XYNfsE8k5npiqNVFatPle3I/utLWVB6/uhuZdvJqx212udb7+YvzcnPUzkDwLh9I4r
	7+a25sfPtBRtjWBTkwm7XO/lKQanu3dMaFV0aaF6ewbWlar/BVM3SZGyAwAA
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxTdxTGc/739vZS7XJBNu5w8UPVuJGAumzZMTNzZln8Q7LNZIsmLm42
	eiOV8pJWUVjIaLFawBmoa5ktVWSzEgRxUNiYNsOqCGojzDlxFpGlA0mrMHkxtBTWblnml5Pn
	nPN7Tp4Ph2eS5mSpvCZvr6TLU2tVnIJVfPh2Wfon9w7vWTPTsBzNpi/RPxSQ4W+GLhanp8ws
	1rY0cRh1/CBHc+txGfbcNbLYd+4s4NC0GfBZxMGgqXOBxailW45Ts/flaDUALni6AW39FgYH
	+n5msMltIDh5fp7D4OWngNbhAIc1YwYWx11HAO0jDjmOXd2Ej4cuyHBhcJTg3ZkQoCswTzDQ
	dRgwasvBk/VtMbttgsOI7xaDNdY+wFPDgww+HXsI6O5+ADjaHgb0NBg5/LOqncHbgRfw1+lx
	DnutlRw+7q8l+OQ8h3VGjwz7bwYBnQ4L4MjvHoJl37ZwaHO2stj58Cc59gfnCPptFoJnWz/A
	IdcIizeq6kksc4z6PgUdNWUkVh4RtDZfIO+6gD4zHWVpY1sHoaZfohxtOtEENBK2AJ06XcZQ
	U1WsvRwaZ+jBtv309I0QR8PTdzjqmalj6fV6kX5XHia02pdOO+2D8s0btynW75K0mkJJt/qd
	HYrs5r/aSUHzigNfGYKyUgilVgDPi8Ib4tGebRWQwLPCSrHlmAPimhNWiQMDs0wcSRZeFUPu
	1ytAwTPClWXivXA7E2eWCG+Jbn8lF9dKAcWLj3xcHEoSjoF4x9vB/rtIFHuPB/7RjJAmDsyP
	kfhRRlgqnpnn4zIhFuGPURonXhSWi10d10gVKO3Pme3Pme3/m+uAaYRkTV5hrlqjfTNDn5Nd
	lKc5kLEzP7cVYj/pKpmr/hGmbm/ygsCDarFyzYNDe5Jk6kJ9Ua4XRJ5RJSvPmWMj5S51UbGk
	y/9ct08r6b2wlGdVKcqsrdKOJGG3eq+UI0kFku6/LeETUkuh5OuL2/21uzOvW28tUNmE1m9e
	tCIz7bOG/HWNHYc2Fm//RqQfvRKBcPmyufzXEjcYs5whr/79at/93oPp8FJJpaKn1J/S9ukW
	Z8FEYqQ8evLJZuMX2mLt5LUa63pP0PZeZu/sluqX3TczhuXBrYsuZZ1wRvZ93Lj6iNk3mZWq
	0UoqVp+tXpvG6PTqvwHBiFqHjwMAAA==
X-CFilter-Loop: Reflected

On Thu, Aug 20, 2026 at 06:51:08PM +0100, Matthew Wilcox wrote:
> On Thu, Aug 20, 2026 at 07:16:05PM +0200, David Hildenbrand (Arm) wrote:
> > > Consider this real deadlock pattern that lockdep cannot detect:
> > >
> > >    context X              context Y              context Z
> > >
> > >                           mutex_lock A
> > >    folio_lock B
> > >                           folio_lock B <- DEADLOCK
> > >                                                  mutex_lock A <- DEADLOCK
> > >                                                  folio_unlock B
> > >                           folio_unlock B
> > >                           mutex_unlock A
> > >                                                  mutex_unlock A
> >
> > But that really just boils down to folio lock being implemented as a PG_lock +
> > some advanced wait mechanism. And we must do that because of lack of bits in
> > struct page.
> >
> > Willy mentioned in a previous version [1]: "I don't think it makes sense to
> > track lock state in the page (nor folio).  Partly because there's just so many
> > of them, but also because the locking rules don't really apply to individual
> > folios so much as they do to the mappings (or anon_vmas) that contain folios."
> >
> > Given that lockdep is a debug feature, and we will at some point allocate struct
> > folio separately, I assume we could just squeeze a "struct lockdep_map" in there
> > in such debug configs and the world would not collapse.
> >
> > Doing that today (one "struct lockdep_map" in each "struct page") wouldn't work
> > as mm_zero_struct_page() would not expect such large "struct page". But
> > conceptually, for a debug kernel with a special CONFIG_LOCKDEP_PAGE_LOCK, maybe
> > that would already be ok and we could just do that (and optimize it as we
> > allocate folios separately).
> >
> > Not that it's ideal, but for a debug feature to at least check PG_lock, probably
> > an easier way to achieve it than some completely new infrastructure.
> >
> > Now, Willy said "locking rules don't really apply to individual folios", I
> > wonder if that could just help to also let lockdep check PG_lock with less
> > metadata? (didn't fully wrap my head around the implications)
> >
> > [1]
> > https://lore.kernel.org/all/aR3WHf9QZ_dizNun@casper.infradead.org/?utm_source=chatgpt.com
> 
> There are a few things going on that make PG_lock special.  Let me try
> to explain again, only better this time.
> 
> 1. The current lifetime of a struct page is the lifetime of the system.
> But the semantics of its PG_lock bit change each time it is freed and
> allocated.

Yes, it's a classification issue that is very important.

> 2. The position of PG_lock in the locking hierarchy only depend on
> what the folio is currently being used for.  That is, all folios in
> a given xfs inode behave exactly the same from a locking perspective.

You are exactly explaining what the classification means.  Perfect.

> There's no need to build up state about how each PG_lock is used;
> they can all share.  Arguably all xfs file inodes are the same as

Right.  That's why DEPT doesn't use a full map in each page but just
uses a timestamp in each.  For the classification, DEPT uses a few
classes for folio, using global maps:

   1. folios in mm paths
   2. folios in block device buffer (meta data)
   3. folios in regular file cache

However, yes.  I bet you could be a big help when classifying folios
more presicely according to its usage.  But the current classification
is still a good start I think.

> each other (directory inodes might be different from file inodes),
> so we might want to go further than telling DEPT that "this folio
> belongs to this inode" and go to "this folio belongs to this xfs file
> inode".

Totally agree.

> 3. PG_lock can be taken in task context then released in interrupt
> context.  For full points, we need to mark the exact point at which
> we submit the folio for read.  Otherwise we can get into the situation
> alluded to by f2c817bed58d and better discussed at
> https://lore.kernel.org/linux-mm/20200127150024.GN1183@dhcp22.suse.cz/
> where we have the folio locked but haven't yet submitted it for I/O
> so it doesn't matter how long we wait, it will never come unlocked.

Interesting.  

The following abstraction might make DEPT work with it.  For example:

   Annotate the point submitting IO as an event for the folio_lock() to
   be released.  That way, the issue above can be detected by DEPT.

Again, DEPT can do every thing we need w.r.t. deadlock.

	Byungchul
