Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597740;
	b=AxlMM2JHxEIB+7ToL+0bDR47A821SJ9bAH/l16USHNq6HWvda/19dzV7D3ZHV0mYQuv/
	 Gms7o1Ev9i9k0k0FilnncAmDrkmSsy7rsU8hytO/qOB9nNtIfsXnrQww8AavBvwJLg8u0
	 yDaFUF8SZIFfTSgHO7EVUk/ouGCe8enCsPl5ov8s9fRSMUHrRrFoFp4Vk5nPIJ1uG1IKE
	 7OLLWq1OWznKRr0bP1AegrEBAOZJ8AjmMRCGJ9pw/gPA+7qI/Gmo3ASEjb4/Xmh0CTqO2
	 YiccVwPOsFN7Na9G97iTynZf23cnR0oRWcjk+kPHOXZ99AQ6wyK4BzMB4sh0rTE/fAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597740;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XIEiNOisrHSeG+nZZTafPITxWQcf7a/wJ6SYkWdCFBA=;
	b=0tEL7WrE+ZhCYGwc2XH7Q8AwlDzdebsSbKFHAMe0skQEH3CRLA9bheq9NPH3VCswhiak
	 0TqCyrVZ89j4tQo715kfLBTm7Jrn8OI4kLJ6n2R8njr+rtGoTcmTk2hFLeXfUXW8QCkW/
	 fXrqpp2YD+IVnCpPIQ84R3JWpf7ywYy5cuD1kCs+YC5cdlBb0VgQ1RXfnCd2umxJxLnsA
	 tXiE8sX/rqb/Xc5oOHBoLgOZG7PFqNSWfI1f3dPKDp1YMIG8aF8G/2gNMaNmdus+xkKtF
	 BqpxHYJ41AELb0PtZU78hIhZdcC6Mm4UYNLtoQw3xZtnIu47JzByJxa32bkKr1C3wSA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TnGnYZbj;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08AF4606A8BA;
	Fri, 13 Nov 2026 19:22:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TnGnYZbj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E88CF1F000C4;
	Fri, 13 Nov 2026 19:22:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597739;
	bh=XIEiNOisrHSeG+nZZTafPITxWQcf7a/wJ6SYkWdCFBA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TnGnYZbjeGOzKxsGx9t75ql4cEQhQ0h5WjfW7XsRIYAKsxNrgAOsojtmPdgVz/9uU
	 CHdKLpcHcA9+L1+DckdMQ9M4XopQdYBFiK1NnWQOwPy0JkH2HHBoXKxV+O2ain9tX+
	 v3DwJBrHrW1CSnDLrnBeQEcwPXLXJ+fqiFT87AEF5jFAM60bXulY/fizdyMsWhg6SB
	 F7mftx98Kl99v5oZ7Nx5U2MUh/D/2beQ+pVI8bapUzfrc9QpTSVwVVLW+jlDnHVDBh
	 aIW4X1uUlZgtyg0bd25wxEpmucI3FJvrthtGyvSp1TeP/tjSGCMHzbUvOeSBXISxq3
	 uPryu8U1rJZkQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:22:01 -0500
