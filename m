Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599057;
	b=kIPhq/WKjjRIZYgvUywo93BVlBP9+f+FxdANqNMVmNgYsmAhE6Hynce/YTArc/2Jg5vu
	 S1p8e4RiPifia6TvuQ/USjFaoUkVQAMR8rae6O5gtvr8q0/o91HycgLxXKRzPJxGuSVOE
	 d8+WiFAzReHNoSwSMK0dRTDQEuo36evNCEcWjEhMfBQfOeRAoMdESr1TsDx4zrzdtwYdr
	 MIgZPPbMAo82QS7R5QNmdt3Sm0ItUMaxl2doMLm1M826VPkNbNnfoffXTSbU0Mq1XEfbj
	 iW9zJqp4jxQYNKYg3MiFjTu6RL16CusCtVn6kZMdOo3buxFF/FdpztjfryVHchAW3Zw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599057;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vJ/vCBj5HJa8g9VlkMZ6quqmzjDhWuCZ98lWzxU41/Q=;
	b=LSHKStvhAaC9YK5A0cclGTOtkT5NYe6dwGA02aWpxkylR59tPXZASTF8KjnIMgf3bYgY
	 fvh8AEi5ti5EjSBM2twmN06cfu6HHwa9PSyNkmPQik1V0omHQfd4m4HJzwHM/ai/Tu459
	 pIK7CCyz63MTvtmXtCy85WFKuuXRWR93ooDSlj6wEm+HGqPq05SVkQ2F2AvvtYYJS331d
	 UlTslQYDdiXrHvPJvFh6kE5hNY+rEKCApU22osWTV1IFbNmBnbi0H9Vpf34gNXhr21srT
	 pbDvMU+qqllgUM0HLJJL2vJ32h+3V1hH2l7MhW7Z0vSVEt1BOxmpCoCn7RIy1fmI2DA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JLPDTlzE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5EA50606A32E
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JLPDTlzE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5D6E51F000CA;
	Fri, 13 Nov 2026 19:44:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599057;
	bh=vJ/vCBj5HJa8g9VlkMZ6quqmzjDhWuCZ98lWzxU41/Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JLPDTlzEp/OyZPeRxvuDDJDmefUZQMHjHP2G4dtD19nvZakoXxdYNgbjt5nVw4fqZ
	 /gruWfGcX94XO0UAfWD3f/2HKPI6agtrK2DkxNVf6oviHK80UNALsFusARK06JiHxn
	 lVEr2pRluVMDb1ZE/Pb8N2D3Va1wMcIBDhiZdR6lhmXYc3W4JyPdDeBPRuKSupd/+D
	 wayLsfBQOo6Rm/9UWp22PuZOrJT/YIASpjitAMqAqElR9lUJ2/cmUN0Pth8bcUW4w3
	 T8KgN/QBpt3OS/OF0keMNHLD8MohB1YNZNeHi27pavVPPocjGRInUs0LF+EILm1ICr
	 jHfAP7iGOBoeQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:44:05 -0500
Subject: [PATCH 7/8] SUNRPC: Move the receive bvec iterator setup out of
 svcsock
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
Message-Id: <20261113-svcsock-bvecs-v1-7-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=11686; i=cel@kernel.org;
 h=from:subject:message-id; bh=/t+8xetQFqaJtxFnRTWxTByZUOn9+NfNJ0ZAUzDFLFk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iHkBOd6gT6ZEpsHXJ1H2FAzjwLbvgJiqLT0
 vA7Jei2YmmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 l/uDD/91hPVCmEcExn4XGdGw2lyE58xRzQl1dogm52QKNPGtBPnGklD8b1CEEO3NZ99DoFJMxO9
 AasZQ1Spk2UsfToGVX7vpXYZbg6Q3yHxbjeVJAC8oHblGstUdvNrHqu+K5Fr+FKZXyj5zsTzjoF
 hXd5lQ3RzZhv+i6heVUmc8KZjPDLwIk/7BcEWX8goNLmotMC3/wPgHdJSMJlYG+J/vHzWODKw0f
 N8ROfjvih1YDAMaO5CKIlVWrTLJDPz3lS+yFLn65Z/S1X+PFdz2TzQkINMBwpquni8NPMWav2ew
 ILddcLf4L3ZVV6JqjQM/YEtlODhiGiHzOQcWlQoDsPqwJvVJme57yNC5d5H5NJvu6TzjtJttxCQ
 b4NVQY572ubSmeJjoggXm0rnnrH9RXok19yxljieMojFBivteb3/IvayqrO/JKk2lZUuq32sZKM
 cdl29dFEnWNqcaBIDU+mi0phS7Kum0kkRs7QXGLrp8IY05lLoP5w9/vPOhvPg16Tu6IRbuGlg1d
 hOA34BmLhmkCGz77a4umXo4iyORyYtbZmmbeH9JhH/UMIQSvzfcQXv0ARx8gyaBOql6ASBysKGa
 T15Jou0F6l3WfjCqrsRfVk/IJzbMzqRJWU8tztv11AADrzu2piYuny73ZCh7UHPJ0U5RaKjCQrG
 6iG3N1m0aCAGDWw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_recv_iter_init() and svc_tcp_flush_pages() map a range of
