Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B9B544D2ECE;
	Thu,  6 Aug 2026 20:20:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047638; cv=none; b=cTmjLozNdzMPGq9fgjMn9GSVwvEpAzCVH1eASa774NeGH+qxQ85PYyHpKK7WAl4uVG0HuewKQkUK7WgiP2FWval+uwiadV674uamuzImEhYN9GxqHGvEa4eIZ/VEFGwNQDiGR1TSW3LayzopwuH++8AxpRyc3lAvByM8q3I5snc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047638; c=relaxed/simple;
	bh=3oVNotWFtrAD9Xeka2+GhQHWAcGZfaj/Rdoma6xNEvE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ndCRSZH28gCI5UHtDIwKU+4Y7FblHtCCuqIYVseUCan3x6MCC/RfpAouwIaAqF578y+bYV/KoaQ+eIy2Hgcz9exMT6b/nXn5roq0vMoxZHUusT/7Hvs6PF/2SOGPt2DDQBOxEY3I3ndGkXiPbSimDOPgPwlKyNvMzEjhFo5XMdk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=i0g9+Ruc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="i0g9+Ruc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D9FE91F000E9;
	Thu,  6 Aug 2026 20:20:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047637;
	bh=6MFLVkziX3hANiicO2h9CJB3xgQAuAMAQlVIbnpFQHw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=i0g9+RucDZTvUwMkUswfR9vQTyA3VFbj71vJ8JZ0+MTtnU9VAAbIIiRj5JqU8EMeJ
	 tCaUxyYd9OovLZYvPNHF543MsLRIMvgcwEX18joOVpJIaqwpQcN2X/3+xLNLNLsXVK
	 uAswRY8xHu5OIWwozTZeB3tsus5s7D9jcGHL014VVbRk2BGlrkse2qVIDqbv4CVgVg
	 kVRDvfOjxdI9hViZE4GCZHZmwrDr29F1uVJpkUHxsmCUEaxBiJgISnxkIPmbgmNl1D
	 5PhO2XjoxAEp7sCRq+qHxAntxFaW+kB89a3aBQrbNudUpZYk5WNc4g4jraFP6hICd+
	 z3Uba4QumhE7g==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:23 -0400
Subject: [PATCH v2 8/8] SUNRPC: fold xs_sock_process_cmsg() into its only
 caller
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-8-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4767; i=cel@kernel.org;
 h=from:subject:message-id; bh=3oVNotWFtrAD9Xeka2+GhQHWAcGZfaj/Rdoma6xNEvE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyMAeb1CO1BmDkCd0zNB/0ICk7K+BVSrEYW1
 WFKzVbeO8mJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsjAAKCRAzarMzb2Z/
 lxrUD/40+nIZ39IOA62BGMCG9HFBCEVpmnEJgYttlr5/Y7WkKcFX8J4OkjyvGzrGUEvTqU28pnx
 4hFC9KoICnxGYF2geKvsDx+EmzMGF36yvyJi5vCfZ/AV+2lGLKB3MG8L4OdL4nivc9U5bX4+zQE
 yoHivAGudHdBnLOSpIkWoocJpwXXPZBxAbsAbkHTh15norJHSstPeX92ii6omybLmZdCPrI1TKa
 dqg+prHRpA0kj0zORiWEozIdpJq2S8p60YAw2YpycXaWFLAd/Psno4GNx6GVNgTp7DQLfmg7X38
 4k+Cp4uYH6VuJh3e5rymd5xuEr+7snf/kc/UlKAEWFlwFdJ35QRGsU2j81kuIAAzkA2Md1gyZT1
 ZDSjAl1iAIBP1y6UXUJzpOEj1ZpjwAVRfuvE8gjaILemkO3hm9QfNCRRZpLoCb5xUCQwyI9iTPj
 LArMXwGdgJ+jXigyO1KN7snDefULas4Ez4inE8yD61xcj+XO5r+B8/akV3KDYMP8AJH7e0ZDcvj
 w8s6Muu34otZZpR2UOzHu5YC2DCi2bwj15TZg3iJNxJEdtpOfDyBWRJkJ8C7l0inc9H7j73WoFH
 154UAUpeKvKqkAVbFsfRqasnCXi+4VjlOXGrS60VnQbkOGdJPOPUPI0Apq6sxDvGQcsmMNZpJhQ
 Yx2x58PUvyq3rig==
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

