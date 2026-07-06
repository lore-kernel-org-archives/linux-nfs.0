Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 2C3003E5A32;
	Mon,  6 Jul 2026 06:22:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318941; cv=none; b=Z9FxOz8QFlVy5LIitkbAZJDaT8BQHHtuXXPAXlH+QvpGLd4dTg4dGon7uz3U5azN7V8FICQtc2h6YTXPitR/d3evNWEl0WvLcVeFGYAa27zuXHorHJd6tCC4e+XdVRkqo3gViqEbLoKGvdnO9nz6hwJEmHIj9X9IOQJ6/MBDVK8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318941; c=relaxed/simple;
	bh=yYQ/ICrr4Ybg4wzxLt2HdYTviFZ3VJcNVrq9rKQPtWM=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version:Content-Type; b=l6pkNDhQSBxb/7NDkEfoqvXfZefrXMctwmpOloYxiriD65lR+aqLVZpj/Peej+fJpTETL/bsHxVj/IQtLm1hpIrPY1qFU2hF0/qnLa1c0zDRBg5lKt+cv1u62U13mRxM8Y33xdSZcq5TaAnObEVPS30piuQwMMlSaLu2mOsOEGw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c45ff70000001609-21-6a4b4983f504
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
Subject: [PATCH v19 37/40] SUNRPC: relocate struct rcu_head to the first field of struct rpc_xprt
Date: Mon,  6 Jul 2026 15:19:25 +0900
Message-Id: <20260706061928.66713-38-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxbdRTG87//+0azbneVZddNs63JNoMO0eA8M4YQY8x1+2LiWzY12shV
	WnlpWmCDzA0cVMZga6qw0IaujJeRtgi01IFQ0mEoIpAhaGmhCNXKZpxbtnUgA5y3kMV9+53n
	PM9zvhwWKxrobaw6J0/U5aiylLSMlP29oX5f6euHNCkOxyYoLzsJ4dkoBYESHwmrlssMLC5b
	MJR1P5BGk5+B2NI0A9UlCB54/QicnSUEVEeiNJjnLQxEfV8iWB69iqE+MoPhD6MHw0R0IwxV
	n6FhfspLQE2di4Rh40WJOraC5fx1Kd7aQ8BIQ5iEmXPVJMwOGii4XDzHgOv3AAXeqaeh3tBI
	Qq01TEOvd4gEf9dvBFS2eygY8w1TMO4YI6HtWpCAYf8PJEyPnmPg6netFDRN/kRAZC5IgXt0
	BMPC2e3w10IzhnGfjQDD3X8pGKzyEdAUu4nh51APgr7yOQJ+nLnLwFfjNhoCpgs03KmTfJaS
	swjOlNWQ4BlYZKD99iUaYg47Da2rAQQ3jTEqPV1wWp1IWL5vQkKs6RQWmoZv0ML9e7/QgnfB
	Rgrd5hlGKO2bYgSbK19wtyQJDb1/EoLLfpoW6pevYyEc6KWF/u/LkdAdOfDGk0dkL2eIWeoC
	Ufds2keyzJaWAaS9sflYj8FKF6PajRUogeW5VH7i9kX8kMdNXUycaW4vHwwuremJ3E7eXTVP
	VSAZi7mJHXxlcxUZXzzGqfj5yGkiziS3m7dO3qPiLOf28yMdRrReuoN3tPvWihIk/ZuVujW/
	gnuBn741SK77N/NDtVGJWenAXr7NqojLWIqe8lhw/C7P/ZrAhwYqifXOx/krLUHSiDjzI3Hz
	/3HzI3EbwnakUOcUZKvUWanJmYU56mPJH+dmu5D0us2fr7zXhe6MvdmPOBYpN8gh/aBGQakK
	9IXZ/YhnsTJRvuepQxqFPENVWCTqcj/U5WeJ+n60nSWVW+XPLxzNUHCfqvLEz0RRK+oebgk2
	YVsx0h79wJq/+62KE/SKJtiqDJ5I9WWGXju++Iya8nzSGDSoNbmrLx6OFRzZUsnk2buLa5JT
	XklzExMd/i1J+51X3i994rC26EDkgkGr63zn2753XzU11x4kuK+dUKhL99tL3UQoxem4lPb2
	dFtbOPTSF7uKlmYn6/boMxr/SXJ37ktUkvpM1XNJWKdX/Qc09s50tgMAAA==
