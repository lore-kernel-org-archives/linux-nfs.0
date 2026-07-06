Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 5D79F3E5ED1;
	Mon,  6 Jul 2026 06:20:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318883; cv=none; b=az8nz1xwnlEeF06HVXextVelV/8ZW+8u9A/TC0rQdPcyFlBCyIqDgIkriObMoVYc/1r9H9L8zLMXBxWrIGpXnZws/Qi9hCj2z7iVf/SaS1Rdrm73F11paIEVirPsELtwjqUWfC++XKlD3OoxK48GMrjAvx1rpcQuIDefp8i47nY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318883; c=relaxed/simple;
	bh=zZ0Z4ACi/Apbu1QY77b88sFXV1NHqKJHKoHUY4xopZ0=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References; b=Gtra1pLvt8zHhoHdh6hVgvazZIVQhCpuKMRxECeLujRLfiOY0y+eFSE06mKTfB81+QhaGcpl5V609iqhBU1hl7p6LeaZAV6AXaqovfB9WTb5fgMcPPzKysaG+bggndgZtYGHksPlGAFInoNGkg/+ozftmTk/YkXHKcjTSpWUlgc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c45ff70000001609-61-6a4b48ff3f1c
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
Subject: [PATCH v19 18/40] dept: apply timeout consideration to waitqueue wait
Date: Mon,  6 Jul 2026 15:19:06 +0900
Message-Id: <20260706061928.66713-19-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSa0wTaRSG95v5Zjpt7GZSUccbaBPWW0AxXk7i9YfZjhIvCZA1anQbOpFi
	QVMURWMsFLAKIjYLRCpaLjYIqNja9dqIKCgCtohCVRBQrFFAElMw5aK2Gv89531y3vPnMKSs
	nZrGqBP3C9pEpUZOS7BkYEJxGLE+Mn5RVs5sMGQcg46uXgraUmswDHkNGMZNN0TwuD0NQ9eQ
	AcHXURMJ48Z6EXh9r0WQl4qg78EXBAUfUzF8rFPA984PBFh6vxHQW3McwXj+HrhQYqNhtNlJ
	QkGeC0FxTycJ1+vfIHCUp9HwPtdOwvOhQRoGWs4R8LmaBnOag4KWpj4ERSYjAn3pVRryi6wY
	Kq0bocviwf5zNJgK9AT4LBUiaCrtwGDRhYKpuZWCt+WFIhjriYDO03kY+jxGGroeZVJgfVmH
	oCrbQ4L1XRsFjlcLoDizDMPZ8x003HU0YDCMexHU33xLQHa1nQKd6SsFrppGCp5VujBc/eAm
	oLH+MYaGwksYnLcvU9DT7abWqvgK2/8EX3W+CvGjI0bEey/qST4j1z8+6B8k+XTbQf5iYz/N
	jwy9oHnHsBnzT0o4vuzECMGfaQ7jbxV2iniz9QCf/nCA2hK2TbJSJWjUyYJ24ep/JXHtJS3U
	PrvoUMM3H61D6fRJJGY4dglX8mJE9JvtT8/8zGl2Dud2+8gAB7GzONspD3USSRiSbQ3hsi2n
	cEBMZDdxN/QDfsEwmA3lun1/B2Ipu4wrbtVRvzpDuMrqmp89Yn9+ZayICLCMXcq9HnyEA50c
	e0HM5Q97iV8LU7n75W6ci6Rm9EcFkqkTkxOUas2S8LiURPWh8Ni9CVbkfzfL0bHtN9EXV1Qt
	YhkknyCFtRviZZQyOSkloRZxDCkPkv41NzJeJlUpUw4L2r27tAc0QlItms5g+RTp4uGDKhm7
	W7lf2CMI+wTtb0sw4mk6FGHQ+NqemLOWd9/bab/X8p87Jzhj8g5245o7Tpc2ZdalZ5tvbW7Y
	iv45UhYtX7xbEWKrRcbYVZHrQj2q05nX6jT5TbJJR+3sJsVMN9qQGtcd1XQkvDk4Da8IdruC
	SmPORqtjnTEz9Gj0xFjWvLCYnP71BnFIjOJT7J9OxWXP7Ao5TopTRswntUnKH7QzLI9qAwAA
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSbUhTcRTG+9+X/66jxW0ZXgoxFqkU9gIWB4ooorq9SfQl6IVa7pbTOWMz
	S0NS18re52KTmppZjtBZpplprUTJMlu5VimpqbBW4tQop0ydNou+HJ7z/M55OB8OQ0pr6QWM
	Up0qaNRylQyLKXHcWl3MNL8jceULx1LI1Z+Brh43DZ+zGyjwjeRSUPDAhiFgqRVBbtUNGl63
	51DQdr8cQY8vF8HYhIUEfd00BQFjswhG/J0iMGUjmLY3IzA7jSR0tL0gwfYom4DflVMYBpp+
	ITD1uTHk92dTMGy9jOCmxyKC/pdbYbDnKQ3T3d8JaB/1IrC6pwhwN5xHEDAnwa2S6uC6+SeG
	Ccd7EvJNbQhu93WT8Ku/F8Gj5q8I7PdyMHwz1JDgcs+Bj75hDC2mSxgGnQUEDFViKM6x0+B8
	O4Cg0GJE4PliJ0B35wEGc2EVBXW99SJwDkwS0GU2ElBetQt6rB4KWg0lRPDc4NTDMLDk64hg
	+UGAqeIpAX5rmWhDKeLH9Fcpvqz6McHrPwQwbyuyIX5i3Ij4kVIdyesNwbbJO0zyZ6tP8qWt
	XsyP+z5h3j5aTPFvSjj+7oVxgs9zxPB1N7tFuzfuE69TCCplmqBZsf6wOKG9xEkfrxGdapny
	4yx0Fl9EIQzHxnI17/L+asxGcR0dfnJGh7KLuOorHvoiEjMk64rgLluvUDNgHhvH1eoGg4Bh
	KHYJ1+vfMmNL2DXcbVcW/S8zgiuvbPibExL0708WEjNayq7mOodfUQYkLkazylCoUp2WLFeq
	Vi/XJiWkq5WnlsenJFeh4DtZMyfznqAR19ZGxDJINlsCG7YnSml5mjY9uRFxDCkLlURG70iU
	ShTy9AxBk3JIc0IlaBvRQoaShUm27xUOS9lj8lQhSRCOC5r/lGBCFmShcKHp0n7x4oqD9c9j
	PU80Ec1Ru0LLIgcDIes2OxRDYerzC78uq8/c41BEH2DIlnMVcXfH9tWc3onqwsszZUdu4Mii
	obnxnX3Xw+dvTHrojY5JUOgXkae37DxqHcUHfftfdn1KJeNd3kDAoZJ+kG+KNYiv2bZltGSY
	nkmob8YoWkZpE+SrlpIarfwPjIP3fkoDAAA=
X-CFilter-Loop: Reflected
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

Now that CONFIG_DEPT_AGGRESSIVE_TIMEOUT_WAIT was introduced, apply the
consideration to waitqueue wait, assuming an input 'ret' in
___wait_event() macro is used as a timeout value.

Signed-off-by: Byungchul Park <byungchul@sk.com>
---
 include/linux/wait.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index c8f8b44060fb..a9524bc8630b 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -306,7 +306,7 @@ extern void init_wait_entry(struct wait_queue_entry *wq_entry, int flags);
 	struct wait_queue_entry __wq_entry;					\
 	long __ret = ret;	/* explicit shadow */				\
 										\
-	sdt_might_sleep_start(NULL);						\
+	sdt_might_sleep_start_timeout(NULL, __ret);				\
 	init_wait_entry(&__wq_entry, exclusive ? WQ_FLAG_EXCLUSIVE : 0);	\
 	for (;;) {								\
 		long __int = prepare_to_wait_event(&wq_head, &__wq_entry, state);\
-- 
2.17.1

