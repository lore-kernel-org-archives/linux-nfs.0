Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2C6A39A806;
	Mon, 20 Jul 2026 14:28:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557703; cv=none; b=LPKYY7gjqds+GOKao7tJpY/66BdG/tknpzccqL3StghKFAHi+BSXGhmWMLnodxVgWlERt4Eep3IjA9c/s6spGhvwfptbbL48NEXgxTr4lrttRCBMMFPkxjYB9B2TjvAs6UY+jcMy3MAFD2EP+DX862cdMrffCwF1BHmSZZONtXk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557703; c=relaxed/simple;
	bh=zZrUD6zl9XaB+62ZkDPmiBs1BA8S+OsiuWonBvcYIv8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=DTRuIFpVHbEowntgKBpgL6cQwaP3A74CgJdULuyRZXcfoZv1+d0hCBIvOG8wpZ5rwuaCoJSKIZnpTRVnrT4vCn5B5OepoxPe+5a1Ov+nE+h8+DWCTGfeeOJAOyvRGLFcYOO/lJBf79f3xqgFITVpcJxNwuuDTQLjZGZbmW7ddLQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KFy/K6UD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KFy/K6UD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7991D1F00AC4;
	Mon, 20 Jul 2026 14:28:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784557700;
	bh=4Ejf4WOykKVoOSCLsi+dm2IbVMl5uodBnkkKqYHe6ms=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KFy/K6UDwjO0C50N4PN106SterFMdmvgXDcp9ZU7rFScUfuauy4A/4uoTYiv/1dAW
	 pVSK36iYwmoGAAfU76luLeZGumy3S9G8S7lEdpsUeDuWT0BxC99obLhjGRQS/9kY74
	 YkbgMuPoJRXbzF4tnx+csP2gRuH91OsjmgA5McAQSWbxHrNLibCuBiFX0pjHIjaLBc
	 NrHZ9nt0fYqzBP15nRXEFbWdsS9em4G7aTI5706ADjy9BvUyDNRILrn3mluLs+Xs4D
	 UAxaCKmiadQK/lPIecf5bxCPI51vxQsGFeu8zlPm2R7EvRvvX0tC0hiyRl7xZ/yVvJ
	 2YMx9mXFsC1wQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 20 Jul 2026 10:27:59 -0400
Subject: [PATCH net-next v2 5/6] SUNRPC: Use read_sock_rectype for svcsock
 TCP receives
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260720-tcp-read-sock-v2-5-29545d034f3c@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8881; i=cel@kernel.org;
 h=from:subject:message-id; bh=Tp+/wYJjzNoQaPM8lWJ3OP14nwgGazAOK8pGYoylzgE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqXjB8tAq4FCT9ArJyvVVqSH46FpKkhFgFY3jgA
 IqZJae0rUWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCal4wfAAKCRAzarMzb2Z/
 l/YxEACHuh0Iu2WU+IyUnHZ2WG3J/DLLx6tsdsuxAe9k9H3HeYfCJbhXjGwjxVKyMTIgWACRpEc
 0voQxlz/l3vJEQuE4Y7MK+ohfmKpKghHk6w5cF39XqSyT2RmOaauMrxXfe1EAoFrdmggRNWMiAQ
 /npC941sRWrXHGxHL2JiXXAMyll7T1i/qO0cSX8gN0WmvpEOVvapuTEyhTT3s9v4G1Jdv+m3xB/
 7vtK07Xra4jsn4vfqd43Dqc02TZPCBBEFJK67FO8bfFYvWrAINCFOZuHzjTNJ0wchFRlOS4eEmX
 UkwkM+YTUOaKFOAo9xSH+UH8I3SiYcmp3k4HG4X83hKysThoRUZ4WVuSEAfI40m02YYcrMhZp+o
 kk614U1jCv4aF1OWDiwLbaRxaOayyQvzlHQtir+y11AQhpkfvW/K8RI4KokRn3bJeVWgcMpJwGB
 MqyaIC3uhVAwP8AhT65cHqlebcbNJTn/ib3S8OkK40PqZh4gGCF+rYhLsqW0s3i8YRjhIJEzyoj
 mxK4u+yNFlWiTEcGb1cYP5FMvUggzENGn4kp9BP4BDLsZFAhag7OQzYGZ/WXeNh6E1l7+Howu6v
 7jWBssu1MNNkZ6VqU15oNCE4a0haP9HB9L9/0oYy7S8iLZUn40eQc1Wqd9zuvYIqnmxT61+F1oI
 76JYNPmoxa85qgg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

The svcsock TCP receive path uses sock_recvmsg() with ancillary data
buffers to detect TLS alerts when kTLS is active. This CMSG-based
approach requires a MSG_CTRUNC recovery dance on every receive and
cannot deliver control records through the read_sock interface.

