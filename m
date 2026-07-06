Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 2EBD33DA5A0;
	Mon,  6 Jul 2026 06:20:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318822; cv=none; b=FAM++fyu1S+xRIeFcGIPvfdvN+baV7f9BtW3U4H9IXF0coqqcnLJ4KtuqkK76UmmTQDeIR/XFMe5zRPPEyyVBTCcUfgzAG3w/9vi0JzWi79DKgOC/xNaflcJbMFqhafl5ZqGj8+5YqysKHmQuq9kOrHLPq4Mi1VIc1vn07TKV2E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318822; c=relaxed/simple;
	bh=+bd9WiorYKiALUTe/ZE9Twmt5uX3p97amk10CfbvR3w=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References; b=Y5w5akgP0ISuBSVGQ02MbCKy+pTq+ifC7UOl34pyd9hXZWKgI1OuJGqWICRul3oUcFyiq8zjYDGQiP5Z8Tf4u2vN7ZcGMSLi9Vr9dfn0qOE9FId7sK2bGSefaTS3LRl9PA0tqpSeDdh4xL8w9nf4UKUHhVGBiypCNVa9uZrYvaU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c2dff70000001609-c9-6a4b48fe94e0
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
Subject: [PATCH v19 13/40] dept: apply sdt_might_sleep_{start,end}() to hashed-waitqueue wait
Date: Mon,  6 Jul 2026 15:19:01 +0900
Message-Id: <20260706061928.66713-14-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSXUxTdxjG/Z/zPx9trDlWM49wASmZmxhlGjXvxT64mOFMk2nUqMEYbezZ
	KFDEgmBNnOJAYYNOMGIGKsWaUvlsqJjxUVNwrpPRUWvACsWKki6T1Q6kMGrZ1hK9++V5nrzP
	e/GwpHyMimPVOfmiNkeZraClWBpYemP9ki92ZH7UM5EEXt8EBcNFdgyhmVIMV9uaafj18TkM
	JZ3/YZiZH2XgteVfGibvTSOo8dcyEPB1U7BQnQV1N6xRvfpvGt44B0moHx8jwWY+R0Pg4VUC
	XlloeDgwieBabRWCzmddDHirqwjwmfwYaq98S8CA0Rsl5yMKnptrGIiMb4Rfmv5goDUwSMGD
	p8MU+BznKWgu95NQ2hXCYBtZB/Xnb2LosT3A4LL/RoG7yYVh1PkDA4NdLRS4KisoMIWCDLjt
	BgKKeo0YzFNXKLhV14Cgyj/NgKPCToBX/xLD3dJnBNwL/UVAuOE+Auedfgb6w/0EPNcHGLgc
	KaWh4/4cA0WvfQj0v6fBP5YXFLQsDCN4dXGGSk0V5kr0WGi03iGEEvcCLTRfb0ZCsbVQCIeG
	aME2a8DCzbIwIVQ61wudNWOMUHx3hBEM7SeE4p8DlGA1JwvGnj8Job2xjN6VmC79WCVmqwtE
	bcqnR6QZtwfKUK6PPWl0tZFnkY/+DklYntvMz7a7qXdsru8mYkxzH/AezzwZ45VcIm+t8Ecz
	UpbkHiXw5aYKHDNWcIf4SPfCYghz7/PB4iEUYxm3le998uRtQQLfZLEvZiRRvTVybbFAzm3h
	R4MOHDvKc3USvmG24e0Xq/leswdfRDIDWtKI5OqcAo1Snb15Q4YuR31yw9FjmnYUHZ3pdOTg
	T2jatacPcSxSLJVB6vZMOaUsyNNp+hDPkoqVsjUf7siUy1RK3SlRe+yw9kS2mNeH4lmsWCXb
	NFuoknNfK/PFLFHMFbXvXIKVxJ1FcVO5ngO7PkuPD2qWO3SF2/p3X0hLGFcd35+UeGbs6JFb
	X+WHOpb9KE9Jspanxi8/BZLM6ylux84vK1uCtrUXHu+zaF7qEz/x7G37Pit9pLV69e6uprl9
	aUNrJ6eIFQZbEn/m8AFV2KsbfK9s++fe06OR/a6+5G86TDWrJgybjC/mLylwXoZyYzKpzVP+
	D4/0jwZwAwAA
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSe0hTcRTH+/3u3d11tLgspVv9UQ16YyVknB5EUbGLVhQUQVB6qUvOV7KV
	ZRE552qahi43qWmp5SV0qfkoH4zWSqtl6LLSHraCZYnWIh/lY9qU+ufwOef7PY8/Dk0o6iXz
	aHXiCUGTyMcrKRkp271RHzrBRcauedfIgtFwHj54vBJ4o3OQMDRoJKGg0kaB33pfCsbqqxJ4
	2plGQntFOQLPkBHB7zErAYaGSRL8phYpDI68l4JZh2DS3oLA4jYR0NX+gABbrQ7DQNUEBX2P
	fiEwf/ZSkN+rI8EnZiG41mOVQm+zCr57miQw2f0VQ+dwPwLRO4HB67iIwG+JgxslNYF2y08K
	xl60EZBvbkdQ/LmbgF+9nxDUtnxEYL+dRsGXnDoCOryz4NWQj4Jn5ksUfHcXYPhRRUFRml0C
	7tY+BIVWE4Ked3YM+puVFFgKq0lo+NQoBXffOIYPFhOG8upd4BF7SHieU4ID5wZcd+eANV+P
	A+EbBvOdJgwjYpl0Synifhsuk1xZzT3MGV76Kc523Ya4sVET4gZL9QRnyAmkj/p9BJdec4or
	fd5PcaNDrynOPlxEcq4SlruVMYq53BehXMO1bumerQdlm44K8epkQbN6c7QsprY1AyV56NM3
	2yuJVOShMlEQzTJr2dvFTXiKKWYp29U1QkxxMLOQrcnukWQiGU0wHQvYLDGbnBJmM4fY8Sb/
	tIlkFrO+9NdoiuXMOvbh27f/hi5gy6sc056gQL1ivHB6gYIJZ9/7npA5SFaEZpShYHVicgKv
	jg9fpY2LSUlUn1515HhCNQr8k3huPLceDXaonIihkXKmHLZExCokfLI2JcGJWJpQBsuXLIuM
	VciP8ilnBM3xKM3JeEHrRPNpUjlHHnFAiFYwx/gTQpwgJAma/yqmg+aloqD0nZtWEMuMGS7X
	nwOZbXnOZ7HBh93DPFUPzcv3RYmOg2c667rx2iPRIQW5hgHCxWxXhabyxrn+sytDnshLLozJ
	V4oFpM8mqvbrlWFLZjTvvJp3/sJHT132or1FO9jS+QPb1u+YuOJytcpupFx/vFDVhsO05bpt
	dZMbOh3O3UpSG8OHrSA0Wv4vV41UCUsDAAA=
