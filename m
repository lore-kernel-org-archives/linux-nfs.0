Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599056;
	b=y/cELT7SWsVOwgH318uMFe9vtjYT82nDu8dn481kl8euJhyL2j3WnRzjeOYkIz7FYMPx
	 /+InCgf+4R3NpW5YE5SNBhWmk7+WWHOqZnRj37LnMWTh7uuW5uC/jRW2b279iO5XlU9Eb
	 sv/5CPZscKrhIZ7rdAqYzFnTgYOY9WxcxTf8iVm1tkuJIwSsaq39aPRp8xWmjprQFzXuE
	 S5GwUG/n5NKnic6nbOWbe2mXcU1rEbtbhUiOQvrPSeJgYGEmOYiWFKABPjsyp1oLu2CPx
	 If9tz8s+7Pzn3tLzArTFZ2HOsoggQ3u8tQcBnIsjlL7Wj3aY5prt5KEvnD9N1q1iliQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599056;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=aTns16kGURc/DMC26JoSfuKrl9Ue2hAcQNbsOHnLCkg=;
	b=BqJ3L7W0zA82eikr+glk9acUiBXJWUkcwkNwMZkfa9CaMMd3+pwxzyaL07uiDaBbtoem
	 Zrb/biUUwhzRrqurFJMOE69naIN1Wfb30a/GXC6kcoAo3zX0XS1t9x7hWdS85G4pkhZKj
	 c0gf/e0I+3zC0skdsMzrsxjlmN9ogVr8Bfkv6AO5O0cHvkfmTfsh10gCjn3i4pVIVynyA
	 b2BWqXp8I0/g3QE613FxIOjxHby3ksNzCf7VcG2x16GIur3rc+k0J8uSUat9MCKW184v0
	 hRUi8QcXxYVqntP0LvogjYonjVW9DmR1ZgSl1ti/ZcuuvqwlKYKfjVXBjki9uPySLvw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k7v2xch3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47144606A335
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k7v2xch3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3EB1A1F000C4;
	Fri, 13 Nov 2026 19:44:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599056;
	bh=aTns16kGURc/DMC26JoSfuKrl9Ue2hAcQNbsOHnLCkg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=k7v2xch3eB8+nKjZqBJhPBe3pz3yEtURbp2nBuVy2sp7O29YPeepg7v1gL4S2qq/L
	 70wQ10l61hkGKOk2qMK0e4SUIhQSL6EIHtxwJlm9kwuDfXFnXg7uJJWTs1ymxV+m2k
	 +m58mWJjiZepSWIkenIG30LV8CAh42XBD2BB3e6WQXZSH9DbE7R8afBmikFEhj8hz+
	 w3xPS7B6LEt4Gr41MexhsoKtHKWVfPcsuseAggwYpZGjeCOlhT1eJrkhRCdUI4vlkU
	 OGcqY0F75qKpox+/PgWJJ6gKX3IBH3IAx2p+ZQCuKDnom5hV/kVfpY5DBaosZ6mitS
	 Np6saitoysUdg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:44:04 -0500
Subject: [PATCH 6/8] SUNRPC: Add svc_rqst_set_arg_len()
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
Message-Id: <20261113-svcsock-bvecs-v1-6-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=9718; i=cel@kernel.org;
 h=from:subject:message-id; bh=puhwHoF2aJU/5qBmlFkl7e7qPssIGDM6QUHYy6nlwNU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iHa0S0J+vzPMNh2fjJYylaDEqPUXDapisSF
 01clnzM2KWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 l1i2D/9L3vee3ToAw5tnVHjfA8QvMeOXGOhho2fPMQuaU9ful2mEDuyEbXcGAe/7FC+MlKiXm7H
 jc7hHWzNzoviPpxdlzh37a12ctBCwoNehLzUHTekrmxs8fXDsitQfUO0uWyUDCI5FzxlkDupdBc
 ougvSej4nSna8+0gR2cwopzvTpfvIq/uyHBaWGPzJIxtzxmiESXm2kom5/IH1hcSLd983vBTerH
 GeLBKwCnb0Wz7269bu3UzR7EkuekfDkdd/myLZ8yj1fMrwYT4ngZf7ICvkf4v1sRzmkovittAot
 uWtU5gv50pmKch8aDMYFp5AA3TlrnFuQqVshRQHbbv3v+VQtq49zp44mZF7fnDB3VaqYqz9ol/T
 2/1xDVXLo3UTk40AHhj09hKP13gJQHx6dbXxh2Nn1ucN2xI/smIGc6NTmMZR96Q4QqArnKOhRoY
 BK6qtEBX6m9G3giDChmCnv9s5cdFpA9Cg3iet8Cql9c6lXyN4lTPHqXXy2gstG+YOufh1MKEmNJ
 O7DpIjTkWi0+RLd3OsZlFA2UYEbpdm0D6fgmh9dQVF9pLfSQ/7C7pld9ydiCDholh17qRnUSSOO
 yaIOYDQArOfEOMJgs/Woc114AvUdiONTiuAQZ+usZYWaFucplbsRnzLsnVvQgt5BVPBbdyfnmn8
 LTLXsSYBOn8dDqA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The trim that fits rq_arg to a received length is open-coded in
