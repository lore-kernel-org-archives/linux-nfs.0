Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A737D3CE48F;
	Mon,  6 Jul 2026 06:22:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318954; cv=none; b=qhWJgLtYqe7xglIpEt65VPg/HFnp5rrGunszJ9rbHmkaDXsZb8iNyyCXfmB+psrVf68mbj5CDris37CvyCeO7ral+17ed7NVdlseNQxkN6gz9y8aIu6BkWu5zRq7EUsP79aCk6LPkgG+O18rSiE3uFQKRREKbGQiTADZprqaPOs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318954; c=relaxed/simple;
	bh=4COXvF59c/1DTqwH8B+Ve+9eXwb29DTJEmWnDMVF5Ls=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References; b=lFTWbPpL3Gtexk5cMkrHk10RRcwh/+qtm78pBlNmFAaBx81SN8Y/XrYjAhQ7BNsa4uXzqvmKIxdXMghfCOxj8tHxhx1K62b+pMOcIi2zBhC2/+/Ef6OFUT+F0SmU/2/OC02yDYv51YGfgcwNxT2qRruYUIpP1JpoqccUEam/dNI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c2dff70000001609-5d-6a4b4984e6c5
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
Subject: [PATCH v19 39/40] rust: completion: Add __rust_helper to rust_helper_wait_for_completion()
Date: Mon,  6 Jul 2026 15:19:27 +0900
Message-Id: <20260706061928.66713-40-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSWUwTURSGvTP3ToeG6qRqHJFEU3cjbgFzHozhzXGN0TfBYGNHKUIhRTYT
	FUG0EERELdHKYtWGpSJ2wA1xwYALIKCoFQoFRAxBLAKVyCJSjG9f/pP/O+fhsLTSTnxYre6o
	qNepw1WMHMv7vc1+p7duD1tXnuMHhpST4HB2E3APGzBcu2NlYMJ0XwavPiVhcLoNCEbGTDSk
	PJzEMJFVI4Ph360ymKysQWBvfEqDtewUBUOlfxjI7j2FwWVJR9BbvQX6nRUEJtu+UZBnlhjo
	Mw4wMFbfQEP25UYE1zvbaBjs7UBQVtOO4H33TGh2uxjob7pGwY9SBprq+hD0tFRSYMyxYWjq
	G6fAYcyioNi2E5yWHgy1mWZqaicDxrvzwJSdTIElcSl0FVydui4/EtrOX8bwuv0jAefLMwSG
	mzspMDxyY7h+5iaGK7kOBh5XvsaQXlpOoN06SSDRNEKg8Vktgdb68zJoeHSbQGeHnYBUX0eD
	PfMrgts/zAxY3C5ZoEYYScnAQpF0jxJS3k0wgjXXioSx0SwkDN9KpoUX3120cFqKE27VfmeE
	yl/5WHhj5oWbqaOU8PBqm0zIt8UIUsEq4cbjXmr36n3yTRoxXBsr6tduPiAPLSsqRFFfSHzL
	hbMoEblxGvJiec6fH0h202mIneYkR4wnZrjlvN3+m/bwHG4RL53rIWlIztLc+4V8uuXcdHc2
	d5DP/dCAPIy5pXxe2U/iYQW3kX9ruk/++RfyxaXPpkVeU3nJeA7lYSUXwLe6XmKPlOfuePEm
	WxfzrzCff15gx5lIkY9mFCGlVhcbodaG+68JTdBp49ccjIywoal/sxwfD3qABhv3ViGORSpv
	BQRuC1MSdWx0QkQV4llaNUexbMX2MKVCo044JuojQ/Qx4WJ0FVrAYtU8xYZfcRold1h9VDwi
	ilGi/v+UYr18EpGhOCj+SXDxgOPrWMgS59Auokrd71dhja2TF0U9r195tzD7p28LkTahb3G8
	yihVt1zqqJq7Ni81xDG6Izhy8a7CzyMrQ7qqM76c4MKSDmkKBjJKDpT8CYjQS3tqP+uY4NGm
	5u4FK0rKNb6D/q0BPnaiC/T2pWdVXEzTDl3pciaocHSoev0qWh+t/gvXZoFpawMAAA==
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSe0xTdxTHd3730UtjzbWSeONMMDXoYoLTKOM4NwT8gzuNZv8Qk02ijd5A
	eVTTKsqI0VKqFdBAl7bRykOURoEptp2IpJFAxAc+6OqDKIhoxRFQFKnIo2JL4j8nn3O+3/PN
	+eNwlLKJWchptHslnVado2LltHzLOmNc0W+bslbePcKj2XQIe/oCDD42tNIYHDPTePpSA4sh
	R5MMza6TDN56Ukhj18V6wL6gGXB8ykGhqXmGxpClQ4ZjE89kaDUAzng7AG0+C4XdXdcpbPAY
	CH5s/MLiUPsooLU/wKJ90EDjiLMU8NSAQ4aDN1LxbV8LgzO9bwg++TQM6Ax8IRhoPQoYsmVj
	VY07vG57z+LUvQcU2q1dgGf6eykcHXwB6Ol4Dug9X8ji67J/KfQH5uLD4AiLt60lLL71nSb4
	rpHF6kIvg767Q4AVDgvgwFMvQePZSyzaKlw0Nr+4JkPf0DTBHpuFYL1rM/Y5B2jsLKsh4XPD
	rssL0GE3knD5n6D1nxaCE846WVItiOOmE7RY575CRNN/IVZsqGwAcWrSAuJYrZESTWXhtn14
	hBKL3PvF2s5hVpwMPmJF76dqWrxTI4jnjk0SsfxenNh8qlf2e/If8l92STmaPEn3Y+IOeaan
	7gLsecUceFp+FA5DkC4GjhP4NUJhz75iiOJYfpnQ3T1BRTiaXyy4jw8wxSDnKN4fI5Q6j9MR
	YT6/U6h89AAiTPOxQpXnAxNhBf+TcN/RNMsCHyPUN7bOBkWF5xenK0iElXy88GzkJl0G8mr4
	rg6iNdq8XLUmJ36FPjszX6s5sGLn7lwXhN/JeXC6/CqM+VPbgOdANUeBSRuzlIw6T5+f2wYC
	R6miFUt/2JSlVOxS5/8l6XZv1+3LkfRt8D1HqxYoNm6Vdij5DPVeKVuS9ki6byrhohYehvqC
	DKLasP/XReN/Dh46WzRn9Lb6zSuDv+qdN5ZUzqR0HCxWOSfiStakGVlH8/qUgrypto/zRy9P
	O6t+Ftv7l23zJLjnhtITEpNal7xcLs9f70uJeZjcuTW+Pe36Z+32tavdab3xiRb/vG0JUbX9
	LvffZ+al39QXbEi3HzN32hWTBSpan6letZzS6dVfAdgyZ0pKAwAA
X-CFilter-Loop: Reflected
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

This is needed to inline these helpers into Rust code, which is required
for DEPT to play with wait_for_completion().

Signed-off-by: Byungchul Park <byungchul@sk.com>
---
 rust/helpers/completion.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/rust/helpers/completion.c b/rust/helpers/completion.c
index 5ea2eef74abc..7b55c960fe22 100644
--- a/rust/helpers/completion.c
+++ b/rust/helpers/completion.c
@@ -7,7 +7,7 @@ __rust_helper void rust_helper_init_completion(struct completion *x)
 	init_completion(x);
 }
 
-void rust_helper_wait_for_completion(struct completion *x)
+__rust_helper void rust_helper_wait_for_completion(struct completion *x)
 {
 	wait_for_completion(x);
 }
-- 
2.17.1

