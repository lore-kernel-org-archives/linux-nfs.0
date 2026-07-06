Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 4EB2A42640F;
	Mon,  6 Jul 2026 06:21:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318929; cv=none; b=mfTH8bs7WW0ZVQ8ZDCec/V04pPEk9yu0DP4GNYEKVmCaumAd20la56okF9ibsUeRFPRRSO3+/aFZ/nT5TMOFMzgD3e0gWsliV/m7JCIf09tU+IiX+glkzesLwiBTAG029Io5Exx3OVgoOoNO401cvvms+erDmM2WZxrY642mHsA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318929; c=relaxed/simple;
	bh=6m46/bR7ahZ1eyue+jCsPNm2Mx2DXPiA4927jmqmv5Q=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References; b=TzdA8LKYHLZj19MJxXoPWDXagSTQsW8zpXfAFbXqBlyqWQnVIv7ybVao8KhN9eu/lgSOtuPDy7efjTitRO3gCKJosM2tbTn+EoSfYeJ/V/zrYrm0F1Jhej1s8NqM/CRbTImLmk9D8xddCRj4Pjvm31NmDwvsILNX/LeDnBdXIAk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c45ff70000001609-03-6a4b4983b95c
From: Byungchul Park <byungchul@sk.com>
To: linux-kernel@vger.kernel.org
Cc: max.byungchul.park@gmail.com,
	kernel_team@skhynix.com,
	torvalds@linux-foundation.org,
	damien.lemoal@opensource.wdc.com,
	linux-ide@vger.kernel.org,
	adilger.kernel@dilger.ca,
	linux-ext4@vger.kernel.org,
	mingo@redhat.com,
	peterz@infradead.org,
	will@kernel.org,
	tglx@linutronix.de,
	rostedt@goodmis.org,
	joel@joelfernandes.org,
	sashal@kernel.org,
	daniel.vetter@ffwll.ch,
	duyuyang@gmail.com,
	johannes.berg@intel.com,
	tj@kernel.org,
	tytso@mit.edu,
	willy@infradead.org,
	david@fromorbit.com,
	amir73il@gmail.com,
	gregkh@linuxfoundation.org,
	kernel-team@lge.com,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	mhocko@kernel.org,
	minchan@kernel.org,
	hannes@cmpxchg.org,
	vdavydov.dev@gmail.com,
	sj@kernel.org,
	jglisse@redhat.com,
	dennis@kernel.org,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	vbabka@suse.cz,
	ngupta@vflare.org,
	linux-block@vger.kernel.org,
	josef@toxicpanda.com,
	linux-fsdevel@vger.kernel.org,
	jack@suse.cz,
	jlayton@kernel.org,
	dan.j.williams@intel.com,
	hch@infradead.org,
	djwong@kernel.org,
	dri-devel@lists.freedesktop.org,
	rodrigosiqueiramelo@gmail.com,
	melissa.srw@gmail.com,
	hamohammed.sa@gmail.com,
	harry.yoo@oracle.com,
	chris.p.wilson@intel.com,
	gwan-gyeong.mun@intel.com,
	boqun.feng@gmail.com,
	longman@redhat.com,
	yunseong.kim@ericsson.com,
	ysk@kzalloc.com,
	yeoreum.yun@arm.com,
	netdev@vger.kernel.org,
	matthew.brost@intel.com,
	her0gyugyu@gmail.com,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	bp@alien8.de,
	x86@kernel.org,
	hpa@zytor.com,
	luto@kernel.org,
	sumit.semwal@linaro.org,
	gustavo@padovan.org,
	christian.koenig@amd.com,
	andi.shyti@kernel.org,
	arnd@arndb.de,
	lorenzo.stoakes@oracle.com,
	Liam.Howlett@oracle.com,
	rppt@kernel.org,
	surenb@google.com,
	mcgrof@kernel.org,
	petr.pavlu@suse.com,
	da.gomez@kernel.org,
	samitolvanen@google.com,
	paulmck@kernel.org,
	frederic@kernel.org,
	neeraj.upadhyay@kernel.org,
	joelagnelf@nvidia.com,
	josh@joshtriplett.org,
	urezki@gmail.com,
	mathieu.desnoyers@efficios.com,
	jiangshanlai@gmail.com,
	qiang.zhang@linux.dev,
	juri.lelli@redhat.com,
	vincent.guittot@linaro.org,
	dietmar.eggemann@arm.com,
	bsegall@google.com,
	mgorman@suse.de,
	vschneid@redhat.com,
	chuck.lever@oracle.com,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	trondmy@kernel.org,
	anna@kernel.org,
	kees@kernel.org,
	bigeasy@linutronix.de,
	clrkwllms@kernel.org,
	mark.rutland@arm.com,
	ada.coupriediaz@arm.com,
	kristina.martsenko@arm.com,
	wangkefeng.wang@huawei.com,
	broonie@kernel.org,
	kevin.brodsky@arm.com,
	dwmw@amazon.co.uk,
	shakeel.butt@linux.dev,
	ast@kernel.org,
	ziy@nvidia.com,
	yuzhao@google.com,
	baolin.wang@linux.alibaba.com,
	usamaarif642@gmail.com,
	joel.granados@kernel.org,
	richard.weiyang@gmail.com,
	geert+renesas@glider.be,
	tim.c.chen@linux.intel.com,
	linux@treblig.org,
	alexander.shishkin@linux.intel.com,
	lillian@star-ark.net,
	chenhuacai@kernel.org,
	francesco@valla.it,
	guoweikang.kernel@gmail.com,
	link@vivo.com,
	jpoimboe@kernel.org,
	masahiroy@kernel.org,
	brauner@kernel.org,
	thomas.weissschuh@linutronix.de,
	oleg@redhat.com,
	mjguzik@gmail.com,
	andrii@kernel.org,
	wangfushuai@baidu.com,
	linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-media@vger.kernel.org,
	linaro-mm-sig@lists.linaro.org,
	linux-i2c@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-modules@vger.kernel.org,
	rcu@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rt-devel@lists.linux.dev,
	2407018371@qq.com,
	dakr@kernel.org,
	miguel.ojeda.sandonis@gmail.com,
	neilb@ownmail.net,
	bagasdotme@gmail.com,
	wsa+renesas@sang-engineering.com,
	dave.hansen@intel.com,
	geert@linux-m68k.org,
	ojeda@kernel.org,
	alex.gaynor@gmail.com,
	gary@garyguo.net,
	bjorn3_gh@protonmail.com,
	lossin@kernel.org,
	a.hindborg@kernel.org,
	aliceryhl@google.com,
	tmgross@umich.edu,
	rust-for-linux@vger.kernel.org
