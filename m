Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599050;
	b=dq8aTDERc2sWgbNKUbCLVUVOJO5C2KbIHuDricm0Db7zSRzgIl8MdQa9+aCeYfP8o4Gl
	 nxypk4DnfM0zh0/7fvQyre5hxjUWHQ4tbt1SMVuW3mHefJgWveQG4frh8VOpEWoMEXDGE
	 AXZ2GyKRFjmg851Vtd5Hy1lQh5K88zEJl0EgupzdZygjaW43k11A+yvQyHAeNIHWg3vaA
	 IqEwwVXOOmcod6d9WLOpUXyfQtIGWSbfifrhKRGC3tIv19wZbvPoz8cQNokPIYQgLXlCK
	 EIYUVicdHG1ns5IxkpJf6qCUu1tr/U3JMo/2CCuQtDEmQjKR9hzqGmpQ/uSOJlIB3gw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599050;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=8twM88+c+/qju1iCkuEQ+kSUtcRIWTsexuBDQ6YzJ6w=;
	b=LoYW0yE1RrDcjacZ+VtIJqr6DgECWuSghakffJd6WoUA92YrMgu9XMKS/axnkpfuBag7
	 NieeIhLIp1qAST5mUjxhZD4hbqnxTzAg7QvMu+riaCdwrZBxIibWE+E76t2Bj9WQFAyc0
	 2Hyj4djn3uSW4wBaas98H6BGSChKHaNP6jPI/KjJkPgKnHSeYJoptffnZXwHANKzAHKaa
	 +Qrn0v22itwV7pVglCmGGjaMqraPOiIX6HvegRaOQ8xaizYNZrEYC6mekr6M11V2IKiWv
	 8qZM0HkNKzvCJf7JpNhfVpZLZZlh7MrMNdkJQkWBxBm7g04RZMNApqfIFKnEYXoKnog==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n61aeHMy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B45EA606A885
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n61aeHMy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 807281F000C5;
	Fri, 13 Nov 2026 19:44:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599050;
	bh=8twM88+c+/qju1iCkuEQ+kSUtcRIWTsexuBDQ6YzJ6w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=n61aeHMyWpncF1ySL2Q9DUy+itSMwc0Xs7QBAj4Omuxb//XDp3/Wp+4K287A/n3j1
	 woy0RTiOFYqof8RnZA0WDCj11C0ozlhlOgy4uZebPOg0hzBAe52FtQA3vaXau4pB/p
	 w9RneKyqpMzkRo+b7rRbeXaY+5AV/Hl1wEL8jZaD6vLh8eOzuALFIcsBimcZk9fdtB
	 zZKlYV2bzSM/5DCFveExjqfQQVMKssrJUa8IGwgOPmoqJOCA2Nnvznwkua4QNeGcfs
	 4FhNduAYSOVMr12W037etCjo2CCz0fTloibe/5nnpTna7IHjQknvaEGRWElfdH41gY
	 DlBgAxVcsXFgg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:43:59 -0500
