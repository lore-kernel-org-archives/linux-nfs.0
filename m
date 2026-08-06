Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2E5D3EC6B5;
	Thu,  6 Aug 2026 20:20:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047635; cv=none; b=kI8PuXQA+kN+EQBFup9DruDtujSeGlDIq2XONANsRDhJxA8uJiZ2jVtULqNBEcthoD0fXPHf9PYDi6ZCNE0I/W/eK3qzysnBLm9OYekF6PjAfiEAXW4zpz2xCgMymCOk4sl0A81NO1pScbeNmZ8JYEU1apPCfWn6OiFO120W6qA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047635; c=relaxed/simple;
	bh=18R077Fb0PLh/21ujxdLOHZVHtEt7WFMeeaKRLnWZ9M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=S6X18LMWE4hr59ySKWVL+i/7GRnXgKWqxqgT4YQqTRYlS7INKr6f25RhzXicXJijIJPujdDmYyoLx3ojrS9Jj4oORhr0p4AONOlsCdXAxdRQ4UgJHpHbyG9KXk+fQwNWeEwQZXzy9kRucq51ZiX8Y6mHeQgKvKzHCB4mH/7wxn8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=djgfVZ9g; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="djgfVZ9g"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C367B1F00A3A;
	Thu,  6 Aug 2026 20:20:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047634;
	bh=ZK366ZyGcfxFMaS+2BWGwlo+nh8zSB9yMepdIN1C8O8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=djgfVZ9gbCfKAIOYawPxz+i4Pb8I4Lg+Nl1jnOrv9mjEXU3GfCRHTl+6G3WTf1Tx6
	 CW0n26Rj3m+f6fulGZZWd1rYFp8M861y4tzLUrvWDFcOmUsPMcfcbNbX0lix5lID2c
	 b/W8aV3+K6JAx+syf7vhPiogA0gJBbr0fx7XBNLoMw9rc7k2wLUD/1bhQnzBEYQUa5
	 Eb4jj67Apw+bak6hyLMkd0yEny4IfIUcMAxi51vuYtPSxYP+BmSmnwu45yGLW7lPRu
	 ok4Xagi3RZRwFkPP1sASGe6fdBYXC7OSF72eI3qZ/iiQaRpNtWgrYd6Ku6Or+LD1oI
	 IdrCn83PLq5HA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:20 -0400
Subject: [PATCH v2 5/8] SUNRPC: fold svc_tcp_sock_process_cmsg() into its
 only caller
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-5-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3682; i=cel@kernel.org;
 h=from:subject:message-id; bh=18R077Fb0PLh/21ujxdLOHZVHtEt7WFMeeaKRLnWZ9M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyMHYGBeW1AlzCyTM/L9W4Y1fqlOyPZ/R2ZQ
 nLJAo8MvteJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsjAAKCRAzarMzb2Z/
 l7e5D/0QmQxOEIj5KimONxHHhJDTe8KI5VjTcRRzRR0PfCHeiK6VacuV6bWZ8jaIhSKBf3RTt6q
 qv/2m73JdPVzI0ykjxIP6iJy1iHHdQNJbgxAPWl12Y4bhtVGSHlQ+9Blg/W4OnIvi+m4lejecBz
 gHJRbteB3h6LhjDDo0NLhxJTotca8NRiBCXfaGPWKTtq4F6SVo2UGVKEI9vCmdk0aHCDWmlYHW1
 uAMjAejsWWA7CpIfvtt2jrHWJPk9Cy+JCpHNkduyPDtOr/ifdNORBVtVHr6/L6pV56uovgXAJiJ
 W5Uc0h/XUKoDnMrga6l17Pi6Y4S7YbQ6WFl1tx4JqfmY57v5h0GmsBDYPiXTecnoAjZ4TWJNFZC
 kWu+tkhXPZbzF3/ITA56gmSQ1mgmb2k/Dgv6+OqKR83pd8snAnTFT2ttMP2Rt5EXaKSvFOmjaVK
 09184tQX+UdTl6bTHyqW/k9EOwUhdD+xYAg5wEn9eorLuVT3tkXJDEBcPQLZYOkJ4+EtjyrjCgI
 F5Lb4LjcsPj7COTXjCF+stu7O96FbJf4PRNog/+ekTMErzZ9IXwwQKl4nViDnw83DVgPunqA/Z+
 djQ6UlTB5ihVGBaKu+3F7dXvFwTIrmN8l8ejtXxTIddD7KlBh6OB7osrHghTJpfG87+bEqYee1q
 8ndmBFk888StURA==
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
index 6fee54f4290c..99a159afd3df 100644
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

