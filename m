Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 997F036D9EB;
	Fri, 21 Aug 2026 17:22:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787332976; cv=none; b=bgKqTGYuOqIKfyMIXS794R9EGDZxOT+gnZJ/uzc2QB23JoI0uCcZcBWzKK807HWrGf1sqaUx1fo0NJO6z2VyRoxLmlPFiXGUOtakql8qYsgpaG3Chr5n7JlM5ZjctKdkFT0KzTj4XW887HFNxZbr4iEB2TDL4b9Lpu/AzBT9nyk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787332976; c=relaxed/simple;
	bh=SCwqRc0qRJ2Sgj77Vgd5bar2mfqiR93bIqyXfkNahgo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=X534EzvlAhzbzPrFvYNscEPQ1Wgn6mog3yHhTya3jOoJMsmH6zWtGf9Kza4pZuf1hY7uTXXcbLiQCsBA1LaseNVkGHCzL6eTuBByNTauoz9EXQiz9EL+hIAB1mdytDJhEdtAEA871f4FMQo7n+p/h5URPXm/yomyrm27jGTCk+M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jA4VOGRn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jA4VOGRn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3EDD41F00A3D;
	Fri, 21 Aug 2026 17:22:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787332974;
	bh=Fml9jSaFQnrLG6ZxBnBAl3H/afGjzwGmvTfnVCrWV3w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jA4VOGRnyVXE5K0iIOw97B5oIZgIVL+9j4oF9o6cSJtns9oJ5sYinjcb5HzFOYna/
	 AIzzIlbZmr9ooCpt0Fci4ELFcTcXLUWhAgHOIahkNI05chfYc8DS/UA9CwASvAxMev
	 N1yltLyosPzpWVXVmi7IlArMTmC2mU46nLco0+9VQ4jgMpJwawYQSUEjeGB3BnfJ0s
	 LEl5hcjanpPHKZ5IhskWXc2fvUL2DN/Ul9l5qyjMhNdawELltkIwT/tpWB9taiGpTc
	 zFj3UBH0QgkdX1qN9u0Uyhlif+gf6jwheZv8zFOshnOZVZtlptbQkgCdBYfV5SjuOP
	 7OQZmZ1rWVlcA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 21 Aug 2026 13:22:39 -0400
Subject: [PATCH 1/5] SUNRPC: Separate the TLS control-record receive from
 its policy
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260821-tls-read-sock-2-v1-1-7ffce164eb45@kernel.org>
References: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
In-Reply-To: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6586; i=cel@kernel.org;
 h=from:subject:message-id; bh=SCwqRc0qRJ2Sgj77Vgd5bar2mfqiR93bIqyXfkNahgo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqiIlrfBxZf7W7YjIu/oodG/jY9VUvd7ynYejpR
 c7C+P7wvEqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoiJawAKCRAzarMzb2Z/
 l7rLEAC+3Qh46bYjhE7BZ31sIowLuon8y6ypXhILD0B34xGKNrBFmp/9Nw60UKv+ghQoGw229px
 QDEklfbrkYUn1S37COe6Hdl1+9fb2YaMJSYLYXVPQ47BIeywWDS+YtjlRgtYbG1hV1a/uNz2yt+
 SVA9AHcWiaXYEMqXTtkzVAI4N/RWvpywnT0vuu0okEvl0S/ROG9+b/LczP1gvNNejjytL5qfYzJ
 LOHTBJXb4ZRHW4FycdpeoOofEcrC99riF/kYYCGvZvT9ih/vbxDkcFucMJaUeZYGj7Z5C9qu2Aq
 fAGtYg41uSraZszgNeIqZDyoI+o/+8z+0ToCYLRmUBfDb7A6ItCF7hON7G85XrBxY+9gxdU9FAA
 XKkCL1/hg4+bWNy3qbE/Cx9LOlGJh2prInWRYSuX1GFp04CI+yj6reTwTxCqlPaOh4F8oJrgU9+
 eqaey4Tjz+3IPwRUAeP4QSw2sU6kPJ9QFZEph1H9G7SNl7wSwE8NA5urtHn0wwzhhLB5h61XArw
 BJbHYxo7V/hxJAXSOuNV1s2aIsk0JyV64QytdqlqcETVn0ySDow6CWcpvEdYJHpmHsIZCgSseag
 Fp3GBcg3DMdHaDXug+fhtBQcBi942DWkXLXwB97DgCW7Zr3AIwHrCTkoLR7tNts2lR+xZzCejC1
 9BcYe0LV2TI+jaQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sock_recv_cmsg() receives the record at the head of the kTLS
