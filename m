Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254017;
	b=ih4mM0JxIpkwpN0HhojHI7Qd5JBN7MQYJzO+3yXbVJ89Q83hBGH5QTGH4EgUQV3YcGHa
	 RGI9r90FpIZ9ZVeHKvyeqWnHgBVOU1sjUSFbYkqMQmybAv254k3DHYe5Ic0sYBGoYDqKl
	 nMCrjuA78ZNjolV8+4BEOX+pj8kWoDYqdnegfApX+JYdDQcokA3FilVLez6zsEMRiNVbU
	 O5xoMNtpiVM84eqoUFQUU4zTTrGvPh1UxaATuIKi2czxEREREyaQVK8Eprd7wYe9KGddm
	 sxvAxBGOB06yCWhd+HyWwqxXNaHQSMJ4xGIEuyF8+hITYUHVUoX72seGtrYNJ5vspGw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254017;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=De+Rth8QR2sqHiQ5tHo274U34Z0fP/sIRZXusv4dQNo=;
	b=l7j8mYa+Gt0Xd9IfDsFX6NDLNc/Kl4k62HZbb1CKqcu373mqWRyTQvnju/dvOqsUN/hf
	 1LS+s/N+YsyiYNuIlYDg+waYcO2XaaxglF6mwUjWc2fn5LwB8JNa/N0V88kB5gUu0ZK9M
	 Lyya7b/kAHuisdhibRAt41VjDEb9fWqEJyjjpCCa4lWnvJc1c0PhNvKcUCxdh5Ib/InNn
	 t6HNITP4Glnh3BxcixYz90fSj448iuf7reBN9loLzbb0lQ7liCj0R1BNPEVhqNDYKSV30
	 SVlxQOReK+3415MaPcBkY+t9rO5pK/zhBkFENVXC+8SqdGi61igWSZez+u381L7swSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cBEQYbR7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3156E60A5BE9
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cBEQYbR7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C67C1F00903;
	Mon,  9 Nov 2026 19:53:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254016;
	bh=De+Rth8QR2sqHiQ5tHo274U34Z0fP/sIRZXusv4dQNo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cBEQYbR7Hhpp0L0mg8uiF8BfwMC4aSuladuaMVQKmtURxNqsv/8s69GPB6YcZx8xD
	 Hp4hrBSvA4gBQ7+nHhmeqc9k8hEZNFut018mdOf3tawHJyeHLiMURuKGdqX+tmECjt
	 AIANuq1Z3B9pVms6h05ZUiXhxwFlWa6J+zIyZ7OAiLJmeVHF+YQnGRigM/z/UwBKfn
	 NQVd7ac4feCcthTTqVTE99XE5thNSEkD76jPQqNcMR/mB0c+emx7LptmnTdE/CMSRc
	 mQ0TEdsYJDjfs8RM+Fvfvj2Ez32sxfmJBb0md6jD+9LBrAZ/azfyFX7yh8OMqvc257
	 Q3VqtcXZfovQA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:24 -0500
