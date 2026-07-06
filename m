Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id B82693DFC6D;
	Mon,  6 Jul 2026 06:20:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318862; cv=none; b=fRlvX9n+6cjdltOB/pc7V/CIKELjFWg2N+HNGubBclcTUc+gOigDYEt7xgkZCTlx6Ig7HE/ppBr+rXSf6mUfjHGjiHRKTrmWaZ65viHdCmRBhX7AEi4sL/JHIpaukBmMlwTpvxI34vWYE88SIODOsNouWuLUirwG+5b+0r1sZZ4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318862; c=relaxed/simple;
	bh=Nq6eF1vNPqQexxbO5CbSo0SEOxl3ixoZ4tUAk3fFOuE=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References; b=XMiP0XGKIVWMuoRsYh20k0phA40CHYuJ0U99IRE+AWerye5mh/ok055w7PQrXsWq0rfvnJmPcj1vLPhRs8nfHnNWTHOE7Taa2w/cmAgJ6b5oMNxbexzOifxcwpuE+9DqNMk5hHZLBE1t6sneKNSyGPpMVP/6/jCmqxGsQwCyGKE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c45ff70000001609-25-6a4b48ff46da
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
Subject: [PATCH v19 16/40] dept: apply timeout consideration to wait_for_completion()/complete()
Date: Mon,  6 Jul 2026 15:19:04 +0900
Message-Id: <20260706061928.66713-17-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSbUxTZxTH99z73NvbxmY3BfUOYzBddBuZCIruJDOED/vwKC7ZYvZhOgbN
	uJPyUkiRt6Gx1reKGAspoFRIa7DraKfYMkW0CbKlipUI1hdEKuCw4EtlMRQjgqyF+OXkd/7/
	f87JSQ5HKx4wcZxas1vUalT5SlaGZaEl1rVoS3pu0qmGFDAc2gdDw2MMhKcMGAyuUwzceKDH
	MBw2IHjzzkzDvMeLoL6/lgZn+34KGp7tx9AYNEsgNHyFgfnAOAW2sfcUjHUdQTBXnwfvem/T
	0FDXh8A6GqDh9bMRBO3exwg8dj0LT41/0XA3PMlCqP80Ba/aWLDoPQz033qBoMlciyA46KHg
	8kinBIbqaylwuL6FYVsQg894JrqehfoLy8HccICKlAkK3tpaJWDTrQZzr5+B2dFkmLcUgtcx
	LoHAiToM50K3Geh5fJ+BS7oRCRg6wxhc/0Za6+EWDFc9PZGz56YQeDueUODvPM2CzvyGgb4u
	HwN3HH0Yzo8PUODz3sDQ0/gHhke9JyRp2aTVfZEih+7MscTZ7ERk6uwBmvz9cpImB91l5Kzv
	JUtmwvdY4pm2YHLzjEBajs5QpKZ3LbncGJAQi6uEHPwnxBC3PeG7dTtkm7PFfHWpqF2XmiXL
	uTc0SBc1y8pbnh9mdGiEq0JSTuBTBG/1KPOBHfaLKMos/5kwMPCWjnIsv0pwHw9GMjKO5v3x
	QrXtOI4aMXyW0DR0aYExv1r4z3mMirKc3yT8bpqlFofGC462roVB0oh+brZpQVfwG4VHk9fx
	YsYhFdpPJi7yJ8I1+wA2IrkFfdSKFGpNaYFKnZ+SmFOhUZcn/lJY4EKRd7Ptnd3ZgV73be9G
	PIeUS+SQtjVXwahKiysKupHA0cpY+ZrP03MV8mxVxW+itjBTW5IvFnejFRxWLpevny7LVvC7
	VLvFPFEsErUfXIqTxunQN10rl/mT635uY4ri7ieF1kw3Ouw+65OvSmcqTROTedL+Thz/vCaz
	qn3HsY/vbrWM3gpsLt9LNli/96b++OlPCemajIfbYmdiTlY2f5kWYzJWrQyuH/yz+teS1Ktx
	XqPJOXH9izK3YufXe0zvl1bqrfIfaj3C9vNFT5P8GRdqxrP0HUpcnKNKTqC1xar/AasiBvRq
	AwAA
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSbUxTZxTHfZ57e3tpKLkWDNeXRG0U3wKTBPSYmaFf9Ilki/GLxqjQzBsp
	r65VXpYYLbXaCRhobNksCKJUAxWxVZSRIi+ObToyEBGCYMHVIgNXBlRGAbuC8cvJ7/z/5/xz
	PhyWkj0SrWCV6acEVboiVc5IaMk3X2oj/SQ+eestUzDodWeh3+kSwUtNEw3eKT0NJXetDMyb
	H4pBb/tJBL/15NLQUVONwOnVI5ieNVOgq/fTMG9oE8PUzCsxGDUI/I42BKZOAwW9HY8psN7X
	YJis/cjAaOsEAuOQi4HiEQ0NHks+gqtusxhGftkL750NIvAPDGPo+TCGwOL6iMHVdBHBvCkF
	yirsgXXTOAOz7X9SUGzsQHB9aICCiZFBBPfbXiNw3M5l4G3hAwq6XCHwwuth4HdjHgPvO0sw
	/FPLQHmuQwSdf4wiKDUbELj7HBi0N+4yYCq10VA/+LMYOkfnMPSbDBiqbV+D0+Km4VlhBQ6c
	G5i6Fw7mYi0OlHcYjHcaMMxYqsS7KhGZ1l2mSZW9DhPd83mGWK9ZEZn1GRCZqtRSRFcYaFvH
	PBQ5b88ilc/GGOLzdjPE8aGcJk8reHLzBx8mRe2RpP7qgHj/7sOSnceFVGWmoPriq0RJUnd/
	H3XymiT75t8XROfQIHsJBbE8F8NX365DC8xwG/je3hlqgcO4Nby9wC26hCQsxXWt5vMtBfSC
	Ecol8qX9DxeZ5tbz49Y8vMBSbht/68oc/hS6mq+ubVoMCgroNXOli7qMi+VfeX6lC5GkHC2p
	QmHK9Mw0hTI1NkqdkpSTrsyO+jYjzYYC/2Q5M1f0CE117W1BHIvkwVLYtS9ZJlJkqnPSWhDP
	UvIwacTG+GSZ9Lgi53tBlZGgOp0qqFvQSpaWh0v3HRQSZdwJxSkhRRBOCqrPLmaDVpxDGY0F
	E9zj1lUe11/BTvcy8CXs2BSnX5s90fhf2/iWnhB/TXLQE4uhznklxB4x+bQs4/q/MW/UpDmr
	e09W6OSPS7dubslcNpTXcLr9xVFU9mSGtQ6bsMaWe2jMEr/Wt6Qxf503rlm/I2rEWcJ/V5QQ
	fSRc2xG/nT92YHno9ju6eomcVicpojdTKrXif+1e7ZpLAwAA