receive queue and decides what its content type means for the
transport. The receive and the decision are one step, so a caller
cannot learn a record's type without also acting on it. A later
caller classifies the head of the queue with MSG_PEEK before it
decides whether to consume the record. It needs the receive without
the decision.

Move the receive into svc_tcp_recv_cmsg(), which takes the recvmsg()
flags and reports the octet count, the record type, and the message
flags. The alert policy stays in svc_tcp_sock_recv_cmsg(), the
helper's only caller in this patch.

The zeroed control buffer replaces the msg_controllen check. An
unfilled buffer reports record type zero, so a positive octet count
with no record type now returns -EBADMSG instead of a count. The
alert parse runs on a second msghdr over the alert buffer, so the
copy and the parse share no iterator state. The rewind that commit
bee47cb026e7 ("sunrpc: fix handling of server side tls alerts")
added by hand is no longer needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 144 ++++++++++++++++++++++-----------------------------
 1 file changed, 63 insertions(+), 81 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5a2d52284d75..b402923c40f1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -271,97 +271,79 @@ svc_tcp_sock_drain_record(struct socket *sock)
 	}
 }
 
-static int
-svc_tcp_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
-			  struct cmsghdr *cmsg, int ret)
-{
-	u8 content_type = tls_get_record_type(sock->sk, cmsg);
-	u8 level, description;
-
-	switch (content_type) {
-	case 0:
-		break;
-	case TLS_RECORD_TYPE_DATA:
-		/* TLS sets EOR at the end of each application data
-		 * record, even though there might be more frames
-		 * waiting to be decrypted.
-		 */
-		msg->msg_flags &= ~MSG_EOR;
-		break;
-	case TLS_RECORD_TYPE_ALERT:
-		tls_alert_recv(sock->sk, msg, &level, &description);
-		/* RFC 8446 Section 6: every alert but a closure alert is
-		 * an error alert.
-		 */
-		switch (description) {
-		case TLS_ALERT_DESC_CLOSE_NOTIFY:
-		case TLS_ALERT_DESC_USER_CANCELED:
-			ret = -EAGAIN;
-			break;
-		default:
-			ret = -ENOTCONN;
-		}
-		break;
-	default:
-		/* discard this record type */
-		ret = -EAGAIN;
-	}
-	return ret;
-}
-
-static int
-svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
+static int svc_tcp_recv_cmsg(struct socket *sock, int flags,
+			     struct kvec *payload, u8 *type,
+			     unsigned int *msg_flags)
 {
 	union {
 		struct cmsghdr	cmsg;
 		u8		buf[CMSG_SPACE(sizeof(u8))];
-	} u;
-	u8 alert[2];
-	struct kvec alert_kvec = {
-		.iov_base = alert,
-		.iov_len = sizeof(alert),
-	};
+	} u = {};
 	struct msghdr msg = {
-		.msg_flags = *msg_flags,
-		.msg_control = &u,
-		.msg_controllen = sizeof(u),
+		.msg_control	= &u,
+		.msg_controllen	= sizeof(u),
 	};
 	int ret;
 
