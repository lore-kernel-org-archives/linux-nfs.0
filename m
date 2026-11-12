Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495154;
	b=k1j+yUS4URLKw8c9Z2kEyeEsk3b0z9oKYZIUlmy58yg73F9ayeXCTWDGh+H2xXD/FLAM
	 m9M7IHKp4CtN2xatxqot7vkgqfVwol/aT1JH+5JHa+dTdmYF2CIVHDDyveRzh9GsiAG66
	 3DEeTIyI8l7NXJwaWHW98pIGKlJnwLsc9EIJAQE2++z+xopVSFwNAhM12uP0AidT3dbGD
	 WyiLXg1MR6Rdu+UZFRk3N4kb92/7qzquRMNbqT/2+uOff51c4YknLzy6TOMM4N/I7aHSc
	 DTOO9CnynYbmZAOZ65ERv7VfxE3KZruPtP8/wscG9mPhHJoBjF3hCk66wN/+VpdI7uQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495154;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=PZ091qK/WRT3f3mqj6eOhTw3ukWNNkLM6Hq0Kkfb0DQ=;
	b=4I8kpN91edN4I5cbwxi5vtHOYoFr6XsgDZW1uGgrgWAA+xtMa3ob4MrQadpVLnUYHp9B
	 kFJc/I+u0MIPgm1BjztTOSaaiXzdu8feynxUnb37/sqUvVsGUWVK9hBeDBMEaK/oBCtFK
	 jePdf+wU+RdVL3d0QoSpWlGa0FsT4RgCc1kzZxDU4PMMSyBjuWiW+SCtTyWRL0WBpk8L6
	 49JQJTk7ckvIFss69IfoXPTV2XBZcijBon5PUz3BLdRATP2E2dnfS0Rhjt/k+Rdf3B+SI
	 Deah/qwZdxKTW4sQTmMOnMmBu8tYDmPLuU2Ud2ioSNp1UYhsEcCUV3w2WO4nw4X0UNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uq5zeAxY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99321606A32D;
	Thu, 12 Nov 2026 14:52:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uq5zeAxY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 75DCE1F00A08;
	Thu, 12 Nov 2026 14:52:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495154;
	bh=PZ091qK/WRT3f3mqj6eOhTw3ukWNNkLM6Hq0Kkfb0DQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Uq5zeAxYQy0fJHh4qlUlVM07ljzDUm7IqHN3/PDOtgiWKmFAd80E/kJGf6GFZIfRO
	 0g9yU8FwYT/yyVeAEGC+OGifEuugVv41mbNzkuUzkwglBZcq1fSIzuegIcYoI/Uekf
	 sk4lHKsAhTqIFAHEmM7Yb/Ecf2NP/TdO8YN0ApzS5+/7jrkHX9DlY5d8vg9+gkoBBr
	 eP9ohNm1xtbnxkDkgy1gDTSlNF6DUtHcPxS3h292KeJEgzgzmhJNiIgSzAs831cSz1
	 3Jw3zAX0Wh77WGN+3ogrBqowdMug/i/bbLebwYKhTcCQ80wVM3DQOk5m+QwdxMj0mV
	 gLt4CSrO6E5wQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:10 -0500
