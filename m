Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8A6136215E;
	Sat,  8 Aug 2026 15:40:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203631; cv=none; b=GeU+hDtS6f3TH8fp03WYBANrqS6i1lAss646LfUsjh9lKxUM3OgQUTPjR6K7xaa3hCkCSYxPaG+YpL3mbJolhOn2JUouyk66vQi1K52fLDdzG6C7MXLJmmkHKLV8kw1GpUWgyGzMzqlG1Gb9GPrIOKd2Y2ccuGGznpckdceF93c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203631; c=relaxed/simple;
	bh=3oVNotWFtrAD9Xeka2+GhQHWAcGZfaj/Rdoma6xNEvE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=DxiwqdE1yxkjMcqChw88YizpXI19jvHrcpjoEPt7CnglGygqMobFai6xmWkrrenlM2A5A7KF0kSlD7FVuBp/kZmlYBKzMhbsr9zhO2WFsP0PdQfBIoK0SwsObmwLR+YOzQyiZPBasY66VejLPPb+8zYWwf1w6dUcFYBi3PBr4vc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lKrkwAn+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lKrkwAn+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 677471F00ACA;
	Sat,  8 Aug 2026 15:40:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203628;
	bh=6MFLVkziX3hANiicO2h9CJB3xgQAuAMAQlVIbnpFQHw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lKrkwAn+v/eyoe66azGN5UguUqvoQEgDMPyXi4tlJAyjM1DGB7QJk0MwEVB/VzBME
	 /Tu67vIcYNgwjBLH21XWRKB2sZ1r5pq8JikQ3bubeiW5I0YefN0ELDcZOsEvXQ50PB
	 Cr6Zs+/OSYPSnhvI13xbFPrMF/m7sL02EceGl0BxqDzCPMqvl5j5wBphNdpIrO0OCK
	 dHdOVicmyZc5VQtspBAlCzkZv/AQj9K+aDW2MDbFhhxdypKAvq0oA31GYHQim30yiU
	 YPDHDoyxPQKayukosGoA2l0ViGnKtDSLsQz0sP+ImC4Bp00FoMHFpGuzKkcAFn6X9q
	 Xo8Eg71wMv+0w==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 08 Aug 2026 11:40:15 -0400
Subject: [PATCH v3 7/7] SUNRPC: fold xs_sock_process_cmsg() into its only
 caller
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260808-svcsock-cmsg-fixes-v3-7-62d9a631c880@kernel.org>
References: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
In-Reply-To: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4767; i=cel@kernel.org;
 h=from:subject:message-id; bh=3oVNotWFtrAD9Xeka2+GhQHWAcGZfaj/Rdoma6xNEvE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03kDAcu0i7WYCBNzqppbvx92XV2KZAT/N04J
 Q3nkXNhupWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN5AAKCRAzarMzb2Z/
 l83gEACJFVJiWmgXsSM3xzXjw1idB+zOFZvxpAbYqvqi/GwJ3xpSvZZR0PPa5+N/Y8R64OC0jW8
 7tLPbBy/kCtJ8V7NRJxhZ/epusSH/431zZxxciFaz/uD8q2tbZQEgLt/tq6ZNd8Am/6uroe4lMT
 4pFkk6AJMflaI/2qF/86YY8ZtYAZ6n09mYR4YLE1rm6vPHjtXlFUGdvxZkv7XvfLqYBXXdpOPpp
 dvmeVWdyng2KiJ75yjh+vsp8k9oq57RAOc+bzAxN8OyhmuNvwHh1bLnBiHbeH90FDot/rlEAxXC
 kF7Q+OZw0TBb171J9QoGOYiirj8MbKU6RKIcJEGkT5mtD+AW2HRtQXi+eqvbWkhnpKbMvh4mUKe
 XmBMqiUcH97CdByZUp//sJHOTgNj1AYzFnAfj5c51+KXPzI8S7IBw6BKS0cZFc0Z4A9C7bw5bU3
 ybq/aBwpkOrev0jG7zfFJ+QIlIa3nPEH/Uziko5DTuHug9DXvQL2njugzkWXr6K8TC0P4UtOwgd
 2s+JMnx/tIaEghFcUYqKE/s/2Usq4EIjyvSARgYpK6JbTQ3bXyllqO/V1/AbkwqMfkaIZj6K38S
 gmD+lLpz2ku72Et2E+CWkXPKTUv4kNm5/popJIxRh/nBeF/iTHJB/hYL1EQdlwkwF+tU6HCAoul
 41AdylEd1rIwCHQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xs_sock_process_cmsg() switches on the TLS record type, and every arm
