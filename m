Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 366683A1D02;
	Mon,  6 Jul 2026 06:19:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783318785; cv=none; b=pObR3vMC9de4UiH0LUELbadndz6mX/B/4plCxFFoI9nCiKc0Yiwg9GINqlhiWiqW+U+zQBcEip5f4lezQWa6o22m1qg9VxKkB99We5OfXmAoB0gzI/NPUCMsYtT7GsWmRvtOpjlL887WbRKpp4J+cxe4Go1+Uo4ezonrBULvonU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783318785; c=relaxed/simple;
	bh=UPgrUdj2zJuIcM2CRwF3Ndg48wh45GAuitrkG1THTag=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References; b=lNax9jNAKf0exLu4g0QgBNMnleF1ztMIGeuZJ7+nYzvhMm1WCs58Fm+8w5/op+xOJ0x11C5MifJFReB/zy6K/sW4N7mJ/0MBKEGto3mOdu94+ED0QkFI8/Lm9w8jtGaGQXelbDR6EgJLKQXQ4AE3ATI+0l6gxqc5bUyduFETRuY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c2dff70000001609-75-6a4b48fb3220
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
Subject: [PATCH v19 02/40] dept: add single event dependency tracker APIs
Date: Mon,  6 Jul 2026 15:18:50 +0900
Message-Id: <20260706061928.66713-3-byungchul@sk.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20260706061928.66713-1-byungchul@sk.com>
References: <20260706061928.66713-1-byungchul@sk.com>
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSbUxbZRTHfe597ksb6m66t0eWOG0UcZEhZDPHZBI+7MMziUZjTBYXdTdw
	A2VQSGFsmKiwDmWw4SQR4wqkFimmZba22QvjZchmNwKN7STQ0TqYKAyhq3PYjRXEdrpvv5z/
	//xyPhyR1U5yqaLeUKkYDXKJjldjdSTFmrFC84pf9LWlQn3dxxCe+o2D8dpBDK3Obh6uThzB
	cC9uZqGuZw3DarNXgKXlkABB/0UWorbjCE7NmgWITPVyMBFbRBD3/cTC7yfPsDD2d5SHSKCV
	gdsuHtrMzQhmJ/sZMHU4eWhpc2Pomb4gQGBhhQGH+zWYss1iaPl+M5i/NDHwxeleBpZtdgFG
	O8IY1ixl4HXMCTB8Y5wD9/UfEbhnEvRVe5iHvv5hDPWrSwhqzPc48A+OcOCcCzIw4r2KIeT7
	TIDOiQADN6eDHHh8oyzEmrbA6dtWHq4NWhjwWjbBmYt1CD691ctDuOkPDGPXexEM1E8zcNl5
	LnFfAIO5tglB/eUYC647XTwcDe+EJYedz82lds9ZhtZdW+Vpd3s3ovEHzYgudZpYemkxytLO
	kUWefu7LoD2nfhHo0YFJgVrcB2lH3zxDJxdeoW77MZ5+Hb/F0obIGPPGM++odxUoJfoqxZiZ
	s19ddDfgZMtHyWHrDReuQZ71DUglEmkHiU3d4R+x3brGJZmXniPB4DKb5A3SU8RzYjYxV4us
	9PNWctx2AieD9dIeEvU2oiRj6Vlyf/jSw2WNtJO4nE3/S7cSh2vwoUglvUS+W2ljkqxNdELR
	KzgpJVKHiji6/pMS6Qnyw7dBfBJpLOgxO9LqDVWlsr5kx/aiaoP+8Pb8slI3Snyc7cOVfefR
	X/63hpAkIl2KBnJfLdZyclVFdekQIiKr26BJS88r1moK5OoPFGPZ+8aDJUrFENoiYt1mTXbs
	UIFWKpQrlQOKUq4YH6WMqEqtQZX+c3I88qZ1Pqc7W1ZJppRdrdqRguB8l/7Y2dpfF3KyW3an
	vc2TGdNCzb777wYyQqbGwv79ez185kbNoUbb0w/eax+e25TPrJu/+dE6g7/h+aw/zVRM26v6
	J+vA49u+OZI1mjO9u3lPYXmflJcfDJWnk/RPyDgamLmb92Tm6y+/oMMVRXLWNtZYIf8LifH4
	F20DAAA=
