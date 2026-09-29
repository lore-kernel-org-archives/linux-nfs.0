Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACB4D391855;
	Tue, 29 Sep 2026 07:18:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790666294; cv=none; b=c2jNIBatUC6ix6+Qw1C1DWXZ5gewPSFi2SCGOLvVGobKGQEUTE4xuZI/fig1sZYPA3DuVg2B6+ta+dMpvmNpZQ9B6DCEwUptSdwHiIprMsov+Mu7WKLlBTvzxEdYCZe96V0cWm5i4uccNsmjtyM5yvjaGFLvF9NrTHc6f3vmxvk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790666294; c=relaxed/simple;
	bh=O6hSXIksPZx9kHh9bRdjJ62Y0nt3rUSNhzlYGqfFT8Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JiuLd3vJM2ayVt8xdu01giAAXTgwWagQv8gH0ep3baBW8LEnIMSMdwwYscSAlf2lAg8rw/p4b1iMs1vBYYAXq6cflqW/K+as83O4xGrMfQ/8iTrjQ/Tp6e6XTVbNgVvl1Jx4KcBoEoFWEDmz49+UueRC0iSVCIQ25CtGlDa65/A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BbuCT+m8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BbuCT+m8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C31591F00899;
	Tue, 29 Sep 2026 07:18:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790666293;
	bh=OPajyF9FpTj0kdlawINv7kUV6GbsYhAG/0HAkx7dZ6s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BbuCT+m8zPy06hZWnuow0+uWftZurI4ASu5Wb63Dvh7l0cVGZT3j4uvj9VIqpVzz8
	 dMLqI2peRMPS/ii2Z0wjkWcoKZDuZCJhsnRRIatPEHFC4OAC2cByCn8Qk22HbiBX8o
	 XHkBrJrYZo/RlzzdRCZXV3LNVc/lGpoqSQH4fZj1ZXRbCEUJ5EsptZTAa2qHzhzs8J
	 xtlomL4J5ccBDKN5WiHp+gxQjTIdpSIKMrnJQFpqdgtTNQr8E9H1HolnlIlE+uQwTX
	 5WkZgPd4ZmXn946h7vjskb/VzO9IfS7PrORPEZGFQrCqmMhUwhA66q3I66s7QaJSdu
	 wVNJ2CU1FzAdw==
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
Subject: [PATCH v3 net-next 4/9] rds: use sk_set_nospace()
Date: Tue, 29 Sep 2026 07:17:38 +0000
Message-ID: <20260929071743.23624-5-edumazet@kernel.org>
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
 net/rds/tcp_send.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 7c52acc749cf4d4003c749a2646c2b4f87f207fe..824222c475119d91e333123c5afc9291005a8696 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -100,7 +100,7 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 
 	if (hdr_off < sizeof(struct rds_header)) {
 		/* see rds_tcp_write_space() */
-		set_bit(SOCK_NOSPACE, &tc->t_sock->sk->sk_socket->flags);
+		sk_set_nospace(tc->t_sock->sk);
 
 		ret = rds_tcp_sendmsg(tc->t_sock,
 				      (void *)&rm->m_inc.i_hdr + hdr_off,
@@ -221,6 +221,5 @@ void rds_tcp_write_space(struct sock *sk)
 	 */
 	write_space(sk);
 
-	if (sk->sk_socket)
-		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+	sk_set_nospace(sk);
 }
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