X-CFilter-Loop: Reflected
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

Make dept able to track dependencies by hashed-waitqueue waits.

Signed-off-by: Byungchul Park <byungchul@sk.com>
---
 include/linux/wait_bit.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/wait_bit.h b/include/linux/wait_bit.h
index 9e29d79fc790..179a616ad245 100644
--- a/include/linux/wait_bit.h
+++ b/include/linux/wait_bit.h
@@ -6,6 +6,7 @@
  * Linux wait-bit related types and methods:
  */
 #include <linux/wait.h>
+#include <linux/dept_sdt.h>
 
 struct wait_bit_key {
 	unsigned long		*flags;
@@ -257,6 +258,7 @@ extern wait_queue_head_t *__var_waitqueue(void *p);
 	struct wait_bit_queue_entry __wbq_entry;			\
 	long __ret = ret; /* explicit shadow */				\
 									\
+	sdt_might_sleep_start(NULL);					\
 	init_wait_var_entry(&__wbq_entry, var,				\
 			    exclusive ? WQ_FLAG_EXCLUSIVE : 0);		\
 	for (;;) {							\
@@ -274,6 +276,7 @@ extern wait_queue_head_t *__var_waitqueue(void *p);
 		cmd;							\
 	}								\
 	finish_wait(__wq_head, &__wbq_entry.wq_entry);			\
+	sdt_might_sleep_end();						\
 __out:	__ret;								\
 })
 
-- 
2.17.1