X-CFilter-Loop: Reflected
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

Now that CONFIG_DEPT_AGGRESSIVE_TIMEOUT_WAIT was introduced, apply the
consideration to wait_for_completion()/complete().

Signed-off-by: Byungchul Park <byungchul@sk.com>
---
 include/linux/completion.h | 4 ++--
 kernel/sched/completion.c  | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/completion.h b/include/linux/completion.h
index bd2c207481d6..3200b741de28 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -41,9 +41,9 @@ do {							\
  */
 #define init_completion_map(x, m) init_completion(x)
 
-static inline void complete_acquire(struct completion *x)
+static inline void complete_acquire(struct completion *x, long timeout)
 {
-	sdt_might_sleep_start(&x->dmap);
+	sdt_might_sleep_start_timeout(&x->dmap, timeout);
 }
 
 static inline void complete_release(struct completion *x)
diff --git a/kernel/sched/completion.c b/kernel/sched/completion.c
index 19ee702273c0..5e45a60ff7b3 100644
--- a/kernel/sched/completion.c
+++ b/kernel/sched/completion.c
@@ -115,7 +115,7 @@ __wait_for_common(struct completion *x,
 {
 	might_sleep();
 
-	complete_acquire(x);
+	complete_acquire(x, timeout);
 
 	raw_spin_lock_irq(&x->wait.lock);
 	timeout = do_wait_for_common(x, action, timeout, state);
-- 
2.17.1

