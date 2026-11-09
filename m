Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254018;
	b=SfAhBlh7LoPC55S/VXBX3zfUPdCJluHYsfSLzUZflPTiI0iBZwa3uXMdElXjRszsr4je
	 PzIdfLsISOmQWXSwE6QsWLfK06RClvKcNF+8ZnzyesjCkbuA24SWszv0oF0hy93MCmpIG
	 pDDjoJTSRbWVqXa5Qejswu/nZ8C9y280vLfSmC9dIdVSfavMAGa5Kr6oUeoFbX3Zr3mDI
	 m33x8/AqWVGzP1DoHrWGyS9weU8mWmv3lRYEAFsRR1fN2a0YG6dFv8Kr2ew8zajVqe8Zs
	 M9vJNYTI5FUJfVpo3S1Av1A7Q+vN4qV15FDP13oyEgTvOuQdJxuXz6cAsIED2Ub9RJg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254018;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=AQoHhIE9VKRQPsylrdUWZRRCRNaM3oZGZ9wlgVZZpVg=;
	b=PoiuMBrOudBwC24ugaPvshtIiQCWD00hnoZjxQfYaDFHHAzJcKiRmEN1EgZqYZ1K29rd
	 BtQuZtY1mrxrZHXVvmFW8IJRO+iZcTGKkPnqqaRYWRVTNACjqexgzsuxn8x6Rgc2etoS6
	 5zX44nBgbxSgfGptbZpcVdN+KDxh87/R3xHQ4L3ju4kcoT0cI5V7727zCj+lGxFFXGGJl
	 1WYLGC2ZaM98Ynqzd1M6TlTVNBoZyS9CNLDAbLrKocMC0TDhVpXLXjR+balZJ6y91GHhA
	 ZOeslrVj+A0cNPMNq++btQUVySYvZm4GpEI/4Ql0tpU80+SBRyVknW231MrBAi4R1aw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LFOdp70b;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA3F460A2625
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LFOdp70b
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2546F1F008A5;
	Mon,  9 Nov 2026 19:53:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254017;
	bh=AQoHhIE9VKRQPsylrdUWZRRCRNaM3oZGZ9wlgVZZpVg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LFOdp70bzR3gz2y0rXJI2gVtd/6SJf0gnXZRmGEF7z6VFnlHoCQDlhiD2FChP0Jsz
	 gEgf4LZg97qYhgdtmEUBsH5twAanSefvFbRyL1gihhAcMRQHluWNzkBIt7F3+gjK2v
	 qs0NICj4sCzHE9OBEhImMmk0H29MrRyLLMGyCoNkiIBGtmL6h2E0N1VsHjlJr/wxte
	 d68dp0mG9LPtC9UITeNbLTXPzEKq1eJWzoMU3WtaA3U2kFrUUkVeJxom8V3rMf0Jqr
	 MuNLJe73SM7PALi4BWFJNJ+nb4NMcvJSrWAAxwhiDdC7XkB7GLu49wQSrAf1W0eW9s
	 wk07uPRFQt2gA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:25 -0500
Subject: [PATCH 09/13] SUNRPC: Restore the auth slack before encoding the
 integrity MIC
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
Message-Id: <20261109-xdr-page-base-v1-9-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=10049; i=cel@kernel.org;
 h=from:subject:message-id; bh=1HeLnKjBPmfoibwMiXAXDYQALhSREeKY/jW3liV4vFc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS4pev97gdsCFSjtSVtBxi1SrO0EZEFkt4PV
 g3TolkXxXyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIkuAAKCRAzarMzb2Z/
 lyZzD/9S1jGVTw3kRGAneyAGV5kqmUakiJgdblf5yI+PCjaQuIpZE2kQmG79tipbigzc/6xDziw
 8t2lQNvyiDPb/Fbv1a8INRsOW4MptTKvhQS9dK+O6bFZUu8VOxfcGETkSmJTpJH9jOsco8WlMSv
 dd/nS7wS/AdrGCFhA83Hc+YqgDxopalUeJSIKxWYQf2XNevDYY97OwVVIUdbtpAaLoKdwc6Kjir
 RzRhhetoDiU7JopEdLXNQRjvICuoEpnQeCljPhoRXEHFobJ+xcIHKHfLxNSkSFSNnyxPMLzAWDS
 sKNVijrNMd2qgDNH2Mo+nALvimQXaeIVrknN59wrruV/h58bQJEsIxOMta0ffHawsa2chEaQsHS
 jaGxYBu24A3vuYYj7uV3jZ8R3hV8qyLIyWFxEiWOnp/O73ihxmQnzbVB/hE54eK03c8qR/wMh18
 OO0830wkKDQRLQV2XYevwwKErtTh2rL0qlitIYRllsPtotCdzJsbYd36GZaGz4K5PRDhORJGpzs
 yXscSdzSxugSH/42v9tzcq2fbVmkRZwOu4/LO21UIgEBOZGLk1bsMvNnOeKn9y/jg4LagLrJ4S2
 N/EE2RC/mt7wcv+IMKo6EsH5plfJH22HeXM0geww9XEFvZqCOO/vaKva3QdAc0aNcmkjjU5Cr9I
 x0DCgntZibljamg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svcxdr_set_auth_slack() takes rq_auth_slack off rq_res.buflen and