Subject: [PATCH 08/13] SUNRPC: Add KUnit tests for encoding after a nonzero
 page_base
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
Message-Id: <20261109-xdr-page-base-v1-8-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=15380; i=cel@kernel.org;
 h=from:subject:message-id; bh=q53UZSq82ZEVJdd8vSYBlkC8HzCKV+H7BlEwzLXohnY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS4IL2hrHFYTxnVG8RCfs+S2LRttLllo7Ag6
 tJOnej1236JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 l3oRD/4vv3yG82lE6cKb9SH81D+nxITqfYyvFwS2jccaUJAA3nFQ2SteuyKObEsgP1PhDdrwT2Q
 +ij7FOjIba0EfbSsXYLJF4Qq4uPh5UGJWyuUizqvIXW7gmSd692GfH07PHt9epDFycne+3Y2Cpc
 4yxo3tBx4cWVO45Ptlkv/X+8PThdLLCwy2MSWge9hNDYUWsJ1BvJ9Eqah4MlsHF/W8STymvMhZm
 Lg5Ww+h6wdlv+6EYGbn1l7EkKYvtJ+dkTdsxNSn0LsP6xYbia7mbOIXlywB6VA7dqd3/pfOQ/Xt
 ppPHVnV+kvKM/EBaOZzlneAxk7Gu+PZNqwMRlMJjKwtR4rjWz9Jutkysr3BBxJ+hHK6ifDEvPXF
 HZ7wVKpo+kA6aDrNUXCDdH0fpn+1m0rywlHwIACUWzuL1Es4lj/G6cwKcoCdSJrwmDQoNkENO/Y
 Ssne0QrxorFutXOhVmA/TeSAW9++oM45gKSgnL0R43JSfzwLVs4FM/ji2r13ERRE7jjq6mGwYj4
 bUJ9aZBXEhEkDWNu0potmrrDuMx+cvqT3QrjDJo/xBeKmSKhVHUQR1PlzvOAuQzsA9dd3ieFSjy
 svWBC3SiKDnVFdkkY5n2vipf3FxBO4BTv70VKvlp9Qai5+2DEPwQyNT1ru0idRvQT3JzETBjQIG
 5xoH+5nHTWV8yhg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

On x86 a misaligned store is silent and a write past the Reply pages
corrupts memory without a fault. A wire test sees the krb5i integrity
failure but not the store or the overrun. net/sunrpc has no KUnit suite
to hold a test that does.

Add one. svcxdr_init_encode() sets up the stream on a kunit-allocated
svc_rqst, as the server path does, and a canary page stands in for the
NULL sentinel at rq_page_end. The cases run at page_base values on both
sides of a page boundary and check that xdr->p stays word-aligned, that
the payload reads back, and that the canary is intact.

Without the preceding "SUNRPC: Account for page_base when encoding into
the reply pages", three cases fail and UML crashes before the remaining
cases run.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/Kconfig           |  14 ++
 net/sunrpc/Makefile          |   3 +
 net/sunrpc/tests/xdr_kunit.c | 379 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 396 insertions(+)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index e7808e5714dc..5a4e098887d6 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -61,6 +61,20 @@ config SUNRPC_DEBUG_TRACE
           logged at boot time, so say N unless you are debugging a problem
           with sunrpc-based clients or services.
 
+config SUNRPC_KUNIT_TEST
+	tristate "KUnit tests for the SunRPC XDR encoder" if !KUNIT_ALL_TESTS
+	depends on SUNRPC && KUNIT
+	default KUNIT_ALL_TESTS
+	help
+	  This builds KUnit tests for encoding an RPC Reply into pages
+	  that begin at a nonzero offset, as an NFSD direct READ leaves
+	  them. The tests report their results in TAP format.
+
+	  For more information on KUnit and unit tests in general, refer
+	  to the KUnit documentation in Documentation/dev-tools/kunit/.
+
+	  If unsure, say N.
+
 config SUNRPC_XPRT_RDMA
 	tristate "RPC-over-RDMA transport"
 	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 96727df3aa85..de080ed08314 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -19,3 +19,6 @@ sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
 sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
