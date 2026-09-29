Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 346CE38DC62;
	Tue, 29 Sep 2026 07:18:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790666290; cv=none; b=bREWtqfqUCGBUIZwdLqLOWtKF6qNM30oft1sIYT0qJGzhpipHNedSf7yyijepUigP5j0nbqFublsIwozmPdyqXsZhc4x24xowgwez6RzZYF6/0Dc74Kvt9pwymclKmgJF5UH7IyA+Aoemd+8wA1dEkNs8+kRwtWe91jLMoIC+Vo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790666290; c=relaxed/simple;
	bh=ldm+w9eNgKayOOg9zqGBUrUGr6woRc0ajPzZb0o6l4g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=azWTdu0o7Nvc03wD9GPoE1BBaaDnjfJHk+otWOmw6lZNglzgAFqWcdfUlENgmtSJt8CFHh7lOx33kiWnGS8AJtfAP7pVe6hG7YviCIQpY17n3cJGn/VrUJH6+xNF1hm/U40A1SzOSXoPCYuN/g061WJPIZzRPaNTpLZxAPN63AA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LHPMDU1s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LHPMDU1s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 656C11F00893;
	Tue, 29 Sep 2026 07:18:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790666288;
	bh=IJFRpgGenZGFgmE716szjfJPy4R2IRxV7+FW89IFnek=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LHPMDU1stnoIOzkVui5b8vIjoubzbqbSkB4Jj1qRkY6vs6k1Y8cf0xmvP9HdU+YYk
	 swI3Mapse3ZMpePDOfv9JPB2K6iAg5gqIteBCHA4COYT3fRb609BKChwFGSCxSziUc
	 Biv+bVQseOx+MUK9r1S5tpgS7zGeRiWE0sh9iij7+BLslOUPKSFPtF8IiBWh+NDmiB
	 T6hCU9+gd6sD7bGJw4O+ZgDRrGfEzJAVQ21WozmNFHiLL1QcS91U27S7+RXqvICDh8
	 0EwVWsV8vAEy1EuFG+wTLl4Px1nPEY48mKz5HPwvfvg8LuX+TzyYQ+Z1TEW7ADYcVh
	 1Rae7OOHJcrOQ==
From: Eric Dumazet <edumazet@kernel.org>
To: "David S . Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: Simon Horman <horms@kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Kuniyuki Iwashima <kuniyu@google.com>,
	edumazet@google.com,
	netdev@vger.kernel.org,
	Alexander Aring <aahringo@redhat.com>,
	David Teigland <teigland@redhat.com>,
	gfs2@lists.linux.dev,
	John Fastabend <john.fastabend@gmail.com>,
	Jakub Sitnicki <jakub@cloudflare.com>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Jiayuan Chen <jiayuan.chen@linux.dev>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	mptcp@lists.linux.dev,
	Wen Gu <guwen@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	Allison Henderson <achender@kernel.org>,
	rds-devel@oss.oracle.com,
	Philipp Reisner <philipp.reisner@linbit.com>,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	=?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph.boehmwalder@linbit.com>,
	Jens Axboe <axboe@kernel.dk>,
	drbd-dev@lists.linux.dev,
	Keith Busch <kbusch@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Sagi Grimberg <sagi@grimberg.me>,
	Chaitanya Kulkarni <kch@nvidia.com>,
	linux-nvme@lists.infradead.org,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	Eric Dumazet <edumazet@kernel.org>
Subject: [PATCH v3 net-next 3/9] sunrpc: use sk_set_nospace() and sk_clear_nospace()
Date: Tue, 29 Sep 2026 07:17:37 +0000
Message-ID: <20260929071743.23624-4-edumazet@kernel.org>
X-Mailer: git-send-email 2.56.0.rc1.315.gc6ed9934b7-goog
In-Reply-To: <20260929071743.23624-1-edumazet@kernel.org>
References: <20260929071743.23624-1-edumazet@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Use the new helpers instead of open coding the SOCK_NOSPACE
manipulation, so that TCP can later maintain a cheaper private
copy of this bit.

No functional change intended.

Reviewed-by: Kuniyuki Iwashima <kuniyu@google.com>
Signed-off-by: Eric Dumazet <edumazet@kernel.org>
---
 net/sunrpc/svcsock.c  | 4 ++--
 net/sunrpc/xprtsock.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 50e5e7f5b762de28c34d0f58cb0c6feb1e3ce79f..2d8cdee0798d540ba8eae589deaac5bd3ff889fa 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -792,11 +792,11 @@ static int svc_udp_has_wspace(struct svc_xprt *xprt)
 	 * Set the SOCK_NOSPACE flag before checking the available
 	 * sock space.
 	 */
-	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	sk_set_nospace(svsk->sk_sk);
 	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
 	if (required*2 > sock_wspace(svsk->sk_sk))
 		return 0;
-	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	sk_clear_nospace(svsk->sk_sk);
 	return 1;
 }
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7f60723fa64d84887e260e5e130e44cdbec6f850..b97c70c12f627630509510facfd3c3cf96ab6cb6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -858,7 +858,7 @@ static int xs_nospace(struct rpc_rqst *req, struct sock_xprt *transport)
 	if (xprt_connected(xprt)) {
 		/* wait for more buffer space */
 		set_bit(XPRT_SOCK_NOSPACE, &transport->sock_state);
-		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		sk_set_nospace(sk);
 		sk->sk_write_pending++;
 		xprt_wait_for_buffer_space(xprt);
 	} else
@@ -1615,7 +1615,7 @@ static void xs_write_space(struct sock *sk)
 
 	if (!sk->sk_socket)
 		return;
-	clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_nospace(sk);
 
 	if (unlikely(!(xprt = xprt_from_sock(sk))))
 		return;
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