Subject: [PATCH net-next v3 03/10] lib: Add KUnit tests for the stringset
 data structure
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261113-tls-session-tags-v3-3-91271964cdb0@kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
In-Reply-To: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=13018; i=cel@kernel.org;
 h=from:subject:message-id; bh=kJgo9sz0fuhjpZOyePClJS9PWLcm1VRLoxx+xPhE9nI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92NfkjDC7AGX1g7v6e6vdns+q3sk/VBvU6T+q
 mS5zAFTxU2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjXwAKCRAzarMzb2Z/
 lzHCD/99Ikp9qDH/tdsDMOvEyDYa/rZ6GOZlAWl5XQCz9MnUep44isDq1aT1Zl43cynlv0aEK3D
 kR9U5Qx4dqhjQC40CHk5++lLVA4qy4iQ1UhRNuDL7QJbgalT2z9mrQRzUHUCiTsBT2nLc8vdBW8
 kZVVBQZeJ3cH7XU5zCrVgAUEYq40hdj+ZCCoiDsUcpIfEZmWuWtEd/WPPoHzzWqY2X911etgG9r
 TAWKo6hhb6R2BMCrM5rGormij4stXtp64u4fg+bwR1Q+cEAK6Fud/SEknofW3XLd/8wdqmrETNd
 6CvkFKBHKiZxqdAH0KlWl3leZFlEZrLHHi0PCn8Qpeh9Zzmnnist4NR9g5nI014P9MY5j/e5/Qh
 TxTDF3cKrArs398jjnEaqPtpnAM+zfYsW1OcomzCJbNhCSBTvwv0/HieLDPYEqBwiOoTXTIJ4ud
 +ETdFf6TH2ogLhRamfqY3YOC9cIcGCaLLVL9eZK8jsHw/mh+VgGR72FW1valY6ghPXqpTZIy73n
 VbVZCPp5qQl3qi5t8CUN67DLXPDMMffk9HoGQvEZinBL6Pa31DSQF2dKeJ59ZiW6sAzMuuUXi3z
 qOsR/lVqBV/4vs85956gAWlnTAPfxQgLqJd5X/3z0gZkdFrhm33V966hSJnKckgFMVqeS+cuJJC
 08Xf9Zzp+L9JsNQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The stringset data structure carries invariants that are easy to
regress silently: stringset_add() transfers ownership of the passed
pointer, stringset_finalize() both sorts and drops duplicate
strings, queries are valid only after finalization, and
stringset_copy() must produce a set that survives destruction of
its source. None of these are exercised today.

Add a KUnit suite that drives the supported usage pattern and
checks the observable results: capacity bounds and the once-only
allocation rule, the post-finalize sort and dedup, binary-search
membership at the array boundaries and in gaps, intersection over
overlapping, disjoint, and empty sets, and copy independence.
Built with KASAN, the dedup and copy cases become use-after-free
detectors. Under kmemleak, the ownership case catches a transfer
that never happened.

The misuse paths guarded by WARN_ON_ONCE() are intentionally left
out: tripping them taints the kernel, and KUnit has no facility to
mark a warning as expected.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 MAINTAINERS                 |   1 +
 lib/Kconfig.debug           |   6 +
 lib/tests/Makefile          |   1 +
 lib/tests/stringset_kunit.c | 311 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 319 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9b058bb60b0f..71a4ffe39c53 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -27028,6 +27028,7 @@ S:	Maintained
 F:	Documentation/core-api/stringset.rst
 F:	include/linux/stringset.h
 F:	lib/stringset.c
+F:	lib/tests/stringset_kunit.c
 
 SUN HAPPY MEAL ETHERNET DRIVER
 M:	Sean Anderson <seanga2@gmail.com>
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 2d22638ec13a..4ae7922d90ef 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -2531,6 +2531,12 @@ config STRING_HELPERS_KUNIT_TEST
 	depends on KUNIT
 	default KUNIT_ALL_TESTS
 
+config STRINGSET_KUNIT_TEST
+	tristate "KUnit test the stringset data structure at runtime" if !KUNIT_ALL_TESTS
+	depends on KUNIT
+	select STRINGSET
+	default KUNIT_ALL_TESTS
+
 config STRING_KUNIT_BENCH
        bool "Benchmark string functions at runtime"
        depends on STRING_KUNIT_TEST
diff --git a/lib/tests/Makefile b/lib/tests/Makefile
index df0537e1b91f..aabc70c40840 100644
--- a/lib/tests/Makefile
+++ b/lib/tests/Makefile
@@ -54,6 +54,7 @@ CFLAGS_stackinit_kunit.o += $(call cc-disable-warning, switch-unreachable)
 obj-$(CONFIG_STACKINIT_KUNIT_TEST) += stackinit_kunit.o
 obj-$(CONFIG_STRING_KUNIT_TEST) += string_kunit.o
 obj-$(CONFIG_STRING_HELPERS_KUNIT_TEST) += string_helpers_kunit.o
+obj-$(CONFIG_STRINGSET_KUNIT_TEST) += stringset_kunit.o
 obj-$(CONFIG_USERCOPY_KUNIT_TEST) += usercopy_kunit.o
 obj-$(CONFIG_UTIL_MACROS_KUNIT) += util_macros_kunit.o
 obj-$(CONFIG_RATELIMIT_KUNIT_TEST) += test_ratelimit.o