the head's xdr->end so the Reply leaves room for the krb5i MIC.
svcauth_gss_wrap_integ() then reserves the MIC against that reduced
buflen, and nothing gives the slack back first. With an NFSv4.1
session, nfsd4_sequence() lowers buflen further, to maxresp_sz less
the slack. A READ sized to fill that bound leaves no room for the
MIC, the reserve fails, svc_authorise() returns an error, and
svc_process() closes the connection.

Restoring buflen alone does not help. xdr_restrict_buflen() and
xdr_get_next_encode_buffer() clamp xdr->end to the reduced buflen
separately. With p == end mid-page, the MIC reserve takes the slow
path, passes the length check, and steps page_ptr onto the next
page, or onto the NULL sentinel at rq_page_end when the READ ends
in the last page.

Add svcxdr_restore_auth_slack() and call it before encoding the
MIC. It returns the slack to buflen and re-seats xdr->end for where
the stream sits: in the head or tail, in the pages, or at p after a
zero-byte reserve. Add KUnit cases for each.

Fixes: 7702378ac4d4 ("SUNRPC: Convert svcauth_gss_wrap_integ() to use xdr_stream()")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h        |  48 ++++++++++++++-
 net/sunrpc/auth_gss/svcauth_gss.c |   1 +
 net/sunrpc/tests/xdr_kunit.c      | 126 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 172 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 43ec1c08bed1..042972163b87 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -690,12 +690,14 @@ static inline bool svcxdr_decode_opaque_payload(struct xdr_stream *xdr,
 }
 
 /**
- * svcxdr_set_auth_slack -
+ * svcxdr_set_auth_slack - Set aside space for the security flavor's trailer
  * @rqstp: RPC transaction
  * @slack: buffer space to reserve for the transaction's security flavor
  *
- * Set the request's slack space requirement, and set aside that much
- * space in the rqstp's rq_res.head for use when the auth wraps the Reply.
+ * Record the slack in @rqstp and take it off rq_res.buflen and the end
+ * of the head, so the Reply leaves room for the flavor's trailer. A
+ * flavor that encodes its trailer through rq_res_stream calls
+ * svcxdr_restore_auth_slack() first to get the space back.
  */
 static inline void svcxdr_set_auth_slack(struct svc_rqst *rqstp, int slack)
 {
@@ -712,6 +714,46 @@ static inline void svcxdr_set_auth_slack(struct svc_rqst *rqstp, int slack)
 	WARN_ON(xdr->p > xdr->end);
 }
 