but TLS_RECORD_TYPE_ALERT returns the -EAGAIN its caller passed in.
The DATA arm clears MSG_EOR in the caller's msghdr, but
xs_sock_recvmsg() has already cleared that flag before the call.
Deriving the record type a second time inside the helper also fires
trace_tls_contenttype() twice for every alert.

Move the alert handling into xs_sock_recv_cmsg() and delete the
helper. Every other record type still returns -EAGAIN. The DATA arm's
account of MSG_EOR moves to xs_sock_recvmsg(), where the flag is
cleared.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtsock.c | 85 ++++++++++++++++++---------------------------------
 1 file changed, 30 insertions(+), 55 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5527f7f8a185..38dd75a23af7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -356,45 +356,6 @@ xs_alloc_sparse_pages(struct xdr_buf *buf, size_t want, gfp_t gfp)
 	return want;
 }
 
-static int
-xs_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
-		     unsigned int *msg_flags, struct cmsghdr *cmsg, int ret)
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
-		*msg_flags &= ~MSG_EOR;
-		break;
-	case TLS_RECORD_TYPE_ALERT:
-		tls_alert_recv(sock->sk, msg, &level, &description);
-		/* RFC 8446 Section 6: every alert but a closure alert is
-		 * an error alert, whatever the legacy AlertLevel octet
-		 * says.
-		 */
-		switch (description) {
-		case TLS_ALERT_DESC_CLOSE_NOTIFY:
-		case TLS_ALERT_DESC_USER_CANCELED:
-			ret = -EAGAIN;
-			break;
-		default:
-			ret = -EACCES;
-		}
-		break;
-	default:
-		/* discard this record type */
-		ret = -EAGAIN;
-	}
-	return ret;
-}
-
 static int
 xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
 {
@@ -412,6 +373,7 @@ xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
 		.msg_control = &u,
 		.msg_controllen = sizeof(u),
 	};
+	u8 level, description;
 	int ret;
 
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
@@ -421,23 +383,32 @@ xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
 	 * kTLS filled in u.cmsg.
 	 */
 	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
-		if (tls_get_record_type(sock->sk, &u.cmsg) ==
-		    TLS_RECORD_TYPE_ALERT) {
-			/* RFC 8446 Section 5.1 requires a record with an
-			 * Alert type to carry exactly one message. An alert
-			 * is two octets. tls_alert_recv() reads both without
-			 * checking the length. alert_kvec caps the count at
-			 * two, so a longer record fills it as well. kTLS
-			 * sets MSG_EOR only once the record has been
-			 * drained.
-			 */
-			if (ret != sizeof(alert) ||
-			    !(msg.msg_flags & MSG_EOR))
-				return -EACCES;
-			iov_iter_revert(&msg.msg_iter, ret);
+		if (tls_get_record_type(sock->sk, &u.cmsg) !=
+		    TLS_RECORD_TYPE_ALERT)
+			return -EAGAIN;
+		/* RFC 8446 Section 5.1: a record with an Alert type carries
+		 * exactly one message, and an alert is two octets.
+		 * tls_alert_recv() reads both without checking the length.
+		 * alert_kvec caps the count at two, so a longer record
+		 * fills it as well. kTLS sets MSG_EOR only once the
+		 * record has been drained.
+		 */
+		if (ret != sizeof(alert) || !(msg.msg_flags & MSG_EOR))
+			return -EACCES;
+		iov_iter_revert(&msg.msg_iter, ret);
+		tls_alert_recv(sock->sk, &msg, &level, &description);
+		/* RFC 8446 Section 6: every alert but a closure alert is
+		 * an error alert, whatever the legacy AlertLevel octet
+		 * says.
+		 */
+		switch (description) {
+		case TLS_ALERT_DESC_CLOSE_NOTIFY:
+		case TLS_ALERT_DESC_USER_CANCELED:
+			ret = -EAGAIN;
+			break;
+		default:
+			ret = -EACCES;
 		}
-		ret = xs_sock_process_cmsg(sock, &msg, msg_flags, &u.cmsg,
-					   -EAGAIN);
 	}
 	return ret;
 }
@@ -451,6 +422,10 @@ xs_sock_recvmsg(struct socket *sock, struct msghdr *msg, int flags, size_t seek)
 	ret = sock_recvmsg(sock, msg, flags);
 	/* Handle TLS inband control message lazily */
 	if (msg->msg_flags & MSG_CTRUNC) {
+		/* TLS sets EOR at the end of each application data
+		 * record, even though there might be more frames
+		 * waiting to be decrypted.
+		 */
 		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
 		if (ret == 0 || ret == -EIO)
 			ret = xs_sock_recv_cmsg(sock, &msg->msg_flags, flags);

-- 
2.54.0

