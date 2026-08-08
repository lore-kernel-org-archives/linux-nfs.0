Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 667E73451CE;
	Sat,  8 Aug 2026 15:40:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203625; cv=none; b=Z5ctmToj0/uf3/Yqb9JDuFEB+Y1lvDgeFwkHS5fZosFR+2KqsnIXnObsB8VPNpeQHULCo3cbsYu4ivRQkhKe+9r9oSE571LDN9MqI1eL27fQjIkl93roe2owhOE54yQrwbFN6orJRvbEttdXxKy3n0R1fu0bn4+1flkFREK4Tpw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203625; c=relaxed/simple;
	bh=GyHNxGJ2TYrjmLdSimLvDhMo/eaMFH4ZWHPgBaSPQ6M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=uZqngi5kDnWTMf8NJd3ppavoMYk8TtexEqlbQT0A+/WZnMZ0sAo61Las55GJhPkd+uS8XGWxaI1ms6tfv50e8k7Ts960g74sMUcyJbhHjA1anX8s4R/r1L7o0aVoZXBw/0HS8m9b+1Mc1Z7qJzSbXaF9J9va9R1k3UpNxy3o60M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=b5zUXXiG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="b5zUXXiG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6A1C51F00A3A;
	Sat,  8 Aug 2026 15:40:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203623;
	bh=w+NCa01ITHOmw1HDAJzvUK0Uh/4EpjXtte7F683u4DY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=b5zUXXiGb7LfYl+/Ark7BvXgPuyab7is5yKGA49wA+o5AsXCejag7ErLfAKnoNOwG
	 grZfY58hhNc9to8KaPPbxWK/NX9Mjn90aK+Kz/r0xfUPHTnx0IGwOCt2x6+PROh8ce
	 QVbb0CMBEeuPocYfOUw1GTnM1QooufLXL2ryQ9QCYixBSSR0oUdz9i+efXGK8uqCJp
	 OfgpBeEQFsU6Nhz1oouf9SiQqQx7hqvcGVAy1e5T4af1To0dwxzGpXuxxCeCpzdS+n
	 ryX4rchoe4nRJl9A6cTN/J9IFz8wzhMdGQ/jKZ30oWyLfwgdZP3cIxvyNU5EKM+ogo
	 LHwHevo+X2BeQ==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 08 Aug 2026 11:40:10 -0400
Subject: [PATCH v3 2/7] SUNRPC: reject a TLS alert record that is not two
 octets
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260808-svcsock-cmsg-fixes-v3-2-62d9a631c880@kernel.org>
References: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
In-Reply-To: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2436; i=cel@kernel.org;
 h=from:subject:message-id; bh=GyHNxGJ2TYrjmLdSimLvDhMo/eaMFH4ZWHPgBaSPQ6M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03jNElzi0FaCeBqZ5nLmc2pYtgLBpWZF+9vC
 GLx33Q4+9qJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN4wAKCRAzarMzb2Z/
 l/93EACSzyZhQl8KPzSamh4ymXclONmc8+Ep1ynT1wpNQRPpU5JOWm41Cs2UwAHffsJwPpAq5py
 3ocJmTZuQfOhdCGSaW1wvIBfrSvxzvk6BE7DyaOYKaR5utjlms/UBU2xDN3OehF7ASbKsVMCiOl
 AamdW8GpCmJN9/o9Mx6MUVSNaOt3HZV0Fkx7ZU6ZZi2ej3iEMGlwRDaaPIg8tCAOYCSMNMKsObY
 zF9/Npi12uYd+jsFhLXiIVvYvY/vm5kmtFIjTp4vQl4+nP+htnBZf/q1ffnDbRHTDjPTvtl3dIA
 /KOlKHh+BVPs0ojGLmz0fa+Bhn3FG9OY+DbJ4RGpY+nijtoATQSiZ7ZH83VN8kp2Hb49+YEsq3W
 GucITy6pf+miOC2E74scVBJQPvygHPrd8Gn0xo2tD9qpw6DuZMAeMqFGwRNXkLvvSgY1q1lDtWR
 4VEAM/4BXDHzij9D+tx3WqYoZBvGwP435xm98SRhhJ5G5c1xWAOELdiLHAJs7dPuSuClogZlVQC
 zdyYfWSPLTf+UvaeDAnyKuH+3ALVCJ9tP6TO/81HLeWOc3AVhncVk9+4nAYnnU7rWpSwbx9ukB5
 mtDG6hy7YOfRNejcIiPHAa0W9WcXRaCiXkjaPs4Zz7UQfRCNG7LmBShvInA/4ImslsAwoIBqgQK
 gIrVExA8WPMO4FQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

tls_alert_recv() reads two octets from the kvec it is handed and does
not check the length (net/handshake/alert.c). svc_tcp_sock_recv_cmsg()
calls it for any positive receive, and the alert[] buffer it supplies
carries no initializer. A one-octet alert body leaves the description
read from uninitialized stack and reported through
trace_tls_alert_recv().

The peer controls that length. Neither tls_rx_msg_size() nor
tls_rx_one_record() enforces the two-octet Alert payload. A TLS 1.3
record carrying only the inner content-type octet decrypts to a
zero-length payload. RFC 8446 Section 5.1 requires a record with an
Alert type to carry exactly one message, so any other length is
malformed.

Require exactly two octets before parsing and return -EBADMSG
otherwise. That closes the transport rather than acting on a partly
uninitialized alert. Gate the path on a control message rather than a
positive count so that a zero-length record reaches the check.

Fixes: bee47cb026e7 ("sunrpc: fix handling of server side tls alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8e1009302e3b..2e5107a1fb89 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -289,13 +289,23 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, &alert_kvec, 1,
 		      alert_kvec.iov_len);
 	ret = sock_recvmsg(sock, &msg, MSG_DONTWAIT);
-	if (ret > 0) {
+	/* put_cmsg() shrinks msg_controllen, so a short one means
+	 * kTLS filled in u.cmsg.
+	 */
+	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
 		/* Returning the count would credit the RPC stream with
 		 * octets that never reached the caller's buffer.
 		 */
 		if (tls_get_record_type(sock->sk, &u.cmsg) !=
 		    TLS_RECORD_TYPE_ALERT)
 			return -EAGAIN;
+		/* An Alert record carries exactly one two-octet message
+		 * (RFC 8446 Section 5.1). alert_kvec caps the receive at two,
+		 * so a longer record produces the same count. MSG_EOR appears
+		 * only once kTLS has drained the whole record.
+		 */
+		if (ret != sizeof(alert) || !(msg.msg_flags & MSG_EOR))
+			return -EBADMSG;
 		iov_iter_revert(&msg.msg_iter, ret);
 		ret = svc_tcp_sock_process_cmsg(sock, &msg, &u.cmsg, -EAGAIN);
 	}

-- 
2.54.0