rq_pages into rq_bvec and flush the received pages. Neither function
depends on TCP, and svc_tcp_flush_pages() uses struct svc_sock only
to read sk_datalen. A UDP receive through a bvec iterator needs the
same two steps.

Move the two functions to svc_xprt.c as svc_rqst_arg_iter_init() and
svc_rqst_arg_flush(). TCP bounds the record at sv_max_mesg, but a
transport outside svcsock does not, so have the iterator setup reject
a range that does not fit in rq_pages.

The TCP actor reports the rejection through desc->error with
desc->count zeroed, as for a copy fault. The errno is -EMSGSIZE, as
for an oversized fragment, so that trace_svcsock_tcp_recv_err names
the cause.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h   |   4 ++
 net/sunrpc/svc_xprt.c        |  55 +++++++++++++++++++++++
 net/sunrpc/svcsock.c         |  51 ++++++----------------
 net/sunrpc/tests/xdr_kunit.c | 101 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 173 insertions(+), 38 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 9f2df8d02169..51ed435c32ce 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -471,6 +471,10 @@ bool		   svc_rqst_replace_page(struct svc_rqst *rqstp,
 void		   svc_rqst_release_pages(struct svc_rqst *rqstp);
 int		   svc_rqst_res_to_bvec(struct svc_rqst *rqstp,
 					unsigned int skip);
+int		   svc_rqst_arg_iter_init(struct svc_rqst *rqstp,
+					  struct iov_iter *iter,
+					  size_t offset, size_t len);
+void		   svc_rqst_arg_flush(struct svc_rqst *rqstp, size_t len);
 bool		   svc_rqst_set_arg_len(struct svc_rqst *rqstp,
 					unsigned int len);
 int		   svc_new_thread(struct svc_serv *serv, struct svc_pool *pool);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 99b2e0aa80aa..61d5749a22da 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -19,6 +19,7 @@
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/highmem.h>
 #include <trace/events/sunrpc.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
@@ -765,6 +766,60 @@ static bool svc_alloc_arg(struct svc_rqst *rqstp)
 	return true;
 }
 