When the socket provides a read_sock_rectype method (now set by
kTLS), svc_tcp_recvfrom() now dispatches to a new
svc_tcp_recvfrom_readsock() path. Two actor callbacks handle the
data:

svc_tcp_recv_actor() parses the RPC record byte stream directly from
skbs. Fragment header bytes fill sk_marker first; subsequent body
bytes are copied into rq_pages at the position tracked by
sk_datalen. When the last fragment of a complete RPC message
arrives, the actor sets desc->count to zero, stopping the read loop.

svc_tcp_rectype_actor() handles non-data TLS records. For fatal
alerts, the transport is marked for deferred close and the read loop
is stopped via desc->count. All non-data records are consumed by
returning 0 so that subsequent data records remain deliverable.

Sockets without read_sock_rectype (plain TCP, non-kTLS) continue to
use the existing sock_recvmsg() path unchanged. A follow-up patch
retires that path in favor of read_sock.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svcsock.c | 244 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 244 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 50e5e7f5b762..e40931d11491 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1134,6 +1134,247 @@ static void svc_tcp_fragment_received(struct svc_sock *svsk)
 	svsk->sk_marker = xdr_zero;
 }
 
+/*
+ * read_sock_rectype data actor: receives decrypted application data
+ * from the TLS layer, parsing the RPC record stream (fragment
+ * headers and message bodies) and assembling complete RPC messages
+ * into rqstp->rq_pages.
+ */
+static int svc_tcp_recv_actor(read_descriptor_t *desc,
+			      struct sk_buff *skb,
+			      unsigned int offset, size_t len)
+{
+	struct svc_rqst *rqstp = desc->arg.data;
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	size_t reclen, received, want, take, done, n;
+	size_t consumed = 0;
+
+	if (!desc->count)
+		return 0;
+
+	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
+		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
+		n = min(want, len);
+
+		if (skb_copy_bits(skb, offset,
+				  (char *)&svsk->sk_marker +
+					svsk->sk_tcplen, n))
+			goto fault;
+		svsk->sk_tcplen += n;
+		offset += n;
+		len -= n;
+		consumed += n;
+
+		if (svsk->sk_tcplen < sizeof(rpc_fraghdr))
+			return consumed;
+
+		trace_svcsock_marker(&svsk->sk_xprt, svsk->sk_marker);
+		if (svc_sock_reclen(svsk) + svsk->sk_datalen >
+		    svsk->sk_xprt.xpt_server->sv_max_mesg) {
+			net_notice_ratelimited("svc: %s oversized RPC fragment (%u octets) from %pISpc\n",
+					       svsk->sk_xprt.xpt_server->sv_name,
+					       svc_sock_reclen(svsk),
+					       (struct sockaddr *)&svsk->sk_xprt.xpt_remote);
+			desc->error = -EMSGSIZE;
+			desc->count = 0;
+			return consumed;
+		}
+	}
+
+	reclen = svc_sock_reclen(svsk);
+	received = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	want = reclen - received;
+	take = min(want, len);
+	done = 0;
+
+	while (done < take) {
+		unsigned int pg = svsk->sk_datalen >> PAGE_SHIFT;
+		unsigned int pg_off = svsk->sk_datalen & (PAGE_SIZE - 1);
+		size_t chunk = min(take - done,
+				   PAGE_SIZE - (size_t)pg_off);
+
+		if (skb_copy_bits(skb, offset,
+				  page_address(rqstp->rq_pages[pg]) + pg_off,
+				  chunk))
+			goto fault;
+		flush_dcache_page(rqstp->rq_pages[pg]);
+		offset += chunk;
+		done += chunk;
+		svsk->sk_datalen += chunk;
+	}
+	svsk->sk_tcplen += take;
+	consumed += take;
+
+	if (svsk->sk_tcplen - sizeof(rpc_fraghdr) >= reclen) {
+		if (svc_sock_final_rec(svsk))
+			desc->count = 0;
+		else
+			svc_tcp_fragment_received(svsk);
+	}
+
+	return consumed;
+
+fault:
+	desc->error = -EFAULT;
+	desc->count = 0;
+	return consumed;
+}
+
+/*
+ * read_sock_rectype non-data record actor: receives non-data TLS
+ * records (alerts, handshake messages) and translates them into
+ * transport-level actions.
+ *
+ * Returns 0 to consume the record and allow the TLS layer to
+ * continue delivering subsequent records. A negative return
+ * causes the TLS layer to requeue the skb on its rx_list,
+ * blocking all further record delivery on this connection.
+ */
+static int svc_tcp_rectype_actor(read_descriptor_t *desc,
+				 struct sk_buff *skb,
+				 unsigned int offset, size_t len,
+				 u8 rectype)
+{
+	struct svc_rqst *rqstp = desc->arg.data;
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+
+	switch (rectype) {
+	case TLS_RECORD_TYPE_ALERT: {
+		u8 alert[2] = {}, level, description;
+		struct kvec kvec = {
+			.iov_base = alert,
+			.iov_len = sizeof(alert),
+		};
+		struct msghdr msg = {};
+
+		if (skb_copy_bits(skb, offset, alert, min(len, sizeof(alert))))
+			break;
+		iov_iter_kvec(&msg.msg_iter, ITER_DEST, &kvec, 1, sizeof(alert));
+		tls_alert_recv(svsk->sk_sk, &msg, &level, &description);
+		if (level == TLS_ALERT_LEVEL_FATAL) {
+			svc_xprt_deferred_close(&svsk->sk_xprt);
+			desc->error = -ENOTCONN;
+			desc->count = 0;
+		}
+		break;
+	}
+	default:
+		break;
+	}
+	return 0;
+}
+
+static int svc_tcp_recvfrom_readsock(struct svc_rqst *rqstp)
+{
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
+	struct sock	*sk = svsk->sk_sk;
+	read_descriptor_t desc = {
+		.arg.data = rqstp,
+	};
+	ssize_t len;
+	__be32 *p;
+	__be32 calldir;
+
+	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+
+	svc_tcp_restore_pages(svsk, rqstp);
+	rqstp->rq_arg.head[0].iov_base = page_address(rqstp->rq_pages[0]);
+
+	desc.count = serv->sv_max_mesg;
+	lock_sock(sk);
+	len = svsk->sk_sock->ops->read_sock_rectype(sk, &desc,
+						    svc_tcp_recv_actor,
+						    svc_tcp_rectype_actor);
+	release_sock(sk);
+
+	if (desc.error < 0) {
+		len = desc.error;
+		goto err_discard;
+	}
+	if (desc.count != 0) {
+		if (len > 0)
+			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+		goto err_incomplete;
+	}
+
+	if (svsk->sk_datalen < 8)
+		goto err_nuts;
+
+	rqstp->rq_arg.len = svsk->sk_datalen;
+	rqstp->rq_arg.page_base = 0;
+	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
+		rqstp->rq_arg.head[0].iov_len = rqstp->rq_arg.len;
+		rqstp->rq_arg.page_len = 0;
+	} else {
+		rqstp->rq_arg.page_len = rqstp->rq_arg.len -
+			rqstp->rq_arg.head[0].iov_len;
+	}
+
+	rqstp->rq_xprt_ctxt   = NULL;
+	rqstp->rq_prot	      = IPPROTO_TCP;
+	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
+		set_bit(RQ_LOCAL, &rqstp->rq_flags);
+	else
+		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
+
+	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
+	calldir = p[1];
+	if (calldir)
+		len = receive_cb_reply(svsk, rqstp);
+
+	/* Reset TCP read info */
+	svsk->sk_datalen = 0;
+	svc_tcp_fragment_received(svsk);
+
+	if (len < 0)
+		goto error;
+
+	trace_svcsock_tcp_recv(&svsk->sk_xprt, rqstp->rq_arg.len);
+	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
+	if (serv->sv_stats)
+		serv->sv_stats->nettcpcnt++;
+
+	svc_sock_secure_port(rqstp);
+	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+	svc_xprt_received(rqstp->rq_xprt);
+	return rqstp->rq_arg.len;
+
+err_incomplete:
+	svc_tcp_save_pages(svsk, rqstp);
+	if (len < 0 && len != -EAGAIN)
+		goto err_delete;
+	if (svsk->sk_tcplen >= sizeof(rpc_fraghdr))
+		trace_svcsock_tcp_recv_short(&svsk->sk_xprt,
+				svc_sock_reclen(svsk),
+				svsk->sk_tcplen - sizeof(rpc_fraghdr));
+	goto err_noclose;
+error:
+	if (len != -EAGAIN)
+		goto err_delete;
+	trace_svcsock_tcp_recv_eagain(&svsk->sk_xprt, 0);
+	goto err_noclose;
+err_nuts:
+	svsk->sk_datalen = 0;
+	goto err_delete;
+err_discard:
+	/*
+	 * Clear sk_datalen so the teardown-time
+	 * svc_tcp_clear_pages() does not walk the emptied
+	 * svsk->sk_pages[].
+	 */
+	svsk->sk_datalen = 0;
+err_delete:
+	trace_svcsock_tcp_recv_err(&svsk->sk_xprt, len);
+	svc_xprt_deferred_close(&svsk->sk_xprt);
+err_noclose:
+	svc_xprt_received(rqstp->rq_xprt);
+	return 0;
+}
+
 /**
  * svc_tcp_recvfrom - Receive data from a TCP socket
  * @rqstp: request structure into which to receive an RPC Call
@@ -1162,6 +1403,9 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	__be32 *p;
 	__be32 calldir;
 
+	if (svsk->sk_sock->ops->read_sock_rectype)
+		return svc_tcp_recvfrom_readsock(rqstp);
+
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	len = svc_tcp_read_marker(svsk, rqstp);
 	if (len < 0)

-- 
2.54.0