+
+obj-$(CONFIG_SUNRPC_KUNIT_TEST) += sunrpc_kunit.o
+sunrpc_kunit-y := tests/xdr_kunit.o
diff --git a/net/sunrpc/tests/xdr_kunit.c b/net/sunrpc/tests/xdr_kunit.c
new file mode 100644
index 000000000000..25eb69dbcc90
--- /dev/null
+++ b/net/sunrpc/tests/xdr_kunit.c
@@ -0,0 +1,379 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KUnit tests for encoding an RPC Reply into pages that begin at a
+ * nonzero page_base, as an NFSD direct READ leaves them. The entry past
+ * the last Reply page holds a canary in place of the NULL sentinel,
+ * since a store through page_address(NULL) kills the test thread.
+ */
+#include <kunit/test.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/xdr.h>
+
+#define XDR_TEST_NPAGES		4
+#define XDR_TEST_HEAD_LEN	(XDR_UNIT * 3)
+#define XDR_TEST_CANARY		0xa5
+#define XDR_TEST_TRAILER	0xfeedface
+
+struct xdr_test_fixture {
+	/* [0] is the head, then the Reply pages, then the canary */
+	struct page		*respages[XDR_TEST_NPAGES + 2];
+};
+
+static const unsigned int xdr_test_bases[] = {
+	0, 4, PAGE_SIZE - 4, PAGE_SIZE + 4,
+};
+
+static void xdr_test_base_desc(const unsigned int *base, char *desc)
+{
+	snprintf(desc, KUNIT_PARAM_DESC_SIZE, "page_base=%u", *base);
+}
+
+KUNIT_ARRAY_PARAM(xdr_test_base, xdr_test_bases, xdr_test_base_desc);
+
+static void xdr_test_free_pages(void *data)
+{
+	struct xdr_test_fixture *f = data;
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(f->respages); i++)
+		if (f->respages[i])
+			__free_page(f->respages[i]);
+}
+
+static struct page *xdr_test_canary(struct kunit *test)
+{
+	struct xdr_test_fixture *f = test->priv;
+
+	return f->respages[XDR_TEST_NPAGES + 1];
+}
+
+/*
+ * Mirror a direct READ: nfsd_direct_read() sets page_base before the
+ * payload is reserved, and nfsd4_encode_readv() takes the pad off buflen
+ * because len never counts it.
+ */
+static struct xdr_stream *xdr_test_setup(struct kunit *test,
+					 unsigned int page_base)
+{
+	struct xdr_test_fixture *f;
+	struct svc_rqst *rqstp;
+	struct xdr_buf *buf;
+	unsigned int i;
+	__be32 *p;
+	int ret;
+
+	f = kunit_kzalloc(test, sizeof(*f), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, f);
+	ret = kunit_add_action_or_reset(test, xdr_test_free_pages, f);
+	KUNIT_ASSERT_EQ(test, ret, 0);
+	for (i = 0; i < ARRAY_SIZE(f->respages); i++) {
+		f->respages[i] = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		KUNIT_ASSERT_NOT_NULL(test, f->respages[i]);
+	}
+	memset(page_address(f->respages[XDR_TEST_NPAGES + 1]),
+	       XDR_TEST_CANARY, PAGE_SIZE);
+
+	rqstp = kunit_kzalloc(test, sizeof(*rqstp), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, rqstp);
+	test->priv = f;
+
+	rqstp->rq_page_end = &f->respages[XDR_TEST_NPAGES + 1];
+	buf = &rqstp->rq_res;
+	buf->head[0].iov_base = page_address(f->respages[0]);
+	buf->pages = &f->respages[1];
+
+	svcxdr_init_encode(rqstp);
+	p = xdr_reserve_space(&rqstp->rq_res_stream, XDR_TEST_HEAD_LEN);
+	KUNIT_ASSERT_NOT_NULL(test, p);
+	memset(p, 0, XDR_TEST_HEAD_LEN);
+
+	buf->page_base = page_base;
+	ret = xdr_restrict_buflen(&rqstp->rq_res_stream,
+				  PAGE_SIZE * (rqstp->rq_page_end - buf->pages) -
+				  page_base);
+	KUNIT_ASSERT_EQ(test, ret, 0);
+	return &rqstp->rq_res_stream;
+}
+
+static void xdr_test_check_stream(struct kunit *test, struct xdr_stream *xdr)
+{
+	struct xdr_buf *buf = xdr->buf;
+
+	KUNIT_EXPECT_EQ(test, (unsigned long)xdr->p % XDR_UNIT, 0UL);
+	KUNIT_EXPECT_TRUE(test,
+			  xdr->page_ptr <= buf->pages + XDR_TEST_NPAGES - 1);
+	KUNIT_EXPECT_NULL(test, memchr_inv(page_address(xdr_test_canary(test)),
+					   XDR_TEST_CANARY, PAGE_SIZE));
+}
+
+/*
+ * The i >> 8 term keeps a shift by whole pages from reading back right.
+ * The i >> 16 term does the same on a 64 KiB page kernel, where the
+ * first two terms repeat every page.
+ */
+static u8 xdr_test_pattern(unsigned int i)
+{
+	return (u8)(i * 7 + (i >> 8) + (i >> 16) + 1);
+}
+
+/* Pattern each byte by its logical offset so misplacement reads back wrong */
+static void xdr_test_fill_payload(struct xdr_buf *buf, unsigned int start,
+				  unsigned int count)
+{
+	unsigned int i, off;
+
+	for (i = start; i < start + count; i++) {
+		off = buf->page_base + i;
+		((u8 *)page_address(buf->pages[off >> PAGE_SHIFT]))
+			[offset_in_page(off)] = xdr_test_pattern(i);
+	}
+}
+
+/* Reserve a payload whose bytes are already in the pages, then pad it */
+static void xdr_test_reserve_payload(struct kunit *test, struct xdr_stream *xdr,
+				     unsigned int start, unsigned int count)
+{
+	__be32 zero = xdr_zero;
+	int ret;
+
+	xdr_test_fill_payload(xdr->buf, start, count);
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, count), 0);
+	ret = write_bytes_to_xdr_buf(xdr->buf, XDR_TEST_HEAD_LEN + start + count,
+				     &zero, xdr_pad_size(count));
+	KUNIT_ASSERT_EQ(test, ret, 0);
+	xdr_test_check_stream(test, xdr);
+}
+
+/* The payload reads back by logical offset and its pad reads back as zero */
+static void xdr_test_check_payload(struct kunit *test, struct xdr_buf *buf,
+				   unsigned int start, unsigned int count)
+{
+	unsigned int end = xdr_align_size(start + count);
+	unsigned int i;
+	u8 *data;
+	int ret;
+
+	data = kunit_kmalloc(test, end - start, GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, data);
+	ret = read_bytes_from_xdr_buf(buf, XDR_TEST_HEAD_LEN + start, data,
+				      end - start);
+	KUNIT_ASSERT_EQ(test, ret, 0);
+	for (i = 0; i < count; i++)
+		if (data[i] != xdr_test_pattern(start + i))
+			break;
+	KUNIT_EXPECT_EQ(test, i, count);
+	for (; i < end - start; i++)
+		KUNIT_EXPECT_EQ(test, data[i], 0);
+}
+
+/*
+ * One word per reserve, as an operation's result is encoded. At
+ * page_base = PAGE_SIZE - 4 the second word steps to the next page.
+ */
+static void xdr_test_encode_two_words(struct kunit *test,
+				      struct xdr_stream *xdr)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, XDR_UNIT);
+	KUNIT_ASSERT_NOT_NULL(test, p);
+	*p = cpu_to_be32(1);
+	p = xdr_reserve_space(xdr, XDR_UNIT);
+	KUNIT_ASSERT_NOT_NULL(test, p);
+	*p = cpu_to_be32(XDR_TEST_TRAILER);
+	xdr_commit_encode(xdr);
+	xdr_test_check_stream(test, xdr);
+}
+
+static void xdr_test_check_two_words(struct kunit *test, struct xdr_buf *buf,
+				     unsigned int offset)
+{
+	__be32 words[2];
+	int ret;
+
+	ret = read_bytes_from_xdr_buf(buf, offset, words, sizeof(words));
+	KUNIT_ASSERT_EQ(test, ret, 0);
+	KUNIT_EXPECT_EQ(test, be32_to_cpu(words[0]), 1);
+	KUNIT_EXPECT_EQ(test, be32_to_cpu(words[1]), XDR_TEST_TRAILER);
+}
+
+static unsigned int xdr_test_room(unsigned int base)
+{
+	return XDR_TEST_NPAGES * PAGE_SIZE - XDR_TEST_HEAD_LEN - base;
+}
+
+/* A padded payload, then two more words; all read back at logical offsets */
+static void xdr_test_payload(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	unsigned int count = 2 * PAGE_SIZE + 5;
+	struct xdr_stream *xdr;
+
+	xdr = xdr_test_setup(test, base);
+	xdr_test_reserve_payload(test, xdr, 0, count);
+	KUNIT_EXPECT_EQ(test, xdr->buf->page_len, xdr_align_size(count));
+	xdr_test_encode_two_words(test, xdr);
+	xdr_test_check_payload(test, xdr->buf, 0, count);
+	xdr_test_check_two_words(test, xdr->buf,
+				 XDR_TEST_HEAD_LEN + xdr_align_size(count));
+}
+
+/* A payload that fills the Reply pages exactly leaves no more room */
+static void xdr_test_exact_fit(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	unsigned int room = xdr_test_room(base);
+	struct xdr_stream *xdr;
+
+	xdr = xdr_test_setup(test, base);
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, room), 0);
+	xdr_test_check_stream(test, xdr);
+	KUNIT_EXPECT_EQ(test, xdr->buf->page_len, room);
+	KUNIT_EXPECT_NULL(test, xdr_reserve_space(xdr, XDR_UNIT));
+	xdr_test_check_stream(test, xdr);
+}
+
+/* One byte more than the room, rounded to a word, is refused */
+static void xdr_test_one_over(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	unsigned int room = xdr_test_room(base);
+	struct xdr_stream *xdr;
+
+	xdr = xdr_test_setup(test, base);
+	KUNIT_EXPECT_EQ(test, xdr_reserve_space_vec(xdr, room + 1), -EMSGSIZE);
+	xdr_test_check_stream(test, xdr);
+}
+
+/* After a zero-byte xdr_reserve_space_vec(), the next reserve enters pages */
+static void xdr_test_zero_vec(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	struct xdr_stream *xdr;
+
+	xdr = xdr_test_setup(test, base);
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, 0), 0);
+	KUNIT_EXPECT_NULL(test, xdr->iov);
+
+	xdr_test_encode_two_words(test, xdr);
+	xdr_test_check_two_words(test, xdr->buf, XDR_TEST_HEAD_LEN);
+}
+
+/* A reserve entering the pages has to fit in the rest of the entry page */
+static void xdr_test_entry_too_large(struct kunit *test)
+{
+	struct xdr_stream *xdr;
+
+	xdr = xdr_test_setup(test, PAGE_SIZE - XDR_UNIT);
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, 0), 0);
+	KUNIT_EXPECT_NULL(test, xdr_reserve_space(xdr, 2 * XDR_UNIT));
+	KUNIT_EXPECT_EQ(test, xdr->buf->page_len, 0);
+	xdr_test_check_stream(test, xdr);
+}
+
+/* Truncating back to the head clears page_base along with the payload */
+static void xdr_test_truncate(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	struct xdr_stream *xdr;
+	struct xdr_buf *buf;
+
+	xdr = xdr_test_setup(test, base);
+	buf = xdr->buf;
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, PAGE_SIZE + 8), 0);
+
+	xdr_truncate_encode(xdr, XDR_TEST_HEAD_LEN);
+	KUNIT_EXPECT_EQ(test, buf->page_base, 0);
+	KUNIT_EXPECT_EQ(test, buf->page_len, 0);
+	KUNIT_EXPECT_EQ(test, buf->len, XDR_TEST_HEAD_LEN);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->page_ptr, buf->pages - 1);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->iov, &buf->head[0]);
+	KUNIT_EXPECT_PTR_EQ(test, (void *)xdr->p,
+			    buf->head[0].iov_base + XDR_TEST_HEAD_LEN);
+	xdr_test_check_stream(test, xdr);
+}
+
+/* A server stream does not enter the pages at an unaligned page_base */
+static void xdr_test_unaligned_base(struct kunit *test)
+{
+	struct xdr_stream *xdr;
+	int ret = 0;
+
+	xdr = xdr_test_setup(test, 1);
+	kunit_warning_suppress(test) {
+		ret = xdr_reserve_space_vec(xdr, 16);
+	}
+	KUNIT_EXPECT_EQ(test, ret, -EMSGSIZE);
+	KUNIT_EXPECT_EQ(test, xdr->buf->page_len, 0);
+	xdr_test_check_stream(test, xdr);
+}
+
+/*
+ * A second payload at page_base + page_len, where a second READ in one
+ * COMPOUND lands. Both payloads, and the words encoded after the second,
+ * read back at logical offsets.
+ */
+static void xdr_test_second_payload(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	unsigned int count1 = PAGE_SIZE + 5, count2 = PAGE_SIZE + 7;
+	unsigned int start2 = xdr_align_size(count1);
+	unsigned int end2 = start2 + xdr_align_size(count2);
+	struct xdr_stream *xdr;
+
+	xdr = xdr_test_setup(test, base);
+	xdr_test_reserve_payload(test, xdr, 0, count1);
+	xdr_test_reserve_payload(test, xdr, start2, count2);
+	KUNIT_EXPECT_EQ(test, xdr->buf->page_len, end2);
+	xdr_test_encode_two_words(test, xdr);
+	xdr_test_check_payload(test, xdr->buf, 0, count1);
+	xdr_test_check_payload(test, xdr->buf, start2, count2);
+	xdr_test_check_two_words(test, xdr->buf, XDR_TEST_HEAD_LEN + end2);
+}
+
+/*
+ * A reserve straddling the head's end is refused: the fragment would
+ * be copied back to page offset 0, not to page_base.
+ */
+static void xdr_test_straddle(struct kunit *test)
+{
+	struct xdr_stream *xdr;
+	__be32 *p;
+
+	xdr = xdr_test_setup(test, XDR_UNIT);
+	p = xdr_reserve_space(xdr, PAGE_SIZE - XDR_TEST_HEAD_LEN - XDR_UNIT);
+	KUNIT_ASSERT_NOT_NULL(test, p);
+	KUNIT_ASSERT_PTR_EQ(test, xdr->iov, &xdr->buf->head[0]);
+
+	kunit_warning_suppress(test) {
+		p = xdr_reserve_space(xdr, 2 * XDR_UNIT);
+	}
+	KUNIT_EXPECT_NULL(test, p);
+	KUNIT_EXPECT_EQ(test, xdr->buf->page_len, 0);
+	xdr_test_check_stream(test, xdr);
+}
+
+static struct kunit_case xdr_test_cases[] = {
+	KUNIT_CASE_PARAM(xdr_test_payload, xdr_test_base_gen_params),
+	KUNIT_CASE_PARAM(xdr_test_exact_fit, xdr_test_base_gen_params),
+	KUNIT_CASE_PARAM(xdr_test_one_over, xdr_test_base_gen_params),
+	KUNIT_CASE_PARAM(xdr_test_zero_vec, xdr_test_base_gen_params),
+	KUNIT_CASE(xdr_test_entry_too_large),
+	KUNIT_CASE_PARAM(xdr_test_truncate, xdr_test_base_gen_params),
+	KUNIT_CASE(xdr_test_unaligned_base),
+	KUNIT_CASE_PARAM(xdr_test_second_payload, xdr_test_base_gen_params),
+	KUNIT_CASE(xdr_test_straddle),
+	{}
+};
+
+static struct kunit_suite xdr_test_suite = {
+	.name = "sunrpc_xdr",
+	.test_cases = xdr_test_cases,
+};
+
+kunit_test_suite(xdr_test_suite);
+
+MODULE_DESCRIPTION("KUnit tests for the SunRPC XDR encoder");
+MODULE_LICENSE("GPL");

-- 
2.56.0