Subject: [PATCH v19 36/40] dept: track PG_writeback with dept
Date: Mon,  6 Jul 2026 15:19:24 +0900
Message-Id: <20260706061928.66713-37-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSf1CTdRzH+z57nmdjuXpcnD3iJd38xWGSdlDv66Lor75l3Zn1j3ZeTXku
	huNHAxHo6gbCBERZI9GDltPp4HApja70CG9C/uAA08Ixhp7oEbYGTOdGjSDb8PzvdZ/3vV/v
	fz4Kmfo6l6TQ5RdLhnytXsMrWeXUomPr9ry9MXe9270BkXANi29OO3lcHq5kUX32IYtwdFSO
	gxUEzh8qGAR6QwRBRz2B/8JbGJ6ZJJhv2olA0z0eIf8YwVAkyKPv4D4e0x08rg0ECKwtFoI9
	9tM8mqwuFtcCcwxOut5Dv/kYg0N+HlFHuxwO4yo8tBUgMGHhceuSiYNr5AJBeOg2g27fWhw1
	HWdRMx8muHjmDgNjy98crrr7OcwcWAav+Q+CxukJAkckKMdvbhuDivN2FhdtS2CZCMlhevAf
	hxPhaRn2/tnFY2iki+BczRiDE21TsSmnh8fdZiuD3sgkA4/lCI/Z1th8yBqrVddH5WipOECw
	r7qJRdWNDHw37yGYNoe5rCzq/NZJaO9kUEarOnfT2ch1nh6vnWXoV4Pr6Nnmm3Jadc4npzbX
	LtrZlkrtP/sZejQU4agvkEld7bU8vXz4X5aODx1iNj23VflatqTXlUiGF1//RJkzWGuSFUaX
	lwYiJmIk0aV1JEEhCulie7BR/pgjPvsC88Ia0euNyuKcKDwvdu6f4OqIUiETfk8W6x372Xjw
	jJAptnabuTizwiqxbuqnBVYJL4tHxq6QR9Jk8WSHe0GUELufmrMycVYLGeJo8BIbl4qCPUEc
	9zdyjwpLxfNtXtZMVDbyRDtR6/JL8rQ6fXpaTlm+rjRtR0Gei8SezfHF3EdnSOjqBz1EUBDN
	IhWy3slVc9qSorK8HiIqZJpE1eqUjblqVba2rFwyFHxs2KWXinrIMgWreVb10szubLXwqbZY
	2ilJhZLhccooEpKMJDN1s2/As6Xvx7KnbnRv/3Jx5YPBuuT7r95lb6Xea/h128Bnb+aY1s5X
	VXaU973/tC4r7fPmry2FDYXJJa1ISbrTX/9kQ4b7wzeuJC5fqW/zhLv04RdKEfi+mCu/abOO
	BveOdP7TQFfrNkVX3F+/xtv113jKKwOZ78K4YtjTvG1J+u1fNGxRjnZDqsxQpP0frpyfJmgD
	AAA=
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSe0hTcRTH+/3u3b3X1eqypF0LKhZZBPaAHodeGP3RLXv9E1EEOfKS87Fs
	K8sgcq6Z2oM52qSWZZYr1HRtpi4bmaI9V5pZZpmTlmVqlrlkU7Ot6J/D53y/53w5fxyGkFaL
	pjNK1SFBrVIkySkxKd66Shel2xiTsPjcZxlk6U/A+06vCF5ra0nwDWWRcKm8lIIxSxUNWfYL
	Inj0JoOEprISBJ2+LATDIxYC9M5xEsaMjTQM+d/RYNIiGHc1IjA3Gwloa7pPQGmFFsNP228K
	eusHEZi6vBTk9WhJGLCeQXCx20JDT8MG6O+sEcF4x2cMb371IbB6f2Pw1p5CMGZOhCuFjuC6
	+TsFI+4XBOSZmhBc7eogYLDHg6Ci8QMC180MCj4Z7hDQ4p0Mr3wDFDw2naagv/kShm82Cgoy
	XCJoftaLIN9iRNDd7sKgu1ZOgTnfToLTc5eG5t5RDO/NRgwl9i3Qae0m4amhEAfPDU7dloEl
	T4eD5QsG060aDH5rMR1dhPhh/TmSL3ZUYl7/coziSy+XIn4kYET8UJGO4PWGYFvfN0DwJx1H
	+KKnfRQf8LVSvOtXAck/KeT469kBzOe6o3jnxQ56+7rd4tVxQpIyVVAvWhsrjndnZxIp/plH
	e32ZKB35I3JQGMOxSzlf+zU6xBQ7j2tr8xMhDmdnc46z3aIcJGYItmUWd8Z6lgwZU9k13A2X
	QRRikp3L5fRX/WUJu5y74nmO/oXO4kpstX+DwoJ62Wg+DrGUXca9G3hIGpC4AE0oRuFKVWqy
	Qpm0bKEmMT5NpTy6cN+BZDsK/pP1+GhuNRpq2VCHWAbJJ0kgelOCVKRI1aQl1yGOIeThksj5
	MQlSSZwi7ZigPrBXfThJ0NShGQwpl0k27RRipex+xSEhURBSBPV/FzNh09MRjrj6zL1+5Y8d
	JdOWb7N50iar7ztaTQerH6dksrYpw7YCO7+Cylhd4ZNFBNyt0Z6Jztzsr5Vz6HqTNEp1eIq/
	xWlfpS107Gr8tujezqrUBTWayB+bB+Uzu9Lxp/lvA7ntcXNUchkzcVJt5ANZ4g22wRUOLxKs
	5/eUn/jYcLwyRk5q4hVLFhBqjeIPAg6jj0sDAAA=
