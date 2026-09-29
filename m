Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FD5238E8CA;
	Tue, 29 Sep 2026 07:18:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790666303; cv=none; b=Bo7kMKj+m4t0CGbcyVOgaGSkK6w370NSCwt8koZd4UNVGzEBy9QVaXo6jVADN1zHgO0+Uf5PsY0tx+JVsB+1jx6moym8ulz44KF8aBvufNokyTs8VUDcFGqYXmmDnt2OdRmzsYeg3kIUIr/ZD1korh3LZRf7CtXGpjWITVQvU5A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790666303; c=relaxed/simple;
	bh=rDxvOjm7grrJIvYuyxm1pKCpGBApcCr6KlaorucIEUA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JJjtE/zF7nt73Mpu/heW8Lj1bc+n0h4O0J5QzG5c7vUVbsYczXkZSWfZy29CycUqj5ejvkerUPm9mcKKQjPUIVv320mS2fy51Ra4Vd038pQD8otB9xOCxORP29p/agyjWpIE2jzi72a1saB6ecPddNsP6sDO8W5rbt8ckFb9I7g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Utmyw0ZM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Utmyw0ZM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C9C0B1F00893;
	Tue, 29 Sep 2026 07:18:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790666302;
	bh=RnWUSUoPlsuP4rnCrMGHZfdBwvKHsEHp7ONS81OIlUg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Utmyw0ZM96CbsgrYi7Di59lazewSJzkqgeCES4nSZti+IkvQCMxSaEX88ZKJjxOaj
	 zUWbZuXoe7uutd0a8VirVY4s6libYi8v+CFbziQeDQ6HwyA5Hr1P2B0tKrg6pDK9G9
	 6EV/14xbrkSI+W3pL6lhkD/dP2yzga6gZbzWU0pJOkwFlkK4BmSrbFCpeitPYiTNkg
	 o3atTJQsP2tS6/yI0SMxpo56E1/28mcKwHn+27jtxmmb6hW3J09MQHWkzuimU/ghVA
	 WMuho6JPxiSj2sOwc0JQkxgLh2KpNt85qfi8fzgt2G0Kddq2PFgtzuUEmSix9n/c1I
	 +Riy/PYJ/j7ew==
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
Subject: [PATCH v3 net-next 6/9] drbd: use sk_set_nospace()
Date: Tue, 29 Sep 2026 07:17:40 +0000
Message-ID: <20260929071743.23624-7-edumazet@kernel.org>
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
 drivers/block/drbd/drbd_worker.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/block/drbd/drbd_worker.c b/drivers/block/drbd/drbd_worker.c
index 0697f99fed18d7e70f00b7c559a131517ee8aa42..8e50131b5a5692a8dfb99eafe706602153be94b7 100644
--- a/drivers/block/drbd/drbd_worker.c
+++ b/drivers/block/drbd/drbd_worker.c
@@ -635,8 +635,7 @@ static int make_resync_request(struct drbd_peer_device *const peer_device, int c
 			int sndbuf = sk->sk_sndbuf;
 			if (queued > sndbuf / 2) {
 				requeue = 1;
-				if (sk->sk_socket)
-					set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+				sk_set_nospace(sk);
 			}
 		} else
 			requeue = 1;
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

