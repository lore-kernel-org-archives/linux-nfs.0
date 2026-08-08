Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71FD635C686;
	Sat,  8 Aug 2026 15:40:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203628; cv=none; b=iQc+W40UfHa8V4FOqkT4twmv07SK+c70J5xGzhIHyQt8LqP/tWh93x1TA+c9/jceLctgrtM8Hv6uZumlgEmIW5dTls1L/JvDGAScdRbQfRMqFjbObOgnsadtUeQ+iHiYMVWTlB3B82Q2rLxSBzHh0lOdifWqCAxu5b7B65BBZdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203628; c=relaxed/simple;
	bh=32QCwh6laOPhecYqjAf8k79v/W1JTfk3Y2FAE9ElvCA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=OJ4mh46xAGIQjQKmq1LwXBCDx44sippf2wQYW+mOXAKCSh/EKrM8rSRiI1+bvzO4CnYgLVtGD8V/F25U7dDKVGzWLUmwS+tAl+zIVWU9H/DV5bQ2rXYNvu5DVWLfQAau7FdJtysYuC1BHdN0WSZYQlvjGTwRm6A3QVfvNR4jdKI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=P7RGTSti; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="P7RGTSti"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 698E31F00A3A;
	Sat,  8 Aug 2026 15:40:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203626;
	bh=zn40YLVcz3rUQq7/GeOckZCTvPm09N5xvV6QnYFHCe8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=P7RGTStiuD/J/sysEC1R0skfjkXx/xYNtTnMBFE9vlvabglw3AQidUpHQ+0IbWQav
	 5QJxvq6NCgvE5Hg4XSb3qJVrFb1hdbzoOAu7LTlhws1wPMEQ5qOuvo6gChI8kjkG2f
	 Xztb81DEI2odF3p7RAxT7v1FLnfrMgz3q16chDEDGLIOqppI1oZsfTNxM5SJe0PRX8
	 mwlrmCggKzZqQlNC59SCAEdViUAqBi6EaokqghXoku+iUM45JWdiOXf0W/uAgpLxMu
	 Xx0guUuaWnJ/X4oE7wst3yScIjossnknIAW4Iyk+TdZMd2PDQcGZIpKgjfQM1qFj7E
	 XnMa9yI7eT9aw==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 08 Aug 2026 11:40:13 -0400
Subject: [PATCH v3 5/7] SUNRPC: reject a client-side TLS alert record that
 is not two octets
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260808-svcsock-cmsg-fixes-v3-5-62d9a631c880@kernel.org>
References: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
In-Reply-To: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2675; i=cel@kernel.org;
 h=from:subject:message-id; bh=32QCwh6laOPhecYqjAf8k79v/W1JTfk3Y2FAE9ElvCA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03kSW2xPfRZbJKSuAw3KysiYalSn8dLUxtA7
 hTB1mMZT3iJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN5AAKCRAzarMzb2Z/
 lyC3D/kBKIHBAFgfIr3z31l2qZ/MWg5Vo0aXgjgqoT2XsrFu3DylJI01Zo7vAUTertDVejrad+u
 A99yWoFZcuMbMaaSiLkxBAEOMORW5mq0qDB9pAeNhhpdGt0IjX1J1/50pYIlc3O3ZonzwjFTH5F
 dX3sPbAGISdgAQOwKpVpPdXtFgzjf//ucuSfPb4UqlUYQU+hyoMCgUNw1yBzLzEAIN+zC5xgQj0
 6hRlY9T5+ErwdExj6qIzG+tlqza5saJndX0SbhC98yErNcMNqiZXD6lLkDEjyklUnLz9WxhNjLj
 bg3WKnQL4G7LX9U8G6162OLHWWsh/IQYWriE5+TEPYVklm2hsoJ7B36U2NmowPt0MqrG/EcQGn2
 qnr6BUEdL+aDRve868vM4x8l/1jpdHQptT8cbeKE+xRU2aE/1ZpaTbs0dyF/wshGWSdWA19IQOa
 8SQQozQbhWbCh2wNrNngoh7BUOfAT1Z+J4Eu5p2b7GMB7yCOtHfCiuZ0sb6ekXX42C0yU3W9q0L
 UaK/QVZoVsf8+vO8H/ooUrc1USUvSfij5cBgf7DjKtfcdp73ltIW7whZMt3JjOqPplod/vNg70i
 qRV+sBLU13RiD79tr9Q48pCz3c7ViJ8NotJsk2DwumNr2dgkKDQ7bXbF50IPciCJacMBDPx3vYf
 MoXUNYuoGLIW9Pg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

tls_alert_recv() reads two octets from the kvec it is handed and does
not check the length (net/handshake/alert.c). xs_sock_process_cmsg()
calls it for any alert record, and the alert[] buffer that
xs_sock_recv_cmsg() supplies carries no initializer. A one-octet alert
body leaves the description read from uninitialized stack and reported
through trace_tls_alert_recv().

The peer controls that length. Neither tls_rx_msg_size() nor
tls_rx_one_record() enforces the two-octet Alert payload. A TLS 1.3
record carrying only the inner content-type octet decrypts to a
zero-length payload. RFC 8446 Section 5.1 requires a record with an
Alert type to carry exactly one message, so any other length is
malformed. RFC 9289 Section 5 bars RPC-with-TLS from negotiating a
version below TLS 1.3, so no other alert framing applies.

Require exactly two octets before parsing and return -EACCES
otherwise. xs_stream_data_receive() already treats -EACCES as a fatal
alert and reports it to the pending tasks. Gate the path on a control
message rather than a positive count so that a zero-length record
reaches the check.

Fixes: cc5d59081fa2 ("sunrpc: fix client side handling of tls alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtsock.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 359407aae03e..8e9d47d77e5b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -407,9 +407,25 @@ xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
 		      alert_kvec.iov_len);
 	ret = sock_recvmsg(sock, &msg, flags);
-	if (ret > 0) {
-		if (tls_get_record_type(sock->sk, &u.cmsg) == TLS_RECORD_TYPE_ALERT)
+	/* put_cmsg() shrinks msg_controllen, so a short one means
+	 * kTLS filled in u.cmsg.
+	 */
+	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
+		if (tls_get_record_type(sock->sk, &u.cmsg) ==
+		    TLS_RECORD_TYPE_ALERT) {
+			/* RFC 8446 Section 5.1 requires a record with an
+			 * Alert type to carry exactly one message. An alert
+			 * is two octets. tls_alert_recv() reads both without
+			 * checking the length. alert_kvec caps the count at
+			 * two, so a longer record fills it as well. kTLS
+			 * sets MSG_EOR only once the record has been
+			 * drained.
+			 */
+			if (ret != sizeof(alert) ||
+			    !(msg.msg_flags & MSG_EOR))
+				return -EACCES;
 			iov_iter_revert(&msg.msg_iter, ret);
+		}
 		ret = xs_sock_process_cmsg(sock, &msg, msg_flags, &u.cmsg,
 					   -EAGAIN);
 	}

-- 
2.54.0

