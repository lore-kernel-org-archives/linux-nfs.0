Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 458B134F49F;
	Wed,  5 Aug 2026 18:31:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954676; cv=none; b=aV+PBOkIklgOgoDuthqIawW2kuEkcmFIKqp0DaC4PJI4pNur1QHeGQiX2suE3rWBfn+Gho7gTHD7gn3DINkCc/sXEqfkLEVCWdCGAQtQGpTvJ0FmqKAkrJCqLj6j08+/0bb4oCGRvFGXOALw9M1vRr7Yb0njdg/crg3tLGhOZuQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954676; c=relaxed/simple;
	bh=04JO6kawVUHd+Sk2jXG9xyxYxcynTsIFSOSi5L4Mfg4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ncwh+RbppwzmI2uQq23sqVW2s0u7aeJ5qBv6oRVZqttvtd3orh8jvoBs6AYu6D+AtLKXan1ihszOC3iNmJ/7w8vg5WKdp4F8OMKrcXDo2nE4Iz7jEr4kZiMORpA0KmhK91xJtLFH1fbT8fjjLxOzPXr4OCq1FVzsgCrpnGoKVZU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=M+nnB5tO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="M+nnB5tO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 402491F00A3A;
	Wed,  5 Aug 2026 18:31:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954674;
	bh=ShQ7LPcNzNFiREA47lP6NbGHXa2c1RyGtL+pzTRXpJI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=M+nnB5tOX4ku08lcLJwyCDaQjZx/hgEgsvBQbqj/8zjrLONiJOblCjs5OMBZMCW0J
	 hT6r1yGgEJaNHOgWeYWVTN3jnHaBAagy5byBFjlTLmdgoh8nWUDvI/f4X9H0ZAwkWM
	 J4y6FMiRRM09eMNt132LEIlsYOS68c4TvdMLcK5rk3siTtkEOgkem3/Dym+MB6Shvi
	 Z5TVZhW2XZNp0tPFe2KVdOQrkdq+fqlUBi0hxuomGXZELr5jAxfoEF9qv1mVBSBh6G
	 PWIykSuPZRQXWo59yOOJSv1WPJ+nAA0U7TMV5mm2Q3hsGqu8AB8zvlZRNK46/RPZdH
	 TO+7tJQwrZYsQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:56 -0400
Subject: [PATCH 5/8] SUNRPC: fold svc_tcp_sock_process_cmsg() into its only
 caller
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-5-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3682; i=cel@kernel.org;
 h=from:subject:message-id; bh=04JO6kawVUHd+Sk2jXG9xyxYxcynTsIFSOSi5L4Mfg4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FrdKEXYO78SarmKOjo2jd+L0/rDCXadwd9j
 RygApydBZWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBawAKCRAzarMzb2Z/
 lzcoD/4icMh/UQSKLNIgBwGt5c+fENx7LTQxJRwWQIo+6L5dWt3t6nS+WjwEBumWy6G12+fd9Wh
 kdoyOWt/gTxwxVzZOAiNofQKMbb2QQ9dkaOyJEtDTEfPf34YXIy7yYXPqFfuypjVYvpCFs5A9WN
 IApAqBG+rDV4FXUSaNNZVpR5iQlAHLvZZ5z2zCO6ZxzXTKQjUTh09UyxVGOW5ylJtH+ga4JTHgw
 6y/F7/y4gRNqmzK6Y9p9miopIarXGM8No/iThm/reLD1+xyHqlIaw0YYLI3mmA7Lbh9lA4pNqXD
 DSMCyNwrrNBIJR7xG9wNoIV4xjuXt+ZwPDfviiE94U0n2es7alR6ttj3vmQJ8i8M0w1ZKwnR2Qo
 jYl0Sh0J1JqhAdmPddGI/qw6i6k9CRv0uysOm/OM0ph7E1g5eS2Z8CNLRx4GPGC+jMmsl9epE8c
 0HR8yZOkgrnXaUNLzyBFvEbwqJ9WAHs8U2jhsBUEmGdNAZhOcF0la7iArAMONgwzqZ03KIS71PR
 5TaC5kCBXPpbLLWQ9M1DxwTIy6RdnUdMTW8h+ZgjDRqwUVzRgbVLhjPIF6vYNob52UuU6/TuMwy
 amQqnPI6UN1bxzirV6f28ATiKuiu6Ge4cTjdnZmoiF2VlfnTuk6vVBXBdCOFqVmOV/bY/DCMEkW
 2f6RmJmFtRNVKuA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sock_process_cmsg() switches on the TLS record type.
svc_tcp_sock_recv_cmsg() now returns -EAGAIN for every record type
except an alert before it calls the helper. The case 0,
TLS_RECORD_TYPE_DATA, and default arms are unreachable. The DATA arm
is inert twice over. It clears MSG_EOR in the msghdr local to
svc_tcp_sock_recv_cmsg(), and that msghdr is discarded on return.
svc_tcp_sock_recvmsg() has already cleared the flag in the caller's
msghdr. Deriving the record type a second time inside the helper also
fires trace_tls_contenttype() twice for every alert.

Move the alert handling into svc_tcp_sock_recv_cmsg() and delete the
helper. The DATA arm's account of MSG_EOR moves to
svc_tcp_sock_recvmsg(), where the flag is now cleared.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 58 ++++++++++++++++------------------------------------
 1 file changed, 18 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d8e836e0832e..6ed136dff0a4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -271,45 +271,6 @@ svc_tcp_sock_drain_record(struct socket *sock)
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
-		 * an error alert, whatever the legacy AlertLevel octet
-		 * says.
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
 static int
 svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 {
@@ -327,6 +288,7 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 		.msg_control = &u,
 		.msg_controllen = sizeof(u),
 	};
+	u8 level, description;
 	int ret;
 
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
@@ -358,7 +320,19 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 		if (ret != sizeof(alert) || !(msg.msg_flags & MSG_EOR))
 			return -EBADMSG;
 		iov_iter_revert(&msg.msg_iter, ret);
-		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
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
+			ret = -ENOTCONN;
+		}
 	}
 	return ret;
 }
@@ -371,6 +345,10 @@ svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
 
 	ret = sock_recvmsg(sock, msg, MSG_DONTWAIT);
 	if (msg->msg_flags & MSG_CTRUNC) {
+		/* TLS sets EOR at the end of each application data
+		 * record, even though there might be more frames
+		 * waiting to be decrypted.
+		 */
 		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
 		if (ret == 0 || ret == -EIO) {
 			ret = svc_tcp_sock_recv_cmsg(sock, &msg->msg_flags);

-- 
2.54.0