Subject: [PATCH net-next v2 06/10] handshake: Add a kunit test for the
 completion gate
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
Message-Id: <20261112-tls-session-tags-v2-6-a587a50de7fc@kernel.org>
References: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
In-Reply-To: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=6472; i=cel@kernel.org;
 h=from:subject:message-id; bh=lEY5zY3icrQ/AAo5SjcNfZhunCUyVNobKveRg+2ae/o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKgEx6xwKOVKTUZ8v3G0h1fA9KhxP0VdRPq8
 ZEabV7LwsqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 l5SND/wMezQ8+CVK9PSJEMAfr01bjw7FwIG9/mOLZk1iT05lO2mwJImFya40jscF3rHOkDJCQ4m
 CDacyPorrCqD2xSgHMjgA/cqT+FRAiTrWEugJ7stzek4ZWSwZI93KHwVmmf4np0FKp4oqobrj5f
 UAyIDuOfO9OKAVnMRjO2rO/7xekDHAED9E9U+Lpnp/K5xbpFiNu4Ld2f1Ma9904fSwz44UP0drD
 e0/mKNGrYhdQwFfX009U7RNlta+JhGaqzApjKfdy70/XYZx66B7UVTWAVvG4Etdt0njNuMMKbBv
 Sw0Jd6OhbgkGhkC3qdRGo42bOJBRFojpbePhd/eXIviaLyojbNE+MbaAH59tWTdFdfbUfcjAz7V
 N9JzoseqMjbBHH2VejwaTCuySdSTifIRwXbMHq7s5rHG2VNud8SDquDFVQubE1wtXJzx7WXjup3
 HX2hezUreRdRA8n2sg3YXf5znVZXKWno/L8uEs+66/mZTBWatepF3hf28ZJwGpnxWkBBqh4AgBL
 yXMC9WRDZvNuIQckKEo3oRU8Jt0NA6h1/Eww6mvm08bFgKNbcFDfuPoCs2z+8BlxU5Abyiq8Niv
 FwviQNvKj/PzAFD6iBGorXvjyXN2HVj1tnCTxbYIlWLRTyuPjG9OMMCsfpxFe6kRWf1F+htQKqg
 /eWELo2keSY8OUQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The genl family runs DONE with parallel_ops, so duplicate or
concurrent DONE downcalls for the same socket can both reach the
same handshake_req. The split try/finish pair guarantees that
exactly one caller drives completion to the consumer's hp_done
callback. Ownership of the collected session tags can then pass to
the request.

Exercise the gate's exclusivity with a kunit case: only the first
handshake_try_complete() wins, and a later handshake_complete() on
the same request leaves hp_done fired exactly once.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/handshake/handshake-test.c | 112 ++++++++++++++++++++++++++++++++++++++++-
 net/handshake/request.c        |   2 +
 2 files changed, 113 insertions(+), 1 deletion(-)

diff --git a/net/handshake/handshake-test.c b/net/handshake/handshake-test.c
index 21fccfa94d89..b6992d1fa4ce 100644
--- a/net/handshake/handshake-test.c
+++ b/net/handshake/handshake-test.c
@@ -465,6 +465,84 @@ static void handshake_req_cancel_test3(struct kunit *test)
 	fput(filp);
 }
 
+static int handshake_try_complete_done_count;
+
+static void test_done_count_func(struct handshake_req *req, int status,
+				 struct genl_info *info)
+{
+	handshake_try_complete_done_count++;
+}
+
+static struct handshake_proto handshake_req_alloc_proto_count = {
+	.hp_handler_class	= HANDSHAKE_HANDLER_CLASS_TLSHD,
+	.hp_accept		= test_accept_func,
+	.hp_done		= test_done_count_func,
+};
+
+static void handshake_try_complete_test1(struct kunit *test)
+{
+	unsigned long fcount_before;
+	struct handshake_req *req, *next;
+	struct handshake_net *hn;
+	struct socket *sock;
+	struct file *filp;
+	struct net *net;
+	bool first, second;
+	int err;
+
+	/* Arrange */
+	handshake_try_complete_done_count = 0;
+
+	req = handshake_req_alloc(&handshake_req_alloc_proto_count, GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, req);
+
+	err = __sock_create(&init_net, PF_INET, SOCK_STREAM, IPPROTO_TCP,
+			    &sock, 1);
+	KUNIT_ASSERT_EQ(test, err, 0);
+
+	filp = sock_alloc_file(sock, O_NONBLOCK, NULL);
+	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, filp);
+	KUNIT_ASSERT_NOT_NULL(test, sock->sk);
+	sock->file = filp;
+
+	fcount_before = file_count(filp);
+	err = handshake_req_submit(sock, req, GFP_KERNEL);
+	KUNIT_ASSERT_EQ(test, err, 0);
+	KUNIT_EXPECT_EQ(test, file_count(filp), fcount_before + 1);
+
+	net = sock_net(sock->sk);
+	hn = handshake_pernet(net);
+	KUNIT_ASSERT_NOT_NULL(test, hn);
+
+	/* Pretend to accept this request */
+	next = handshake_req_next(hn, HANDSHAKE_HANDLER_CLASS_TLSHD);
+	KUNIT_ASSERT_PTR_EQ(test, req, next);
+	/* Simulate FD_PREPARE() consuming the file reference handed
+	 * off by handshake_req_next(); see handshake_nl_accept_doit().
+	 */
+	fput(filp);
+
+	/* Act */
+	first = handshake_try_complete(req);
+	second = handshake_try_complete(req);
+	handshake_finish_complete(req, 0, NULL, NULL);
+	/* handshake_finish_complete() drops the request's pin on the file. */
+	KUNIT_EXPECT_EQ(test, file_count(filp), fcount_before);
+	/* handshake_complete() re-enters the gate via
+	 * handshake_try_complete(). With the gate already taken,
+	 * hp_done must not fire a second time.
+	 */
+	handshake_complete(req, 0, NULL);
+
+	/* Assert */
+	KUNIT_EXPECT_TRUE(test, first);
+	KUNIT_EXPECT_FALSE(test, second);
+	KUNIT_EXPECT_EQ(test, handshake_try_complete_done_count, 1);
+	KUNIT_EXPECT_EQ(test, file_count(filp), fcount_before);
+
+	fput(filp);
+}
+
 static struct handshake_req *handshake_req_destroy_test;
 
 static void test_destroy_func(struct handshake_req *req)
