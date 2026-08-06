Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D77E63E8331;
	Thu,  6 Aug 2026 20:20:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047634; cv=none; b=Bju/P/CzR2kWyUjgKu4GcbPJdufu4G7U3V33XIPogITSJYvc4YQFtLARdRHK0gH6LDShw630hQVzQTN5fv2vaCbBSyVkrhClvICQjx+8/Pdp/jeP5O1wdzCAWWFKv4E2tEqSNXEPgWfklRvYAloXIuaVAKgoh0kPGBLj5C6LA2s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047634; c=relaxed/simple;
	bh=3hnz3WnV3QZqWcoSs4+oBtJk6U+/qtBqJHNTXzr25RA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=WSkHYiyS+TkfIWkokt0O6DiAHny/GZYekd/AdE+587J/011oBk34oXcvAOIy224EZuic0PDgmYYV1sxiIQK802h4NC6lElkBTo1kja2wUeGzHer3B5DuQEhI6xzXmR2KlykTG2BO9G1lapxLQ3BWVtDu1Si3xI+Y7xTVkWAk/3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fENCAnmE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fENCAnmE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BB8C11F00A3D;
	Thu,  6 Aug 2026 20:20:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047632;
	bh=T0hRh7l2rV74IxDoHsEZxW6V7Ia8A+R98l1383av770=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fENCAnmE1SWvKUmI5GfWM1wCgmFPKvNkq9QvANwD3UsSY8RRNHbJNSp3I7ejr05H/
	 NtoWW4mGQ2Qf2/6yFQFTGFpGZ40EYphxLeX959HQ9uWoOkTqsOGnHWVSuaHgMgEF64
	 DubaGpfxmWwy6Rnaq870C70GyF+AN6sCF7KCJfbL8aCA5a9cN2aOopqLsMlYusHAvy
	 HwQMbycExwnCKtMzVxSJaBe8Aes1cvWilzype24ql3Xgu1kj4s0WveKZGUx5LiSWWx
	 GXz3T9ZqN97xOyiCQCPo8aOP0nmpSx6lYhAHTOoTD+Rb8G1X6kV0+N0HzKLRlgoK8P
	 Nj5AbVFipBrPg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:18 -0400
Subject: [PATCH v2 3/8] SUNRPC: treat every TLS error alert as fatal
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-3-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1783; i=cel@kernel.org;
 h=from:subject:message-id; bh=3hnz3WnV3QZqWcoSs4+oBtJk6U+/qtBqJHNTXzr25RA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyMbRqAMlKEfjGUcDdNzfdIeb3pZECzBC+DG
 kGJM/f8RHmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsjAAKCRAzarMzb2Z/
 l0O6D/0RDraGcn+GNKhpcZBmUl2rW5KEvmxY1x7K1Ra9Q3u1mdqZuXv9vwptogyohxChwe/lRxe
 9bxEj7uptCRyiqhMI2g4JLkpk68kv73aF6tn6/tEij/xjpBAY2GbqeCSSsPukp59lqzMRI0h7IL
 YslWYF1GDTMk47g1aQArWTR3910yU1abuJM1Z34Y3rhDsor6925CObalwNURQxE91Zda4uxIGkB
 lwRNTPl0svM0MerIUsVQ3IL0qOsi2grg5WFRlykuYP+sZ+YnLfjR7gmxGX4kVYSOPZXEUGdDsAX
 0Sm9hpFhGQ1zE0NegroirZ+Ywwv9nfKVBqvOiH2qWP+8gHy8I679pysxCY9AIa148stWevR4Wn2
 o2I6v09nWRU7dj0q7WykzUpo27N2aFzYorWmd7IUGaqQPBP3hMrd+n43JAY9Dj4Vi+5Q3bStooH
 cUkgjWM6i2uUzjCv3FoAHzqy9j86p2DNnh6Anxas/5lM5LZywk96uiKObrEP85xx71dPjCCGuHj
 LIrVCVNCLPwxckUqbabrLQluHkfN+Xz4vWs1CtfEBk4D9Sku5OQZnPMIaWSLR3HgUaUjaJEwTwj
 icpDOcZElhx8yoRsEs+5P8DA9PmGdysUUSSmqNYKW363Fv32EguXOjBc/LwWPhfF57fpK9v7tuv
 UAwLkT2kFuRwBog==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sock_process_cmsg() decides whether an alert ends the session
by reading the alert's level octet. RFC 8446 Section 6 retired that
field. The severity is implicit in the description, and a receiver
treats every alert listed in Section 6.2 as an error alert
"regardless of the AlertLevel in the message". A peer that aborts
with unexpected_message but leaves the legacy octet set to warning
makes the server return -EAGAIN. svc_tcp_recvfrom() then leaves a
dead TLS session attached to an open transport. NFSD keeps polling
it.

Decide from the alert description instead. close_notify and
user_canceled are the closure alerts (RFC 8446 Section 6.1). Every
other description ends the session, including one this kernel does
not recognize.

Fixes: 39067dda1d86 ("SUNRPC: Use new helpers to handle TLS Alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2e5107a1fb89..756db84e4aec 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -257,8 +257,18 @@ svc_tcp_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
 		break;
 	case TLS_RECORD_TYPE_ALERT:
 		tls_alert_recv(sock->sk, msg, &level, &description);
-		ret = (level == TLS_ALERT_LEVEL_FATAL) ?
-			-ENOTCONN : -EAGAIN;
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
 		break;
 	default:
 		/* discard this record type */

-- 
2.54.0

