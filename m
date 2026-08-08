Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59431348C4A;
	Sat,  8 Aug 2026 15:40:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203630; cv=none; b=lV50zBZqM/IYZJ2IzTBLk/m1Sf5IyMEuG8sQ6KqejH/i2IqwIgFIBzyQgg0m+0wLQXvRzPT8Fs15ZwWx9YdYwPs02OCKyHZUET5LKxxyoN9kNYkzM58jjNbMriClDzVQGYsNcCnL01ZiBG6LWxYC6rc/2PfVtlppajLBojuSC20=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203630; c=relaxed/simple;
	bh=tQymvd3cq9u4Xw7lCoMZNfOhQ71cBExEm43PoiqBKcM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=KkyBLaxF30SDFPR0hL/7ASAA2n123wG3NauV6nMUF3zBKZbG4EHp3+xnM6kQ1PIKicgBIexpOvMv+l9wBy3fc3tBIbE0GQ2lBzGhckQZd92mj7tuV7vntDYoC0wGh4odhAsxKRRBxA9VVh342dtL4+cWSyfaV4/dUCptfWN6Bkw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mv42LsHN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mv42LsHN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6AB421F00A3F;
	Sat,  8 Aug 2026 15:40:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203627;
	bh=bdMS28E674svxUoP4VoVM0nGWgrI+E3JONo+rrgpu/g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mv42LsHNlwcwcE6UdT5LqX5g3i5qEyWpu8iqZJvlG1ddyF4iCQ/2WM3aAiigueiLp
	 eC9134dSUREXvL79s+oIehnFfhbnuzw5oeDQ5gWq7uNexhDrs/2hQX49w5IaRCJPXI
	 T5fnCigPYyhhNoJT87xB9gniVVCsd9Damlod9Hqa+6pLQCRJbwwPZl2M6mkAEEJkVG
	 wST+Rs2LNmR/5XBnTjYLUcK6pSnhpGQFH4sHIGlpSVrAQUUjrlMeb6xxGw2pDl5y7z
	 18ycdSBJnL51VzwHbqOeiXZAB38CVS+i7jIEUNfj1PWssVmqJjwbr78Xek1Jvc93kY
	 a4pZLLdg5JYRg==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 08 Aug 2026 11:40:14 -0400
Subject: [PATCH v3 6/7] SUNRPC: treat every client-side TLS error alert as
 fatal
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260808-svcsock-cmsg-fixes-v3-6-62d9a631c880@kernel.org>
References: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
In-Reply-To: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1810; i=cel@kernel.org;
 h=from:subject:message-id; bh=tQymvd3cq9u4Xw7lCoMZNfOhQ71cBExEm43PoiqBKcM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03kOTFwGhqdoxYTMIQ9wDIjSvQaeqTlDMR+L
 Gmn1g8uuP2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN5AAKCRAzarMzb2Z/
 l9xZEACovd5nTjBNxPU0Fzt6aDJulBbCa3GB1OYwMXVSj6pnbPPAgvs4sHZhlKqZt48nXA5ZPjt
 fzmDkxVHyeAIKtPTm9W/3t6zMrbUMQouz4rftFUxEs/uDGCX5sAWAzxP5Jf4XnLpfWPEruuHJJP
 +tevwC0XB9B9xLyrDy9NOz/wKYT+07QprWmAPZ2rYD7YU7Z7OJryes4hXtt0+VRRIul7moVjKhM
 /YXu6KQg0rvIEBDSAhdtQGk1q/rcV5ngnjvCPY5zxB/KJgvanw2EaLQ/JzKDjZgeik64qF33Zc/
 SYx82kHN+WCKIn/MlKXvK/esmNUpNg8nPWPKT3g09PnVkL5bgEuv5pg5qn2b7oUSCJgTwHrq5tU
 UUNH+REjmKqcZThPmbtSZqpVk4N1GSI1ttpN4oc5/uxKp6UHaPQT68AMJoeAtrvTq/wMs4bMHqH
 A6qk7zlTp4X+AAdUdBm6D8iAlg1+ZdmoCrVjUccu96xUb9xbI4CtVvYyXh7GlRm57sLXlLAkZj4
 y2f2dQhC0NLBFMhjz8fCAIHCguiqZdYUNJAmnoUD9E1jkEux4hZpCOdm6m/uf/28sWYoAF2ulrd
 7FCTcqN81KWXSIyYn6uBOnT+h74xN+Bfw+XNFieM296lgFwpNeaUEkIkZm8y18mli+or1q/GImt
 O07YmYNkgOekpOQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xs_sock_process_cmsg() decides whether an alert ends the session by
reading the alert's level octet. RFC 8446 Section 6 retired that
field. The severity is implicit in the description, and a receiver
treats every alert listed in Section 6.2 as an error alert
"regardless of the AlertLevel in the message". A peer that aborts
with unexpected_message but leaves the legacy octet set to warning
makes the client return -EAGAIN. xs_stream_data_receive() wakes no
pending task for that error, so RPC Calls queued on a dead TLS
session wait for their timeouts to expire.

Decide from the alert description instead. close_notify and
user_canceled are the closure alerts (RFC 8446 Section 6.1). Every
other description ends the session, including one this kernel does
not recognize.

Fixes: 39067dda1d86 ("SUNRPC: Use new helpers to handle TLS Alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtsock.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8e9d47d77e5b..5527f7f8a185 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -375,8 +375,18 @@ xs_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
 		break;
 	case TLS_RECORD_TYPE_ALERT:
 		tls_alert_recv(sock->sk, msg, &level, &description);
-		ret = (level == TLS_ALERT_LEVEL_FATAL) ?
-			-EACCES : -EAGAIN;
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
+		}
 		break;
 	default:
 		/* discard this record type */

-- 
2.54.0