X-Brightmail-Tracker: H4sIAAAAAAAAAzWSbUxScRTG+997+YMs2h1Z3upDja2XuWkvyzpbL6svddPVauttfSnKO0XR
	DMyy1RKNsrJSFrgCiyhZqQWBltYo09IMXRK9uNS0jSjTwqFQvqBBrS9nv3Oe5zw7H46AFNfy
	ZgtkmdmcIlMql2AhJdyyqiBujE1KWxIsmgWF6pPQ1ePhwXtVPQWB4UIKDJYqDCH9Qz4U2q7w
	4OWHfAra71Ui6AkUIvg1pidBXTdJQUjTxIfhkU4+aFUIJh1NCHQuDQkd7U9JqKpWETBkncDQ
	3+hHoP3swVDap6LAZy5CcNWr50Pfi43wo+cxDya7vxLwITiAwOyZIMBTfwZBSJcO10328Lpu
	EMNY22sSSrXtCG587ibB39eLoLrpEwLH7XwMX4prSHB7psHbgA9Di/Y8hh8uAwE/rRiM+Q4e
	uFr7EZTpNQi8Hx0EFNy0YNCV2Sio633EB1f/OAFdOg0BlbbN0GP2UuAsNhHhc8Ou+zGgLy0g
	wuUbAdq7jwkYMVfw15Uj9pf6IsVW2B8QrPpNCLNV16oQOzaqQexweQHJqovDbeOAj2RP2Y+w
	5c4BzI4G3mHWETRS7CsTw946O0qwJW1xbN3Vbv7W9XuEq5M5uSyHUyxeu0+YOuSykFmtzFHT
	JyuVh+zTz6EoAUMvZypMk7wIY3oh09ExQkY4mp7H2C94w3OhgKTdc5ki8wUqIkynNzG+pvMo
	whQ9n/nd0vh3WUQnMFbLRfwvdC5Taa3/GxRFr2DujZcRERaHPZ2+ZqoYCY1oSgWKlmXmZEhl
	8oR4ZXpqbqbsaPyBgxk2FP4n84nxklo07N7YgGgBkkwVwbrENDFPmqPMzWhAjICURIsWLEpK
	E4uSpbnHOMXBvYrDck7ZgOYIKEmMKHEXt09Mp0izuXSOy+IU/1VCEDU7D3Xaj89KnrdXbV05
	Ur2+y/lkPJCVYnoR2BlcozXGv1dZyiZmHLlksGVf2e3/vv1pL13y3Hi5xXnYPbNX5RxKEnkH
	WxubkXzwWTA2b7Vkx6PEUMPrmQr/0il32uI2ZONLK7OWSbfXusUPa1TfmjNU+22n6wwf/R0J
	WsO2E19wzKEJCaVMlS6NJRVK6R9hxjY0SwMAAA==
X-CFilter-Loop: Reflected
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

Wrapped the base APIs for easier annotation on wait and event.  Start
with supporting waiters on each single event.  More general support for
multiple events is a future work.  Do more when the need arises.

How to annotate:

1. Initaialize a map for the interesting wait.

   /*
    * Place along with the wait instance.
    */
   struct dept_map my_wait;

   /*
    * Place in the initialization code.
    */
   sdt_map_init(&my_wait);

2. Place the following at the wait code.

   sdt_wait(&my_wait);

3. Place the following at the event code.

   sdt_event(&my_wait);

That's it!

Signed-off-by: Byungchul Park <byungchul@sk.com>
---
 include/linux/dept_sdt.h | 65 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)
 create mode 100644 include/linux/dept_sdt.h

diff --git a/include/linux/dept_sdt.h b/include/linux/dept_sdt.h
new file mode 100644
index 000000000000..0535f763b21b
--- /dev/null
+++ b/include/linux/dept_sdt.h
@@ -0,0 +1,65 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Single-event Dependency Tracker
+ *
+ * Started by Byungchul Park <max.byungchul.park@gmail.com>:
+ *
+ *  Copyright (c) 2020 LG Electronics, Inc., Byungchul Park
+ *  Copyright (c) 2024 SK hynix, Inc., Byungchul Park
+ */
+
+#ifndef __LINUX_DEPT_SDT_H
+#define __LINUX_DEPT_SDT_H
+
+#include <linux/kernel.h>
+#include <linux/dept.h>
+
+#ifdef CONFIG_DEPT
+#define sdt_map_init(m)							\
+	do {								\
+		static struct dept_key __key;				\
+		dept_map_init(m, &__key, 0, #m);			\
+	} while (0)
+
+#define sdt_map_init_key(m, k)		dept_map_init(m, k, 0, #m)
+
+#define sdt_wait(m)							\
+	do {								\
+		dept_request_event(m);					\
+		dept_wait(m, 1UL, _THIS_IP_, __func__, 0);		\
+	} while (0)
+
+/*
+ * sdt_might_sleep() and its family will be committed in __schedule()
+ * when it actually gets to __schedule(). Both dept_request_event() and
+ * dept_wait() will be performed on the commit.
+ */
+
+/*
+ * Use the code location as the class key if an explicit map is not used.
+ */
+#define sdt_might_sleep_start(m)					\
+	do {								\
+		struct dept_map *__m = m;				\
+		static struct dept_key __key;				\
+		dept_stage_wait(__m, __m ? NULL : &__key, _THIS_IP_, __func__);\
+	} while (0)
+
+#define sdt_might_sleep_end()		dept_clean_stage()
+
+#define sdt_ecxt_enter(m)		dept_ecxt_enter(m, 1UL, _THIS_IP_, "start", "event", 0)
+#define sdt_event(m)			dept_event(m, 1UL, _THIS_IP_, __func__)
+#define sdt_ecxt_exit(m)		dept_ecxt_exit(m, 1UL, _THIS_IP_)
+#define sdt_request_event(m)		dept_request_event(m)
+#else /* !CONFIG_DEPT */
+#define sdt_map_init(m)			do { } while (0)
+#define sdt_map_init_key(m, k)		do { (void)(k); } while (0)
+#define sdt_wait(m)			do { } while (0)
+#define sdt_might_sleep_start(m)	do { } while (0)
+#define sdt_might_sleep_end()		do { } while (0)
+#define sdt_ecxt_enter(m)		do { } while (0)
+#define sdt_event(m)			do { } while (0)
+#define sdt_ecxt_exit(m)		do { } while (0)
+#define sdt_request_event(m)		do { } while (0)
+#endif
+#endif /* __LINUX_DEPT_SDT_H */
-- 
2.17.1

