Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 377E93D5253;
	Wed,  5 Aug 2026 18:31:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954678; cv=none; b=imapQ+sn60NP5Tjv+iWqsgJHuADqSdSwli8WDBmZGWwN5bfqzsoFj2l66B6Mn8xHzFGzaGOWIKjwMJENfQazucyII3M5gafWpwTJOu29Az0OFChQLXcEp6PHDKGZ46uL4PGbGdRsTNB43LurB41Tyhysp4PEcajxAVy3Ck080+g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954678; c=relaxed/simple;
	bh=BJ4RffULPieODLiZvKfTM1Hx4cMFTrZNqsZeh4cUBwQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=XSqs+AjBq2ZE6JuUw0TVCrh7z4Lm/GAmbm8DH8PP6qWxBU7r3zsT08MjpK5421+9bpj/N6gJQVbHyC0orJlnlg4hiz1mZnY4mRKiMMBMwtFlWXXaBjXcZ6Q1i53HdnVHrz9YcQYh1GbvtWmWvcFexDs3OIH9wsEEBLp7+h0kC7g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=S4sK3OOs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="S4sK3OOs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 45E011F00A3D;
	Wed,  5 Aug 2026 18:31:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954676;
	bh=lUeUE+tPXQndXaVFJ9Pwcg9wTZmoFCU/vxWhw7QHBI4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=S4sK3OOsBwxp/xWnn6bG89lbIpCBnIU1VuJ6++Ne6P8vcc3dwRCmpP5cBQTLU7rj6
	 GnL47z11Ps7IJy41ovngCsILLvA0TtG5xwg6mNOmKlvIx2/t0c8HhgCCF6ADDQ2Vbt
	 L9SS8X8zSS4KkqSG5x5C5sqjSfdszCbueOiEMpwOahuUmmfGBekugKhTh15scNjy6O
	 seGlV89njZdlAJ9fgr0roQtU+rPVqza1ROzFX1bnW/Jttx7E8alSGPqblOQ12VcuAP
	 FBLDO+NWCOM4M4pqNJiRz3Cd1zh0IDC01evpxfHMq5goyvFmjz7Y4Rt8pLuP9VPGUQ
	 5BWo2KgKq4zew==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 05 Aug 2026 14:30:58 -0400
Subject: [PATCH 7/8] SUNRPC: reject a client-side TLS alert record that is
 not two octets
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260805-svcsock-cmsg-fixes-v1-7-43514a32da9b@kernel.org>
References: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
In-Reply-To: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2675; i=cel@kernel.org;
 h=from:subject:message-id; bh=BJ4RffULPieODLiZvKfTM1Hx4cMFTrZNqsZeh4cUBwQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FrJ2PQymIRc7MGQWOKAw+S24DScm5LSNK15
 JwcWtJAsquJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBawAKCRAzarMzb2Z/
 lxrhD/9hdoFNj60yGqK8XN5g/89b7RX1bZRp4aGVnzTzu1CLnloRe6SnbEWx4f1fryOmyvCKVtp
 XPlHa+TuQpGo+5B9UA3Gcf7iqOKxDA2U5MZNtxDEx3I9+r1me2H7/iKYFtSs0ymZNBwCUV3+KUF
 DCChuBnxvd0lY8AC7EESZuFSXrnqKnxPWY3iPjOvxwBhWQ+2GStolChuAJWWqphzDEy3snJTQz0
 QJofOf2BfcCbiMQDtKg0QJhkgLxJ7xayf0lh2YJZ2ep1+UaQU0UODRgDFfjRwX+zJp2ymo6/IYU
 8vFeyh2iGStPTNpf5zT1heQEKtLCgAeHNjEruPlWskYJjCxY0GWQdXSUIiQM2MAIxIUnh/8mIbw
 ujWLtySFazTS3wH4q+h7wtJZk1d6BSHrBv2MjWzuJ0S7cbH6XERzBzuA8ZmnfrmfPuyvlbJkByn
 zzSrCzSPHwkLHKFX9d9NjU++q+j+kx4zNzkag8PdvHvEbfVIKbcJYzXEpkbfKcRmYfMkac15KEC
 RLfuokf5cyhpS0lI1jP4Y6qvtx8eLySuhv7eY/WhtsuKl0LOFzo0S8+PgQplIP+Eb4wrm5oELXX
 sCVCFNAPZay9Dgqf2jU2nNXeKrDqPZW39FzSB0HO5mkLyMjB4sioOW5Aem+4gM95Ig4MfU9gJsD
 UhHMhWQHXV5xl3Q==
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
index 7178db70c1ff..5527f7f8a185 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -417,9 +417,25 @@ xs_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags, int flags)
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

