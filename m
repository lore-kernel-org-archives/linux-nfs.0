Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07DA34C6800;
	Mon, 31 Aug 2026 16:16:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192962; cv=none; b=ELfYXqWL+7N2st1RX4edVEsRG5Txe7LGAJMM5SV228Booxm9zslFeGDxheqKZuqqXCbfGavO8b8lRJToliRm0MTurc2dI75AOYISOs8f9TzRh+1Q6LNhkZJh1YwFw4YZzSYufKvuPMzE3AzOfIh4dj0SXh8prUjgE/RYOLNph5o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192962; c=relaxed/simple;
	bh=grf6clZnkQGXGoZ9rkU2+lKlywCVByX9ysCCD0mMuIg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=VE48ZOLBalA2zv1IE/kYCQDLxwY/9HLoiS6RLZNOlkro2mlbTmZ58VGAhFL5MJ/9+tx4N/GteMjfrdQtRiEZIDQpo961xiaHD7kQmQDQYNVqHd5znUOBtnMnxbvGqv1b6SqiJfoJEPwf+//taWHlko2LA6XZ2REIEX4n02Z0LYk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ApfWe4ym; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ApfWe4ym"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 659FF1F000E9;
	Mon, 31 Aug 2026 16:15:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192960;
	bh=+xLJWmj9sHbeFwxKybs/pfRQuWXRiA1jYXOW+vEeb5Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ApfWe4ymY781tQiaMrPed108X/TAPsyAkvY0XOMuHRFtmdeVp64MIYpMpJFpgBeMY
	 2xPsAY7anNBPLRL9R5sHH60QSrIj5EPajY+Di8Z79VkxRLnruPqFKfQ6LggDkXChzw
	 gMCuJjtQhpmbgK923DrYgR0bO8O51YtlSyxSLxYU85D9GUlvKWsllH0FuOQdbULkPf
	 3ojmuQ7MUl42F70MqPJ8wny7qSCM9fsphYNOpw0JiMT2mKm1o2r6nM0poL1TyRwL4L
	 QQjCZBjxGOUbfUwhtg/V4E5Ka3MnTQUh8Lc68KXPxKHomkJcUvlbtVdYpFiWgkNPz0
	 UxpT8JEFzTuXA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:56 -0400
Subject: [PATCH v4 14/14] selftests/nfsd: check that listener removal asks
 rpcbind once
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-14-0f4e89139409@kernel.org>
References: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
In-Reply-To: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2494; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=grf6clZnkQGXGoZ9rkU2+lKlywCVByX9ysCCD0mMuIg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaintFaR6Lo01AKYk0WWEnnoyjEQ5mFScTL6H
 xT48VXWKleJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWopwAKCRAADmhBGVaC
 FclCEACCXT51cYbhdaIr2T+leg20uyxRaHUQlcjWkUWlVHkSihZKT89lWeUDfWJW8Tk3/RyL08c
 8iUwUyDsVLbDJPBMpRzMSVn0h+/FlX6D9HCU61XcCNZB+yyELum7RnJavcxB7xUVhhACKsd3uqm
 TjAML8Y9RSgFGaIwi9AuzoSOz2zFWYTLGMPgW8k6UYhQpRUICd7++etlsKm21RIuXzMcGW8tU+f
 AihS93zV2uE7qU6M+4zMPGbUP6D7dxZLiI7g21izRuGXoLqX8+2y2aGWtKlUNtxWLoQnSywQ0f3
 5kX+0iVZLY3ThqEA8n20ZQ7xmeQ1QdPt5V3Y7CIi6R7jA/2oAzcIxcUfHpCsvkcNNelT6bEpo6M
 pFBdd0/c3uDvyWokbaRsptI4c2KfnEa1r2qDwZGR27B3hsyD1TE8460K1sS8Lo9IF91Zp4a7Daa
 QDmhjEwzrPxddxXl7NRfmGM4gil7Rg/vqZfoFX2aR/gfZrpaUIg9Ie7QAkYcJlZylTBXDb+6die
 YZDeLlwmUInrQ+cRTH6TNg7nrM/OzwutD7UDqKa0X8g3uz4PCA5LYVYVhR8GEgHP9lIEmgGcyEB
 PA6vlPvBfkF/QITwwZcKgiQhkeMJHfq47cEzfXdFBdLtJXe6VcSc5zeF7lfeTynZxkQv44gn99d
 4fZrKTyvYE0RsqA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Cover the teardown side of the same rule. Remove one listener, then three,
with the stub silent, and compare what it saw. Three removals must not cost
three timeouts.

Both measurements also pay the svc_unregister() sweep that
nfsd_destroy_serv() runs once the last listener is gone, so that cancels
out of the comparison. The listeners are registered with the stub
answering, so each one has an entry to remove.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 39 ++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index 511d20566ff3..89d1da825b95 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -1248,6 +1248,45 @@ TEST_F(nfsd_listener, rpcb_retry_next_request)
 	EXPECT_STREQ("", last_extack);
 }
 
+/*
+ * The same rule on the way out. Removing a listener unregisters it, so a
+ * rpcbind that stops answering used to cost one timeout for each listener
+ * removed. Register one listener while the stub answers, silence the stub,
+ * remove it and count; then do the same with three.
+ *
+ * Both measurements also pay the svc_unregister() sweep that
+ * nfsd_destroy_serv() runs once the last listener is gone, so that cancels
+ * out of the comparison.
+ */
+TEST_F(nfsd_listener, rpcb_unreg_stop_after_failure)
+{
+	int before, one, three, off;
+	char attrs[192];
+
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(attrs, off));
+
+	rpcb_stub_set_mode(RPCB_STUB_SILENT);
+	before = rpcb_calls();
+	ASSERT_EQ(0, listener_set(NULL, 0));
+	one = rpcb_calls() - before;
+	ASSERT_GT(one, 0);
+
+	rpcb_stub_set_mode(RPCB_STUB_ACCEPT);
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 1);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 2);
+	ASSERT_EQ(0, listener_set(attrs, off));
+
+	rpcb_stub_set_mode(RPCB_STUB_SILENT);
+	before = rpcb_calls();
+	ASSERT_EQ(0, listener_set(NULL, 0));
+	three = rpcb_calls() - before;
+
+	/* the second and third removals must not reach rpcbind at all */
+	EXPECT_LE(three, one);
+}
+
 /* ===================== threads / -EBUSY semantics ===================== */
 
 TEST_F(nfsd_listener, sem_busy_on_change)

-- 
2.55.0