-	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
-		      alert_kvec.iov_len);
-	ret = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	/* put_cmsg() shrinks msg_controllen, so a short one means
-	 * kTLS filled in u.cmsg.
-	 */
-	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
-		u8 content_type = tls_get_record_type(sock->sk, &u.cmsg);
-
-		/* Returning the count would credit the RPC stream with
-		 * octets that never reached the caller's buffer.
-		 */
-		if (content_type != TLS_RECORD_TYPE_ALERT) {
-			/* An application data record carries RPC payload.
-			 * Draining one breaks RPC fragment framing.
-			 */
-			if (content_type != TLS_RECORD_TYPE_DATA &&
-			    !(msg.msg_flags & MSG_EOR))
-				svc_tcp_sock_drain_record(sock);
-			return -EAGAIN;
-		}
-		/* An Alert record carries exactly one two-octet message
-		 * (RFC 8446 Section 5.1). alert_kvec caps the receive at two,
-		 * so a longer record produces the same count. MSG_EOR appears
-		 * only once kTLS has drained the whole record.
-		 */
-		if (ret != sizeof(alert) || !(msg.msg_flags & MSG_EOR))
-			return -EBADMSG;
-		iov_iter_revert(&msg.msg_iter, ret);
-		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
-	}
+	iov_iter_kvec(&msg.msg_iter, ITER_DEST, payload, 1, payload->iov_len);
+	ret = sock_recvmsg(sock, &msg, flags);
+	if (ret < 0)
+		return ret;
+	*msg_flags = msg.msg_flags;
+	*type = tls_get_record_type(sock->sk, &u.cmsg);
+	if (!*type && ret)
+		return -EBADMSG;
 	return ret;
 }
 
+static int
+svc_tcp_sock_recv_cmsg(struct socket *sock)
+{
+	u8 alert[2], type, level, description;
+	struct kvec recv_kvec = {
+		.iov_base	= alert,
+		.iov_len	= sizeof(alert),
+	};
+	unsigned int msg_flags;
+	struct msghdr msg = {};
+	int ret;
+
+	ret = svc_tcp_recv_cmsg(sock, MSG_DONTWAIT, &recv_kvec, &type,
+				&msg_flags);
+	if (ret < 0 || !type)
+		return ret;
+	if (type != TLS_RECORD_TYPE_ALERT) {
+		/* An application data record carries RPC payload.
+		 * Draining one breaks RPC fragment framing.
+		 */
+		if (type != TLS_RECORD_TYPE_DATA && !(msg_flags & MSG_EOR))
+			svc_tcp_sock_drain_record(sock);
+		return -EAGAIN;
+	}
+	/* An Alert record carries exactly one two-octet message (RFC
+	 * 8446 Section 5.1). recv_kvec caps the receive at two, so a
+	 * longer record produces the same count. MSG_EOR appears only
+	 * once kTLS has drained the whole record.
+	 */
+	if (ret != sizeof(alert) || !(msg_flags & MSG_EOR))
+		return -EBADMSG;
+
+	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &recv_kvec, 1,
+		      recv_kvec.iov_len);
+	tls_alert_recv(sock->sk, &msg, &level, &description);
+
+	/* RFC 8446 Section 6: every alert but a closure alert is
+	 * an error alert.
+	 */
+	switch (description) {
+	case TLS_ALERT_DESC_CLOSE_NOTIFY:
+	case TLS_ALERT_DESC_USER_CANCELED:
+		return -EAGAIN;
+	default:
+		return -ENOTCONN;
+	}
+}
+
 static int
 svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
 {
@@ -372,7 +354,7 @@ svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
 	if (msg->msg_flags & MSG_CTRUNC) {
 		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
 		if (ret == 0 || ret == -EIO) {
-			ret = svc_tcp_sock_recv_cmsg(sock, &msg->msg_flags);
+			ret = svc_tcp_sock_recv_cmsg(sock);
 			/* A control record delivers nothing to the caller,
 			 * and kTLS announces no data_ready for records it
 			 * already holds. Mark the transport ready so that

-- 
2.54.0