Subject: [PATCH 1/8] SUNRPC: Add KUnit tests for xdr_buf_to_bvec()
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
Message-Id: <20261113-svcsock-bvecs-v1-1-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=11020; i=cel@kernel.org;
 h=from:subject:message-id; bh=jVjCAnlFhtqYS2psaxivvS1tqZvBU/YZxpsKOGC0NLA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iHBIPy+1vG9HMe3bjVtqMYOJ5qP6n/iRa/L
 r1BujI8IIGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 l3mkD/9CX4t/6t7Vkdrjy2e1QZ6NanduinNVV8ZBrOvuJqnqq5ZO71mXLsr04aDwnYGLlCub5FF
 8We8DjibnAyEXacQ/5TtAWmsxdmGfKF0ltfu/z8MoLDmifVDn+lN0TfHC2rynWCwxR88UlbSsrn
 uLisE2q/njUbup+xHW5Y8n55WSI3Nz4DsWB1hVVjT7zCqhusF46sMYbIdYiSj/wxWS+bLCg+/Pt
 9GlN1ARyNoNN8eFCRHSejdCrzZsTaCU+spiz4Lt7lOl//Nda4jc0gbFAmAV1frA/6cArkISy/hd
 bfxPMwIkSDe3Vs+N59z1bAaIRTF/8UQKomHYGG1smjgNDOiiidWJG70dNFPqANuNPqYonJAJcfa
 jEAx9M5ONe4rq5McOfZnDgd1qNXHHKzV73vb6XqcFIX+zWBpUbt8jhn+i3TckpFbSCpHFm8hJ8M
 vywuBg7QtlwJ4TxhELIAfUbGE0d49twK+BB7zEHAipov93u8x0GoJXNW1orSOzANigduWVcHgft
 sMH/nOVqJzM+OzSLefhTT6fg7dJJP1Tohf63IV8SQ4d2kWVgolUYphaitiEe5vNjhBjwryer4w2
 7ACx9OpPoPhJ/hmMvqsgeF/ZnbI0vunweWqY4aO2uLNyJgW1A/UAocsCrIYdFfVTbA4kPdIDnYU
 apkhle4IVQeExZA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Commit 32af2cb54ed1 ("nfsd: account for page_base when advancing
rq_next_page") changed how xdr_buf_to_bvec() walks the page array,
and the function has no test. A splice READ at an unaligned offset
produces a page_base within the first page. A page_base of a page or
more arises only from a direct READ on a device with large logical
blocks, and most test rigs do not have one.

Add KUnit tests that cover the page_base cases, head and tail
sharing a page, a buffer with head, pages, and tail, an exact fit on
the last page, a bio_vec array filled exactly, and overflow at the
head, in the pages, and at the tail. The two cases with a page_base
of a page or more fail without that commit and pass with it.

Split the page allocation out of xdr_test_setup() so that the new
tests share the encoder tests' pages without setting up an
xdr_stream.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/Kconfig           |   5 +-
 net/sunrpc/tests/xdr_kunit.c | 208 +++++++++++++++++++++++++++++++++++++++----
 2 files changed, 193 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 5a4e098887d6..8854cf0bb1e1 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -62,13 +62,14 @@ config SUNRPC_DEBUG_TRACE
           with sunrpc-based clients or services.
 
 config SUNRPC_KUNIT_TEST
-	tristate "KUnit tests for the SunRPC XDR encoder" if !KUNIT_ALL_TESTS
+	tristate "KUnit tests for SunRPC XDR buffers" if !KUNIT_ALL_TESTS
 	depends on SUNRPC && KUNIT
 	default KUNIT_ALL_TESTS
 	help
 	  This builds KUnit tests for encoding an RPC Reply into pages
 	  that begin at a nonzero offset, as an NFSD direct READ leaves
-	  them. The tests report their results in TAP format.
+	  them, and for converting an xdr_buf to a bio_vec array. The
+	  tests report their results in TAP format.
 
 	  For more information on KUnit and unit tests in general, refer
 	  to the KUnit documentation in Documentation/dev-tools/kunit/.
diff --git a/net/sunrpc/tests/xdr_kunit.c b/net/sunrpc/tests/xdr_kunit.c
index f0652401e28d..93dc7a9d7b9e 100644
--- a/net/sunrpc/tests/xdr_kunit.c
+++ b/net/sunrpc/tests/xdr_kunit.c
@@ -1,9 +1,10 @@
 // SPDX-License-Identifier: GPL-2.0
 /*
- * KUnit tests for encoding an RPC Reply into pages that begin at a
- * nonzero page_base, as an NFSD direct READ leaves them. The entry past
- * the last Reply page holds a canary in place of the NULL sentinel,
- * since a store through page_address(NULL) kills the test thread.
+ * KUnit tests for encoding an RPC Reply into pages that begin at a nonzero
+ * page_base, as an NFSD direct READ leaves them, and for converting an xdr_buf
+ * to a bio_vec array. The entry past the last Reply page holds a canary in
+ * place of the NULL sentinel, since a store through page_address(NULL) kills
+ * the test thread.
  */
 #include <kunit/test.h>
 #include <linux/mm.h>
@@ -50,19 +51,10 @@ static struct page *xdr_test_canary(struct kunit *test)
 	return f->respages[XDR_TEST_NPAGES + 1];
 }
 