diff --git a/lib/tests/stringset_kunit.c b/lib/tests/stringset_kunit.c
new file mode 100644
index 000000000000..6e814b1faffb
--- /dev/null
+++ b/lib/tests/stringset_kunit.c
@@ -0,0 +1,311 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KUnit tests for the stringset data structure.
+ *
+ * Copyright (c) 2025, Oracle and/or its affiliates.
+ */
+
+#include <kunit/resource.h>
+#include <kunit/test.h>
+#include <linux/stringset.h>
+
+KUNIT_DEFINE_ACTION_WRAPPER(stringset_destroy_action, stringset_destroy,
+			    struct stringset *);
+
+/*
+ * Cleanup actions run after a failed assertion has ended the test
+ * thread, so the set cannot live on that thread's stack.
+ */
+static struct stringset *new_set(struct kunit *test)
+{
+	struct stringset *set;
+	int err;
+
+	set = kunit_kzalloc(test, sizeof(*set), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, set);
+	stringset_init(set);
+	err = kunit_add_action_or_reset(test, stringset_destroy_action, set);
+	KUNIT_ASSERT_EQ(test, err, 0);
+	return set;
+}
+
+/* Build a populated (but not yet finalized) set from an array of literals. */
+static struct stringset *build_set(struct kunit *test,
+				   const char * const *strs, unsigned int n)
+{
+	struct stringset *set = new_set(test);
+	unsigned int i;
+
+	KUNIT_ASSERT_TRUE(test, stringset_alloc(set, n, GFP_KERNEL));
+	for (i = 0; i < n; i++)
+		KUNIT_ASSERT_TRUE(test,
+				  stringset_add_dup(set, strs[i], GFP_KERNEL));
+	return set;
+}
+
+static void stringset_init_empty(struct kunit *test)
+{
+	DEFINE_STRINGSET(set);
+
+	KUNIT_EXPECT_TRUE(test, stringset_is_empty(&set));
+	KUNIT_EXPECT_EQ(test, stringset_count(&set), 0u);
+	stringset_destroy(&set);
+}
+
+static void stringset_alloc_zero_is_empty_set(struct kunit *test)
+{
+	DEFINE_STRINGSET(set);
+
+	KUNIT_EXPECT_TRUE(test, stringset_alloc(&set, 0, GFP_KERNEL));
+	stringset_finalize(&set);
+	KUNIT_EXPECT_FALSE(test, stringset_is_member(&set, "anything"));
+	KUNIT_EXPECT_EQ(test, stringset_count(&set), 0u);
+	stringset_destroy(&set);
+}
+
+static void stringset_alloc_twice_fails(struct kunit *test)
+{
+	DEFINE_STRINGSET(set);
+
+	KUNIT_EXPECT_TRUE(test, stringset_alloc(&set, 4, GFP_KERNEL));
+	KUNIT_EXPECT_FALSE(test, stringset_alloc(&set, 4, GFP_KERNEL));
+	stringset_destroy(&set);
+}
+
+static void stringset_realloc_after_destroy(struct kunit *test)
+{
+	const char * const in[] = { "a", "b" };
+	struct stringset *set;
+
+	set = build_set(test, in, ARRAY_SIZE(in));
+	stringset_finalize(set);
+	stringset_destroy(set);
+	KUNIT_EXPECT_TRUE(test, stringset_alloc(set, 2, GFP_KERNEL));
+}
+
+static void stringset_add_capacity_exhausted(struct kunit *test)
+{
+	struct stringset *set = new_set(test);
+	char *overflow;
+	bool added;
+
+	KUNIT_ASSERT_TRUE(test, stringset_alloc(set, 1, GFP_KERNEL));
+	KUNIT_ASSERT_TRUE(test, stringset_add_dup(set, "a", GFP_KERNEL));
+	KUNIT_EXPECT_FALSE(test, stringset_add_dup(set, "b", GFP_KERNEL));
+
+	/* The failed add does not transfer ownership, so free the string. */
+	overflow = kstrdup("b", GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, overflow);
+	added = stringset_add(set, overflow);
+	KUNIT_EXPECT_FALSE(test, added);
+	if (!added)
+		kfree(overflow);
+
+	KUNIT_EXPECT_EQ(test, stringset_count(set), 1u);
+}
+
+static void stringset_add_null_rejected(struct kunit *test)
+{
+	DEFINE_STRINGSET(set);
+
+	KUNIT_ASSERT_TRUE(test, stringset_alloc(&set, 1, GFP_KERNEL));
+	KUNIT_EXPECT_FALSE(test, stringset_add(&set, NULL));
+	KUNIT_EXPECT_FALSE(test, stringset_add_dup(&set, NULL, GFP_KERNEL));
+	stringset_destroy(&set);
+}
+
+/*
+ * stringset_add takes ownership; destroy must free it. A missed
+ * transfer leaks the string, which leak checkers (kmemleak) catch.
+ */
+static void stringset_add_takes_ownership(struct kunit *test)
+{
+	struct stringset *set = new_set(test);
+	char *str;
+
+	KUNIT_ASSERT_TRUE(test, stringset_alloc(set, 1, GFP_KERNEL));
+	str = kstrdup("owned", GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, str);
+	KUNIT_EXPECT_TRUE(test, stringset_add(set, str));
+	stringset_finalize(set);
+}
+
+static void stringset_add_is_queryable(struct kunit *test)
+{
+	struct stringset *set = new_set(test);
+	char *str;
+
+	KUNIT_ASSERT_TRUE(test, stringset_alloc(set, 1, GFP_KERNEL));
+	str = kstrdup("owned", GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, str);
+	KUNIT_EXPECT_TRUE(test, stringset_add(set, str));
+	KUNIT_EXPECT_FALSE(test, stringset_is_empty(set));
+	stringset_finalize(set);
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(set, "owned"));
+}
+
+static void stringset_finalize_dedups(struct kunit *test)
+{
+	const char * const in[] = { "a", "b", "a", "b" };
+	struct stringset *set;
+
+	set = build_set(test, in, ARRAY_SIZE(in));
+	KUNIT_EXPECT_EQ(test, stringset_count(set), 4u);
+	stringset_finalize(set);
+	KUNIT_EXPECT_EQ(test, stringset_count(set), 2u);
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(set, "a"));
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(set, "b"));
+}
+
+/*
+ * Callers must not depend on iteration order, but the sort is what
+ * makes binary-search membership work, so check it directly here.
+ */
+static void stringset_finalize_sorts(struct kunit *test)
+{
+	const char * const in[] = { "charlie", "alpha", "bravo" };
+	const char *prev = NULL, *str;
+	struct stringset *set;
+	unsigned int i;
+
+	set = build_set(test, in, ARRAY_SIZE(in));
+	stringset_finalize(set);
+	stringset_for_each(set, i, str) {
+		if (prev)
+			KUNIT_EXPECT_LT(test, strcmp(prev, str), 0);
+		prev = str;
+	}
+}
+
+static void stringset_is_member_present_and_absent(struct kunit *test)
+{
+	const char * const in[] = { "b", "d", "f", "h" };
+	struct stringset *set;
+
+	set = build_set(test, in, ARRAY_SIZE(in));
+	stringset_finalize(set);
+	/* present: first, middle, last */
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(set, "b"));
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(set, "f"));
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(set, "h"));
+	/* absent: before first, in a gap, after last */
+	KUNIT_EXPECT_FALSE(test, stringset_is_member(set, "a"));
+	KUNIT_EXPECT_FALSE(test, stringset_is_member(set, "e"));
+	KUNIT_EXPECT_FALSE(test, stringset_is_member(set, "z"));
+}
+
+static void stringset_intersection_overlap(struct kunit *test)
+{
+	const char * const a[] = { "a", "c", "e" };
+	const char * const b[] = { "b", "c", "d" };
+	struct stringset *s1, *s2;
+
+	s1 = build_set(test, a, ARRAY_SIZE(a));
+	s2 = build_set(test, b, ARRAY_SIZE(b));
+	stringset_finalize(s1);
+	stringset_finalize(s2);
+	KUNIT_EXPECT_TRUE(test, stringset_intersection(s1, s2));
+}
+
+static void stringset_intersection_disjoint(struct kunit *test)
+{
+	const char * const a[] = { "a", "b", "c" };
+	const char * const b[] = { "x", "y", "z" };
+	struct stringset *s1, *s2;
+
+	s1 = build_set(test, a, ARRAY_SIZE(a));
+	s2 = build_set(test, b, ARRAY_SIZE(b));
+	stringset_finalize(s1);
+	stringset_finalize(s2);
+	KUNIT_EXPECT_FALSE(test, stringset_intersection(s1, s2));
+}
+
+static void stringset_intersection_with_empty(struct kunit *test)
+{
+	const char * const a[] = { "a", "b" };
+	struct stringset *s1;
+	DEFINE_STRINGSET(empty);
+
+	s1 = build_set(test, a, ARRAY_SIZE(a));
+	stringset_finalize(s1);
+	stringset_finalize(&empty);
+	KUNIT_EXPECT_FALSE(test, stringset_intersection(s1, &empty));
+	stringset_destroy(&empty);
+}
+
+/* Copy is deep: destroying the source must not disturb the copy. */
+static void stringset_copy_is_independent(struct kunit *test)
+{
+	const char * const in[] = { "one", "two", "three" };
+	struct stringset *src, *dst;
+
+	src = build_set(test, in, ARRAY_SIZE(in));
+	stringset_finalize(src);
+	dst = new_set(test);
+	KUNIT_ASSERT_TRUE(test, stringset_copy(dst, src, GFP_KERNEL));
+	KUNIT_EXPECT_EQ(test, stringset_count(dst), 3u);
+
+	stringset_destroy(src);
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(dst, "one"));
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(dst, "three"));
+}
+
+static void stringset_copy_empty_src(struct kunit *test)
+{
+	DEFINE_STRINGSET(src);
+	DEFINE_STRINGSET(dst);
+
+	stringset_finalize(&src);
+	KUNIT_EXPECT_TRUE(test, stringset_copy(&dst, &src, GFP_KERNEL));
+	KUNIT_EXPECT_EQ(test, stringset_count(&dst), 0u);
+	/* dst is finalized, so a query is well-defined and returns false */
+	KUNIT_EXPECT_FALSE(test, stringset_is_member(&dst, "x"));
+	stringset_destroy(&dst);
+	stringset_destroy(&src);
+}
+
+static void stringset_iteration_visits_all(struct kunit *test)
+{
+	const char * const in[] = { "a", "b", "c", "d" };
+	unsigned int i, seen = 0;
+	struct stringset *set;
+	char *str;
+
+	set = build_set(test, in, ARRAY_SIZE(in));
+	stringset_finalize(set);
+	stringset_for_each(set, i, str) {
+		KUNIT_EXPECT_TRUE(test, stringset_is_member(set, str));
+		seen++;
+	}
+	KUNIT_EXPECT_EQ(test, seen, stringset_count(set));
+}
+
+static struct kunit_case stringset_test_cases[] = {
+	KUNIT_CASE(stringset_init_empty),
+	KUNIT_CASE(stringset_alloc_zero_is_empty_set),
+	KUNIT_CASE(stringset_alloc_twice_fails),
+	KUNIT_CASE(stringset_realloc_after_destroy),
+	KUNIT_CASE(stringset_add_capacity_exhausted),
+	KUNIT_CASE(stringset_add_null_rejected),
+	KUNIT_CASE(stringset_add_takes_ownership),
+	KUNIT_CASE(stringset_add_is_queryable),
+	KUNIT_CASE(stringset_finalize_dedups),
+	KUNIT_CASE(stringset_finalize_sorts),
+	KUNIT_CASE(stringset_is_member_present_and_absent),
+	KUNIT_CASE(stringset_intersection_overlap),
+	KUNIT_CASE(stringset_intersection_disjoint),
+	KUNIT_CASE(stringset_intersection_with_empty),
+	KUNIT_CASE(stringset_copy_is_independent),
+	KUNIT_CASE(stringset_copy_empty_src),
+	KUNIT_CASE(stringset_iteration_visits_all),
+	{}
+};
+
+static struct kunit_suite stringset_test_suite = {
+	.name = "stringset",
+	.test_cases = stringset_test_cases,
+};
+kunit_test_suite(stringset_test_suite);
+
+MODULE_DESCRIPTION("KUnit tests for the stringset data structure");
+MODULE_LICENSE("GPL");

-- 
2.56.0

