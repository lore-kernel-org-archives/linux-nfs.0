Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E37E73E556D;
	Thu,  6 Aug 2026 20:20:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047633; cv=none; b=GFVNAws0LygkJGyGrVSG6owmcFgNfoN1PDLYRQBcovkbPQDNrHuypdS99yGSYehCXGxZqpuTjyrNEVIR2ZGEnsYZJ2hGzhExptl8SFAw6cqqzQnsvjB9ziYjJehZBi/8/lUJLPvgN+ban+xQWZnbFOBFltE0xn0rQxeHF/g0AhQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047633; c=relaxed/simple;
	bh=GyHNxGJ2TYrjmLdSimLvDhMo/eaMFH4ZWHPgBaSPQ6M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=m1vl2YUfYcjo4FuKU5hOP5B+EtqfRGWBHGA8GSVOjB4RIjcDUF8sjGkeM91XD4a8Q62Ln9rOxmLTQ/IKa/hb++Hu3hvj9UUNo1rKiJkFsG5qV4pM+c2B4f+D+sCfB49s/1IE128qM16yPLrjfTxQlazpWRzdmpx3FtP08pSXfOI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jgNHKEqp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jgNHKEqp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BB8B91F00ACA;
	Thu,  6 Aug 2026 20:20:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047631;
	bh=w+NCa01ITHOmw1HDAJzvUK0Uh/4EpjXtte7F683u4DY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jgNHKEqpqQMBiVmeaDTydlCLOIirA9lemLOE6SO9BQCPY/4xawvbwkzbaD3AWtxn4
	 uh31YpmmqJklh4NgspAOQi6ChN4yILQ2bI+ekKZL/iPv70EzWwCbPqSOkUC7mBr+sQ
	 qBfISThxWaSax1KUcvzUyyiM7kGumGUQewsom+ucgpV5oA+7MvZFMo6TLAPiONu3ir
	 4M6qZ0073DYSt5ZjQXTGaHUmLDYUfocZF9KdUpXoEgWc8mcQJg1+FDki9e2glI74QD
	 NmEEK4U57YE1o80TzbEfEeYsNdNNUTora0OtfYBQzWI1lLA5MDhJbJvLl/KXLCsDm+
	 ixzU7vMXBGBng==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:17 -0400
Subject: [PATCH v2 2/8] SUNRPC: reject a TLS alert record that is not two
 octets
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-2-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2436; i=cel@kernel.org;
 h=from:subject:message-id; bh=GyHNxGJ2TYrjmLdSimLvDhMo/eaMFH4ZWHPgBaSPQ6M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyLjk1UrF1JNSUEm5dvMsSP7FKbpjwFFspLu
 r4MNdR58JiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsiwAKCRAzarMzb2Z/
 l6EsD/9hsRDxqhR/9/Be3k7HuRcmGiIVvKWeJncwzelG38zknXKzWKLb9cMirMzYDx7MLyJ9YWW
 N2RJPytBzM2HaoIsiTpxj/DHSVXMyUmUa7rcwHlWD7hpjxoIK4t9iDsLBFAOB5+JXXe1CFVeKw7
 b36wfoH5/ZDeap77qFfxretgSxF+bUCIShMxGcDAmu6t641vgomkXCnMNAYoHJXDQH2DtC1dBfU
 LO+aho3JlQH8nUdTudgXXuZc+CKdLSpCnUFjLO5sIr1ZGSaoL1TFXj+jT0rnse7MATGiLTcJsGr
 tS2USREzkMtijL6GgZhu9GRUYqd4cvdhW3xxyXPjXSCKXCUU35IGYTtY3g6wAUPI/6kIlqy+QMr
 6mvt/o5q+esulY6yUipNE1D5pKwK7Vm35DZ9kT6nZiRTLDcDLOBDijVwMjsukqaY6VadDHK/NNj
 zYLm+d9NZQRU6kdFYfP0WqMKvL/gKn8OsLBMl3vJ4JYeGNNrf5tsoAVcLfPBE0eKDhR+ZLdYA6z
 k5xRezThYYffZH7L6ynmwLI7GWwiuxJW7UHIgKICfgN8RYOTQzMcsS+Do6lQZ1QsuGA0cqy3088
 pIZb23j3ccF0gz9TpWjrhh7gIYhcGiOeaMGAvZrg+rRmxqZLDkKqBuk1QT9A+IMjXSXXFgi9D53
 oEBxl1BZRT7ix4w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

tls_alert_recv() reads two octets from the kvec it is handed and does
not check the length (net/handshake/alert.c). svc_tcp_sock_recv_cmsg()
calls it for any positive receive, and the alert[] buffer it supplies
carries no initializer. A one-octet alert body leaves the description
read from uninitialized stack and reported through
trace_tls_alert_recv().

The peer controls that length. Neither tls_rx_msg_size() nor
tls_rx_one_record() enforces the two-octet Alert payload. A TLS 1.3
record carrying only the inner content-type octet decrypts to a
zero-length payload. RFC 8446 Section 5.1 requires a record with an
Alert type to carry exactly one message, so any other length is
malformed.

Require exactly two octets before parsing and return -EBADMSG
otherwise. That closes the transport rather than acting on a partly
uninitialized alert. Gate the path on a control message rather than a
positive count so that a zero-length record reaches the check.

Fixes: bee47cb026e7 ("sunrpc: fix handling of server side tls alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8e1009302e3b..2e5107a1fb89 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -289,13 +289,23 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
 		      alert_kvec.iov_len);
 	ret = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	if (ret > 0) {
+	/* put_cmsg() shrinks msg_controllen, so a short one means
+	 * kTLS filled in u.cmsg.
+	 */
+	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
 		/* Returning the count would credit the RPC stream with
 		 * octets that never reached the caller's buffer.
 		 */
 		if (tls_get_record_type(sock->sk, &u.cmsg) !=
 		    TLS_RECORD_TYPE_ALERT)
 			return -EAGAIN;
+		/* An Alert record carries exactly one two-octet message
+		 * (RFC 8446 Section 5.1). alert_kvec caps the receive at two,
+		 * so a longer record produces the same count. MSG_EOR appears
+		 * only once kTLS has drained the whole record.
+		 */
+		if (ret != sizeof(alert) || !(msg.msg_flags & MSG_EOR))
+			return -EBADMSG;
 		iov_iter_revert(&msg.msg_iter, ret);
 		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
 	}

-- 
2.54.0

