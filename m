Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794067752;
	b=xhiq+nB8mZuqlsdU1Ytf51u2G8MMtDnrAvx24r1wcdIbdx0xOW8p/qsDMz3gTDieDv0P
	 KnbK2vPQmxG/oLumRLzOKsUXDdXPIajc/oZkIPPpqeoEutF7IjBMcXqnP2/ZBouh6fIqL
	 mK7h8Hw5JYpLVw/uO8kr34ljomskmSORIaWxdyUx4WIyUEn5y7jxU4KP/UIXum4pVTPEo
	 5bITSwC0ApUjms6YawUTCu8yYYzqUX+7+dQ/5LfEOHmNwTLwvHlhq9Iy5rFlofol7ugeu
	 Vop5DfTIKbNQGp/OADMCU4vn2rG7Zb5IC3U+KjfKoSbg0506gTZk4JHo7K08n0wOYmQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794067752;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=6AsXxa1QewrAJW9HgRSeLmPAvdr89MQRaxzXQoRN1ks=;
	b=uWqULqBv90nJBQm/H6o+oo4os3KD35bEsaw30/9r75rPJ8ipGYANgoHewW6s0qjELb8H
	 uN0A0ERlbh86zDCXbVfMHAlgV6aVBbnp2XJp3+WD3yzOa2lgsqa8DVNmy/ylNVxZ/pY0V
	 oPQOJu6qQg+dxq1y44nOImhMmn9/hZBaI331n5CoSGnUNxX/5qTYx8F4fPLOuB0Xa6I4q
	 CfUC8e76eZWTlRVDJqoJQoQcDTkmjFC1QGBunJtGwqm+M9uSXo9pyS5HbCLyNVwcchDGX
	 Iw4tHUtI3/xyOwcjCucNGyiVLk0tZRQcG8nobxK6vTIRFnXAaKQxGHflUBhNLpbyKLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=OozIVqE8;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5AD960A2633
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 16:09:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C5AD960A2633
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=OozIVqE8
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794067751;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6AsXxa1QewrAJW9HgRSeLmPAvdr89MQRaxzXQoRN1ks=;
	b=OozIVqE85AOnatbUbInJ+64MJZD3gZ0a2Oqjfs0oDi9OrOXGV6eobfQLAd/axOE7s7LTqW
	XgZOIMa7H5S/F5lDn9l0X0Nb6ktGTlU4/ukyGYlJof/Ar2DNYTZOXaJgQiOxIJrpkbCCah
	7N4ecF6vzgkcIR52wIwcAe/zwi3Tww0=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-22-lVK-RAyPOjClaWJ-RHBHMA-1; Sat,
 07 Nov 2026 11:09:04 -0500
X-MC-Unique: lVK-RAyPOjClaWJ-RHBHMA-1
X-Mimecast-MFC-AGG-ID: lVK-RAyPOjClaWJ-RHBHMA_1794067741
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id BBA0F1956094;
	Sat,  7 Nov 2026 16:09:01 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id A648818004F7;
	Sat,  7 Nov 2026 16:08:57 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-block@vger.kernel.org
Subject: [PATCH v16 05/15] iov_iter: Add a bvecq kunit test
Date: Sat,  7 Nov 2026 16:08:08 +0000
Message-ID: <20261107160823.1465553-6-dhowells@redhat.com>
In-Reply-To: <20261107160823.1465553-1-dhowells@redhat.com>
References: <20261107160823.1465553-1-dhowells@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Add a bvecq kunit test to exercise the bvecq iterator in a bunch of
different ways.  Each kunit test sets up a series of folios of different
sizes (1, 2, 4 or 8 pages) and fills each subpage thereof with a distinct
predictable pattern that it can then sample to check that the iterator
appears to be in the right place.

The folios are then assembled into a bvecq chain depending on a particular
recipe and partialness list and then advance, revert and copy-out is
tested, along with checking iov_iter_npages() at each point.

Each test is a combination of a bvecq chain recipe:

 - A single bvecq with 16 folios with no gaps (zero-len bio_vec).
 - A chain of two bvecqs, each with 8 folios and no gaps.
 - As the previous, but with a gap at the end of the first chain.
 - A chain of four bvecqs, each with 4 folios and scattered gaps,
   including at the front and back.
 - A chain of five bvecqs, 3 with folios and two with no folios, one empty
   and one with a couple of gaps.
 - A chain of seven bvecqs, 3 with folios, 3 completely empty (including
   first and last bvecqs in the chain) and 1 with just a couple of gaps.

