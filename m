Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 663733D093A;
	Wed,  5 Aug 2026 18:31:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954672; cv=none; b=QgnKqsChJuNian+O7wR0/0xKPpq7C/qw5lzbGdpXiL6miqwdOyEdNV2JIIjBx29z5l8nvD5OacMHnagoBuOBHxECEM6YsaiOMa9JimYJwjcdiHjsEi9vL9F10cj4WEtxSXr/bznzpC8iUDS/dxPnCA3maoZfXNOf/84UrIsHWvA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954672; c=relaxed/simple;
	bh=8yxdIUsRJxbQG9Cv629Pk2MeF+oBwOS0sKAX1btV+ZY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mV5j6oVvxjxvvrwhPvjff6YkhbR3BLkFrH9D8oHj6VpG1Vfx0llAYWn420D+JbwF8oTFFRsAH5Ebf7Ja01XBA+N1ugy9jCvOLIDxCwhIytXInM0DMjC6/MYkDrrN2hgQBgk6bLZyr4sLTv4EW8wbgcAUxhN99VfqkCSWBJQXuz8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=N0I+PCNu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="N0I+PCNu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A8531F00A3D;
	Wed,  5 Aug 2026 18:31:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954670;
	bh=oeaZvCTwK/s16ioLWrfJMUb08zgrX+F1Ph0wrRIvJVI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N0I+PCNu1DxPDos6weSm+5gbPJHUfnd5c5hPxBVOHHhh/XBXPn1bJJeLan3EFrnHf
	 y79W4I7D3DVus1+KxLjxaxIGuQzYzfHuxsaSHG6ExC0dnoh5Gifnqe/cvhKobk4zHz
	 cU/3ZfK28ZUyrDQKCYGtugSBCaRD9G0T34O5LqfOYiHGYBV3/0shC9ff+4v8eQ/QXZ
	 9vskLMZa/VEI4CtCR6KZvlqEotNc25EFiUAV5Yt6gixAKUhDiZ9XtPiuQS5cD7ZxDT
	 QlcUrb4wCHjQnocD9GeUQk/Aalriyy+zN/IymhawuCEltEcH8xYnipmtY+DpQ6SGj5
	 e7nKlCjEElctw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:52 -0400
Subject: [PATCH 1/8] SUNRPC: treat every TLS error alert as fatal
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-1-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1783; i=cel@kernel.org;
 h=from:subject:message-id; bh=8yxdIUsRJxbQG9Cv629Pk2MeF+oBwOS0sKAX1btV+ZY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FraqmYfVF1pyRokdmUAGTfmlQ/3feUV9SBT
 3aqpEfECnKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBawAKCRAzarMzb2Z/
 lw77EAC/Ps7ow5VB+7RFetrdEdY/jnmKkiyX56oP4bc/WqGWop2Bc4xtyXdyZMA2dhNFtrlMtWW
 l3L4bDlfM3GV/NCA7xAXg2GBpDPGogea/gQPG9GWOWsomSt8wGfupMp3xfV9bsOob5gSd7Uy2BS
 nvA1CQ5gRRuEUm+kvm25Z9aZESr+bEPXKt95YePfOa7Uvct51tcosTjL94n24qh0uwoNK5krivD
 aOj6XxZHJQGkev2PT8+VZ7coVCTxiw2FjKQ6zCePA0xNG8XLUXQOUllMmsP5Zbpanf6VxqSnvz0
 u301dPM71BYqmmFEkDDJKjobk8H5zqlh9gCOGUlApfN5a5fJ2gvPe1np68iXNPZbyjQiNCUIshu
 FMaf5vrgzeAE8qPat50Xmzfp0je/KB8iuOWy71Qt/fljIY8yHfNpH2JMBS1DGmY9tZFu0eXuh9O
 Qzy50zHF9/n7O2/0fxDHrdNPCqiLXOCM6oOaXgQ4xQmpu4GF1462geNm5FowChLRjGsjnZqgYc8
 AqD7widlu6zoZr9d+TCAYo4pOtDbHSVtzCcrGnf6Q2iCCh0iYpKmLv0fBxMbN+o8kNtEfSfHH03
 6TD8W+elswDvdKeGPsKI/awPhbn9iA546JtzL79HL1bhX64+mxxVrhTY9KZrgdTh3XoMgbCVILx
 3qAtFd/qgE1zVaw==
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
index 50e5e7f5b762..95146e5eb934 100644
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

