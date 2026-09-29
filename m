Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B082F3451D6;
	Tue, 29 Sep 2026 07:18:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790666307; cv=none; b=RBLjp6Jahmr5xERtxbc+XruWCXWW/F8RA54pvLKZMTzsbN/Z55Yc5oUr/V1C9Qsl7l93poLN3SuvcI4wIL4TKYyCYs0hNukJfH0RUyMAglc6xUaiy7kOQH6D4/xU1kRcED5jPMIr/SAkV9S/P4714OUlJ6UxZp+KMikE6m6zoKw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790666307; c=relaxed/simple;
	bh=HjoQsE6HQdzGw+KMpLI8hOVBrhCx1wyGTA1hNtXTzZQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=j9AxIIwr9GhjCnCHcZJf6smZghi89dGSgpPIa1iII+78Bry5957xQ87emKdLd+Pf4u7pJiwoYexkYQaXGtPwIOc7J+y2dFg6DtOsjLE/2pl6q5eOnBqdy5+/u9u2RJTcrdXtUwO0yxxX8L0DxwI6IIWDjwvTEb1tESSBYn6xabs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=H1cdlZ0K; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="H1cdlZ0K"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 159F81F00898;
	Tue, 29 Sep 2026 07:18:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790666306;
	bh=SzyVW5II+GzZ2Kkc45gez6YC7wp+NQFrBHSESlX7gQI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=H1cdlZ0KoyRcwCIuvoJcNR/Y4PP9Q7y1AW2bQfnybfPcty/KPw69k279QkahNdmMQ
	 AcMS3CTyIBCTR8WlcE0it4bnS8sRPN7WyUBPDJ3iDhKqaJ1qo5XbU4CEdCso1ZqkM/
	 JQ9SFbTDWRw1COa8Fmi+dUuFRCy4FzTvhhAm4jU8Uv19cIncCZCeyyUIsVT3IP/W4O
	 v3MBnLIH+LQMqy8Rf21QfbOQDSpZWcSKtOehWAemHNSySobnSvhmc/p6PvQHiD5pTz
	 eZAs9ej6HDQJLaL8gj/P1EB+//rV0i8X0PDaF712sNC/Erv1bcnqWzzNh+EkC2vWhj
	 ZHCvKJcaFL7nw==
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
Subject: [PATCH v3 net-next 7/9] nvme-tcp: use sk_clear_nospace()
Date: Tue, 29 Sep 2026 07:17:41 +0000
Message-ID: <20260929071743.23624-8-edumazet@kernel.org>
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
 drivers/nvme/host/tcp.c   | 2 +-
 drivers/nvme/target/tcp.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/nvme/host/tcp.c b/drivers/nvme/host/tcp.c
index 921934028e0b22c2e4c9fd60d09ed8e50051262d..b853ca2d598fa4cb8ea9cb66513f1e1070cd1fb4 100644
--- a/drivers/nvme/host/tcp.c
+++ b/drivers/nvme/host/tcp.c
@@ -1133,7 +1133,7 @@ static void nvme_tcp_write_space(struct sock *sk)
 	read_lock_bh(&sk->sk_callback_lock);
 	queue = sk->sk_user_data;
 	if (likely(queue && sk_stream_is_writeable(sk))) {
-		clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		sk_clear_nospace(sk);
 		/* Ensure pending TLS partial records are retried */
 		if (nvme_tcp_queue_tls(queue))
 			queue->write_space(sk);
diff --git a/drivers/nvme/target/tcp.c b/drivers/nvme/target/tcp.c
index e598101752620448423925d2385b606e0b4346e8..c38ea3501ea5def168b6f180b56734b99d21bdea 100644
--- a/drivers/nvme/target/tcp.c
+++ b/drivers/nvme/target/tcp.c
@@ -1686,7 +1686,7 @@ static void nvmet_tcp_write_space(struct sock *sk)
 	}
 
 	if (sk_stream_is_writeable(sk)) {
-		clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		sk_clear_nospace(sk);
 		queue_work_on(queue_cpu(queue), nvmet_tcp_wq, &queue->io_work);
 	}
 out:
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

