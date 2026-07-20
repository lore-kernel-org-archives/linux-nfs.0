Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F41D42586C;
	Mon, 20 Jul 2026 14:28:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557699; cv=none; b=Trjq+kzwg3AGsjOMLMzoQI3OX3+H6cZE99bRIwgSNxhuyM9FYeVWD1LD26RlQtdVLvJrsC6TkYdCv5owA9+nE4wUSAO0pKox14qEPkbmPYnyGEuY6YUMMBjE3KcsLjwhQiU5MZN6eKvT8vuUQ8z5p8Z5g33Z3b2W2yyiU3XlbiM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557699; c=relaxed/simple;
	bh=u7U5N5wDiMy4eBTnkiJZUFOyXOnXebkzwDbLfAuXDtg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Ys3hglwO09uv4AhfDKlBS/lRYmxN2GTbc606+uyU1GHSM5Tegar15XU/pMsqk/p0EaHPTG731Tm6Y2D4fdB0JENuU7U31ej9PbmRzOEzXJCJvbNgkyibpxw/iL2q9F6cJ2H7wjzlsx5OA7fjLt48Oyum3OAL1Kw1uWuQ5B/KCek=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=No53ePxY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="No53ePxY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C0B561F00A3F;
	Mon, 20 Jul 2026 14:28:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784557697;
	bh=HeK+7WAe1j9DLbre9kaKG26xAJJ07uQ1XfFW/xxfFOE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=No53ePxYmI8OkpzhvdQ2njNr02q4a2k987+tZkyleMTgnPSGTs2VozqLPBGt4R+tV
	 /kAraW0e5k66S2/bD7kq2pN2vBXN1ZdAquVe2lfcMBLk2SQvbLf0ymUeat50BdVybC
	 qOcFzK7yLsek/5TH40mJn9I+d87fpa+NoayBG4CNwtEF5akSKckMNnxolYBk2hzDKf
	 FquCvqe+mvVlAIKL5ZOj9GyM/2/An6fta7DE6AfFKu41ppzqvvZR6rGcGdSxn3KvEt
	 Gy1eci0qfh548gSayOhbFjG2zgHAGrFdP0pbfQm8OeQpH/TR9e8KVKmgJaxzdF1cBp
	 +h79Gy8ldP7MA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 20 Jul 2026 10:27:57 -0400
Subject: [PATCH net-next v2 3/6] tls: Implement read_sock_rectype for kTLS
 software path
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260720-tcp-read-sock-v2-3-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
To: Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Shuah Khan <shuah@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Chuck Lever <cel@kernel.org>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev, 
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4508; i=cel@kernel.org;
 h=from:subject:message-id; bh=oJObk2kNjvM+ukhGUGgZGEq4NeHvZsgwwkul/qLO0W4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqXjB8DOLxloNnzNFR8eb6YjzGR0uICumzhaOyK
 dimRo6SXp+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCal4wfAAKCRAzarMzb2Z/
 l4leD/9IHF8/DyM5KiRS/94GR7xT8ERexktSyvKJZOqBSFXfXeZQU6kR6PB9HFawEvPV3WL1aQX
 DehLrW0FcI+ZQhfSrBypSiLH67hlm4Iirt+8tLk7RvnA78ZbtScDZtkQYPmyIQAwp0LmPN9AIyl
 MunmWdmDT4LhOHutwLoGhGYu1U59+xtWGhCq6r+9xECPmvZIEOVLhkRSaxca8Tz59hy5y7fbQ2Z
 29asPPupbZ75BvGJBhDU34/vE7uYRT9+M9XXIGmxhtg2EtQKgbyJYTATlIV1Ij0WNIlyH/IErz4
 oGEWRI48Y4BB9ZRj/kUBOEDlp0mweY9VZK4FAISz+qEK+GpoDR3iTJLPWKADeedmFZFR51tXBHE
 R3QdrW0RxXwLDIRhkB2zo9MeBzFipioQNAePmkj1z49CoItuAMF+ONMl3sw+3fKd50u+IIlGYKN
 0+XJJelvNAk7zR0BYtdOqyPhUaZvWh+rm6lKHhqb/AXIU6/pk6J4IKxzg90mXlSMHiIRaRlwZo8
 MQMcmMr0PLZ9sRr83DKozx+XIOdPuf4k3i/U7cf2AyXp4ur4/rg6OVE/qATuKb513PDefhBqh57
 StR+Z+qxtdDpSoqgwfkEhz6I9WOJMpwQ7FA6uXwM2bdDDc7wL94Ws5iY317tVdSlnOTIdWwOx9k
 I/JGgDjILcz2yTA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

tls_sw_read_sock() rejects non-data records (alerts, handshake
messages) with -EINVAL. Kernel consumers that need TLS alert
delivery, such as NFSD, NFS client, and NVMe target, must fall back
to the sock_recvmsg() API to receive control messages via CMSG.