svc_tcp_recvfrom(), svc_udp_recvfrom(), and svc_process_bc(), which also
clamps an oversized length. A receive path hoisted out of the transports
needs the trim in one place, and a transport that can receive more than
rq_arg holds needs to learn that the clamp fired.

Factor the three into svc_rqst_set_arg_len(), which returns false when
it clamps. svc_tcp_recv_actor() rejects a record larger than
sv_max_mesg, and rq_arg holds more than sv_max_mesg. A clamp in
svc_tcp_recvfrom() means the receive accounting is broken. Warn once and
close the connection.

The helper zeroes page_base, which the backchannel site did not, but no
backchannel transport sets page_base in rq_rcv_buf. Add KUnit cases for
the clamp, which no runtime test reaches.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h   |  2 +
 net/sunrpc/svc.c             | 13 +------
 net/sunrpc/svc_xprt.c        | 32 ++++++++++++++++
 net/sunrpc/svcsock.c         | 20 +++-------
 net/sunrpc/tests/xdr_kunit.c | 88 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 128 insertions(+), 27 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 47545866b41d..9f2df8d02169 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -471,6 +471,8 @@ bool		   svc_rqst_replace_page(struct svc_rqst *rqstp,
 void		   svc_rqst_release_pages(struct svc_rqst *rqstp);
 int		   svc_rqst_res_to_bvec(struct svc_rqst *rqstp,
 					unsigned int skip);
+bool		   svc_rqst_set_arg_len(struct svc_rqst *rqstp,
+					unsigned int len);
 int		   svc_new_thread(struct svc_serv *serv, struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *prog,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b61edc49b253..6be2020a4907 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1809,18 +1809,7 @@ void svc_process_bc(struct rpc_rqst *req, struct svc_rqst *rqstp)
 	memcpy(&rqstp->rq_arg, &req->rq_rcv_buf, sizeof(rqstp->rq_arg));
 	memcpy(&rqstp->rq_res, &req->rq_snd_buf, sizeof(rqstp->rq_res));
 
-	/* Adjust the argument buffer length */
-	rqstp->rq_arg.len = req->rq_private_buf.len;
-	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
-		rqstp->rq_arg.head[0].iov_len = rqstp->rq_arg.len;
-		rqstp->rq_arg.page_len = 0;
-	} else if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len +
-			rqstp->rq_arg.page_len)
-		rqstp->rq_arg.page_len = rqstp->rq_arg.len -
-			rqstp->rq_arg.head[0].iov_len;
-	else
-		rqstp->rq_arg.len = rqstp->rq_arg.head[0].iov_len +
-			rqstp->rq_arg.page_len;
+	svc_rqst_set_arg_len(rqstp, req->rq_private_buf.len);
 
 	/* Reset the response buffer */
 	rqstp->rq_res.head[0].iov_len = 0;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bcc867592f2d..99b2e0aa80aa 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -765,6 +765,38 @@ static bool svc_alloc_arg(struct svc_rqst *rqstp)
 	return true;
 }
 
+/**
+ * svc_rqst_set_arg_len - Trim the Call buffer to a received length
+ * @rqstp: RPC transaction context
+ * @len: count of octets received into rq_arg
+ *
+ * On entry head[0].iov_len and page_len give the capacity of rq_arg. On return
+ * page_base is zero. The head and page buffers are not read or written, so the
+ * helper works whatever memory backs rq_arg.
+ *
+ * Return: %true when @len fits, %false when it exceeds the capacity
+ * and rq_arg was clamped to the capacity instead.
+ */
+bool svc_rqst_set_arg_len(struct svc_rqst *rqstp, unsigned int len)
+{
+	struct xdr_buf *arg = &rqstp->rq_arg;
+	unsigned int capacity = arg->head[0].iov_len + arg->page_len;
+	bool fits = len <= capacity;
+
+	if (!fits)
+		len = capacity;
+	arg->len = len;
+	arg->page_base = 0;
+	if (len <= arg->head[0].iov_len) {
+		arg->head[0].iov_len = len;
+		arg->page_len = 0;
+	} else {
+		arg->page_len = len - arg->head[0].iov_len;
+	}
+	return fits;
+}
+EXPORT_SYMBOL_GPL(svc_rqst_set_arg_len);
+
 static bool
 svc_thread_should_sleep(struct svc_rqst *rqstp)
 {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8dc7921a5b91..d95ab14dea89 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -606,7 +606,6 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
 
 	len = skb->len;
-	rqstp->rq_arg.len = len;
 	trace_svcsock_udp_recv(&svsk->sk_xprt, len);
 
 	rqstp->rq_prot = IPPROTO_UDP;
@@ -631,13 +630,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_xprt_ctxt = skb;
 	}
 
