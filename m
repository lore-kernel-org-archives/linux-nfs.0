Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB16438DC45;
	Tue, 29 Sep 2026 07:18:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790666312; cv=none; b=XE0v1vYEd5rZ/U6qlmWRNlclhoB4IEDlCp1qnDYMFSFDXvs95VYX16fcPHQANQzhv6Tl5ztmig9j6A4jdxBI6d5+86Rb1MUKhg+6EGZun8m1nUp+leK2YD2P1WoWpo3aubouYfyBVlPZNWUPIvz/QSLdfa1UvLArDXamHlEqcUk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790666312; c=relaxed/simple;
	bh=hLjVNr62yYkjIgaGFa9SsdIqSYR1I5cZ9kOXmpD4/dI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PfVhGcxGGyNp/4woSZpHev9+zvu4o6UwN4eg68cmPrkWPcVo3DhQ/E0dCev/pSQegrU1wgWTovHWtf0bRdDOj+6Qr0IcmHmnlI6WzAaLXAvYizAKS2g3chuDSYh3eWWjZa/oV/oZnEAZh1wA5taerltIswR3Q+QhXpEP1UcU70o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FmRxfTDP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FmRxfTDP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D8C91F000FF;
	Tue, 29 Sep 2026 07:18:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790666310;
	bh=984oS/2M5KIktVHs6exbd7VGWIOJaQY+nCN+ILc+rzw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=FmRxfTDPEZousgH1mjwF32qw+pB3arJrOFJKVf9mYNrECcwDd0kY5zJEDCAeOfA+h
	 8QMxbbyA3qAZGDy07ZV0BxvdAAP3J68e49cPkJt6Qqx6otSeCjZ7L53yR+diox0onh
	 0f3FLaVkDB96yhiRoQ/51IQ8Jjw9vtUtF6xRj1BTZbdWu8Sg+6hWOhiXzqXplYNXdr
	 A6ZOhgMIkCEDC5tqlKqrUVUUTFn3iZyu1kpzjEUylNVswdGDZ2IZTOmqFxGGutWa/U
	 ADZwjBHN4QGRKgik1vrs/ngbSim7hOwW5sYh9KJo12K4Dl1epBaHdQ/sTKvrSDq5Xt
	 XHscnmim4ChLA==
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
Subject: [PATCH v3 net-next 8/9] libceph: use sk_clear_nospace()
Date: Tue, 29 Sep 2026 07:17:42 +0000
Message-ID: <20260929071743.23624-9-edumazet@kernel.org>
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
 net/ceph/messenger.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 212e7797f9e48edde4a4536bba6f1ff293628b5b..cc7db8c61db37a998b698566caa7c936fa83fe4a 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -375,7 +375,7 @@ static void ceph_sock_write_space(struct sock *sk)
 	if (ceph_con_flag_test(con, CEPH_CON_F_WRITE_PENDING)) {
 		if (sk_stream_is_writeable(sk)) {
 			dout("%s %p queueing write work\n", __func__, con);
-			clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+			sk_clear_nospace(sk);
 			queue_con(con);
 		}
 	} else {
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

