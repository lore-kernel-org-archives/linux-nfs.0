Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DD063D47CE;
	Wed,  5 Aug 2026 18:31:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954678; cv=none; b=MtpK1RbhJUunkty+1A5UouIUwEQ+MWZMikb3OcAijvp3Z3MbCkQVie5o2xiTdTFY0RnpwlBPRjpL13NLm2K5MYNTu/Gy4Mvr8tJdVdK5PRuIvQkCkR+6RTZ4rNrxAHJqrMzTRW4/0bI+d35HfpbEwBSs4mX099DOI0crxcERfMQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954678; c=relaxed/simple;
	bh=DTDimTxSglw/bEOxgIjiyiYmvsc5c5nxRWBRc916CTU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=OfdnJTjyBgSDvGbnJnx6VNTwidqxvqEk5dAMEqSM+O75C/ihZpt7mR2dpqnhS50134KdlmFoqM0dKic3zOkhSEF0U0aBJLjDq42xy7cxzXdV7Ova5hDVNs68eGRecKRraeNeada8OD2fOXGej6uFJoj5drQBSBBDtpPAy0c9wB8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dioD57bj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dioD57bj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 415851F00A3E;
	Wed,  5 Aug 2026 18:31:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954675;
	bh=IbmDIp0ec2T0hVVNsCTQvaF2VC9+W2AmR2sPfx02EO0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dioD57bjxsoHO6x5VN6KGu0HM87tpIstXYXsOqsr++rSSDoXHnohnV7H9hhIHoMFA
	 rGCpXKrBe/TJv+vuF7E2Dot9HV5RSbs+UN+2wH+oNjJpui6jyXcDT4nfrY4hnnVole
	 xDnyYbODmS46OjyP8kfpkT5Vp4ZyKgD0Eiosmt7O7YiueGhLue7/druvbTRM/WoE2g
	 xblQE63q3UMA35to0uzDr7vofNhrHZSj14Kyw9taRY65Rh74+78RApOJWtfYIJSCx8
	 AVYllX4q9sMcgaTSxbS/U9lTMlfmc9WeenrgAaVJYtPemqISTnV/KgAnmGzsZuvRG2
	 PNKD6qxW7lBbw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:57 -0400
Subject: [PATCH 6/8] SUNRPC: treat every client-side TLS error alert as
 fatal
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-6-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1810; i=cel@kernel.org;
 h=from:subject:message-id; bh=DTDimTxSglw/bEOxgIjiyiYmvsc5c5nxRWBRc916CTU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FrFJ5Hn8k8V7t92mMxIvHrAC9lUXHvbQsAx
 0cU00evkMOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBawAKCRAzarMzb2Z/
 lz0EEACp8Qn3fmKXm4jg2aSo+9HbcalF4u1ohciLsjI8vO0zVoVpVQvHcqDHBK/V763GSYUmSm7
 9Zk1MUYMQer+VQb+ySgFMK8vQ79oIyFQQ8PCzgOLCQiPvQWgblkWr4pD6lWsuvy9Bw9fzFempgF
 88EpbA30f//M6MJnLiPbsTfGcyQ5oy1idODDTu3OKHSC7cEjMVbD8f60WPA9TSES33o2G/QPDkL
 dPEVzng/ptj7KO6tIKM8QvmbzPWYaTEIUGjCOMFVKj34s2kX//cDnRFnlyypfv5BRpZ4LJoCfiN
 dMWge/XYinL+h55WDA63pT/7TfqnUeLDeCsCuxxF3vjFKfP2+v4W7DtRTab4NF/IPOrhtBIn8Ow
 RyXHbNarg6zX6oc6mcnQtyDg+vk4mkda0og29PiitNUyefcsR80IV8hVTtLgRcMdUCzypSFNwrU
 1FyUSOTW9vY5Y/z8km3U5T896zqjGUbkT3Iw8LL4yvEEWOzfHpAzmglxX2ZF6YPKq+lrBN4DdR7
 6a+iAETo4GS6V1EHytqmUcYxBBOQCK0+UgO4itvPzbYT2mxg3ZFK9+J7BedZS0nnqGtVcdBUY82
 zoDB585DrbnhqduR9An2hs+JuwN7jtBFlfn1WDaRgEbZCFhyrvRYX0ZGAuu1198MtwcRHI8bWU8
 fHx/bZre4WjFkHQ==
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
index 359407aae03e..7178db70c1ff 100644
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