+/**
+ * svcxdr_restore_auth_slack - Return the auth slack to the Reply buffer
+ * @rqstp: RPC transaction
+ *
+ * Give back the space svcxdr_set_auth_slack() set aside, so the
+ * security flavor can encode its trailer after the Reply.
+ *
+ * Context: Process context. Call at most once per Reply, after the
+ * Reply has been encoded.
+ */
+static inline void svcxdr_restore_auth_slack(struct svc_rqst *rqstp)
+{
+	struct xdr_stream *xdr = &rqstp->rq_res_stream;
+	struct xdr_buf *buf = &rqstp->rq_res;
+	void *page_end, *end;
+	int left;
+
+	buf->buflen += rqstp->rq_auth_slack;
+
+	/*
+	 * A zero-byte xdr_reserve_space_vec() leaves iov NULL with end == p
+	 * in the head. Extending end here would put the trailer in the head
+	 * but charge it to page_len.
+	 */
+	if (!xdr->iov && !buf->page_len)
+		return;
+
+	/* The head and the tail both sit in the head page */
+	if (xdr->iov) {
+		xdr->end += XDR_QUADLEN(rqstp->rq_auth_slack);
+		return;
+	}
+
+	/* p on a page boundary still belongs to *page_ptr */
+	page_end = page_address(*xdr->page_ptr) + PAGE_SIZE;
+	left = buf->buflen - buf->len;
+	end = (void *)xdr->p + max(left, 0);
+	xdr->end = end < page_end ? end : page_end;
+}
+
 /**
  * svcxdr_set_accept_stat - Reserve space for the accept_stat field
  * @rqstp: RPC transaction context
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index d5da541353e7..d2f862053354 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1833,6 +1833,7 @@ static int svcauth_gss_wrap_integ(struct svc_rqst *rqstp)
 	if (maj_stat != GSS_S_COMPLETE)
 		goto bad_mic;
 
+	svcxdr_restore_auth_slack(rqstp);
 	if (xdr_stream_encode_opaque(xdr, checksum.data, checksum.len) < 0)
 		goto wrap_failed;
 	xdr_commit_encode(xdr);
diff --git a/net/sunrpc/tests/xdr_kunit.c b/net/sunrpc/tests/xdr_kunit.c
index 25eb69dbcc90..f0652401e28d 100644
--- a/net/sunrpc/tests/xdr_kunit.c
+++ b/net/sunrpc/tests/xdr_kunit.c
@@ -19,6 +19,7 @@
 struct xdr_test_fixture {
 	/* [0] is the head, then the Reply pages, then the canary */
 	struct page		*respages[XDR_TEST_NPAGES + 2];