+/**
+ * svc_rqst_arg_iter_init - Map a range of rq_pages for a receive
+ * @rqstp: RPC transaction context
+ * @iter: set up as an ITER_DEST iterator backed by rq_bvec
+ * @offset: byte offset into rq_pages of the first octet to receive
+ * @len: count of octets to receive
+ *
+ * Maps only the pages that [@offset, @offset + @len) covers, so a transport
+ * that receives a message in pieces does not re-map the untouched remainder on
+ * every piece.
+ *
+ * Return: %0 on success, or %-EINVAL when the range does not fit in
+ * rq_pages, in which case @iter is not touched.
+ */
+int svc_rqst_arg_iter_init(struct svc_rqst *rqstp, struct iov_iter *iter,
+			   size_t offset, size_t len)
+{
+	unsigned int first = offset >> PAGE_SHIFT;
+	size_t seek = offset_in_page(offset);
+	unsigned int i, pages;
+	size_t end;
+
+	if (check_add_overflow(offset, len, &end) ||
+	    end > (size_t)rqstp->rq_maxpages << PAGE_SHIFT)
+		return -EINVAL;
+
+	pages = DIV_ROUND_UP(seek + len, PAGE_SIZE);
+	for (i = 0; i < pages; i++)
+		bvec_set_page(&rqstp->rq_bvec[i], rqstp->rq_pages[first + i],
+			      PAGE_SIZE, 0);
+
+	iov_iter_bvec(iter, ITER_DEST, rqstp->rq_bvec, pages, seek + len);
+	iov_iter_advance(iter, seek);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(svc_rqst_arg_iter_init);
+
+/**
+ * svc_rqst_arg_flush - Flush the dcache for a received Call
+ * @rqstp: RPC transaction context
+ * @len: count of octets received, measured from the start of rq_pages[0]
+ *
+ * A copy through the iterator that svc_rqst_arg_iter_init() sets up
+ * does not flush the dcache. Call this once after the whole message
+ * has been received.
+ */
+void svc_rqst_arg_flush(struct svc_rqst *rqstp, size_t len)
+{
+	unsigned int pg, pages = DIV_ROUND_UP(len, PAGE_SIZE);
+
+	for (pg = 0; pg < pages; pg++)
+		flush_dcache_page(rqstp->rq_pages[pg]);
+}
+
 /**
  * svc_rqst_set_arg_len - Trim the Call buffer to a received length
  * @rqstp: RPC transaction context
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d95ab14dea89..4c33a1d95594 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -39,7 +39,6 @@
 #include <net/tls_prot.h>
 #include <net/handshake.h>
 #include <linux/uaccess.h>
-#include <linux/highmem.h>
 #include <asm/ioctls.h>
 #include <linux/key.h>
 
@@ -1044,41 +1043,6 @@ struct svc_tcp_recv_ctx {
 	bool			complete;
 };
 
-/*
- * Nothing reads the message body before the message is complete, and
- * partial receives refill the same pages. Flush once here, after the
- * socket lock is released, rather than once per copy in the actor.
- */
-static void svc_tcp_flush_pages(struct svc_sock *svsk,
-				struct svc_rqst *rqstp)
-{
-	unsigned int pg, pages = DIV_ROUND_UP(svsk->sk_datalen, PAGE_SIZE);
-
-	for (pg = 0; pg < pages; pg++)
-		flush_dcache_page(rqstp->rq_pages[pg]);
-}
-
-/*
- * Mapping the message's unfilled remainder would re-map untouched
- * pages on every call, at a cost that grows with the message rather
- * than with the octets copied.
- */
-static void svc_tcp_recv_iter_init(struct svc_rqst *rqstp,
-				   struct iov_iter *iter, size_t body_off,
-				   size_t len)
-{
-	unsigned int first = body_off >> PAGE_SHIFT;
-	size_t seek = offset_in_page(body_off);
-	unsigned int i, pages = DIV_ROUND_UP(seek + len, PAGE_SIZE);
-
-	for (i = 0; i < pages; i++)
-		bvec_set_page(&rqstp->rq_bvec[i], rqstp->rq_pages[first + i],
-			      PAGE_SIZE, 0);
-
-	iov_iter_bvec(iter, ITER_DEST, rqstp->rq_bvec, pages, seek + len);
-	iov_iter_advance(iter, seek);
-}
-
 /*
  * ->read_sock actor, called under the socket lock. sk_datalen is both
  * the count of body octets received so far and their write offset into
@@ -1137,7 +1101,9 @@ static int svc_tcp_recv_actor(read_descriptor_t *desc, struct sk_buff *skb,
 	if (take) {
 		struct iov_iter iter;
 
-		svc_tcp_recv_iter_init(rqstp, &iter, svsk->sk_datalen, take);
+		if (svc_rqst_arg_iter_init(rqstp, &iter, svsk->sk_datalen,
+					   take))
+			goto toobig;
 		if (skb_copy_datagram_iter(skb, offset, &iter, take))
 			goto fault;
 		svsk->sk_datalen += take;
@@ -1159,6 +1125,10 @@ static int svc_tcp_recv_actor(read_descriptor_t *desc, struct sk_buff *skb,
 
 	return consumed;
 
+toobig:
+	desc->error = -EMSGSIZE;
+	desc->count = 0;
+	return consumed;
 fault:
 	desc->error = -EFAULT;
 	desc->count = 0;
@@ -1254,7 +1224,12 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (svsk->sk_datalen < 8)
 		goto err_nuts;
 
-	svc_tcp_flush_pages(svsk, rqstp);
+	/* Nothing reads the message body before the message is
+	 * complete, and partial receives refill the same pages. Flush
+	 * once here, after the socket lock is released, rather than
+	 * once per copy in the actor.
+	 */
+	svc_rqst_arg_flush(rqstp, svsk->sk_datalen);
 
 	if (WARN_ON_ONCE(!svc_rqst_set_arg_len(rqstp, svsk->sk_datalen))) {
 		len = -EMSGSIZE;
diff --git a/net/sunrpc/tests/xdr_kunit.c b/net/sunrpc/tests/xdr_kunit.c
index 1b1cf9f2126a..7e2ff24167ec 100644
--- a/net/sunrpc/tests/xdr_kunit.c
+++ b/net/sunrpc/tests/xdr_kunit.c
@@ -9,6 +9,7 @@
 #include <kunit/test.h>
 #include <linux/mm.h>
 #include <linux/string.h>
+#include <linux/uio.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/xdr.h>
 
@@ -720,6 +721,101 @@ static void xdr_test_set_arg_len_clamp(struct kunit *test)
 	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_base, 0);
 }
 
