Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A28743D565D;
	Mon,  6 Jul 2026 06:20:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318816; cv=none; b=WJ88BjzwEw1zAbj36q+kH7+MGGlYzZkY+NklHH14PuAbeEWt7OJChPd67Bgj/ThfiYFvdz8duDEcdQIpycxjfxOiBzyflXWlu6kMxz5xjEiEgTy2gCQRwcw/OsPlalPtX2JRPrdKh3WIAtZOJOqxnkJ+xjXMaU7LT7C+a8+Deyo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318816; c=relaxed/simple;
	bh=kGgEzobFbLUd8tx4gLWx/R771yHZRXgu8kLDW12YZyE=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References; b=Dd9Px3vMQwL/v3ZSiNPP2eiEetf67eH5EVQW98So+ZbDO8rOkXuAYtnhbISiZsCc19+yDvwSXMe9jQaYA/wqIdpkaUy4DZMjl5tLMwwQgthtCx1JNdBIseH9HM0MYSdKW2MShN4u17yKPgIVdaC9eZyzCjDRLwX+A5ZtsK6xl9w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c45ff70000001609-4e-6a4b48fd70e1
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
Subject: [PATCH v19 09/40] dept: record the latest one out of consecutive waits of the same class
Date: Mon,  6 Jul 2026 15:18:57 +0900
Message-Id: <20260706061928.66713-10-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSa0xTdxjG9z/nfy6tdJ5UMw5O49Kpcy46MW55XdRo9mEnI2xOE122BD2R
	EyhrCxYssmSRq1Yuk5C1xFYUJNZa8LJ2KLqxVUCQLYayClQu1ja12AFjmgIjokgxfvvleX/P
	8+llSWU/tYxV63IkvU7UqGg5lo/H1a2fE5IyNk4/SwBjyVEY8oco6CtwY5iMGjE8t15nwOg8
	RcGd/kIM/kkjgulnVhJKbsxhiM4MMmAqQGDuqSLB5/mDBFMgREN1pACDJWxlIHL7M5gbHiGg
	f2oMgS30goCQ+ziCs+dcNIya/5t3TR4EdYFhEp5GHiL4peMBghZ7IQ3e0Jtwb3KChi5TGQ3j
	PacJCA+0EFBUf4UGc40Tw5C5ioAGZzL4bWEM5p/jwVr9mIAZm4MB610vBUG7hYHZQCLM1WZC
	R8MIA8MnTRguj3dT0PWgjwJ/5zEKruc/ZMB5/zaC6L0AAY3lYRJOnRmiwfg8iqCjOUhA+dUm
	Cjzuvyj4u8GDoctyEcPg3ZMMdN+8RO1IFRyua4TQeKYRCdHzRaRQUjlPbWMTpFDsyhVapmqx
	8Oc5XrhhGWaE4t8HGKHWeVgobh+nBJd9nVD/W4QQBka3CU7HCXrX+m/kW1Mljdog6T/cfkCe
	3lddiLMeLTrypOIflI/aZaVIxvLcZn7EU0aWInaBz5o1sZjm3uN9vhkyxku5d3hXRZgqRXKW
	5Lwr+XJbBY75SziR77SsjTmYW81HTjThGCu4j/mfmiqIV/Mr+Yar7oUd2Xx+ebZmIVdyH/GD
	E504tslzLhn/Y9RNvyok8LfsPlyJFLXoDQdSqnUGrajWbN6QnqdTH9lwMFPrRPPvZvth9ttm
	9NSzpxVxLFLFKWDH5xlKSjRk52lbEc+SqqWKNWuTMpSKVDHve0mfuV9/WCNlt6K3WayKV2ya
	yk1VcmlijvSdJGVJ+tdXgpUty0e6TxIvjUa2uH1JJXvTktum3992+oPFcUe394h9dmWKtnir
	fTdf3VuzEw5UNfs64w0bn+Q+Tqi/ORpuMXj+/1oabH43ecyaNr0n5d8L0Z3x2rTd+d5fV3k/
	vXjokaO7t3L5lcCxYEbwkP+Lr8KeMkXwrboVX3oP7mrvXdK2z52TlTJZpMLZ6WLiOlKfLb4E
	eVVQ9moDAAA=
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSfUxTZxTGfd/79vbSreymYrxxZtYmfibiR6Y52YxzyyLvUJa5GHWLiTR6
	MwqlmJahmMxBWbPKxECztkphMja6CVWwpcyONBKc+IFuMFSIikBSO/moddiCfBTWmuyfk995
	znOenD8OxyhaJEs4jS5f1OvUWhUrI7KP3y1ZF6M7szcEhxaB2fQ1PBoISOB+cRuBaMRMoKrR
	xULM8ZsUzO6zErjRayTQdbEBwUDUjGByxsGAyTdPIGbpkEJk6qEUrMUI5v0dCGzdFgb6uq4w
	4GouxvCiaY6F0avjCKxDARbsw8UEws5TCCqDDikMX0uD0ECrBOb7/8HQOzGGwBmYwxBo+xZB
	zJYD52o98XXbcxZm7vzFgN3aheDHoX4GxocHETR3PEbg/9XIwpNyLwM9gWS4Gw2zcNP6HQuh
	7ioMz5pYqDH6JdB9exRBtcOCIPjAj6Hkp0YWbNVuAr7B36XQPTqL4ZHNgqHBnQEDziCBzvJa
	HD837rq0GBz2EhwvTzFYL7RimHLWS7fXITppOk1ovacFU9PfMZa6fnAhOjNtQTRSV8JQU3m8
	vToWZug3nqO0rnOMpdPReyz1T9QQeqtWoD+fnMa04s466qvsl37y/ueyrYdFraZA1K/flinL
	um83kiNPXjv2b9kIKkJ/JJUijhP4t4VzNm0pSuJYfpXQ1zfFJDiFVwqesqCkFMk4hu9ZJpxy
	lpGEfyGvFq5Xrk54CL9CGD7pJQmW81uE771lOMECv0xoaGp7lZMU1y/OVr/SFfxm4WH4OilH
	shq0oB6laHQFuWqNdnOqISerUKc5lnooL9eN4t/k/Gq24jKK9KS1I55DqtflsD09WyFRFxgK
	c9uRwDGqFPnK1TuzFfLD6sLjoj7voP5LrWhoR29yRLVYnr5PzFTwX6jzxRxRPCLq/59iLmlJ
	EVo/M/l8xJmVtyHT/eLTzL3LXbrI8bSwYsK49mb2NvbDkMerpKEP7r2XMXcldvCNqvyMz5TK
	j6K9e3z1l996WtR/YvC81N16djL9WajTu/uXpSs2rTnxznLf/v3U32LHXoUn19y8JrXiwAiX
	vGNTLz9undc2vVyAd201K/9sbD+afEZFDFnqjWsZvUH9H6rrtARJAwAA