X-Brightmail-Tracker: H4sIAAAAAAAAA02Sa0wTWRSA986dTofGkrGQOEFd3GZ9xKi7m4g5icZHjHFWsmY3/jDxj050
	lPKStIBgVgVqsSBuSpOW0EpFlIpQBYuoiF0JBlypRBBZiIKIW4uEIkZbTUsLTjUb/XPz3XO+
	8/hxaKyYlSTQqsxsQZ3JpyspGSnbuV67WvtrcurPd6ZWgV53AoZHPRL4t7CdhIBfT8LZRgcF
	EetNKeidlRL4Z7CIhN6rDQhGA3oEH2esGHStcyREjF1S8AefScFUiGDO1YXA3GfEMNR7F4Pj
	eiEB75tmKZi89w6BacxDQcVEIQnT9jIEFq9VChOd22FqtE0CcyPjBAx+8CGwe2YJ8LSfQhAx
	p8G5mmax3PyWgpmeRxgqTL0Izo+NYHg38QLB9a7nCFx1RRS8MrRg6PfEwpPANAUPTKcpmOo7
	S8CbJgqqi1wS6Hs4iaDKakTgfeoiQHuhkQJzlZOE1he3pdA3GSZg2GwkoMH5G4zavSS4DTWE
	uK5oXVsA1gotIT6vCTBdaSMgaK+Xbq5F3EfdXyRX33yD4HSPIxTnsDkQNxMyIs5fq8WcziB+
	7/mmMXey+QhX6/ZRXCgwQHGuD9Uk113DchdLQgRX3rOaa7WMSH/fske24YCQrsoV1D9t3CdL
	qavrRFm++XltxTaqAFXGlqIYmmXWso+Nt6RRppjl7NBQEEc5nlnCNp/xSkqRjMZMfyJbZj9D
	RhNxDM96x0qIKJPMUtY2GJBEWc6sYx9eM6AvTRPZhqb2z41ixPjVcNVnX8Eksc+m75Nf/Pns
	g0qPyLQ4YDnbaFNEw1gs1bZYsQHJLd9Ylq+W5RurGuF6FK/KzM3gVelJazRpKfmZqrw1+w9n
	OJF4lfZj4fJbyN+/vQMxNFLOk8PmHakKCZ+ryc/oQCyNlfHyZSuSUxXyA3z+UUF9eK86J13Q
	dKCFNKlcIN+xW9inYA7x2UKaIGQJ6v+zBB2TUIDc/SH3wN/2FcGw+whOlI//t3/D4q0q/6ns
	E/rZsLaok36y9sdd53aef2+L7eiu7fTLy5OX3L/rjJMlWkqK12/JebrIl1vwZ0vCywGjMdU/
	Hjn0aLCUPh7nefvHd3k/bJu7nJT1KlS2tFu1yTFsv33cqjp9MFzM56yq6Io/+X2wZ/ElJalJ
	4X9ZidUa/hOqfMNukQMAAA==
X-CFilter-Loop: Reflected

While compiling Linux kernel with DEPT on, the following error was
observed:

   ./include/linux/rcupdate.h:1084:17: note: in expansion of macro
   ‘BUILD_BUG_ON’
   1084 | BUILD_BUG_ON(offsetof(typeof(*(ptr)), rhf) >= 4096);	\
        | ^~~~~~~~~~~~
   ./include/linux/rcupdate.h:1047:29: note: in expansion of macro
   'kvfree_rcu_arg_2'
   1047 | #define kfree_rcu(ptr, rhf) kvfree_rcu_arg_2(ptr, rhf)
        |                             ^~~~~~~~~~~~~~~~
   net/sunrpc/xprt.c:1856:9: note: in expansion of macro 'kfree_rcu'
   1856 | kfree_rcu(xprt, rcu);
        | ^~~~~~~~~
    CC net/kcm/kcmproc.o
   make[4]: *** [scripts/Makefile.build:203: net/sunrpc/xprt.o] Error 1

Since kfree_rcu() assumes 'offset of struct rcu_head in a rcu-managed
struct < 4096', the offest of struct rcu_head in struct rpc_xprt should
not exceed 4096 but does, due to the debug information added by DEPT.

Relocate struct rcu_head to the first field of struct rpc_xprt from an
arbitrary location to avoid the issue and meet the assumption.

Reported-by: Yunseong Kim <ysk@kzalloc.com>
Signed-off-by: Byungchul Park <byungchul@sk.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/xprt.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index f46d1fb8f71a..666e42a17a31 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -211,6 +211,14 @@ enum xprt_transports {
 
 struct rpc_sysfs_xprt;
 struct rpc_xprt {
+	/*
+	 * Place struct rcu_head within the first 4096 bytes of struct
+	 * rpc_xprt if sizeof(struct rpc_xprt) > 4096, so that
+	 * kfree_rcu() can simply work assuming that.  See the comment
+	 * in kfree_rcu().
+	 */
+	struct rcu_head		rcu;
+
 	struct kref		kref;		/* Reference count */
 	const struct rpc_xprt_ops *ops;		/* transport methods */
 	unsigned int		id;		/* transport id */
@@ -317,7 +325,6 @@ struct rpc_xprt {
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	struct dentry		*debugfs;		/* debugfs directory */
 #endif
-	struct rcu_head		rcu;
 	const struct xprt_class	*xprt_class;
 	struct rpc_sysfs_xprt	*xprt_sysfs;
 	bool			main; /*mark if this is the 1st transport */
-- 
2.17.1

