Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47EE6347BC6;
	Sat,  8 Aug 2026 15:40:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203627; cv=none; b=kLM+XNtLxEk8fNiXvZ08UPgYgWaA0HIghQxuQXdgSl4gn5u5Rn9YqPOgSTUg21lwbIKjMrKmzgGcPNi7YLGLuFU6Qp+mQ89WEglY9bTH+Uee9lBjM1XJZFEoZ2iH96I5k6PZrmnKRsUwZvdOk5IUTXRwEANAH6h/sIXHgMh7vhY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203627; c=relaxed/simple;
	bh=8dHVnmlixIfDjSH3hGtQoczjk4Jlm4Z2nzGK0cBQp1c=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=uOr++QEC0v2FDQj0NsS8J+YzMd1h+CSTB23VX3R7GHYspjJAwiITMc8ZDjbNL9A3MaXApnTBx91ed9VufbWMp2Gbxtkgp60iqXd1o4XgGNwlfmEOwkMur58xhRbmmyWXQ0XiWNrDm21PTnQlJXK8t40XkYLAmIJ6GvqACc+Qvbg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OIWb/Z1Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OIWb/Z1Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 687B81F000E9;
	Sat,  8 Aug 2026 15:40:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203625;
	bh=L5py4PvEbv7e+5d1VezVZliQi4t2oShGyDrtY7/JLTg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OIWb/Z1YWTeTSZKVNqKZ4JXFB0g1sGQ+BAyZ2Ijn6cI1BnZmtHRYqR4us/slU7HzV
	 GvKQ+sbpCWQSLSMPlSs0D/xVVoIUPH8cX1RkYndde4Ug6eVDivEhgVZ1IvpX+/Ln2X
	 pNLuh+HoM6XkhKdq6RAGa+EIKX4fHzyeJf7bPIlXHJWDdJbVuNdSpjXihI2z/Oftze
	 M/g18ee3pUw0qdDGXZ/ekKMklXRziadssQK5jPLlzgz3e2Tc7kmPM6w7kKp6V8zJhL
	 xguKu0rJ7UuUJ3M3os1y6eUgIyk4VroZJeht3vluJU8aYa5LZxS/wmgNQeg/8l7Yff
	 fNnPVOLgju2dg==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 08 Aug 2026 11:40:12 -0400
Subject: [PATCH v3 4/7] SUNRPC: resume receiving after a TLS control record
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260808-svcsock-cmsg-fixes-v3-4-62d9a631c880@kernel.org>
References: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
In-Reply-To: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3822; i=cel@kernel.org;
 h=from:subject:message-id; bh=8dHVnmlixIfDjSH3hGtQoczjk4Jlm4Z2nzGK0cBQp1c=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03jeGbLHqt/TnYiJRBzRcuKO+zXRkqy1a4Ek
 HBxOjYkQhiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN4wAKCRAzarMzb2Z/
 l9DUD/wOXyofx61AxgkaNYu9Fn5z42GsXUSkgCrskoCo0gbTbnhY1I/rSnQPW23LKmKpwJ2KQ01
 PRrYN8zuRPWKaYjdDZDr5MN6QCT3UhIFwj+62hAiZZp+1Xx01Q9gWbwO/GsXNl1ftZWJYzA+qqM
 wDgmEX8cYG+9kQtHffCGZEFECwImDat9ATzBvYTqyZNwabyWf3STYQ0bqIvDbSNV5jRAyUkrOYH
 OB06aWvinqKgfEticT1Q1pHgy76EgAktSjadB6PZA6C91I7IYuOLNWI/4lLM7LPZsRp5T5Y5sAq
 eu6I3DWBZO7tvGem0V0KFhwZskwZIlFeE0Og0xe1xjS5exXypQB7yX8xVSshA1Monr/fLM2an1v
 s/DH2GBNA1CKRthwkdPD7k0JAN95t2DfAtH0wutBlhHAnT5cjUhtF6YK8andXBHnMLYsBk9kxTt
 dFvA9419HLI8/43/GBIW3l61G2ibEalyj8/U2RALl8MKWCgzbRqzXoKEvNv2Ylwj97yUXuN9H1C
 Hd2DXJi18RIzKS4F2++n0efEnZRRdf9VMwcC9cM1DhL0R64dqyvSoZyUYV2EV8IQvmdTSmdmk1y
 nQSsAh/BxN4XqCwvSGY/WLsyQVr5ohBAKGn6bNvwzA/VZHQpsnh2Hj8MPvtsvfOeL16Je8TGG8l
 gWfYyjm3xxHRmkA==
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