Implement the new read_sock_rectype() method for these consumers,
delivering non-data records to a callback through the kTLS software
receive path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/tls/tls.h      |  3 +++
 net/tls/tls_main.c |  5 +++++
 net/tls/tls_sw.c   | 41 ++++++++++++++++++++++++++++++++++++-----
 3 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/net/tls/tls.h b/net/tls/tls.h
index 60a37bdaaa25..c21d2a985e13 100644
--- a/net/tls/tls.h
+++ b/net/tls/tls.h
@@ -168,6 +168,9 @@ ssize_t tls_sw_splice_read(struct socket *sock, loff_t *ppos,
 			   size_t len, unsigned int flags);
 int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
 		     sk_read_actor_t read_actor);
+int tls_sw_read_sock_rectype(struct sock *sk, read_descriptor_t *desc,
+			     sk_read_actor_t read_actor,
+			     sk_read_rectype_actor_t rectype_actor);
 
 int tls_device_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
 void tls_device_splice_eof(struct socket *sock);
diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index 8c588cdab733..4963e0caf6d5 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -949,12 +949,17 @@ static void build_proto_ops(struct proto_ops ops[TLS_NUM_CONFIG][TLS_NUM_CONFIG]
 	ops[TLS_BASE][TLS_SW  ].splice_read	= tls_sw_splice_read;
 	ops[TLS_BASE][TLS_SW  ].poll		= tls_sk_poll;
 	ops[TLS_BASE][TLS_SW  ].read_sock	= tls_sw_read_sock;
+	ops[TLS_BASE][TLS_SW  ].read_sock_rectype	= tls_sw_read_sock_rectype;
 
 	ops[TLS_SW  ][TLS_SW  ] = ops[TLS_SW  ][TLS_BASE];
 	ops[TLS_SW  ][TLS_SW  ].splice_read	= tls_sw_splice_read;
 	ops[TLS_SW  ][TLS_SW  ].poll		= tls_sk_poll;
 	ops[TLS_SW  ][TLS_SW  ].read_sock	= tls_sw_read_sock;
+	ops[TLS_SW  ][TLS_SW  ].read_sock_rectype	= tls_sw_read_sock_rectype;
 
+	/* TLS_HW (device offload) RX entries inherit
+	 * read_sock{,_rectype} from SW via the struct copies below.
+	 */
 #ifdef CONFIG_TLS_DEVICE
 	ops[TLS_HW  ][TLS_BASE] = ops[TLS_BASE][TLS_BASE];
 
diff --git a/net/tls/tls_sw.c b/net/tls/tls_sw.c
index 087950ca639c..af347b5b17fa 100644
--- a/net/tls/tls_sw.c
+++ b/net/tls/tls_sw.c
@@ -2054,8 +2054,9 @@ ssize_t tls_sw_splice_read(struct socket *sock,  loff_t *ppos,
  */
 #define TLS_RX_NODATA_LIMIT 16
 
-int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
-		     sk_read_actor_t read_actor)
+static int __tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
+			      sk_read_actor_t read_actor,
+			      sk_read_rectype_actor_t rectype_actor)
 {
 	struct tls_context *tls_ctx = tls_get_ctx(sk);
 	struct tls_sw_context_rx *ctx = tls_sw_ctx_rx(tls_ctx);
@@ -2115,10 +2116,27 @@ int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
 			tls_rx_rec_done(ctx);
 		}
 
-		/* read_sock does not support reading control messages */
+		/* Control records (alerts, handshake) reach a consumer
+		 * only through rectype_actor; without one, read_sock
+		 * rejects them.
+		 */
 		if (tlm->control != TLS_RECORD_TYPE_DATA) {
-			err = -EINVAL;
-			goto read_sock_requeue;
+			if (!rectype_actor) {
+				err = -EINVAL;
+				goto read_sock_requeue;
+			}
+			err = rectype_actor(desc, skb, rxm->offset,
+					 rxm->full_len,
+					 tlm->control);
+			if (err < 0)
+				goto read_sock_requeue;
+			err = 0;
+			/* rectype_actor consumes the whole record; no partial path */
+			consume_skb(skb);
+			skb = NULL;
+			if (++nodata_count >= TLS_RX_NODATA_LIMIT)
+				break;
+			continue;
 		}
 
 		/* An empty data record (legal in TLS 1.3) gives a zero
@@ -2164,6 +2182,19 @@ int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
 	goto read_sock_end;
 }
 
+int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
+		     sk_read_actor_t read_actor)
+{
+	return __tls_sw_read_sock(sk, desc, read_actor, NULL);
+}
+
+int tls_sw_read_sock_rectype(struct sock *sk, read_descriptor_t *desc,
+			     sk_read_actor_t read_actor,
+			     sk_read_rectype_actor_t rectype_actor)
+{
+	return __tls_sw_read_sock(sk, desc, read_actor, rectype_actor);
+}
+
 bool tls_sw_sock_is_readable(struct sock *sk)
 {
 	struct tls_context *tls_ctx = tls_get_ctx(sk);

-- 
2.54.0

