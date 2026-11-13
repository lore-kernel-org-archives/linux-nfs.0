Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597748;
	b=xFqdifvfszQQWuiNtr4RhKMN5dDnyQPryKIs8cYxEOp28PmhmBwvNE8A6OLiFf86t2KB
	 xZ00R/d71czIkqypKKrbVwrqK0lj29GKWk+rYRP0raicoZd8bUd1cvvtfWQ4zh4TtwsI6
	 rB+fGSt20wQbPC92rJkDVHZ4T9ZdaNQVUs/IqN37DVFjNEdr+wRafhNk0g4GeKBgTchc8
	 /KVs2asjMhHI4BGT7sOarSKYauUSfZbZ7aWOHtaZDjy0EKq5Ts+c4G5Lk+f2tvA6wzQty
	 ZGG8sAkIrY6Y920nKjPLhhhu7KksKLzzHxb5x5p3NtGCdGSPGDwE+0gVQVJytv+dlNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597748;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=I+hL5QQE6GyRoMtW1B5hMOK4wLRT/tC2hYnS7Jh1VQs=;
	b=fN82QztuDJWaxM6iswP7kJgd2i0NmJGFZZrN0F/rjRWE1RA4SeaVOpUYW1qzOononm5T
	 kQmeJv/KOCX2vXrGp2nY7Q0AKEIRARjdAhQhQlBPHT9FvIuC9JjXz9zCiE03wMOvjsLNO
	 sXfCEFnPPUTCCCKqqHFWPiIABqYuset5fvI0WI6zqmPT4LT8fqMLbt6hlDKIA+iBwwaM8
	 wvRWMMxEBja4JBIOF35IsEWyGqdG5Dqqkr5eO17ZjpxzZASzC7UHyY/ZskvwJC91loJ21
	 HUw6vjX/AtVlOYvy9dhDNHmbMpAP2PfUXA6JSHAW4oNOm3b4s+ifOxzL1/UvCVSrcOg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KOZCeWLF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EDD69606A897;
	Fri, 13 Nov 2026 19:22:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KOZCeWLF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 256BD1F000C8;
	Fri, 13 Nov 2026 19:22:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597747;
	bh=I+hL5QQE6GyRoMtW1B5hMOK4wLRT/tC2hYnS7Jh1VQs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KOZCeWLFVoni4EdGGydXzRafreR8BwXNM6418PclNrmwcSAbm/pLh77kzDqAZP965
	 1+LLl09FbHKKZERQ1kmlvb+YzZB71U7fbbp5zsLOGV59IpJyJj9yLa3zb1r+qmVlxf
	 ObA+/LuZ7os08E1WXh4pCG7znZtbcEB7aJkzfXD8EtlHtAWn2SpLRZjUhpJqbOwlIv
	 NwhSO+Yto2d+KFMySBSuATs20W3/nQ10yDhshtcIkq5wXpbGfM0qgqqbtbyqHZTTLf
	 HDoA3G8G1aXnegu9ZmeuMqKR7dWFuGtuG4+zeST5CATtoJCE7v+YFr3cgw3mzk3kbN
	 yRn+Aca4MH9Yg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:22:04 -0500
Subject: [PATCH net-next v3 06/10] handshake: Add a kunit test for the
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
Message-Id: <20261113-tls-session-tags-v3-6-91271964cdb0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=4697; i=cel@kernel.org;
 h=from:subject:message-id; bh=H81ze1RI93ATjQVrkoT7StPaKToyrSCrsGr9t8uhCsM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92Nf8q+lJcP+aIgtXhVJMR4NtY6WkVgWiRzzr
 jqagK/ZgrqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjXwAKCRAzarMzb2Z/
 l92FD/4rMROLWBW7BVy9zgQ3+OPJA1H8goVDLXqdNuev5Z33HfACNIY0hBmipKFzQ7jvig3Acar
 WlM4DkL54i+O4LeagJ9YVitKXlXaj9XMkO5rInA84IzuGlwtjZFZ1JfTGK4gn7PVSYcvMSBy6NT
 8QUM2kL8MrpMi9hW/l3ubSavCEoMb7rFaMfk7WlQfXijV5zB9gfqhykDvz/F7WOOF33xU4w7u+M
 CpT12SO8qLB/KWC818k/53cu6BXUTJe/GEKUH0jpvmEBwfYBdEXmVBZl464wufbEhfRH1NpbXRi
 G5b1ZCb3oWu8f4dBTAGSMZOiLF0+MwXH3zlPUDC0vA83e8G2886WaITsTzUYsam1sN7ZIef82cb
 u4IZVdpLzeHrgs7NklkolArt8x6dO7/RT9Ts9JcAWsfD7+jzqWeXEp0tNcpwXVcoGmBGXj88OhH
 WCd4KuU+bsx0rukYpoHIOOqp4Yc5tO8hny7t2tBKuk0HGxt+vY3Gb3IXAhh1lBvnRsxjgwCX2M+
 Y49eaguQcqgUSAJLJ4xTZiDxIFlPeZghVPQe9oW+YxEs+u0MzPP5u/DglwzB7EoiToQeqWTh5jt
 TW3v2fJ1S7IJe8Skv7zuZAva1LHPSWI2oX7auuxQBjhE/2mzwzp00i4f0e0MrbAZcudx7jDnTiD
 8XzzIlgqtGIRlXQ==
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
 net/handshake/handshake-test.c | 82 ++++++++++++++++++++++++++++++++++++++++++
 net/handshake/request.c        |  2 ++
 2 files changed, 84 insertions(+)

diff --git a/net/handshake/handshake-test.c b/net/handshake/handshake-test.c
index b4a56c4350bd..b6992d1fa4ce 100644
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
@@ -751,6 +829,10 @@ static struct kunit_case handshake_api_test_cases[] = {
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