and a selection of folio parts:

 - Whole folios only.
 - Scattered parts of folios, with some contiguities.
 - Every folio with the first and last bytes excluded.

and a test algorithm:

 - For each possible starting position in the bvecq, do a small advance,
   check fill, a couple of small reverts, each checked and then advance to
   the next starting position.
 - Starting at the beginning, advance in jumps by a largish step forward,
   checking after each jump; then when the end is hit revert in jumps by a
   slightly larger step back, checking each time; then double the step and
   repeat until the step exceeds the size of the iterator.

iov_iter_alignment() is compared at the beginning of one of the test sets
to a compound of alignments from an ITER_BVEC.  Note that the ITER_BVEC
alignment check malfunctions if given a zero-length bio_vec array.

Exercising extraction, copy-from and copy-to is done in kunit_iov_iter.c,
with those bits added in a different patch.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara (Red Hat) <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-block@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 MAINTAINERS             |   1 +
 lib/Kconfig.debug       |  13 +
 lib/tests/Makefile      |   1 +
 lib/tests/kunit_bvecq.c | 599 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 614 insertions(+)
 create mode 100644 lib/tests/kunit_bvecq.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 9cb3785a5bd2..bdda4ad58ab4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10391,6 +10391,7 @@ F:	include/linux/fscache*.h
 F:	include/linux/netfs.h
 F:	include/trace/events/fscache.h
 F:	include/trace/events/netfs.h
+F:	lib/tests/kunit_bvecq.c
 
 FILESYSTEMS [STACKABLE]
 M:	Miklos Szeredi <miklos@szeredi.hu>
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 2d22638ec13a..06b4546421a1 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -2385,6 +2385,19 @@ config TEST_IOV_ITER
 
 	  If unsure, say N.
 
+config TEST_BVECQ
+	tristate "Test bvecq operation" if !KUNIT_ALL_TESTS
+	depends on KUNIT
+	depends on MMU
+	depends on NETFS_SUPPORT
+	default KUNIT_ALL_TESTS
+	help
+	  Enable this to turn on testing of the operation of the bvecq
+	  structure.  This test is executed only once during system
+	  boot (so affects only boot time), or at module load time.
+
+	  If unsure, say N.
+
 config KPROBES_SANITY_TEST
 	tristate "Kprobes sanity tests" if !KUNIT_ALL_TESTS
 	depends on DEBUG_KERNEL
diff --git a/lib/tests/Makefile b/lib/tests/Makefile
index df0537e1b91f..85e3c5e1f7d2 100644
--- a/lib/tests/Makefile
+++ b/lib/tests/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_GLOB_KUNIT_TEST) += glob_kunit.o
 obj-$(CONFIG_HASHTABLE_KUNIT_TEST) += hashtable_test.o
 obj-$(CONFIG_HASH_KUNIT_TEST) += test_hash.o
 obj-$(CONFIG_TEST_IOV_ITER) += kunit_iov_iter.o
+obj-$(CONFIG_TEST_BVECQ) += kunit_bvecq.o
 obj-$(CONFIG_IS_SIGNED_TYPE_KUNIT_TEST) += is_signed_type_kunit.o
 obj-$(CONFIG_KPROBES_SANITY_TEST) += test_kprobes.o
 obj-$(CONFIG_LIST_KUNIT_TEST) += list-test.o
