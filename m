Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 193574772A7;
	Thu, 20 Aug 2026 17:51:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787248299; cv=none; b=KOJ5vifLwDLliH3ebZdtjdF5krTj4MPz/rCFyrWWm4+ka5c9SLM2bwW2u/EMro9feBy6QFdDq3gGgTpimcVmPBKbP5Q8WgKgv2b53AkdKR+9fWsvj52wzub3EmnAkquEkW9xs3v0bEQSapTuKmBBvUE8xL8s8UoHHYmy4a1MG18=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787248299; c=relaxed/simple;
	bh=chts6MzIHj/bJVBkghPzRmsWqaknd18UrkOwhvE4I/s=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sEYd10Tfnm/vspxErgLmgi6kgoceHQsDKq8LDsIfm7y6/kZcforDTAlriHHK1PoCTWzqW34Gfx5CL4ti2aDLlChSOWJmUQMAhnhA6AUe05L2IyuEebLH1UAbj87fybBo2un2lM/8IzcbcI/bUI54pK7k0pYvfnZwR0tCwn1DLv0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=rTRFHt4F; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rTRFHt4F"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=/nTZ7s1goF+GPCz6EL3sBTg9gNDkE+Bk0F4MEDCId3U=; b=rTRFHt4F8LNezy/fzAgoJCTaEn
	Hu0D4RqGfIK9MUZUy7y5Vba3MurgAp9pBMd9z6PEiUlWaCso04QtHq/uQ4n17N1VQ2wPu6RajSIxt
	5VjB0H2feVYd3mqUp5gCxaMbrQOO+i6lj9uOvypef8Qk/ac19GC7w3Hfcyxj83iTd9QOFZIzV0iBp
	/SGM/O64CQwL9ZlzHX0Ox5TCul40K5Mnq+2KwcSaH/1h0KS1/qNKeUME6lYFYtYCfh4F7sNx59RpD
	pLEI6i3LHvbHNk4ESUjf0GkAf6n+DO9ur6QkErSHO05zM44QUpEFH+mMqGSk1hMk5dNHlM0YQq3eB
	Pzxk6gcA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx6uy-0000000G2y1-3Dxp;
	Thu, 20 Aug 2026 17:51:08 +0000
Date: Thu, 20 Aug 2026 18:51:08 +0100
From: Matthew Wilcox <willy@infradead.org>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: Byungchul Park <byungchul@sk.com>, linux-kernel@vger.kernel.org,
	max.byungchul.park@gmail.com, kernel_team@skhynix.com,
	torvalds@linux-foundation.org, damien.lemoal@opensource.wdc.com,
	linux-ide@vger.kernel.org, adilger.kernel@dilger.ca,
	linux-ext4@vger.kernel.org, mingo@redhat.com, peterz@infradead.org,
	will@kernel.org, tglx@linutronix.de, rostedt@goodmis.org,
	joel@joelfernandes.org, sashal@kernel.org, daniel.vetter@ffwll.ch,
	duyuyang@gmail.com, johannes.berg@intel.com, tj@kernel.org,
	tytso@mit.edu, david@fromorbit.com, amir73il@gmail.com,
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
Message-ID: <aoc-jJ10op62jXFK@casper.infradead.org>
References: <20260706061928.66713-1-byungchul@sk.com>
 <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>

On Thu, Aug 20, 2026 at 07:16:05PM +0200, David Hildenbrand (Arm) wrote:
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
> 
> Given that lockdep is a debug feature, and we will at some point allocate struct
> folio separately, I assume we could just squeeze a "struct lockdep_map" in there
> in such debug configs and the world would not collapse.
> 
> Doing that today (one "struct lockdep_map" in each "struct page") wouldn't work
> as mm_zero_struct_page() would not expect such large "struct page". But
> conceptually, for a debug kernel with a special CONFIG_LOCKDEP_PAGE_LOCK, maybe
> that would already be ok and we could just do that (and optimize it as we
> allocate folios separately).
> 
> Not that it's ideal, but for a debug feature to at least check PG_lock, probably
> an easier way to achieve it than some completely new infrastructure.
> 
> Now, Willy said "locking rules don't really apply to individual folios", I
> wonder if that could just help to also let lockdep check PG_lock with less
> metadata? (didn't fully wrap my head around the implications)
> 
> [1]
> https://lore.kernel.org/all/aR3WHf9QZ_dizNun@casper.infradead.org/?utm_source=chatgpt.com

There are a few things going on that make PG_lock special.  Let me try
to explain again, only better this time.

1. The current lifetime of a struct page is the lifetime of the system.
But the semantics of its PG_lock bit change each time it is freed and
allocated.

2. The position of PG_lock in the locking hierarchy only depend on
what the folio is currently being used for.  That is, all folios in
a given xfs inode behave exactly the same from a locking perspective.
There's no need to build up state about how each PG_lock is used;
they can all share.  Arguably all xfs file inodes are the same as
each other (directory inodes might be different from file inodes),
so we might want to go further than telling DEPT that "this folio
belongs to this inode" and go to "this folio belongs to this xfs file
inode".

3. PG_lock can be taken in task context then released in interrupt
context.  For full points, we need to mark the exact point at which
we submit the folio for read.  Otherwise we can get into the situation
alluded to by f2c817bed58d and better discussed at
https://lore.kernel.org/linux-mm/20200127150024.GN1183@dhcp22.suse.cz/
where we have the folio locked but haven't yet submitted it for I/O
so it doesn't matter how long we wait, it will never come unlocked.