@@ -651,7 +729,7 @@ static void handshake_sessiontags_duplicate(struct kunit *test)
 	info.nlhdr = nlh;
 
 	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), 0);
-	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 2);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 1);
 	stringset_finalize(&tags);
 	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 1);
 	KUNIT_EXPECT_TRUE(test, stringset_is_member(&tags, "dup"));
@@ -660,6 +738,30 @@ static void handshake_sessiontags_duplicate(struct kunit *test)
 	kfree_skb(skb);
 }
 
+static void handshake_sessiontags_duplicate_at_cap(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+	unsigned int i;
+
+	skb = handshake_done_msg(test, &nlh);
+	for (i = 0; i < HANDSHAKE_MAX_SESSIONTAGS; i++)
+		nla_put_string(skb, HANDSHAKE_A_DONE_TAG, "dup");
+	nla_put_string(skb, HANDSHAKE_A_DONE_TAG, "last");
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), 0);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 2);
+	stringset_finalize(&tags);
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(&tags, "last"));
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
 static void handshake_sessiontags_truncate(struct kunit *test)
 {
 	struct genl_info info = {};
@@ -727,6 +829,10 @@ static struct kunit_case handshake_api_test_cases[] = {
 		.name			= "req_cancel after done",
 		.run_case		= handshake_req_cancel_test3,
 	},
+	{
+		.name			= "try_complete gate is exclusive",
+		.run_case		= handshake_try_complete_test1,
+	},
 	{
 		.name			= "req_destroy works",
 		.run_case		= handshake_req_destroy_test1,
@@ -755,6 +861,10 @@ static struct kunit_case handshake_api_test_cases[] = {
 		.name			= "sessiontags duplicate",
 		.run_case		= handshake_sessiontags_duplicate,
 	},
+	{
+		.name			= "sessiontags duplicates at cap",
+		.run_case		= handshake_sessiontags_duplicate_at_cap,
+	},
 	{
 		.name			= "sessiontags truncate at cap",
 		.run_case		= handshake_sessiontags_truncate,
diff --git a/net/handshake/request.c b/net/handshake/request.c
index 72515e5e8cc2..31a81b7cb7e9 100644
--- a/net/handshake/request.c
+++ b/net/handshake/request.c
@@ -340,6 +340,7 @@ bool handshake_try_complete(struct handshake_req *req)
 {
 	return !test_and_set_bit(HANDSHAKE_F_REQ_COMPLETED, &req->hr_flags);
 }
+EXPORT_SYMBOL_IF_KUNIT(handshake_try_complete);
 
 /**
  * handshake_finish_complete - Deliver completion to the consumer
@@ -372,6 +373,7 @@ void handshake_finish_complete(struct handshake_req *req, int status,
 
 	fput(file);
 }
+EXPORT_SYMBOL_IF_KUNIT(handshake_finish_complete);
 
 void handshake_complete(struct handshake_req *req, int status,
 			struct genl_info *info)

-- 
2.56.0