X-CFilter-Loop: Reflected
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

Makes dept able to track PG_writeback waits and events, which will be
useful in practice.

Signed-off-by: Byungchul Park <byungchul@sk.com>
---
 include/linux/mm_types.h   | 1 +
 include/linux/page-flags.h | 7 +++++++
 mm/filemap.c               | 6 +++++-
 mm/mm_init.c               | 1 +
 4 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e25d09f3dfa9..81dc9999090a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -222,6 +222,7 @@ struct page {
 #endif
 	struct dept_page_usage usage;
 	struct dept_ext_wgen pg_locked_wgen;
+	struct dept_ext_wgen pg_writeback_wgen;
 } _struct_page_alignment;
 
 /*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 0b0655354b08..ec736811a2c6 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -203,6 +203,7 @@ enum pageflags {
 #include <linux/dept.h>
 
 extern struct dept_map pg_locked_map;
+extern struct dept_map pg_writeback_map;
 
 static inline void dept_set_page_usage(struct page *p,
 		unsigned int new_type)
@@ -292,6 +293,8 @@ static inline void dept_page_set_bit(struct page *p, int bit_nr)
 
 	if (bit_nr == PG_locked)
 		dept_request_event(&pg_locked_map, &p->pg_locked_wgen);
+	else if (bit_nr == PG_writeback)
+		dept_request_event(&pg_writeback_map, &p->pg_writeback_wgen);
 }
 
 static inline void dept_page_clear_bit(struct page *p, int bit_nr)
@@ -300,6 +303,8 @@ static inline void dept_page_clear_bit(struct page *p, int bit_nr)
 
 	if (bit_nr == PG_locked)
 		dept_event(&pg_locked_map, evt_f, _RET_IP_, __func__, &p->pg_locked_wgen);
+	else if (bit_nr == PG_writeback)
+		dept_event(&pg_writeback_map, evt_f, _RET_IP_, __func__, &p->pg_writeback_wgen);
 }
 
 static inline void dept_page_wait_on_bit(struct page *p, int bit_nr)
@@ -311,6 +316,8 @@ static inline void dept_page_wait_on_bit(struct page *p, int bit_nr)
 
 	if (bit_nr == PG_locked)
 		dept_wait(&pg_locked_map, evt_f, _RET_IP_, __func__, 0, -1L);
+	else if (bit_nr == PG_writeback)
+		dept_wait(&pg_writeback_map, evt_f, _RET_IP_, __func__, 0, -1L);
 }
 
 static inline void dept_folio_set_bit(struct folio *f, int bit_nr)
diff --git a/mm/filemap.c b/mm/filemap.c
index c0bff1e08a28..e3aa2754da3f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1197,7 +1197,7 @@ static void folio_wake_bit(struct folio *folio, int bit_nr)
 	 * dept_page_clear_bit() being called multiple times is harmless.
 	 * The worst case is to miss some dependencies but it's okay.
 	 */
