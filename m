Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A40F43A7F7;
	Tue,  1 Sep 2026 13:40:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270029; cv=none; b=lxdTTBYg2LsaEeFxq+rqqHUgoP4aSoNprB9v4/so+WlbjFg+Og7zVUTtl4jPnR9KkmPdVWm7mv0RA7S/+eXG4JweO09RyZsROZqJLetl03Sd2hZrQe8bSfFPdFtMBVHSHp6iUhgvtJFaEuGbyAzRLOEKIm0ZSs5zExSsEnfUmII=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270029; c=relaxed/simple;
	bh=75QO4SurT2sIQy+kvdxUPZUZy8/rxZ/KBie3jlSvnBY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MGDDeLRAghIV1mBV+TdyDxwZiRnkD00pWKkENJ/g+VTa77aVNRc2/gI0dBKnslYJci3+v1dGzxnyvN7IG1ViLWVmqryWK3lcGvcVBuQOnIFzHdayJfwfKfYznPh1ujMGr3Btg2NgxQkI+yvwU85ooHXkgx4OResR+v0/ruiYmsY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bJRJrhk+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bJRJrhk+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C88AB1F00A3F;
	Tue,  1 Sep 2026 13:40:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270028;
	bh=V8VOs9E8hva8yGO31qnDmSPXxyBXMikzs/FU9U06NdY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bJRJrhk+QLIfmBVWyhrNApv0vVVPTB/aXPkmQ5xaWLgqdA9jfNNAo/UhWSdY2G+h9
	 8NqMuFClJt7UrxC7Em6yqoDgTuiFRF7t2UcrVdeSK6qbHzX+91RIiIgj16gdunFE2O
	 5wnScRd1IKVRLpY4qjGWiAviNiHJGEGG9PxWd5N3eji/LDFiRLkcERhtbqvAYEDzaF
	 aOWC3rruUF6YkqDVXC80iht7wA33gv3zX+5s37dGcY2AfgIZHgl8eUw/NdzEhIPJko
	 U6YCyOdGuRilkkNA2EcZwRWgpMQ7qwAj9XeN7Dg00n1zXprybPPFvqdfWvNtU8lKRR
	 v7pHZ+b5RfbIQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:53 -0400
Subject: [PATCH v5 15/15] selftests/nfsd: check that listener removal asks
 rpcbind once
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-15-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
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
 h=from:subject:message-id; bh=75QO4SurT2sIQy+kvdxUPZUZy8/rxZ/KBie3jlSvnBY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWxzlZQ6zkCOPXJCRJeGCIuwjvpv17ImQeBG
 l3KSlA8xNiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVsQAKCRAADmhBGVaC
 FQYDD/0QKqW/kjPzJ4hzy4NFHOIaoufargbQwwI9L+7045iYjeuEb/AEWhIprAf4pCWRJ5WrSz1
 U8F2a+VEtRaXKUr0aenCvT12UQC5VLMChwnptrrmkft8jFme2Xo18AjD+fWv3jcUiZ+KhgjZ+dp
 CuaTQDniPZeQGFjJgdABcuAdDyUzsVFJiepD98iQ/25pdb8Kn687lSp9tSgODOyeKJKNeaiknvD
 hak0V8vTPUXdKz+OmTht9A7+WiESTUW5nhUUw+LYhk4PAM8e2me29t8bxYrVTc3HR1Re+m0HeHo
 d8zXLU2atK/a8huQ3rwWz6Mp5mVHMCmLz/gb7RKol88IYsnk3zeeOLrQKj58KmeJL6SAvbQELjV
 XkZvDMCn64uhkwyS2JkYvfw0rMH6UIuwdiDfp6ygs/kfv7bsSJcPOBj6RFU407oJsMizfMHlE9t
 MNOcVSVWJkcQvNzZjy4tMRmzw019XeyinTx4xQo2UUkzz8e9XGrJv8MVQf6hABb802X9fF/D4vF
 SbwP790gwHmVJHZk1h+4rUX+3iVIBMpIA9Q/YpXCDswOJKH/jnzXqPtq7E7tQOZu058cuubhW8D
 5ohRTg4x2pGiI75u4jdiG23Zqc3eZBaIoRar3Lk6pst66mgHfsOco6Sp6eFVS26K5C4E1G9C23u
 gVmIyUF9v7QcnUA==
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
index d0f4258f905d..106360f87b99 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -1243,6 +1243,45 @@ TEST_F(nfsd_listener, rpcb_retry_next_request)
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