-	rqstp->rq_arg.page_base = 0;
-	if (len <= rqstp->rq_arg.head[0].iov_len) {
-		rqstp->rq_arg.head[0].iov_len = len;
-		rqstp->rq_arg.page_len = 0;
-	} else {
-		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
-	}
+	svc_rqst_set_arg_len(rqstp, len);
 
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;
@@ -1263,13 +1256,10 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	svc_tcp_flush_pages(svsk, rqstp);
 
-	rqstp->rq_arg.len = svsk->sk_datalen;
-	rqstp->rq_arg.page_base = 0;
-	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
-		rqstp->rq_arg.head[0].iov_len = rqstp->rq_arg.len;
-		rqstp->rq_arg.page_len = 0;
-	} else
-		rqstp->rq_arg.page_len = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
+	if (WARN_ON_ONCE(!svc_rqst_set_arg_len(rqstp, svsk->sk_datalen))) {
+		len = -EMSGSIZE;
+		goto err_nuts;
+	}
 
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
diff --git a/net/sunrpc/tests/xdr_kunit.c b/net/sunrpc/tests/xdr_kunit.c
index 93dc7a9d7b9e..1b1cf9f2126a 100644
--- a/net/sunrpc/tests/xdr_kunit.c
+++ b/net/sunrpc/tests/xdr_kunit.c
@@ -638,6 +638,88 @@ static void xdr_test_bvec_overflow_tail(struct kunit *test)
 	KUNIT_EXPECT_NULL(test, bvec[2].bv_page);
 }
 
+#define XDR_TEST_ARG_HEAD_LEN	4096
+#define XDR_TEST_ARG_PAGE_LEN	8192
+
+/* Fills in only the svc_rqst fields svc_rqst_set_arg_len() uses. */
+static struct svc_rqst *xdr_test_arg_rqst(struct kunit *test)
+{
+	struct svc_rqst *rqstp;
+
+	rqstp = kunit_kzalloc(test, sizeof(*rqstp), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, rqstp);
+	rqstp->rq_arg.head[0].iov_len = XDR_TEST_ARG_HEAD_LEN;
+	rqstp->rq_arg.page_len = XDR_TEST_ARG_PAGE_LEN;
+	rqstp->rq_arg.page_base = 512;
+	return rqstp;
+}
+
+static void xdr_test_set_arg_len_zero(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_rqst(test);
+
+	KUNIT_EXPECT_TRUE(test, svc_rqst_set_arg_len(rqstp, 0));
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.len, 0);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.head[0].iov_len, 0);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_len, 0);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_base, 0);
+}
+
+static void xdr_test_set_arg_len_head(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_rqst(test);
+
+	KUNIT_EXPECT_TRUE(test, svc_rqst_set_arg_len(rqstp, 100));
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.len, 100);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.head[0].iov_len, 100);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_len, 0);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_base, 0);
+}
+
+static void xdr_test_set_arg_len_head_full(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_rqst(test);
+
+	KUNIT_EXPECT_TRUE(test, svc_rqst_set_arg_len(rqstp, 4096));
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.len, 4096);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.head[0].iov_len, 4096);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_len, 0);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_base, 0);
+}
+
+static void xdr_test_set_arg_len_pages(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_rqst(test);
+
+	KUNIT_EXPECT_TRUE(test, svc_rqst_set_arg_len(rqstp, 6000));
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.len, 6000);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.head[0].iov_len, 4096);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_len, 1904);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_base, 0);
+}
+
+static void xdr_test_set_arg_len_exact_fit(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_rqst(test);
+
+	KUNIT_EXPECT_TRUE(test, svc_rqst_set_arg_len(rqstp, 12288));
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.len, 12288);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.head[0].iov_len, 4096);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_len, 8192);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_base, 0);
+}
+
+static void xdr_test_set_arg_len_clamp(struct kunit *test)
+{
+	struct svc_rqst *rqstp = xdr_test_arg_rqst(test);
+
+	KUNIT_EXPECT_FALSE(test, svc_rqst_set_arg_len(rqstp, 20000));
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.len, 12288);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.head[0].iov_len, 4096);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_len, 8192);
+	KUNIT_EXPECT_EQ(test, rqstp->rq_arg.page_base, 0);
+}
+
 static struct kunit_case xdr_test_cases[] = {
 	KUNIT_CASE_PARAM(xdr_test_payload, xdr_test_base_gen_params),
 	KUNIT_CASE_PARAM(xdr_test_exact_fit, xdr_test_base_gen_params),
@@ -663,6 +745,12 @@ static struct kunit_case xdr_test_cases[] = {
 	KUNIT_CASE(xdr_test_bvec_overflow_head),
 	KUNIT_CASE(xdr_test_bvec_overflow_pages),
 	KUNIT_CASE(xdr_test_bvec_overflow_tail),
+	KUNIT_CASE(xdr_test_set_arg_len_zero),
+	KUNIT_CASE(xdr_test_set_arg_len_head),
+	KUNIT_CASE(xdr_test_set_arg_len_head_full),
+	KUNIT_CASE(xdr_test_set_arg_len_pages),
+	KUNIT_CASE(xdr_test_set_arg_len_exact_fit),
+	KUNIT_CASE(xdr_test_set_arg_len_clamp),
 	{}
 };
 

-- 
2.56.0

