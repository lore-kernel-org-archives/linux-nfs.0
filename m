Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F1FF3E6DD5;
	Thu,  6 Aug 2026 20:20:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047634; cv=none; b=G2WGT23VdQoKYulfOCjgBVvNn71xuHUA948wx55rG9dsGBElIpVBCMqIhgsgfXOviNL0f/z/vXc6UTuimdgu86u+kErbGyyvuFC8u1wcoE0FE6v87NtO7vo9UFTcFw60RKCZ1tRtlP2E4sI4OxNx1JRJW4Xg1kRfvfDNpBWRBXE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047634; c=relaxed/simple;
	bh=8dHVnmlixIfDjSH3hGtQoczjk4Jlm4Z2nzGK0cBQp1c=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LWEsjCC4t4yFlafjGoPXM/WjJ4F15MQgeTcNQ8TMnzmLLN2pYuWjm80fHhtQXjjcVLj9gRf+oCOwoSMG63DrEL/WtFume7Q5g4NMEqDXKXuYA7YSbVzGB1Qw0q2fDATPc96vTp8nBoCDHzu1JaUScsHN6Il4xW/vVsCdRyVCChM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=epbaNsFF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="epbaNsFF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD70C1F000E9;
	Thu,  6 Aug 2026 20:20:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047633;
	bh=L5py4PvEbv7e+5d1VezVZliQi4t2oShGyDrtY7/JLTg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=epbaNsFFqUzGz1mE8+86JyYgaG2eYY0TVE+fBzaF3qwmnyEJS+M5QjhXZggp9nTXa
	 dGY3pG9qeeykTELHVpdugSQ1uLsNy5pyeUhisbnBZ0hfKFZt8+C3BECL0iz5KGEefi
	 78fkfPM1maEdQnwW0I5Ea0zhfXADFiSSjWu9FXf2C+M9OLXKZTl9LvS4difjM+U14H
	 j9otTdPWOpwxd+kY0GWs0l3taiaeAlp0QFBPOSyjrJqlu32F62AyCBwqn9IHMQ0IKV
	 OM4YQLU7nRKroJuzpt5+GFvfH//FuwXvQMgQwBvaMugpR4D6t72ki7z8BMeHkzEJEG
	 pMoPjoZ+XZ1KQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:19 -0400
Subject: [PATCH v2 4/8] SUNRPC: resume receiving after a TLS control record
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-4-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3822; i=cel@kernel.org;
 h=from:subject:message-id; bh=8dHVnmlixIfDjSH3hGtQoczjk4Jlm4Z2nzGK0cBQp1c=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyMFNR18O4Crxf9JgSOz6mjZMxwFejdfXGpV
 6hpaO4B3uOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsjAAKCRAzarMzb2Z/
 l7hjD/423RjWbW8yClufp/WYhWjs2DRQLd3y+WKtQTPRYsw+xgYt63/p8dZ16zQz1SFo+UUKb1M
 ehhRTE1zK2BGAd3cC/xQ6g4UzF3ZCy2YNraprlSLvqWY8qNS0DhnVPWAAnS7dTN1pBEbfw3cYpz
 kdYVCgx6C5qli7eC9LlxV6QDQoNqk15xa8ApEAUhTTcQtgWo1/NusmTz8BFyT4zQPWI/zVBwXEL
 5fgbEq3i9SG0sH9BzdoeyD7K7IdDqZeRNmgDr1bVq6MNJtP36xGp18Qpixa38Jzx4ClXUiQNIJ9
 GH0DmavCHm20wygfhxWSSmI0NCGdC9RfTlPczFH1AbEYMvOzmIra8odL77YfFzS9JPymTdeGhmk
 zuLFSKJ5Bqp96HES5mzaCGcjKSk5vbOQkYfIVoQ1zh6egi7631j9LRXthY4l5MzwOHAnz1v4N0J
 sFqm3dU6uixowP0BsdyVDMWl5YdrsMT20ApmbUtRrsUNXoMJWqjl5gZMJzEHQmHbiuvry6ShZGB
 kxjxF50z4iKv+JRisWKR2YSk/WsW3/e/yKsFqS1/ZNhWtaveDPajQCt0Hur6DmnY2/rsd5NNP0w
 +vjwfLc2N+HRrZIQYJq3EnDZXI6yFotvEM62UCx7dB7MWTcNTja+K1EXuFup7MQa3j+Wo+QzZ25
 Mn8FERdCSTzs1RA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A TLS control record delivers no payload to the RPC layer.