+#define XDR_TEST_ARG_MAXPAGES	8
+
+static struct svc_rqst *xdr_test_arg_iter_rqst(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_rqst(test);
+	struct page *pages;
+	unsigned int i;
+
+	rqstp->rq_maxpages = XDR_TEST_ARG_MAXPAGES;
+	rqstp->rq_pages = kunit_kcalloc(test, XDR_TEST_ARG_MAXPAGES,
+					sizeof(struct page *), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, rqstp->rq_pages);
+	/* Nothing reads these pages. They give each rq_pages slot a
+	 * distinct address to compare against.
+	 */
+	pages = kunit_kcalloc(test, XDR_TEST_ARG_MAXPAGES,
+			      sizeof(struct page), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, pages);
+	for (i = 0; i < XDR_TEST_ARG_MAXPAGES; i++)
+		rqstp->rq_pages[i] = &pages[i];
+	rqstp->rq_bvec = kunit_kcalloc(test, XDR_TEST_ARG_MAXPAGES +
+				       RPCSVC_BVEC_HEADROOM,
+				       sizeof(struct bio_vec), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, rqstp->rq_bvec);
+	return rqstp;
+}
+
+static void xdr_test_arg_iter_init_span(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_iter_rqst(test);
+	struct iov_iter iter;
+	unsigned int i;
+
+	KUNIT_EXPECT_EQ(test, svc_rqst_arg_iter_init(rqstp, &iter,
+						     PAGE_SIZE + 100,
+						     3 * PAGE_SIZE), 0);
+	KUNIT_EXPECT_EQ(test, iov_iter_count(&iter), 3 * PAGE_SIZE);
+	KUNIT_EXPECT_EQ(test, iter.iov_offset, 100);
+	KUNIT_ASSERT_EQ(test, iter.nr_segs, 4);
+	for (i = 0; i < 4; i++)
+		KUNIT_EXPECT_PTR_EQ(test, rqstp->rq_bvec[i].bv_page,
+				    rqstp->rq_pages[1 + i]);
+}
+
+static void xdr_test_arg_iter_init_empty(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_iter_rqst(test);
+	struct iov_iter iter;
+
+	KUNIT_EXPECT_EQ(test, svc_rqst_arg_iter_init(rqstp, &iter, 0, 0), 0);
+	KUNIT_EXPECT_EQ(test, iov_iter_count(&iter), 0);
+	KUNIT_EXPECT_EQ(test, svc_rqst_arg_iter_init(rqstp, &iter,
+						     8 * PAGE_SIZE, 0), 0);
+	KUNIT_EXPECT_EQ(test, iov_iter_count(&iter), 0);
+}
+
+static void xdr_test_arg_iter_init_fits(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_iter_rqst(test);
+	struct iov_iter iter;
+
+	KUNIT_EXPECT_EQ(test, svc_rqst_arg_iter_init(rqstp, &iter,
+						     7 * PAGE_SIZE + 100,
+						     PAGE_SIZE - 100), 0);
+	KUNIT_EXPECT_EQ(test, iov_iter_count(&iter), PAGE_SIZE - 100);
+	KUNIT_EXPECT_EQ(test, iter.iov_offset, 100);
+	KUNIT_EXPECT_EQ(test, iter.nr_segs, 1);
+}
+
+/*
+ * A check on the page count alone would accept these ranges. Each needs fewer
+ * than rq_maxpages pages but runs past the end of rq_pages.
+ */
+static void xdr_test_arg_iter_init_range(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_iter_rqst(test);
+	struct iov_iter iter;
+
+	KUNIT_EXPECT_EQ(test, svc_rqst_arg_iter_init(rqstp, &iter,
+						     7 * PAGE_SIZE,
+						     2 * PAGE_SIZE), -EINVAL);
+	KUNIT_EXPECT_EQ(test, svc_rqst_arg_iter_init(rqstp, &iter,
+						     8 * PAGE_SIZE, 1),
+			-EINVAL);
+}
+
+static void xdr_test_arg_iter_init_overflow(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_iter_rqst(test);
+	struct iov_iter iter;
+
+	KUNIT_EXPECT_EQ(test, svc_rqst_arg_iter_init(rqstp, &iter, SIZE_MAX,
+						     2), -EINVAL);
+}
+
 static struct kunit_case xdr_test_cases[] = {
 	KUNIT_CASE_PARAM(xdr_test_payload, xdr_test_base_gen_params),
 	KUNIT_CASE_PARAM(xdr_test_exact_fit, xdr_test_base_gen_params),
@@ -751,6 +847,11 @@ static struct kunit_case xdr_test_cases[] = {
 	KUNIT_CASE(xdr_test_set_arg_len_pages),
 	KUNIT_CASE(xdr_test_set_arg_len_exact_fit),
 	KUNIT_CASE(xdr_test_set_arg_len_clamp),
+	KUNIT_CASE(xdr_test_arg_iter_init_fits),
+	KUNIT_CASE(xdr_test_arg_iter_init_span),
+	KUNIT_CASE(xdr_test_arg_iter_init_empty),
+	KUNIT_CASE(xdr_test_arg_iter_init_range),
+	KUNIT_CASE(xdr_test_arg_iter_init_overflow),
 	{}
 };
 

-- 
2.56.0

