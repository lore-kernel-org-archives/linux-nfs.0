Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5ADC42A176;
	Mon, 20 Jul 2026 14:28:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557702; cv=none; b=SKGDN+OsqoTxr6K7x0DJR/DaZ/pFCnlYJugq8CS5rg4amGm65Waaz5YInzoD2c6PSvUPb6HORc6HHB4c+TZbmTJNJ/rL61SyhjYCXRJaiwiwcDaOI24c5BVS3uWFbpMi6NcAP/o+EhESoRHaE4CDFEAN9wg5NOwuX0Lc9QvwfFk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557702; c=relaxed/simple;
	bh=LZ8H7L62SZrWhC3xbaKofo49kg1FQ9h5Al65yygygeQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gYN/XviuYGiWls14QWZmi0GpRwkG1tG4/ckSW1QHN94MhH7xWLocuoXzY2FNzrOn0cxo5DfwFVUQ1pD6m05vgecCQ+1BA/XL5zjCKzPifJbWwGXp/19STWsq68S6g6XWNOEvmEhJ620arcgMWNN8KazgSExGaSE9PCW2NnzpGcI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=e+apMp7l; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="e+apMp7l"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7593F1F00A3E;
	Mon, 20 Jul 2026 14:28:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784557696;
	bh=BLP6t+bwM71ggqK6f8c8WkUsb0wNMTfPc+tIwur4seY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=e+apMp7lIXaEdb50INhF/blEOCNcpbEAHol2MD60M3BM+kuO5AS2vTp0VJX69v36O
	 UPOX/3zPJmIJDI2xlHaNf2xYNxULfNQ923mvcePhNacma0tAGcGjZh7GSjKidiWiTS
	 efp0HbFMvMYrX2b6xUyIyB6cXDRxU7Uq9XAaqagRbxZZS6t7o3W9/mp5tlKC/f+exE
	 Kv+dUc/gZBTPaUbX+4EJ52C7ecQWBudgi4GPdyQTZ1ISCeX9I0gwVAdE0PaqTDF0hL
	 Ecyni83+9QfHe4T7WpJA3duKx2gAg/nFM7RvUm563v3umLfhAvLuxwTEY4uDWTDsZA
	 s9RjUQDkzdMXA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 20 Jul 2026 10:27:56 -0400
Subject: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype proto_ops
 for control record delivery
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
To: Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Shuah Khan <shuah@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Chuck Lever <cel@kernel.org>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev, 
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3374; i=cel@kernel.org;
 h=from:subject:message-id; bh=Hi3lIEvfWxb+lEWEyIUYzpt7ptUTpvrtzjknbXxygYg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqXjB8nQx0RCIi5zgJB2XOSzHdNZOmIxIu1vPpp
 7ouVGQMkpuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCal4wfAAKCRAzarMzb2Z/
 lwd+D/9+MzI6sJK/q2JZ4lz4wOlgBzJ032+nYmcFlUCJ7WrNdk/i53T2nzL/Zeg0xEbhMovBik9
 LNvdRoWCwoWVmsJTd65cz8JtvmRJ/fW3K7zKkcCLe62rP45RUBqnrgIj8LFlO8hEQj/bt9g5JaH
 Ne78nqeiPzWrtQV0K52+hGb0KCcWeaiugilnTW7RB8tPjzg7JROFCA7h+TSrvSESMYOarcmqOxD
 g7JMjvwi6U2wEDRdLzShIEVdkcpiDQ4mb1M6/jmiBQMRZNCohhXCXdasH/oreWyG7kURL2Zq/xC
 +MG6yzmDJ0hSEThVjExOSpDzoXJtSH1Kb0pSVuYaENJBUCdR1IDorutIbpMVBvKiR2rh2wzmGny
 XqRWZYrSjoCZBjvL27ue448lS1hwKmYQlY4Yim5SYuYCYmUcu/9KIX6pqdspVnOtPzwIklBFO97
 0vCFyf6DyC6siS1ABkt33MFZQ/GwNzVbRFIJGGP25GchD1eMkPbKpBB1ePw7LCHEXwnOOUwAeMd
 AaAEbI1HR36l/+H02QAjouHArhJCkI86uQM1R1SJTc90vKguTwAXZ+nLgdXHY1pbWmbuiipZkwN
 IxvuYUIdb4KpqcprZ5mT78GSDzIlTszAHK+qC1Ojhy5odmPO6y3hu0ka1P7UlW5UWq7Vr5eUImP
 1eZWRdZKz1QO0Hw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

Kernel TCP consumers that use the read_sock interface
(proto_ops.read_sock) cannot receive TLS control messages (Alerts,
Handshake records) when kTLS is active. The current
tls_sw_read_sock() method rejects non-data records with -EINVAL, and
the sk_read_actor_t callback has no channel for delivering record-
type metadata.

Four kernel subsystems are affected: NFSD (sunrpc svcsock), NFS
client (sunrpc xprtsock), NVMe target (nvmet-tcp), and NVMe host
(nvme-tcp). Each of these either falls back to the sock_recvmsg()
API or lacks TLS alert handling entirely.

A new read_sock_rectype method in struct proto_ops provides a
separate code path that delivers non-data TLS records to a callback,
without changing the behavior seen by existing read_sock consumers.

The new sk_read_rectype_actor_t callback type extends the
sk_read_actor_t signature with a rectype parameter carrying the
protocol-layer record type (for example, TLS_RECORD_TYPE_ALERT). The
record-type callback returns 0 to consume a record or a negative
value to requeue it and stop delivery; unlike the data callback, its
return value does not count bytes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/net.h | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index 277188a40c72..7a19a743a617 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -198,6 +198,13 @@ struct sk_buff;
 struct proto_accept_arg;
 typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
 			       unsigned int, size_t);
+/* rectype carries the transport record type, for example a
+ * TLS_RECORD_TYPE_* value.
+ */
+typedef int (*sk_read_rectype_actor_t)(read_descriptor_t *,
+				       struct sk_buff *,
+				       unsigned int, size_t,
+				       u8 rectype);
 typedef int (*skb_read_actor_t)(struct sock *, struct sk_buff *);
 
 
@@ -264,6 +271,27 @@ struct proto_ops {
 	 */
 	int		(*read_sock)(struct sock *sk, read_descriptor_t *desc,
 				     sk_read_actor_t recv_actor);
+	/*
+	 * read_sock_rectype splits delivery across two callbacks:
+	 * recv_actor for data records, per the sk_read_actor_t
+	 * convention, and rectype_actor for all other records,
+	 * with rectype identifying each. A NULL rectype_actor
+	 * leaves non-data records pending. rectype_actor returns 0
+	 * to consume a record or negative to leave it pending for
+	 * redelivery and stop delivery; the negative return is a
+	 * backpressure signal, not a fatal error. Both callbacks
+	 * report errors and early stop the way recv_actor does:
+	 * by setting desc->count to 0 and recording the reason in
+	 * desc->error, per the read_descriptor_t convention and
+	 * independent of the return value. The return value reports
+	 * only data bytes consumed by recv_actor; the caller
+	 * detects an error or early stop via desc->count and
+	 * desc->error.
+	 */
+	int		(*read_sock_rectype)(struct sock *sk,
+					     read_descriptor_t *desc,
+					     sk_read_actor_t recv_actor,
+					     sk_read_rectype_actor_t rectype_actor);
 	/* This is different from read_sock(), it reads an entire skb at a time. */
 	int		(*read_skb)(struct sock *sk, skb_read_actor_t recv_actor);
 	int		(*sendmsg_locked)(struct sock *sk, struct msghdr *msg,

-- 
2.54.0