svc_tcp_recvfrom() clears XPT_DATA before the receive, and
svc_tcp_sock_recv_cmsg() returns -EAGAIN for the record it consumed.
Nothing marks the transport ready again. kTLS raises data_ready for
arriving TCP segments, not for records it has already decrypted. An
RPC Call queued behind an alert or a KeyUpdate waits until the client
sends more. The client blocks until its RPC timeout expires.

The receive takes only the first two octets of the record. kTLS holds
the remainder on its receive list, where each later receive takes two
octets more.

Drain a record that is not an alert, then mark the transport ready
once a control record has been consumed.

Fixes: 5e052dda121e ("SUNRPC: Recognize control messages in server-side TCP socket code")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 52 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 756db84e4aec..6fee54f4290c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -238,6 +238,39 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 	return len;
 }
 
+/*
+ * kTLS delivers a record only up to the caller's buffer and keeps
+ * the remainder on its receive list, where no further data_ready
+ * announces it. Consume the whole record.
+ */
+static void
+svc_tcp_sock_drain_record(struct socket *sock)
+{
+	union {
+		struct cmsghdr	cmsg;
+		u8		buf[CMSG_SPACE(sizeof(u8))];
+	} u;
+	u8 discard[64];
+	struct kvec discard_kvec = {
+		.iov_base = discard,
+		.iov_len = sizeof(discard),
+	};
+
+	for (;;) {
+		struct msghdr msg = {
+			.msg_control = &u,
+			.msg_controllen = sizeof(u),
+		};
+
+		iov_iter_kvec(&msg.msg_iter, ITER_DEST, &discard_kvec, 1,
+			      discard_kvec.iov_len);
+		if (sock_recvmsg(sock, &msg, MSG_DONTWAIT) <= 0)
+			break;
+		if (msg.msg_flags & MSG_EOR)
+			break;
+	}
+}
+
 static int
 svc_tcp_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
 			  struct cmsghdr *cmsg, int ret)
@@ -303,12 +336,20 @@ svc_tcp_sock_recv_cmsg(struct socket *sock, unsigned int *msg_flags)
 	 * kTLS filled in u.cmsg.
 	 */
 	if (ret >= 0 && msg.msg_controllen < sizeof(u)) {
+		u8 content_type = tls_get_record_type(sock->sk, &u.cmsg);
+
 		/* Returning the count would credit the RPC stream with
 		 * octets that never reached the caller's buffer.
 		 */
-		if (tls_get_record_type(sock->sk, &u.cmsg) !=
-		    TLS_RECORD_TYPE_ALERT)
+		if (content_type != TLS_RECORD_TYPE_ALERT) {
+			/* Draining an application data record would
+			 * discard the RPC stream.
+			 */
+			if (content_type != TLS_RECORD_TYPE_DATA &&
+			    !(msg.msg_flags & MSG_EOR))
+				svc_tcp_sock_drain_record(sock);
 			return -EAGAIN;
+		}
 		/* An Alert record carries exactly one two-octet message
 		 * (RFC 8446 Section 5.1). alert_kvec caps the receive at two,
 		 * so a longer record produces the same count. MSG_EOR appears
@@ -331,8 +372,16 @@ svc_tcp_sock_recvmsg(struct svc_sock *svsk, struct msghdr *msg)
 	ret = sock_recvmsg(sock, msg, MSG_DONTWAIT);
 	if (msg->msg_flags & MSG_CTRUNC) {
 		msg->msg_flags &= ~(MSG_CTRUNC | MSG_EOR);
-		if (ret == 0 || ret == -EIO)
+		if (ret == 0 || ret == -EIO) {
 			ret = svc_tcp_sock_recv_cmsg(sock, &msg->msg_flags);
+			/* A control record delivers nothing to the caller,
+			 * and kTLS announces no data_ready for records it
+			 * already holds. Mark the transport ready so that
+			 * the records behind this one can be received.
+			 */
+			if (ret == -EAGAIN)
+				set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+		}
 	}
 	return ret;
 }

-- 
2.54.0

