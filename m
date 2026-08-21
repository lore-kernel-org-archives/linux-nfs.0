Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF8283264F7;
	Fri, 21 Aug 2026 17:22:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787332980; cv=none; b=qkA6UN/lxWMx90auQ7LswjItv9eIb5OvIZEYiSmuR6CKWbS6yJhEQHRhesuNoRx7O+u8ehC14Pcw8NAsDrapBvRspdRE5RnLU8W92cimc7W0jNg7ySAHMy/rslxRxcS0wZ2Hf7I2v34Bv4DmIj+uMtG1lQ7SvchOq2uVvcVW9II=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787332980; c=relaxed/simple;
	bh=WWiMj4PA5NTv6VJ4P8XB2m6beaVJiVsJptaajE7nVeE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=q6/EX1Kt/WRUoFAHB9fA0KnncsztYAIVGxVxZEORVf2dEOoh/lvXYUBbMWZ/MTae9I6OiSwocEWmFgZfZT8RlzwCTLzpmXNRLDGHPcdIcaGt9T5nQ+ZA6ldBavUrlqxA34l67QfLF5eySetPNV113gpm+sm7nMLb10MUKvp3Tlw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Fu9Bd3MA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fu9Bd3MA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 836D01F00A3A;
	Fri, 21 Aug 2026 17:22:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787332979;
	bh=cZGI608/0mTlF6Yn6F9gbY6WkBWnyoCdgyNeswFAlok=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Fu9Bd3MAJEmBt+sRxu50NxSIfI+e3jbq8N2ouBeMP5T7NTAL5MH8baUR633/Y+7ZZ
	 zf59PHDrEOeX8N9mmI0wtFzK1aLYzI6+hsIPcNUhgxRE/Rlnmbo5R8Y3KD6Ab1JIUE
	 vkOH4upmpvILx+PzYkF/2NoO+x6VRcGBsooXKUH7xEhSHFdwMe/+t4W5VcwJuJpv9n
	 aPm0tFzlpYNAdN0qKBkLkg2EPs4gZJ8PnAbe2AMlAY/VwijIH2ZxDZ7dli0KaB9rj8
	 iQvWz794U4YrRkSgpcz/0dcPs4kM81oXsAHhSFn5XQBxWOQ0lPNpTYXfjTCKum5l7X
	 VOJkD2dA6bovw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 21 Aug 2026 13:22:43 -0400
Subject: [PATCH 5/5] SUNRPC: Bypass sock_recvmsg() for the TLS
 control-record receive
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260821-tls-read-sock-2-v1-5-7ffce164eb45@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2257; i=cel@kernel.org;
 h=from:subject:message-id; bh=WWiMj4PA5NTv6VJ4P8XB2m6beaVJiVsJptaajE7nVeE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqiIlrwkOx1hvsrg743hJCPJjtXTqQaysyvWPsV
 tFgC7Wn3OGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoiJawAKCRAzarMzb2Z/
 l0cSD/91Nn/CLKbrhfS9HznxLCxRdCQLR8TNC0Ccyx/R8PTTE33bt5Pyd5ou26m1hrd82lWfon4
 KO/i8Y7Y4j2U4lLlIUIqb177ZSlyaf+DpTsT5xxNOCqzybAKvK0budt4BaS0AS+8zPsG7W9VBxg
 IjyTuF+xvZhlHgxtmj8C3TwmDACoJFTDu/vOwDyn36BGdPCqUFX5HWS7sVGvepmMCDYYu3us5x+
 FFblLYdCU+e9OYmKKioq/jq5Z7uwzYwjmte0nywS6cHmuDyVFtI6SRWwrnzqEWd+VxXQHOJopc7
 p84jVHUSZSfUC7d85PnQZh57kxDRWVwZlVqMou3A/fCofM30wICgEa296AOdn3X7Ff9b0KPazyr
 wWMTNSQa2DdF2Ugn5EmmaXgXGGGgRXhlfxR0GPFlIkoXU8/3BrmlQ4E8mPMOrih3i0mzO0ULZ62
 AAh6PzH7yJK8JEgfdivEoL7+pvHyximJlMKqOqa8lp5KSWwpCFmGtyXFGXkxekZ6KgRpe8z7/q0
 Jf4poQE+i/X98eBTI98qmK/6uHGRvdDLgQZ9NFo0tF2sOaeFeBKBkxfwLql3TZSiaWdx6vawnuS
 eXd/buS1HJ7rPQL8V/8Y98rIo6rRI2YNLHN8W2v0I0+HtKhidizv3AYSzDkkRP9n+QThEN66iuB
 4mPZb+FPW/n5FOg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_recvfrom() parses the RPC record stream with ->read_sock,
which calls neither security_socket_recvmsg() nor the
sock:sock_recv_length tracepoint. svc_tcp_recv_cmsg() still goes
through sock_recvmsg(), so an LSM mediates only the TLS control
records on a server socket, and sock:sock_recv_length reports only
those. Partial coverage is worse than none. It makes the RPC stream
look mediated and observed when it is not.

Until the record stream moved to ->read_sock, an LSM saw every octet
NFSD read from a TCP socket. An SELinux policy that denies
SOCKET__READ to NFSD blocked the receive. After this change no call
on the server's TCP receive path consults an LSM, so that denial has
no effect.

Dispatch ->recvmsg directly so the whole receive path behaves one
way. sock_recvmsg_nosec() reaches ->recvmsg through
INDIRECT_CALL_INET(), so on a retpoline build the direct dispatch
costs one indirect call per control record. Control records are rare
on an established connection.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index fe307d8314c4..ef7ac080fcd3 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -229,10 +229,16 @@ static int svc_one_sock_name(struct svc_sock *svsk, char *buf, int remaining)
 	return len;
 }
 
+/*
+ * The ->read_sock data path invokes neither security_socket_recvmsg()
+ * nor the sock:sock_recv_length tracepoint. Dispatch ->recvmsg
+ * directly so the whole receive path behaves one way.
+ */
 static int svc_tcp_recv_cmsg(struct socket *sock, int flags,
 			     struct kvec *payload, u8 *type,
 			     unsigned int *msg_flags)
 {
+	const struct proto_ops *ops = READ_ONCE(sock->ops);
 	union {
 		struct cmsghdr	cmsg;
 		u8		buf[CMSG_SPACE(sizeof(u8))];
@@ -244,7 +250,7 @@ static int svc_tcp_recv_cmsg(struct socket *sock, int flags,
 	int ret;
 
 	iov_iter_kvec(&msg.msg_iter, ITER_DEST, payload, 1, payload->iov_len);
-	ret = sock_recvmsg(sock, &msg, flags);
+	ret = ops->recvmsg(sock, &msg, msg_data_left(&msg), flags);
 	if (ret < 0)
 		return ret;
 	*msg_flags = msg.msg_flags;

-- 
2.54.0

