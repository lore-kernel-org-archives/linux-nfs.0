Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82F0925A640;
	Tue, 25 Aug 2026 02:40:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787625641; cv=none; b=Xm6mkBjRJ6tuuHOTva0Lqw+k1HWKjkRaZSkos067FCuNl1ZofVFhQbQAdIKREzhqvPZv65Rn7rU1cZRIF2+vYzb309xXXfFiw9cZ2bU17NZo6mAXnCEnu5O0NzzXUfYLk77WDuEddqB6r8IxR+brS3lNhPGIiicXxXXvKWcbWFI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787625641; c=relaxed/simple;
	bh=grmr8ShzbmokeeZM8GJP7va3jRxjvHZ4u/qI8TrYDQ0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=r0GvZ4K+sWj+29sHFYdaDzrHKzkBQB/Hwvl+qDGQA2gA5zfwWU+Vq2VmlLsVB/g1b+JKSQITlE80D1sdjAyOmHi+SeG5lUIbzMw7LcRskG6WvPSvYlBdOzTBYdA+/lpE3zLpahIkiwtviCBx1ZwyQefUSuZ+VyWj+UmtE9+fO5w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=hzGqzCFd; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hzGqzCFd"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=cMhE1zLIBEfW8ce0tgca2Z8WQ504QioXQyvOVgDlw9s=; b=hzGqzCFd/Zil7siDD7txgS0PkI
	0btYf2KcGF4Jt5LTpvtm3rcvqgdEJSmZrUdBF9aqMpMYUh9Wx2DIzUj8xdR3ux2f0ydIJjgu6/GP/
	GCGCI2Cu8TlWQosSPGxvlQtgSVvTwAmUUZIpR/2u1oLk4ZJts6jT8AMgHc7WKf4EmDelDxaZNwldB
	bwuBAzBiHPtS2yBO9dgBLMH1854Fm9Yq579Rygv7X8gtmLlRanmAfRNHAJH+8I1bkHkoV2E7aBA/w
	Rmforme87QTE7Bp3x5xKUtL/ppwt4PjCQFG+iz4NzVNJh7Q9S88tpLt+noBixClVZE+hH5oiywcdZ
	NRPAIH+Q==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wyh57-00000008BRG-20Ss;
	Tue, 25 Aug 2026 02:40:09 +0000
Date: Tue, 25 Aug 2026 03:40:09 +0100
From: Matthew Wilcox <willy@infradead.org>
To: NeilBrown <neil@brown.name>
Cc: "David Hildenbrand (Arm)" <david@kernel.org>,
	Byungchul Park <byungchul@sk.com>, linux-kernel@vger.kernel.org,
	max.byungchul.park@gmail.com, kernel_team@skhynix.com,
	torvalds@linux-foundation.org, linux-ide@vger.kernel.org,
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
	hch@infradead.org, djwong@kernel.org,
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
	chuck.lever@oracle.com, okorniev@redhat.com, Dai.Ngo@oracle.com,
	tom@talpey.com, trondmy@kernel.org, anna@kernel.org,
	kees@kernel.org, bigeasy@linutronix.de, clrkwllms@kernel.org,
	mark.rutland@arm.com, ada.coupriediaz@arm.com,
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
	miguel.ojeda.sandonis@gmail.com, bagasdotme@gmail.com,
	wsa+renesas@sang-engineering.com, dave.hansen@intel.com,
	geert@linux-m68k.org, ojeda@kernel.org, alex.gaynor@gmail.com,
	gary@garyguo.net, bjorn3_gh@protonmail.com, lossin@kernel.org,
	a.hindborg@kernel.org, aliceryhl@google.com, tmgross@umich.edu,
	rust-for-linux@vger.kernel.org
Subject: Re: [PATCH v19 00/40] DEPT(DEPendency Tracker)
Message-ID: <ao0AieB7zg5FKD39@casper.infradead.org>
References: <20260706061928.66713-1-byungchul@sk.com>
 <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
 <20260821042143.GA40890@system.software.com>
 <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
 <178730572084.2852630.7732425311008244683@noble.neil.brown.name>
 <3d58eb3c-7a9d-4183-907b-46172664631c@kernel.org>
 <178761465493.3510150.12380729360578969391@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <178761465493.3510150.12380729360578969391@noble.neil.brown.name>

On Tue, Aug 25, 2026 at 09:37:34AM +1000, NeilBrown wrote:
> > For readahead, I think that queues / lru are not involved. We submit the I/O,
> > and once the I/O is done, we unlock the folio from interrupt context.
> 
> "submit the I/O" means "attach the page to a "struct bio" (or similar)
> and attach the struct bio to a transmit queue for the device (or
> similar).  So there really is a queue.
> 
> > 
> > end_buffer_async_read() / iomap_finish_folio_read() end up calling
> > folio_end_read(), where we do the magic
> > 
> > 	folio_wake_bit(folio, PG_locked);
> 
> Exactly where the lock ownership should be reclaimed is not immediately
> clear to me.  bio_endio() might be early enough but there are probably
> better points.
> 
> A small difficulty here is that a bio has multiple folios and they are
> all locked.  I cannot see that lockdep has a concept of holding an
> arbitrarily large set of related locks.
> We could just tell lockdep 
>   "I have some folios locked" 
> or maybe enhance lockdep to allow
>   "I have N folios locked"
> or even
>   "I have N folios in address-space A with the highest offset being O".
> 
> This would allow lockdep to check the validity of locking another folio
> - only allowed if the address space is the same and the offset is larger
> than the previous largest.

It's more complex than that; see my other emails on the subject.

I think we need the ability for lockdep to call a function which says "I
hold this lock, is that lock OK to acquire".  But the devil is in the
details.

> > 
> > It's interesting, that for writeback we never unlock the folio on the I/O path,
> > but instead have the dedicated page flag to tell us when writeback is complete.
> 
> PG_locked and PG_writeback are two different lock-bits with two
> different meanings.
> When a folio is PG_locked the content is invalid and shouldn't be accessed.
> When a folio is in PG_writeback its data is not safe even though
> PG_dirty has been cleared (if I remember correctly).
> 
> So these are two separate, though related, lock bits that would both
> need to be tracked.  lockdep would detect how they are related.

Some history ... before we had PG_writeback, we held PG_locked
throughout the writeback process.  People argued convincingly that it
was fine to map a page into a process's address space (which requires
PG_locked) while it was being written back.  And so PG_locked was
split.  Now we take PG_locked at the beginning of the writeback process
and downgrade to PG_writeback at some point.

