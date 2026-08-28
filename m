Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D887D471D1A;
	Fri, 28 Aug 2026 16:38:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935090; cv=none; b=Ob073JGAl/QwEGrgxNZWg3dDpolknbnejiN5mUsgd+HQItzFHAso0Pxe5n9a85YpZJ8gtFO04E/Oq1CaZ64Yzk8DocKw6+aBGt7Qm4z6o8h6yF4M+9E5f+JLCevSlJxNafusT99HCdDuM8mS3xOYPboeRSjWeAxZUyPJ3YEAutM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935090; c=relaxed/simple;
	bh=grf6clZnkQGXGoZ9rkU2+lKlywCVByX9ysCCD0mMuIg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iiBR1HMOMl0pQqvikjwxwvs4ejYcO89qjYl2fpjNc5ZM4ALoxZldQVu5WzTRqzMkQ+y2QdjOhFRBN1LD9aMr6DUYh4W02PWVjD1UeGOKxebrqmkb4hYQL0jmyWnnnH1iSaIfagb4PNw+D64HxpC8XEktL7kDkE/3VbJRAf2O9Fo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QXJ70Eww; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QXJ70Eww"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 327DE1F00A3E;
	Fri, 28 Aug 2026 16:38:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935088;
	bh=+xLJWmj9sHbeFwxKybs/pfRQuWXRiA1jYXOW+vEeb5Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QXJ70EwwrIbUEgXB/o3pZWDrildJPBUbdTtferhpVBxs5btkH/7PSMcN/knX6kdfu
	 RP0A5DmRKXkH1G/uu/RyhJtchqK+kKxWbQcK8Kgy6dhIG2JFrfhrPFLGX6zG/6NTtl
	 lq/dMCbVu/3BCax44MHimVryl9ZQqqKuGhSGTAIdUg5Gz34IThclmPQCIpoS0O48Os
	 q+FpWCmwozZpne6y8HJzavL9iV8viZowrjsNtF3m9gOpRgtnlWyAgaJK2ZzPYgGG/T
	 yxVl9EK8TmL/VrOSQ4EFmO6v0R07F48AQ9ruUZMU+qehrea1OUwjOwEt/TCLMtJYFu
	 hN4/ITAcYk9Pg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:44 -0400
Subject: [PATCH v3 14/14] selftests/nfsd: check that listener removal asks
 rpcbind once
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-14-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
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
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblXQ84/SwzI8TY+nEZKodk71hnK9eZPXcoE2
 /7OJjXpLT+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VwAKCRAADmhBGVaC
 FctmD/9P6TyHKgFTtGhoaBecAnRF+LL2b27njB3KxVyN5Dj/4EaLYaHqaEhFvQJHR/6YGpc8vQF
 I9ZOd7mBPH3JHzbL83z7IN/5hipG7Yg25XlD2LGPzDt6vs9pQNCIk8AahZasSSSoMtSKh/B8sjY
 otz6FdbiZE3sSEpGZlfynSx5Yzx8grXgMhEOuwxYeov8Cb7d6I1OFd6ADbf4p4EfLX0RvirkZe/
 wUv9eFmue9t78nrmEh+X5wD949snKF6NQ0y0P+Qh/Da3HZFB+GvLn36eExZKI6AFs8RriEAIadM
 HkWf9SINcYVMLPQMGy6lXeb52x93tE5ng3+qWVtR47/XVy9htIuU0CFl/SRRW6XduvcLAIcKaG7
 gE6xl6tY1t5rHr+SF1bXIhz+0Ut2VskEW72NXD60/V74fFZ4OSMdN6yyL5YVcAAvMpD/egtqmYP
 XMN2ynwJ+udaVUgKwr+iXRauCiYOT457O5RkCSbjySfEHck1raRaIsHiKFarWHUrAqLLF45FNDW
 EVdCBL6so9dU6xgOmP83th0mjvgwYL2X3QfxnUQhK0/YfdPextuh89POHJgb6A7R8+8cyNRNfNL
 tFYS2/LP7DR3fhZ3rNahotlbSPXODBPqZw6NwNlP7i+C5sRXfYHayoyBrSHxHzWVsgQXLsOmgYN
 soyNYcP2FbV5++g==
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

