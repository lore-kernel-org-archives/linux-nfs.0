Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0EFB3E44F9;
	Thu,  6 Aug 2026 20:20:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047636; cv=none; b=WEXx2l3moxmvnxO0DEVqwNXs7gyAnNJ21aIYfsLuj/vWw6lgO23X7pceOE8RGZbJAgcpot8tsP8EjU6yULTJbr8FCY/IX07KGIS6FtMdVL5AnuHiDm6UVRJ/aeKRAD88trfohYTU5wLBonaNCXjwd7OHOJN2U7rH4+KLrNJPxzw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047636; c=relaxed/simple;
	bh=32QCwh6laOPhecYqjAf8k79v/W1JTfk3Y2FAE9ElvCA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=VilBCMjH8CzbzBuTCOW/n0JTmi2oTXzNjd+Sy5cq0wVr7fsBLdCOMJAQTgwEg5LPcy9ptttnK08PyoPPw5i0H1Yw57LvJvh/CykAhzcAjSAqZyaTnnmBl7UQJa5TVkqTtSDJ6KYdhL7299yWitnup8mXa4MunH1wee5k56NiSgE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=df1YW+1d; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="df1YW+1d"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C55DF1F00AC4;
	Thu,  6 Aug 2026 20:20:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047635;
	bh=zn40YLVcz3rUQq7/GeOckZCTvPm09N5xvV6QnYFHCe8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=df1YW+1dlfCuvlVBfAO//9UGndqsPhKjuX5fy8bm/f1pqUsckI/B+fnmJOp8bGJDO
	 3VYwt6+8VyFKB5I+168uAp8eYStg6gjCtjbWZzPOHBgYqHt6EBNcDYbrvt0osKj5xA
	 gqYKvkcnzftpnXdb19W+RnTX+UruBiZHyaGbao/SXYMZa0Xdy6rbKCO9xZGwYEVO51
	 FTznDiYQbnbcHICMB34lLWs0cfWnr5/Mk67l3vxz4gKq8Z/Zxp/Mn5wbll/dRNLQgR
	 26O5Dncnpeoh7dCybuQVvx0quyZyxzoyvAtACujmzBlfmA2eetBve+8fsZrWM1BDtO
	 hFHI5ZnUxGDqQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:21 -0400
Subject: [PATCH v2 6/8] SUNRPC: reject a client-side TLS alert record that
 is not two octets
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-6-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2675; i=cel@kernel.org;
 h=from:subject:message-id; bh=32QCwh6laOPhecYqjAf8k79v/W1JTfk3Y2FAE9ElvCA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyMJAxGwqAi8uYcyhGtKMF1Tp5Q/JogH5/Cx
 3Z1jY3I6omJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsjAAKCRAzarMzb2Z/
 l9O1D/4/euASRy2dCpu+S9xlmeYfinYqBP4VGVojET6yBIwm2ZQsXzrkgbnBAKyrfJdvWNSaGxV
 XeO+nFygk3lV6yPf4JeM/7SAy3c7T0y27SsQaLRD5Q+E3D8W7MkFqc8KP5UksJYfWvzhDz0KsmJ
 lE4VueobeGr5qftzfaSDMc7eKhqIQ0nd+5/FYLQa6sSJQP/Qv3NjY1OZn09RJZyqTJb6+ruxK1P
 rmEWbfK/aqTeVm0HqV/j8SHD0C4kO5Y5L85PFNehJUYtIHoOLMmjEklUNmIJHnGnl/ZgNU0CIOO
 hXiDrQdRy34Hq5BfulIRLoGsDsPZrF9T782KTUDWStbX2plOf5oMk9gF6s+oXEA+qudhrIGpk50
 AEZhb9SIMJdbRgS5+cyjDA4fGEoBGbajWJbmmHmipqeeBQT2eGzwJIXpMr9zfB57fNgpWeZvir2
 o56YkpBwdjVsznZkYi1vB0imjT07wltDjgSiBJmYJRhBpvgzJCdqZ6C/TQyBzAL/uqp9IIXpgv3
 5i+hxivpN/Upc8jw+foLhBoHSnMLleHe2zu8YPUoFTrebmJqLWpyj9SSM0ysQqdN2k9tcoHVD9E
 sAf5K2QPnaGjJ05CjiVo2FFca2Qyv7lAAP8zVB2orsE4CG0cbCWOH/212NFg5p1FST+kr/juo2K
 Fl0Nuks5yZFR25Q==
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

