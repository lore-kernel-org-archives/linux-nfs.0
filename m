Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB56C397338;
	Tue, 29 Sep 2026 07:18:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790666298; cv=none; b=oaJ4YxfOylk6HEP59Afk0KpESF7mJYcpf0Q29uiR1I03redTuThqJXF7YSTdB0EJIJg6/tYGPL6v97fX4/yL13MOdVFj2nuEske3S7wIR6hubyAdQcV7v8bg79yPHK4vO3m+A4HZY6hiM5TtBcBaGcqxxZdXi52Wqp3SGzkIje0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790666298; c=relaxed/simple;
	bh=7Ef0u1n4rA80U3wvj+1MNSMfNuxnKiPp45+RAjtvn+Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cQBRifxFmcskO5KJSFG7fv1GFo4RDGWqiD2ZuxUA2zzDyliMNjardVFgKPVlZcNbvDTMmZUsMISArWf1NQ8v+1BaW2oDiVdqtMGjyXRoKKJ2K4m1FthDxyQhKkFdLQU1zqmForwWg6fZo0R3hqZYDKLLmLBxkhK4ijsc2qWbets=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VwivzD3a; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VwivzD3a"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 318A41F000FF;
	Tue, 29 Sep 2026 07:18:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790666297;
	bh=hThQis9jrIYHM2qp/AUyAye12+rzpdk99d0bmSnxuAo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VwivzD3a6Tfbg1hAmWgU/0lvAsOcO/D2hXgF4I0INZapunQeWFiA/vY9+Pj8um46k
	 ooyPMj18vfhDBUXjxz3dhKxrC+XN2JW9+9CM6Kpr4craL9R0MJ26TlUwOoQk0DosJu
	 gTHOTAGt2AbJdtEAc/Se1u3UgBdqRffpKtTmiwlVip3IaR4H8tSqGTpPXp7sS/0lT7
	 RuQ5LJQxjPDDmef9IVOvE7Ymzh2NTA1DTF+GbYrPFmTDsuyfVORv6qnKeLEbwRO0gn
	 iTkQMEQ0zTsXm9q0ymW/E/4EZGn948lnU6kHmrmasVInSPxWwImDhDQUPdijALzpug
	 1/z5MjigjDm7g==
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
Subject: [PATCH v3 net-next 5/9] dlm: use sk_set_nospace() and sk_clear_nospace()
Date: Tue, 29 Sep 2026 07:17:39 +0000
Message-ID: <20260929071743.23624-6-edumazet@kernel.org>
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
 fs/dlm/lowcomms.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index abe9ae4c643fae061d2e168c03219a4f4e1bc007..6aa68a24acab574429664acc3f5ecc25ddd1553d 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -519,7 +519,7 @@ static void lowcomms_write_space(struct sock *sk)
 {
 	struct connection *con = sock2con(sk);
 
-	clear_bit(SOCK_NOSPACE, &con->sock->flags);
+	sk_clear_nospace(sk);
 
 	spin_lock_bh(&con->writequeue_lock);
 	if (test_and_clear_bit(CF_APP_LIMITED, &con->flags))
@@ -1394,7 +1394,7 @@ static int send_to_sock(struct connection *con)
 			/* Notify TCP that we're limited by the
 			 * application window size.
 			 */
-			set_bit(SOCK_NOSPACE, &con->sock->sk->sk_socket->flags);
+			sk_set_nospace(con->sock->sk);
 			con->sock->sk->sk_write_pending++;
 
 			clear_bit(CF_SEND_PENDING, &con->flags);
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