diff --git a/lib/tests/kunit_bvecq.c b/lib/tests/kunit_bvecq.c
new file mode 100644
index 000000000000..7cdd455df692
--- /dev/null
+++ b/lib/tests/kunit_bvecq.c
@@ -0,0 +1,599 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/* bvecq iterator tests.  Exercises:
+ *	- advance
+ *	- revert
+ *	- npages
+ *	- alignment
+ *
+ * See also kunit_iov_iter.c for bvecq copy and extract tests.
+ *
+ * Copyright (C) 2026 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/uio.h>
+#include <linux/bvecq.h>
+#include <kunit/test.h>
+
+MODULE_DESCRIPTION("bvecq testing");
+MODULE_AUTHOR("David Howells <dhowells@redhat.com>");
+MODULE_LICENSE("GPL");
+
+/*
+ * Info for the fill pattern generator.
+ */
+static const u8 bvecq_kunit_orders[16] = {
+	0, 1, 2, 3,
+	0, 1, 3, 2,
+	0, 2, 1, 3,
+	2, 0, 3, 1
+};
+
+static const s8 bvecq_kunit_fills[16] = {
+	1, 2, 3, 5, 7, 11, 13, 17,
+	-1, -2, -3, -5, -7, -11, -13, -17
+};
+static struct folio *bvecq_kunit_folios[16];
+
+/*
+ * Info for the fill pattern predictor.
+ */
+struct bvecq_test_pagemap {
+	u32 pos;
+	u32 offset;
+	u8 folio;
+	u8 subpage;
+};
+
+static struct bvecq_test_pagemap bvecq_kunit_pagemap[64];
+static int bvecq_kunit_pagemap_nr;
+
+/*
+ * bvecq assembly recipes.
+ */
+enum bvecq_test_cmd {
+	BVECQ_KUNIT_STOP,	/* Stop loading */
+	BVECQ_KUNIT_ALLOC,	/* Append new bvecq of size count and move to it */
+	BVECQ_KUNIT_LOAD,	/* Load count segments into current bvecq */
+	BVECQ_KUNIT_EMPTY,	/* Add count empty segments into current bvecq */
+} __mode(byte);
+
+struct bvecq_test_recipe {
+	enum bvecq_test_cmd	cmd;
+	u8			count;
+};
+
+#define ALLOC(C) { .cmd = BVECQ_KUNIT_ALLOC, .count = C }
+#define LOAD(C)  { .cmd = BVECQ_KUNIT_LOAD,  .count = C }
+#define EMPTY(C) { .cmd = BVECQ_KUNIT_EMPTY, .count = C }
+#define END	 { .cmd = BVECQ_KUNIT_STOP, }
+
+static const struct bvecq_test_recipe bvecq_test_recipe_0[] = {
+	ALLOC(16), LOAD(16),
+	END
+};
+
+static const struct bvecq_test_recipe bvecq_test_recipe_1[] = {
+	ALLOC(8), LOAD(8),
+	ALLOC(8), LOAD(8),
+	END
+};
+
+static const struct bvecq_test_recipe bvecq_test_recipe_2[] = {
+	ALLOC(9), LOAD(8), EMPTY(1),
+	ALLOC(8), LOAD(8),
+	END
+};
+
+static const struct bvecq_test_recipe bvecq_test_recipe_3[] = {
+	ALLOC(9), EMPTY(1), LOAD(2), EMPTY(2), LOAD(2), EMPTY(1),
+	ALLOC(8), LOAD(4), EMPTY(2),
+	ALLOC(8), EMPTY(1), LOAD(4),
+	ALLOC(8), EMPTY(2), LOAD(4), EMPTY(1),
+	END
+};
+
+static const struct bvecq_test_recipe bvecq_test_recipe_4[] = {
+	ALLOC(9), LOAD(2), EMPTY(1),
+	ALLOC(2),
+	ALLOC(2), LOAD(2),
+	ALLOC(2), EMPTY(2),
+	ALLOC(8), LOAD(8),
+	END
+};
+
+static const struct bvecq_test_recipe bvecq_test_recipe_5[] = {
+	ALLOC(2),
+	ALLOC(9), LOAD(2), EMPTY(1),
+	ALLOC(2),
+	ALLOC(2), LOAD(2),
+	ALLOC(2), EMPTY(2),
+	ALLOC(8), LOAD(8),
+	ALLOC(2),
+	END
+};
+
+static const struct bvecq_test_recipe bvecq_test_recipe_6[] = {
+	ALLOC(2), EMPTY(1),
+	ALLOC(2),
+	ALLOC(9), LOAD(2), EMPTY(1),
+	ALLOC(2),
+	ALLOC(2), LOAD(2),
+	ALLOC(2), EMPTY(2),
+	ALLOC(8), LOAD(8),
+	ALLOC(2),
+	ALLOC(2), EMPTY(1),
+	END
+};
+
+/*
+ * Sets of variations of how much of each folio is added to the bvecq chain,
+ * allowing a part of the folio to be excluded from each end.
+ */
+struct bvecq_test_partials {
+	u16	add_start;	/* Amount to exclude from the low end */
+	u16	sub_end;	/* Amount to exclude from the high end */
+};
+
+/* All whole folios. */
+static const struct bvecq_test_partials bvecq_test_partials_full[16] = {
+	[0 ... 15] = { 0, 0 }
+};
+
+/* Scattered partial folios, with some folios contiguous. */
+static const struct bvecq_test_partials bvecq_test_partials_scattered[16] = {
+	//0, 1, 2, 3,
+	{ 0x277,  0x136 },
+	{ 0x999,  0x1011 },
+	{ 0x2020, 0x0 },
+	{ 0x0,    0x1123 },
+	//0, 1, 3, 2,
+	{ 0x0,    0x136 },
+	{ 0x27,   0x777 },
+	{ 0x771,  0x0 },
+	{ 0x555,  0x0 },
+	//0, 2, 1, 3,
+	{ 0x277,  0x136 },
+	{ 0x1123, 0x0 },
+	{ 0x0,	  0x0 },
+	{ 0,      0x5011 },
+	//2, 0, 3, 1
+	{ 0x2020, 0x0 },
+	{ 0x277,  0x136 },
+	{ 0x1999, 0x1011 },
+	{ 0x0,    0x1010 },
+};
+
+/* Partial folios, all with a byte excluded from each end. */
+static const struct bvecq_test_partials bvecq_test_partials_edges[16] = {
+	[0 ... 15] = { 1, 1 }
+};
+
+/*
+ * Clean up routines.
+ */
+static void bvecq_kunit_release_folios(void *data)
+{
+	struct folio **folios = data;
+
+	release_pages(folios, ARRAY_SIZE(bvecq_kunit_folios));
+	memset(bvecq_kunit_folios, 0, sizeof(bvecq_kunit_folios));
+}
+
+static void bvecq_kunit_bvecq_put(void *data)
+{
+	bvecq_put(data);
+}
+
+/*
+ * Calculate the fill pattern, for a particular byte of a particular subpage of
+ * a particular folio.
+ */
+static inline u8 bvecq_kunit_pattern(unsigned int folio, int subpage, int offset)
+{
+	int fill_step = bvecq_kunit_fills[folio];
+
+	return (subpage + offset * fill_step) & 0xff;
+}
+
+/*
+ * Calculate the fill pattern, given the 'byte position' in the bvecq chain.
+ * This looks up the folio, subpage and offset from a table generated whilst
+ * the bvecq is being assembled.
+ */
+static inline u8 bvecq_kunit_predict(struct kunit *test, size_t pos)
+{
+	size_t last_pos = 0;
+
+	for (int i = 0; i < bvecq_kunit_pagemap_nr; i++) {
+		if (pos < bvecq_kunit_pagemap[i].pos)
+			return bvecq_kunit_pattern(
+				bvecq_kunit_pagemap[i].folio,
+				bvecq_kunit_pagemap[i].subpage,
+				bvecq_kunit_pagemap[i].offset + (pos - last_pos));
+		last_pos = bvecq_kunit_pagemap[i].pos;
+	}
+
+	KUNIT_FAIL(test, "Overran pagemap pos=%zx\n", pos);
+	return 0;
+}
+
+/*
+ * Determine which page we're looking at, taking all the folios to be split
+ * into pages.  This can be used to determine what iov_iter_npages() will say.
+ */
+static inline int bvecq_kunit_pos2page(struct kunit *test, size_t pos)
+{
+	for (int i = 0; i < bvecq_kunit_pagemap_nr; i++)
+		if (pos < bvecq_kunit_pagemap[i].pos)
+			return i;
+
+	if (pos > bvecq_kunit_pagemap[bvecq_kunit_pagemap_nr - 1].pos)
+		KUNIT_FAIL(test, "Overran pagemap pos=%zx\n", pos);
+	return bvecq_kunit_pagemap_nr;
+}
+
+/*
+ * Allocate a variety of folios of different orders and fill them with the
+ * pattern set for each folio.
+ */
+static void __init iov_bvecq_alloc_folios(struct kunit *test)
+{
+	struct folio *folio, **folios = bvecq_kunit_folios;
+	const int nr = ARRAY_SIZE(bvecq_kunit_folios);
+
+	bvecq_kunit_pagemap_nr = 0;
+	memset(bvecq_kunit_pagemap, 0, sizeof(bvecq_kunit_pagemap));
+	memset(bvecq_kunit_folios, 0, sizeof(bvecq_kunit_folios));
+
+	for (int i = 0; i < nr; i++) {
+		folio = folio_alloc(GFP_KERNEL, bvecq_kunit_orders[i]);
+		KUNIT_ASSERT_NOT_NULL(test, folio);
+		folios[i] = folio;
+
+		/* Fill each subpage with a different but predictable pattern. */
+		for (int j = 0; j < folio_nr_pages(folio); j++) {
+			u8 *p = kmap_local_folio(folio, PAGE_SIZE * j);
+
+			for (int k = 0; k < PAGE_SIZE; k++)
+				p[k] = bvecq_kunit_pattern(i, j, k);
+			kunmap_local(p);
+		}
+	}
+
+	kunit_add_action_or_reset(test, bvecq_kunit_release_folios, folios);
+}
+
+/*
+ * Follow the specified recipe to allocate a bvecq chain and stick the folios
+ * and empty gaps into it.  Further, the offset into and length of each folio
+ * is adjusted from the partials list.  Each ALLOC command will append a new
+ * bvecq to the chain and move to filling that.
+ */
+static struct bvecq *__init bvecq_kunit_load_chain(
+	struct kunit *test,
+	const struct bvecq_test_recipe *rec,
+	const struct bvecq_test_partials *parts,
+	size_t *size)
+{
+	struct bvecq *head = NULL, *bq = NULL, *p;
+	size_t pos = 0;
+	int folio_index = 0;
+
+	*size = 0;
+
+	for (; rec->cmd != BVECQ_KUNIT_STOP; rec++) {
+		if (!head)
+			KUNIT_ASSERT_EQ(test, rec->cmd, BVECQ_KUNIT_ALLOC);
+
+		switch (rec->cmd) {
+		case BVECQ_KUNIT_STOP:
+			break;
+
+		case BVECQ_KUNIT_ALLOC:
+			p = bvecq_alloc_one(rec->count, GFP_KERNEL, false);
+			KUNIT_ASSERT_NOT_NULL(test, p);
+
+			if (!head) {
+				head = p;
+				kunit_add_action_or_reset(test, bvecq_kunit_bvecq_put, head);
+				bq = p;
+			} else {
+				bvecq_append(bq, p);
+				bq = p;
+			}
+			break;
+
+		case BVECQ_KUNIT_LOAD:
+			KUNIT_ASSERT_LE(test, folio_index + rec->count,
+					ARRAY_SIZE(bvecq_kunit_orders));
+			KUNIT_ASSERT_LE(test, bq->nr_slots + rec->count, bq->max_slots);
+			for (int i = 0; i < rec->count; i++) {
+				struct folio *folio = bvecq_kunit_folios[folio_index];
+				size_t flen = PAGE_SIZE << bvecq_kunit_orders[folio_index];
+				size_t foff = 0;
+
+				KUNIT_ASSERT_LE(test,
+						parts[folio_index].add_start +
+						parts[folio_index].sub_end,
+						flen);
+
+				foff += parts[folio_index].add_start;
+				flen -= parts[folio_index].add_start;
+				flen -= parts[folio_index].sub_end;
+
+				bvec_set_page(&bq->bv[bq->nr_slots + i],
+					      folio_page(folio, 0), flen, foff);
+				*size += flen;
+
+				for (int j = 0; j < folio_nr_pages(folio); j++) {
+					struct bvecq_test_pagemap *pm;
+					size_t part;
+
+					if (foff >= PAGE_SIZE) {
+						foff -= PAGE_SIZE;
+						continue;
+					}
+					part = min(flen, PAGE_SIZE - foff);
+					pos += part;
+					pm = &bvecq_kunit_pagemap[bvecq_kunit_pagemap_nr];
+					pm->pos     = pos;
+					pm->folio   = folio_index;
+					pm->subpage = j;
+					pm->offset  = foff;
+					bvecq_kunit_pagemap_nr++;
+					flen -= part;
+					if (!flen)
+						break;
+					foff = 0;
+				}
+
+				folio_index++;
+			}
+			bvecq_filled_to(bq, bq->nr_slots + rec->count);
+			break;
+
+		case BVECQ_KUNIT_EMPTY:
+			KUNIT_ASSERT_LE(test, bq->nr_slots + rec->count, bq->max_slots);
+			for (int i = 0; i < rec->count; i++) {
+				bq->bv[bq->nr_slots + i].bv_page = ERR_PTR(-EIO);
+				bq->bv[bq->nr_slots + i].bv_offset = 0;
+				bq->bv[bq->nr_slots + i].bv_len = 0;
+			}
+			bvecq_filled_to(bq, bq->nr_slots + rec->count);
+			break;
+		}
+	}
+
+	return head;
+}
+
+/*
+ * Check the next few bytes of pattern from an iterator.  Note that it is
+ * permitted for the iterator to have less data remaining than the number to
+ * check - in which case the copy is required to come up short.
+ */
+static void __init bvecq_kunit_check_next(struct kunit *test, struct iov_iter *iter,
+					  size_t *pos, size_t *left, size_t nr)
+{
+	size_t part, n;
+	u8 buf[3], pred[3];
+
+	KUNIT_ASSERT_EQ(test, iov_iter_count(iter), *left);
+
+	part = min(*left, nr);
+	n = copy_from_iter(buf, nr, iter);
+	KUNIT_ASSERT_EQ(test, n, part);
+	*left -= n;
+
+	for (size_t i = 0; i < n; i++)
+		pred[i] = bvecq_kunit_predict(test, *pos + i);
+
+	for (size_t i = 0; i < n; i++) {
+		if (buf[i] != pred[i]) {
+			pr_notice(">>> pos=%05zx+%zx c=%zx buf=%*phN pred=%*phN\n",
+				  *pos, i, iov_iter_count(iter) + n,
+				  (int)n, buf, (int)n, pred);
+		}
+		KUNIT_ASSERT_EQ(test, buf[i], pred[i]);
+	}
+
+	*pos += n;
+}
+
+/*
+ * Test advancing and reverting over a bvecq chain.
+ *
+ * The loop starts at each 'byte position' in the chain, advancing a small
+ * amount, copying a few bytes of data, checking the fill pattern, reverting a
+ * bit, checking, reverting, checking and then reverting to a byte position one
+ * further on than the previous loop.  Use small prime numbers for the advance
+ * and first revert so that we should test crossing the edges of the folios.
+ */
+static void __init bvecq_kunit_advance(struct kunit *test,
+				       const struct bvecq_test_recipe *recipe,
+				       const struct bvecq_test_partials *parts)
+{
+	struct iov_iter iter;
+	struct bvecq *bq, *p;
+	unsigned long bvec_align = 0;
+	size_t size, pos = 0, from;
+	int npages;
+
+	iov_bvecq_alloc_folios(test);
+	bq = bvecq_kunit_load_chain(test, recipe, parts, &size);
+
+	/* Compound up the alignments for ITER_BVEC on each individual bvecq
+	 * span and compare that to the alignment for ITER_BVECQ.  There is an
+	 * issue in ITER_BVEC, however, in that it includes bv_offset from
+	 * bio_vecs for which bv_len is 0, which ITER_BVECQ does not.
+	 */
+	for (p = bq; p; p = p->next) {
+		size_t psize = 0;
+
+		for (int i = 0; i < p->nr_slots; i++)
+			psize += p->bv[i].bv_len;
+
+		if (!psize)
+			continue;
+		iov_iter_bvec(&iter, ITER_SOURCE, p->bv, p->nr_slots, psize);
+		bvec_align |= iov_iter_alignment(&iter);
+	}
+
+	iov_iter_bvec_queue(&iter, ITER_SOURCE, bq, 0, 0, size);
+
+	KUNIT_ASSERT_EQ(test, iov_iter_alignment(&iter), bvec_align);
+
+	npages = iov_iter_npages(&iter, INT_MAX);
+	from = iov_iter_count(&iter);
+	do {
+		size_t left = from, part;
+
+		KUNIT_ASSERT_EQ(test, iov_iter_npages(&iter, INT_MAX),
+				npages - bvecq_kunit_pos2page(test, pos));
+
+		/* 3 steps forward. */
+		part = min(left, 3);
+		iov_iter_advance(&iter, 3); /* May be short. */
+		pos += part;
+		left -= part;
+		bvecq_kunit_check_next(test, &iter, &pos, &left, 3);
+
+		/* 2 steps back */
+		part = umin(2, left);
+		iov_iter_revert(&iter, part);
+		pos -= part;
+		left += part;
+		bvecq_kunit_check_next(test, &iter, &pos, &left, 2);
+
+		/* 1 more step back */
+		part = umin(1, left);
+		iov_iter_revert(&iter, part);
+		pos -= part;
+		left += part;
+		bvecq_kunit_check_next(test, &iter, &pos, &left, 1);
+
+		KUNIT_ASSERT_EQ(test, left, iov_iter_count(&iter));
+
+		/* Move to one place on from the current loop. */
+		from--;
+		if (iov_iter_count(&iter) < from) {
+			part = from - iov_iter_count(&iter);
+			iov_iter_revert(&iter, part);
+			pos -= part;
+		}
+		KUNIT_ASSERT_EQ(test, from, iov_iter_count(&iter));
+	} while (from > 0);
+}
+
+/*
+ * Test jumping around in a bvecq chain using advance and revert.
+ *
+ * The loop starts at the start of the chain, then jumps forwards through the
+ * chain and then back again by large amounts, sampling the data each time.
+ */
+static void __init bvecq_kunit_jump(struct kunit *test,
+				    const struct bvecq_test_recipe *recipe,
+				    const struct bvecq_test_partials *parts)
+{
+	struct iov_iter iter;
+	struct bvecq *bq;
+	size_t size, pos = 0, step = 0x100;
+	bool dir = false;
+	int npages;
+
+	iov_bvecq_alloc_folios(test);
+	bq = bvecq_kunit_load_chain(test, recipe, parts, &size);
+
+	iov_iter_bvec_queue(&iter, ITER_SOURCE, bq, 0, 0, size);
+
+	npages = iov_iter_npages(&iter, INT_MAX);
+	while (step < size) {
+		size_t left = iov_iter_count(&iter), part;
+
+		KUNIT_ASSERT_EQ(test, iov_iter_npages(&iter, INT_MAX),
+				npages - bvecq_kunit_pos2page(test, pos));
+
+		if (!dir) {
+			/* Advance by step and then 3 more in check. */
+			part = min(left, step);
+			iov_iter_advance(&iter, step); /* May be short. */
+			pos += part;
+			left -= part;
+			bvecq_kunit_check_next(test, &iter, &pos, &left, 3);
+
+			KUNIT_ASSERT_EQ(test, left, iov_iter_count(&iter));
+
+			if (left == 0) {
+				/* Switch to reverting. */
+				dir = true;
+				step += 3;
+			}
+		} else {
+			/* Revert by step and then advance by 3 in check. */
+			part = min(size - left, step);
+			iov_iter_revert(&iter, part);
+			pos -= part;
+			left += part;
+			bvecq_kunit_check_next(test, &iter, &pos, &left, 3);
+
+			KUNIT_ASSERT_EQ(test, left, iov_iter_count(&iter));
+
+			if (pos <= 3) {
+				/* Switch to advancing. */
+				dir = false;
+				step *= 2;
+			}
+		}
+	}
+}
+
+/*
+ * Run the individual test combinations
+ */
+#define ADVANCE_TESTS_SET(CHECK, PARTIALS) \
+	TEST(CHECK, PARTIALS, 0)	\
+	TEST(CHECK, PARTIALS, 1)	\
+	TEST(CHECK, PARTIALS, 2)	\
+	TEST(CHECK, PARTIALS, 3)	\
+	TEST(CHECK, PARTIALS, 4)	\
+	TEST(CHECK, PARTIALS, 5)	\
+	TEST(CHECK, PARTIALS, 6)
+
+#define ADVANCE_TESTS(CHECK)			\
+	ADVANCE_TESTS_SET(CHECK, full)		\
+	ADVANCE_TESTS_SET(CHECK, scattered)	\
+	ADVANCE_TESTS_SET(CHECK, edges)
+
+#define TEST(CHECK, PARTIALS, RECIPE) \
+static void __init bvecq_kunit_##CHECK##_##PARTIALS##_##RECIPE(struct kunit *test) \
+{ \
+	bvecq_kunit_##CHECK(test, \
+			    bvecq_test_recipe_##RECIPE,	      \
+			    bvecq_test_partials_##PARTIALS);  \
+}
+
+/* Emit test stub functions. */
+ADVANCE_TESTS(advance);
+ADVANCE_TESTS(jump);
+#undef TEST
+
+#define TEST(CHECK, PARTIALS, RECIPE)				\
+	KUNIT_CASE(bvecq_kunit_##CHECK##_##PARTIALS##_##RECIPE),
+
+static struct kunit_case __refdata bvecq_kunit_cases[] = {
+	ADVANCE_TESTS(advance)
+	ADVANCE_TESTS(jump)
+	{}
+};
+
+static struct kunit_suite bvecq_kunit_suite = {
+	.name = "bvecq",
+	.test_cases = bvecq_kunit_cases,
+};
+
+kunit_test_suites(&bvecq_kunit_suite);