+	struct svc_rqst		*rqstp;
 };
 
 static const unsigned int xdr_test_bases[] = {
@@ -77,6 +78,7 @@ static struct xdr_stream *xdr_test_setup(struct kunit *test,
 
 	rqstp = kunit_kzalloc(test, sizeof(*rqstp), GFP_KERNEL);
 	KUNIT_ASSERT_NOT_NULL(test, rqstp);
+	f->rqstp = rqstp;
 	test->priv = f;
 
 	rqstp->rq_page_end = &f->respages[XDR_TEST_NPAGES + 1];
@@ -355,6 +357,123 @@ static void xdr_test_straddle(struct kunit *test)
 	xdr_test_check_stream(test, xdr);
 }
 
+/* Set the auth slack aside as svcauth_gss_accept() does for krb5i */
+static void xdr_test_set_slack(struct kunit *test, struct xdr_stream *xdr)
+{
+	struct xdr_test_fixture *f = test->priv;
+	unsigned int buflen = xdr->buf->buflen;
+	__be32 *end = xdr->end;
+
+	svcxdr_set_auth_slack(f->rqstp, RPC_MAX_AUTH_SIZE);
+	KUNIT_EXPECT_EQ(test, xdr->buf->buflen, buflen - RPC_MAX_AUTH_SIZE);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->end, end - XDR_QUADLEN(RPC_MAX_AUTH_SIZE));
+}
+
+/* Restoring the slack while still in the head gives the head its end back */
+static void xdr_test_restore_slack_head(struct kunit *test)
+{
+	struct xdr_test_fixture *f;
+	struct xdr_stream *xdr;
+	unsigned int buflen;
+	__be32 *end;
+
+	xdr = xdr_test_setup(test, 0);
+	f = test->priv;
+	buflen = xdr->buf->buflen;
+	end = xdr->end;
+
+	xdr_test_set_slack(test, xdr);
+	svcxdr_restore_auth_slack(f->rqstp);
+	KUNIT_EXPECT_EQ(test, xdr->buf->buflen, buflen);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->end, end);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->iov, &xdr->buf->head[0]);
+}
+
+/*
+ * After a zero-byte xdr_reserve_space_vec(), the restore leaves end at p
+ * so the next reserve enters the pages.
+ */
+static void xdr_test_restore_slack_zero_vec(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	struct xdr_test_fixture *f;
+	struct xdr_stream *xdr;
+	unsigned int buflen;
+
+	xdr = xdr_test_setup(test, base);
+	f = test->priv;
+	buflen = xdr->buf->buflen;
+
+	xdr_test_set_slack(test, xdr);
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, 0), 0);
+	KUNIT_EXPECT_NULL(test, xdr->iov);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->end, xdr->p);
+
+	svcxdr_restore_auth_slack(f->rqstp);
+	KUNIT_EXPECT_EQ(test, xdr->buf->buflen, buflen);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->end, xdr->p);
+
+	xdr_test_encode_two_words(test, xdr);
+	xdr_test_check_two_words(test, xdr->buf, XDR_TEST_HEAD_LEN);
+}
+
+/*
+ * A payload that fills the reduced buflen ends mid-page. The restore
+ * re-seats end so exactly the slack fits after the payload.
+ */
+static void xdr_test_restore_slack_pages(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	unsigned int room = XDR_TEST_NPAGES * PAGE_SIZE -
+			    XDR_TEST_HEAD_LEN - base - RPC_MAX_AUTH_SIZE;
+	struct xdr_test_fixture *f;
+	struct xdr_stream *xdr;
+
+	xdr = xdr_test_setup(test, base);
+	f = test->priv;
+
+	xdr_test_set_slack(test, xdr);
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, room), 0);
+	KUNIT_EXPECT_NULL(test, xdr_reserve_space(xdr, XDR_UNIT));
+	xdr_test_check_stream(test, xdr);
+
+	svcxdr_restore_auth_slack(f->rqstp);
+	KUNIT_EXPECT_EQ(test, xdr_reserve_space_vec(xdr, RPC_MAX_AUTH_SIZE), 0);
+	KUNIT_EXPECT_EQ(test, xdr->buf->page_len, room + RPC_MAX_AUTH_SIZE);
+	KUNIT_EXPECT_EQ(test, xdr->buf->len, xdr->buf->buflen);
+	KUNIT_EXPECT_NULL(test, xdr_reserve_space(xdr, XDR_UNIT));
+	xdr_test_check_stream(test, xdr);
+}
+
+/*
+ * A payload ending on a page boundary leaves p in the page it fills.
+ * The restore caps end at that page, so the next reserve steps
+ * page_ptr forward rather than writing past the page.
+ */
+static void xdr_test_restore_slack_page_boundary(struct kunit *test)
+{
+	unsigned int base = *(const unsigned int *)test->param_value;
+	unsigned int count = PAGE_SIZE - offset_in_page(base);
+	struct xdr_test_fixture *f;
+	struct xdr_stream *xdr;
+	struct page **page_ptr;
+
+	xdr = xdr_test_setup(test, base);
+	f = test->priv;
+
+	xdr_test_set_slack(test, xdr);
+	KUNIT_ASSERT_EQ(test, xdr_reserve_space_vec(xdr, count), 0);
+	KUNIT_EXPECT_EQ(test, offset_in_page(xdr->p), 0);
+	page_ptr = xdr->page_ptr;
+
+	svcxdr_restore_auth_slack(f->rqstp);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->end, xdr->p);
+
+	xdr_test_encode_two_words(test, xdr);
+	KUNIT_EXPECT_PTR_EQ(test, xdr->page_ptr, page_ptr + 1);
+	xdr_test_check_two_words(test, xdr->buf, XDR_TEST_HEAD_LEN + count);
+}
+
 static struct kunit_case xdr_test_cases[] = {
 	KUNIT_CASE_PARAM(xdr_test_payload, xdr_test_base_gen_params),
 	KUNIT_CASE_PARAM(xdr_test_exact_fit, xdr_test_base_gen_params),
@@ -365,6 +484,13 @@ static struct kunit_case xdr_test_cases[] = {
 	KUNIT_CASE(xdr_test_unaligned_base),
 	KUNIT_CASE_PARAM(xdr_test_second_payload, xdr_test_base_gen_params),
 	KUNIT_CASE(xdr_test_straddle),
+	KUNIT_CASE(xdr_test_restore_slack_head),
+	KUNIT_CASE_PARAM(xdr_test_restore_slack_zero_vec,
+			 xdr_test_base_gen_params),
+	KUNIT_CASE_PARAM(xdr_test_restore_slack_pages,
+			 xdr_test_base_gen_params),
+	KUNIT_CASE_PARAM(xdr_test_restore_slack_page_boundary,
+			 xdr_test_base_gen_params),
 	{}
 };
 

-- 
2.56.0

