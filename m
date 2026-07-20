Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84C7642A14E;
	Mon, 20 Jul 2026 14:28:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557697; cv=none; b=lVmqpzinVPDzfDVpBAB7bQpPzPNpGMEZC7ZrvTDf9blFIRfYGaTEWAlmmjRGQNaywoLEVCsVbvxlUCNwo8U/5VZ0AYXL7LpNLFp0xwsx2QJ95iLXdWCtbJmMZRqs1hEHlSbAp28w6PqCs10fssHZw70gwt23rtrLrcIllfnffts=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557697; c=relaxed/simple;
	bh=on+G882KjZTShdkmEvEByWqLywXr3VQ77ncm3kyBQNc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=GWkAQPLlpC2dhV7DCoUKyjpvtCm3uSh3bEpukn5BGZhZsYxotw0mAhy+Slw1iL1ARbcuTQKLN3Ip9cwbXjdVvrmWa7zxHFJKLipHmpky5XSiUhmUDLtO9TvcLcuKpNmUiZO5dBodTE6xnYO3sOiO4qCdNxuM36s21fa5gy+Y86E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bOzPSQxj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bOzPSQxj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 24A2C1F00A3A;
	Mon, 20 Jul 2026 14:28:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784557695;
	bh=3rNs2JeT6guvgdkKirduA8NjGGPjD3GPBTBGrwZW6Ps=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bOzPSQxj8TIOSAtUzLwVZXzdZj/uNIXAla7VQh1KiTPeqPWs3ud/1Ztr+5psTCeqD
	 1O+veCiZr1Ca1pMsnWAcsKcflF9HwxLNdp+V8wMK8IMqtHaEK97cZqrET0Hw4MY26p
	 leuZkVqXm17CzgxZGWl06L2nrMKGdWp8948HIQmAmZbT5A2m80JSCOLVtFgq/YF1Gl
	 YhksmhCBc/d4DlBE5tDP/ZKhYeWQ4ZJ9U22pJZZLCSAoGy4PClQTLyMlUeN/6b2mN2
	 cMgw+68vcG3P8s1315z8AS/sWYb3gpqtxvUO6l7dJwsZJp8C3MQUUkxXFjY+MXmgM0
	 emZC0+SdQcAJQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 20 Jul 2026 10:27:55 -0400
Subject: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data records
 in tls_sw_read_sock()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
To: Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Shuah Khan <shuah@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Chuck Lever <cel@kernel.org>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev, 
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3121; i=cel@kernel.org;
 h=from:subject:message-id; bh=on+G882KjZTShdkmEvEByWqLywXr3VQ77ncm3kyBQNc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqXjB8Eyx+HkU1IJBnxXOCXvrz8j2e+AfbHheQT
 SKBwSv01PKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCal4wfAAKCRAzarMzb2Z/
 l3KdEACrbpNZjZ0YyxuUYgMyYE6fA71CGt2ErQsLea8sgfjLf+urCWNDFhkqkQOyjqRMY3+UfPH
 iZQIlVxutFAW99DjGxjLe4sD6AQVE1iIIR6Zhg4FTBhxMMiqg56XwQV6+9znzODpRjlJ6qmTJJL
 S+TtZFyHhdHiPRe+KCyYwpc1AN1eP2nHstPlhKnlGbpH+cPmEBKeqaQeHhlkcKtSyp4Ldu+6Tup
 441NqdfdoFOxrXGTtdxrrueigea1m3eDy2wbFzTNytpPfx9nfocUIPTd7gYz1sx3G0UqTxkivKc
 Xj8D0Bp09EJMdqJ+zQbNUVonZljk7O5QWOr8DyEWDo2qQYQ/JBHMVpF5Kubqfs2G+YLziSbX4Kr
 ufoqbGaJImHFR7ULFYrt0MKTEaMo57fwwkbhEHbmGY+5XIhEJyoDF1N2wW2KhIirmm8Zl4iq50H
 orNmMo7ZoBI+0ckB3gi2OvxEOtOQ7q1ELie6OCtIUtBbNWyTO8RWoZjV0tE789LPbx59XyT6Qpg
 BiLOaRmccUH1XWt2qkjiy+rQILd5sIbyd8DIEedxdg9vh4K0Oemze6PxzzQNrhNjUCU3ao7AEV9
 FdwyI7r6aztQ7vLc/E3kiDGpmuOEmfIEwJNpbKebEisja16Z0wsJwOzndx2k4LiVc1aateQ2jA2
 WOkAalW/LJz22xQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A record that delivers no payload -- an empty TLS 1.3 data record
today, a control record once read_sock_rectype() lands -- leaves
tls_sw_read_sock() in its loop without advancing the caller's read
descriptor. A peer that streams such records keeps the receive loop
running, and the socket lock held, for as long as the records
arrive.

Cap the number of consecutive no-data records consumed per call. The
count resets on any record that delivers bytes, so a normal stream
is unaffected; a peer supplying only empty records is bounded to
TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock
consumers treat that as "no progress, re-poll" rather than EOF, so
the connection stays up and makes progress once real data arrives.

Only tls_sw_read_sock() needs this cap. Its consumers drive the receive
loop from kernel context -- a work item or service thread holding the
socket lock across the whole call with no return to userspace -- so an
unbounded empty-record stream keeps that context and the lock pinned
for as long as the flood lasts. The cap supplies the return boundary
that a system call would otherwise provide. tls_sw_splice_read()
and tls_sw_recvmsg() already have one: they run in the calling task's
context, reschedule while draining the socket backlog (cond_resched()
in __release_sock()), and drop the socket lock when the call returns. A
flood there costs the caller only its own scheduler time, so the cap
would add nothing.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/tls/tls_sw.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/tls/tls_sw.c b/net/tls/tls_sw.c
index d4afc90fd796..087950ca639c 100644
--- a/net/tls/tls_sw.c
+++ b/net/tls/tls_sw.c
@@ -2049,6 +2049,11 @@ ssize_t tls_sw_splice_read(struct socket *sock,  loff_t *ppos,
 	goto splice_read_end;
 }
 
+/* Consecutive empty data records deliver no bytes; cap them per
+ * call so a peer streaming them cannot hold the socket lock here.
+ */
+#define TLS_RX_NODATA_LIMIT 16
+
 int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
 		     sk_read_actor_t read_actor)
 {
@@ -2057,6 +2062,7 @@ int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
 	struct tls_prot_info *prot = &tls_ctx->prot_info;
 	struct strp_msg *rxm = NULL;
 	struct sk_buff *skb = NULL;
+	unsigned int nodata_count = 0;
 	struct sk_psock *psock;
 	size_t flushed_at = 0;
 	bool released = true;
@@ -2122,7 +2128,13 @@ int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
 		 * here instead.
 		 */
 		if (rxm->full_len == 0) {
+			err = 0;
 			consume_skb(skb);
+			/* tls_rx_reader_release() announces any parsed record
+			 * on exit, so returning 0 here cannot strand it.
+			 */
+			if (++nodata_count >= TLS_RX_NODATA_LIMIT)
+				break;
 			continue;
 		}
 
@@ -2133,6 +2145,7 @@ int tls_sw_read_sock(struct sock *sk, read_descriptor_t *desc,
 			goto read_sock_requeue;
 		}
 		copied += used;
+		nodata_count = 0;
 		if (used < rxm->full_len) {
 			rxm->offset += used;
 			rxm->full_len -= used;

-- 
2.54.0