-	if (bit_nr == PG_locked)
+	if (bit_nr == PG_locked || bit_nr == PG_writeback)
 		dept_page_clear_bit(&folio->page, bit_nr);
 
 	spin_lock_irqsave(&q->lock, flags);
@@ -1254,6 +1254,9 @@ static inline bool folio_trylock_flag(struct folio *folio, int bit_nr,
 struct dept_map __maybe_unused pg_locked_map = DEPT_MAP_INITIALIZER(pg_locked_map, NULL);
 EXPORT_SYMBOL(pg_locked_map);
 
+struct dept_map __maybe_unused pg_writeback_map = DEPT_MAP_INITIALIZER(pg_writeback_map, NULL);
+EXPORT_SYMBOL(pg_writeback_map);
+
 static inline int folio_wait_bit_common(struct folio *folio, int bit_nr,
 		int state, enum behavior behavior)
 {
@@ -1697,6 +1700,7 @@ void folio_end_writeback_no_dropbehind(struct folio *folio)
 		folio_rotate_reclaimable(folio);
 	}
 
+	dept_page_clear_bit(&folio->page, PG_writeback);
 	if (__folio_end_writeback(folio))
 		folio_wake_bit(folio, PG_writeback);
 
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 66b68c02d8d4..2695d7b3b089 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -589,6 +589,7 @@ void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	page_cpupid_reset_last(page);
 	page_kasan_tag_reset(page);
 	dept_ext_wgen_init(&page->pg_locked_wgen);
+	dept_ext_wgen_init(&page->pg_writeback_wgen);
 
 	INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
-- 
2.17.1