-/*
- * Mirror a direct READ: nfsd_direct_read() sets page_base before the
- * payload is reserved, and nfsd4_encode_readv() takes the pad off buflen
- * because len never counts it.
- */
-static struct xdr_stream *xdr_test_setup(struct kunit *test,
-					 unsigned int page_base)
+static struct xdr_test_fixture *xdr_test_alloc_fixture(struct kunit *test)
 {
 	struct xdr_test_fixture *f;
-	struct svc_rqst *rqstp;
-	struct xdr_buf *buf;
 	unsigned int i;
-	__be32 *p;
 	int ret;
 
 	f = kunit_kzalloc(test, sizeof(*f), GFP_KERNEL);
@@ -76,10 +68,25 @@ static struct xdr_stream *xdr_test_setup(struct kunit *test,
 	memset(page_address(f->respages[XDR_TEST_NPAGES + 1]),
 	       XDR_TEST_CANARY, PAGE_SIZE);
 
-	rqstp = kunit_kzalloc(test, sizeof(*rqstp), GFP_KERNEL);
-	KUNIT_ASSERT_NOT_NULL(test, rqstp);
-	f->rqstp = rqstp;
+	f->rqstp = kunit_kzalloc(test, sizeof(*f->rqstp), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, f->rqstp);
 	test->priv = f;
+	return f;
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
+	struct xdr_test_fixture *f = xdr_test_alloc_fixture(test);
+	struct svc_rqst *rqstp = f->rqstp;
+	struct xdr_buf *buf;
+	__be32 *p;
+	int ret;
 
 	rqstp->rq_page_end = &f->respages[XDR_TEST_NPAGES + 1];
 	buf = &rqstp->rq_res;
@@ -474,6 +481,163 @@ static void xdr_test_restore_slack_page_boundary(struct kunit *test)
 	xdr_test_check_two_words(test, xdr->buf, XDR_TEST_HEAD_LEN + count);
 }
 
+#define XDR_TEST_BVEC_SIZE	(XDR_TEST_NPAGES + 2)
+
+static struct xdr_buf *xdr_test_bvec_buf(struct kunit *test,
+					 unsigned int head_len,
+					 unsigned int page_base,
+					 unsigned int page_len,
+					 unsigned int tail_len)
+{
+	struct xdr_test_fixture *f = xdr_test_alloc_fixture(test);
+	struct xdr_buf *buf = &f->rqstp->rq_res;
+	void *head = page_address(f->respages[0]);
+
+	buf->head[0].iov_base = head;
+	buf->head[0].iov_len = head_len;
+	buf->pages = &f->respages[1];
+	buf->page_base = page_base;
+	buf->page_len = page_len;
+	buf->tail[0].iov_base = head + PAGE_SIZE - tail_len;
+	buf->tail[0].iov_len = tail_len;
+	buf->len = head_len + page_len + tail_len;
+	buf->buflen = buf->len;
+	return buf;
+}
+
+static struct page *xdr_test_head_page(struct kunit *test)
+{
+	struct xdr_test_fixture *f = test->priv;
+
+	return f->respages[0];
+}
+
+static void xdr_test_bvec_expect(struct kunit *test, const struct bio_vec *bv,
+				 struct page *page, unsigned int offset,
+				 unsigned int len)
+{
+	KUNIT_EXPECT_PTR_EQ(test, bv->bv_page, page);
+	KUNIT_EXPECT_EQ(test, bv->bv_offset, offset);
+	KUNIT_EXPECT_EQ(test, bv->bv_len, len);
+}
+
+static void xdr_test_bvec_head_tail_same_page(struct kunit *test)
+{
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 100, 0, 0, 8);
+	struct page *head = xdr_test_head_page(test);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, ARRAY_SIZE(bvec), buf);
+
+	KUNIT_ASSERT_EQ(test, count, 2);
+	xdr_test_bvec_expect(test, &bvec[0], head, 0, 100);
+	xdr_test_bvec_expect(test, &bvec[1], head, PAGE_SIZE - 8, 8);
+}
+
+static void xdr_test_bvec_page_base(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 64, base, PAGE_SIZE, 0);
+	struct page **pages = buf->pages + (base >> PAGE_SHIFT);
+	unsigned int offset = offset_in_page(base);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, ARRAY_SIZE(bvec), buf);
+
+	KUNIT_ASSERT_EQ(test, count, offset ? 3 : 2);
+	xdr_test_bvec_expect(test, &bvec[0], xdr_test_head_page(test), 0, 64);
+	xdr_test_bvec_expect(test, &bvec[1], pages[0], offset,
+			     PAGE_SIZE - offset);
+	if (offset)
+		xdr_test_bvec_expect(test, &bvec[2], pages[1], 0, offset);
+}
+
+static void xdr_test_bvec_exact_fit_last_page(struct kunit *test)
+{
+	unsigned int page_len = (XDR_TEST_NPAGES - 1) * PAGE_SIZE;
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 64, PAGE_SIZE, page_len, 0);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	unsigned int i;
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, ARRAY_SIZE(bvec), buf);
+
+	KUNIT_ASSERT_EQ(test, count, XDR_TEST_NPAGES);
+	xdr_test_bvec_expect(test, &bvec[0], xdr_test_head_page(test), 0, 64);
+	for (i = 1; i < XDR_TEST_NPAGES; i++)
+		xdr_test_bvec_expect(test, &bvec[i], buf->pages[i], 0,
+				     PAGE_SIZE);
+}
+
+static void xdr_test_bvec_head_pages_tail(struct kunit *test)
+{
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 64, 512, PAGE_SIZE, 8);
+	struct page *head = xdr_test_head_page(test);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, ARRAY_SIZE(bvec), buf);
+
+	KUNIT_ASSERT_EQ(test, count, 4);
+	xdr_test_bvec_expect(test, &bvec[0], head, 0, 64);
+	xdr_test_bvec_expect(test, &bvec[1], buf->pages[0], 512,
+			     PAGE_SIZE - 512);
+	xdr_test_bvec_expect(test, &bvec[2], buf->pages[1], 0, 512);
+	xdr_test_bvec_expect(test, &bvec[3], head, PAGE_SIZE - 8, 8);
+}
+
+static void xdr_test_bvec_exact_fill(struct kunit *test)
+{
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 64, 0, 2 * PAGE_SIZE, 0);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, 3, buf);
+
+	KUNIT_ASSERT_EQ(test, count, 3);
+	xdr_test_bvec_expect(test, &bvec[0], xdr_test_head_page(test), 0, 64);
+	xdr_test_bvec_expect(test, &bvec[1], buf->pages[0], 0, PAGE_SIZE);
+	xdr_test_bvec_expect(test, &bvec[2], buf->pages[1], 0, PAGE_SIZE);
+}
+
+static void xdr_test_bvec_overflow_head(struct kunit *test)
+{
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 64, 0, 0, 0);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, 0, buf);
+
+	KUNIT_EXPECT_EQ(test, count, -ESERVERFAULT);
+	KUNIT_EXPECT_NULL(test, bvec[0].bv_page);
+}
+
+static void xdr_test_bvec_overflow_pages(struct kunit *test)
+{
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 64, 0, 2 * PAGE_SIZE, 0);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, 2, buf);
+
+	KUNIT_EXPECT_EQ(test, count, -ESERVERFAULT);
+	KUNIT_EXPECT_NULL(test, bvec[2].bv_page);
+}
+
+static void xdr_test_bvec_overflow_tail(struct kunit *test)
+{
+	struct xdr_buf *buf = xdr_test_bvec_buf(test, 64, 0, PAGE_SIZE, 8);
+	struct bio_vec bvec[XDR_TEST_BVEC_SIZE] = { };
+	int count;
+
+	count = xdr_buf_to_bvec(bvec, 2, buf);
+
+	KUNIT_EXPECT_EQ(test, count, -ESERVERFAULT);
+	KUNIT_EXPECT_NULL(test, bvec[2].bv_page);
+}
+
 static struct kunit_case xdr_test_cases[] = {
 	KUNIT_CASE_PARAM(xdr_test_payload, xdr_test_base_gen_params),
 	KUNIT_CASE_PARAM(xdr_test_exact_fit, xdr_test_base_gen_params),
@@ -491,6 +655,14 @@ static struct kunit_case xdr_test_cases[] = {
 			 xdr_test_base_gen_params),
 	KUNIT_CASE_PARAM(xdr_test_restore_slack_page_boundary,
 			 xdr_test_base_gen_params),
+	KUNIT_CASE(xdr_test_bvec_head_tail_same_page),
+	KUNIT_CASE_PARAM(xdr_test_bvec_page_base, xdr_test_base_gen_params),
+	KUNIT_CASE(xdr_test_bvec_exact_fit_last_page),
+	KUNIT_CASE(xdr_test_bvec_head_pages_tail),
+	KUNIT_CASE(xdr_test_bvec_exact_fill),
+	KUNIT_CASE(xdr_test_bvec_overflow_head),
+	KUNIT_CASE(xdr_test_bvec_overflow_pages),
+	KUNIT_CASE(xdr_test_bvec_overflow_tail),
 	{}
 };
 
@@ -501,5 +673,5 @@ static struct kunit_suite xdr_test_suite = {
 
 kunit_test_suite(xdr_test_suite);
 
-MODULE_DESCRIPTION("KUnit tests for the SunRPC XDR encoder");
+MODULE_DESCRIPTION("KUnit tests for SunRPC XDR buffers");
 MODULE_LICENSE("GPL");

-- 
2.56.0

