Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 22586352019;
	Fri, 21 Aug 2026 17:22:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787332977; cv=none; b=Yh+GgQDtOLol0EurZm4AAg5XGJaerC8K9GINoP1xYTnbCGMerIkLacuQV9zaQ2qmPMqsXCXCreE9pg/r11gDYVuBCpA452ohIrLVHEKtTjQFUoTWZGt83RJCb5jfnNgrQ301hHlefC3PwPLkUJSPfJeYKDGRV0mO0O+ceqp0kfQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787332977; c=relaxed/simple;
	bh=YWRoyNRw/ZqBY3oBVuVEe+FJ+VrcDamVs5TBq+2MGV0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pUqcXH/hv6A0j6GUQQMbzknFmEyZOGvEkWvW/+wVjJ1I6fOx4Y/5bQPa6FscJKoKLd2MBfP21eJpfI6kcWjZQfNuYGVYnvmfnOu7/B7LqW40c8nHhuRFXkNfX0NQJxtlWZCElf/UJA3eXoaE7fAPiMNf2/f2HPd606lyJ4fPjPA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BChz8YTh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BChz8YTh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8ABBB1F00A3A;
	Fri, 21 Aug 2026 17:22:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787332975;
	bh=wjxVgUs8E6V6zECpK1cnKmO4cIBV3xpjd1RMMbgM9G0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BChz8YTh72CqSBY4YS6hcgczSnTIpyueBbgr9IHxM4UOHTjFoP4zfKNXwg5RiGO71
	 d6DrZjtFALSR7B6rQpxqBWm9eedECzdOQ/rPCQUK8Vws6nXNaAW16++qcAxWhXcdOt
	 H0WUEJDyGu2JnyNF/k3wLAE9qplBCjSH+YtkdPhKfoNxyFSXZ/prD30/azhCwzJnb/
	 IwcuSVSl8x7mc1RSBsUVDE7qPymGy7lrMiWs0i90uOvxfXlK0Vwyycwq6czBI+YP4q
	 SgDHXJZq80pcId4NHGUrb548XQcmuPcNBDhS3lbfVLTwsARPGq4Mc8z7feExzI1yMT
	 c8B5PTMElAemg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 21 Aug 2026 13:22:40 -0400
Subject: [PATCH 2/5] SUNRPC: Close the transport on an unhandled TLS record
 type
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260821-tls-read-sock-2-v1-2-7ffce164eb45@kernel.org>
References: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
In-Reply-To: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3059; i=cel@kernel.org;
 h=from:subject:message-id; bh=YWRoyNRw/ZqBY3oBVuVEe+FJ+VrcDamVs5TBq+2MGV0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqiIlrNq+Uj9pEW9yyFwePDQHlwgbX9jKiLlfw0
 gza7H47C9SJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoiJawAKCRAzarMzb2Z/
 l4RWEAC0np7g1U1uWphudONMjZT8zuizWuUsoo+oONXSEeen3f3qRuMJG8PqGxtddneCYpurzYe
 IJJ7ummmW53a+97o5ytC1AmJrNpEoiq+RdHL9ZvpYic06yzjtrQzysFasiMwWR79G5HlxCHwlSl
 SbPLn7HjGSkgD2tPuR9Sx623RhFgYc1lbVat3nEFgrEDD7xYST1hM6974zSFL/b2lh/lZq7zr9H
 FbLbAjCNslIRDe255HuMZNYaH7wJlw47OUmv7fZwnRZgPiejf6XvTWDH8dV0Ig9RZ0KdTQC7EvU
 /6lAL+eZpvfsC2yIMmw29gTbLwXzFQfOSjIa3GFYVxfC0FEBuGD3mOE0p7cR4hoYaob4EPJJg+X
 fWvxknuL2om0mBnB7h468zrvMsegSGSR6ymAGInRBgwdx/VPCv+D/0zuIMPD7faIew1FidJOHRB
 nOAymNI7GA+D8nzrT6+aYplKZPF8NVqT+FRHq5zL5X859n9xUc4D9tfAeTydWhYcy9qm2IG/HjX
 I4pzo0cTNdef3yyuFX5rbTepcZG5RiNa22m3E7CzoxUYJysIiAJcLkRj9ljKAUJFkG8UTTMQyA1
 2pK7P9hZOK1+ynvoGzkgIURyYahfUI+X4rNTq+9XOZW2GQUclGIYRZpu8BMicYitaB9aX5gYq17
 X71/mosVcAejjqw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_sock_recv_cmsg() drains a TLS record that is neither an alert
nor application data, then returns -EAGAIN so the receive loop retries.
It runs only on an established TLS session. A handshake record there
carries a post-handshake message, and the server has no handler for
one. Draining a KeyUpdate only delays the close. kTLS sets
key_update_pending when it decrypts that record, and a later receive
returns -EKEYEXPIRED. kTLS flags only a KeyUpdate, so any other
post-handshake message disappears and the connection keeps running.

Return -EPROTO for an unhandled record type. Any error but -EAGAIN
closes the transport. An application data record keeps its -EAGAIN
return. No NFS client is known to send a handshake record on an
established connection.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 47 +++++++----------------------------------------
 1 file changed, 7 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b402923c40f1..ae1f3c474f8b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -238,39 +238,6 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 	return len;
 }
 
-/*
- * kTLS delivers a record only up to the caller's buffer and keeps
- * the remainder on its receive list, where no further data_ready
- * announces it. Consume the whole record.
- */
-static void
-svc_tcp_sock_drain_record(struct socket *sock)
-{
-	union {
-		struct cmsghdr	cmsg;
-		u8		buf[CMSG_SPACE(sizeof(u8))];
-	} u;
-	u8 discard[64];
-	struct kvec discard_kvec = {
-		.iov_base = discard,
-		.iov_len = sizeof(discard),
-	};
-
-	for (;;) {
-		struct msghdr msg = {
-			.msg_control = &u,
-			.msg_controllen = sizeof(u),
-		};
-
-		iov_iter_kvec(&msg.msg_iter, ITER_DEST, &discard_kvec, 1,
-			      discard_kvec.iov_len);
-		if (sock_recvmsg(sock, &msg, MSG_DONTWAIT) <= 0)
-			break;
-		if (msg.msg_flags & MSG_EOR)
-			break;
-	}
-}
-
 static int svc_tcp_recv_cmsg(struct socket *sock, int flags,
 			     struct kvec *payload, u8 *type,
 			     unsigned int *msg_flags)
@@ -312,14 +279,14 @@ svc_tcp_sock_recv_cmsg(struct socket *sock)
 				&msg_flags);
 	if (ret < 0 || !type)
 		return ret;
-	if (type != TLS_RECORD_TYPE_ALERT) {
-		/* An application data record carries RPC payload.
-		 * Draining one breaks RPC fragment framing.
-		 */
-		if (type != TLS_RECORD_TYPE_DATA && !(msg_flags & MSG_EOR))
-			svc_tcp_sock_drain_record(sock);
+	/* A data record reaches here only when kTLS queued an empty one
+	 * ahead of the control record. Consuming it takes no payload,
+	 * and the retry picks up the control record.
+	 */
+	if (type == TLS_RECORD_TYPE_DATA)
 		return -EAGAIN;
-	}
+	if (type != TLS_RECORD_TYPE_ALERT)
+		return -EPROTO;
 	/* An Alert record carries exactly one two-octet message (RFC
 	 * 8446 Section 5.1). recv_kvec caps the receive at two, so a
 	 * longer record produces the same count. MSG_EOR appears only

-- 
2.54.0