X-CFilter-Loop: Reflected
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The current code records all the waits for later use to track relation
between waits and events within each context.  However, since the same
class is handled the same way, it'd be okay to record only one on behalf
of the others if they all have the same class.

Even though it's the ideal to search the whole history buffer for that,
since it'd cost too high, alternatively, let's keep the latest one when
the same class'ed waits consecutively appear.

Signed-off-by: Byungchul Park <byungchul@sk.com>
---
 kernel/dependency/dept.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/kernel/dependency/dept.c b/kernel/dependency/dept.c
index 4b4b28ddc819..3af360ba17d8 100644
--- a/kernel/dependency/dept.c
+++ b/kernel/dependency/dept.c
@@ -1486,9 +1486,28 @@ static struct dept_wait_hist *new_hist(void)
 	return wh;
 }
 
+static struct dept_wait_hist *last_hist(void)
+{
+	int pos_n = hist_pos_next();
+	struct dept_wait_hist *wh_n = hist(pos_n);
+
+	/*
+	 * This is the first try.
+	 */
+	if (!pos_n && !wh_n->wait)
+		return NULL;
+
+	return hist(pos_n + DEPT_MAX_WAIT_HIST - 1);
+}
+
 static void add_hist(struct dept_wait *w, unsigned int wg, unsigned int ctxt_id)
 {
-	struct dept_wait_hist *wh = new_hist();
+	struct dept_wait_hist *wh;
+
+	wh = last_hist();
+
+	if (!wh || wh->wait->class != w->class || wh->ctxt_id != ctxt_id)
+		wh = new_hist();
 
 	if (likely(wh->wait))
 		put_wait(wh->wait);
-- 
2.17.1

