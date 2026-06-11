Received: from mail-m49198.qiye.163.com (mail-m49198.qiye.163.com [45.254.49.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AED426CE1E;
	Thu, 11 Jun 2026 05:41:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.254.49.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781156478; cv=none; b=rq71CRvX5agPgXFNIYAgc0agETUpl0MP6wcqQrgNEsXZkWHyJZzNfpOwaNzGNPge+CF+LUvHe2O55TmZpUFg5oocR5zNHO7cRow9aw8ojV57ONPlZMFW0JZXoKsF4HBdSLHP13aff6OzHFSfnvRoWzlNBWFSB9QTUH61dsqmlUQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781156478; c=relaxed/simple;
	bh=Y4LY/B8jP3E5C8ecFySMZOBAenR4mfBNCsURgNi5TE0=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=R3kFOVFpB+O1vLl+4WgM44GH3cLBH0yRdOCq28yQiWt3YTCvH2P5ACvxaw/ypRWvFT/8v2cbn5FFCdHyxS2LVhE7nOFE4YjyJZSz8B6e/YED35aXjb6NrQlao+F3lGZL9cL7Vl2aqhq6Rs7ztogzcIOHa+K/yg0VKk/wK8C/uR0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn; spf=pass smtp.mailfrom=seu.edu.cn; dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b=DjjP1DSk; arc=none smtp.client-ip=45.254.49.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b="DjjP1DSk"
Received: from PC-202605011814.localdomain (unknown [222.191.246.242])
	by smtp.qiye.163.com (Hmail) with ESMTP id 41f34cbfd;
	Thu, 11 Jun 2026 13:36:02 +0800 (GMT+08:00)
From: Runyu Xiao <runyu.xiao@seu.edu.cn>
To: chuck.lever@oracle.com,
	trondmy@kernel.org,
	linux-nfs@vger.kernel.org
Cc: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	anna@kernel.org,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	jianhao.xu@seu.edu.cn,
	runyu.xiao@seu.edu.cn
Subject: [PATCH net] sunrpc: xprtsock: annotate shared socket callbacks with READ_ONCE/WRITE_ONCE
Date: Thu, 11 Jun 2026 13:35:56 +0800
Message-Id: <20260611053556.2432448-1-runyu.xiao@seu.edu.cn>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-HM-Tid: 0a9eb52e29ba03a1kunmeb62097c151664
X-HM-MType: 10
X-HM-Spam-Status: e1kfGhgUHx5ZQUpXWQgPGg8OCBgUHx5ZQUlOS1dZFg8aDwILHllBWSg2Ly
	tZV1koWUFITzdXWRgWCB1ZQUpXWS1ZQUlXWQ8JGhUIEh9ZQVkZT0xPVkNPHUMaSk5NTEkeSFYeHw
	5VEwETFhoSFyQUDg9ZV1kYEgtZQVlJSUlVSkJKVUlPTVVJT0lZV1kWGg8SFR0UWUFZT0tIVUpLSU
	hOQ0NVSktLVUtZBg++
DKIM-Signature: a=rsa-sha256;
	b=DjjP1DSk187qWxAt/pZPky6kI6/coRoplu9xjzdFiOWShl9gTzH9SFAwy86fDTAacVmZ3QD6vA1XiwVEFcLb09cN6piDqx018man/T5smnuoP7zgtJwjni7QnOZOX+owDHjq7PdvdoyuPUa58U0IzznytpGTONbPg2HV4O1vK94=; s=default; c=relaxed/relaxed; d=seu.edu.cn; v=1;
	bh=e0yRTbTsjEGgxguzv/AJcLiM3TClLwRrtdJVF0K9LZ4=;
	h=date:mime-version:subject:message-id:from;

xprtsock replaces and restores sk->sk_data_ready and
sk->sk_write_space on live sockets with plain stores, and
xs_udp_do_set_buffer_size() invokes sk->sk_write_space via a plain
load. These callback pointers are shared with generic socket and
protocol paths that may read or invoke them concurrently, so xprtsock
needs the same READ_ONCE()/WRITE_ONCE() callback visibility contract
that the validated 4022 family applied elsewhere.

When SUNRPC takes over an AF_LOCAL, UDP, or TCP socket and later
restores the lower-socket callbacks during teardown, another CPU may
still hold an earlier callback snapshot. The plain replace/restore
pattern leaves the same visibility hole as the validated 4022 family,
so a stale snapshot can still invoke xs_data_ready() or
xs_udp_write_space() after the live callback fields have already been
restored to the lower-socket handlers.

Use WRITE_ONCE() for the shared sk_data_ready and sk_write_space
stores in xs_local_finish_connecting(), xs_udp_finish_connecting(),
xs_tcp_finish_connecting(), and xs_restore_old_callbacks(). Use
READ_ONCE() for the direct sk_write_space invocation in
xs_udp_do_set_buffer_size(). This matches the required callback
visibility contract while leaving adjacent sk_state_change and
sk_error_report handling unchanged.

Fixes: a246b0105bbd ("[PATCH] RPC: introduce client-side transport switch")
Signed-off-by: Runyu Xiao <runyu.xiao@seu.edu.cn>
---
 net/sunrpc/xprtsock.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3aa987e7f072..325cb81cf937 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1202,9 +1202,9 @@ static void xs_save_old_callbacks(struct sock_xprt *transport, struct sock *sk)
 
 static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *sk)
 {
-	sk->sk_data_ready = transport->old_data_ready;
+	WRITE_ONCE(sk->sk_data_ready, transport->old_data_ready);
 	sk->sk_state_change = transport->old_state_change;
-	sk->sk_write_space = transport->old_write_space;
+	WRITE_ONCE(sk->sk_write_space, transport->old_write_space);
 	sk->sk_error_report = transport->old_error_report;
 }
 
@@ -1664,6 +1664,7 @@ static void xs_udp_do_set_buffer_size(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct sock *sk = transport->inet;
+	void (*write_space)(struct sock *sock);
 
 	if (transport->rcvsize) {
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
@@ -1672,7 +1673,8 @@ static void xs_udp_do_set_buffer_size(struct rpc_xprt *xprt)
 	if (transport->sndsize) {
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
 		sk->sk_sndbuf = transport->sndsize * xprt->max_reqs * 2;
-		sk->sk_write_space(sk);
+		write_space = READ_ONCE(sk->sk_write_space);
+		write_space(sk);
 	}
 }
 
@@ -1988,8 +1990,8 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		xs_save_old_callbacks(transport, sk);
 
 		sk->sk_user_data = xprt;
-		sk->sk_data_ready = xs_data_ready;
-		sk->sk_write_space = xs_udp_write_space;
+		WRITE_ONCE(sk->sk_data_ready, xs_data_ready);
+		WRITE_ONCE(sk->sk_write_space, xs_udp_write_space);
 		sk->sk_state_change = xs_local_state_change;
 		sk->sk_error_report = xs_error_report;
 		sk->sk_use_task_frag = false;
@@ -2191,8 +2193,8 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		xs_save_old_callbacks(transport, sk);
 
 		sk->sk_user_data = xprt;
-		sk->sk_data_ready = xs_data_ready;
-		sk->sk_write_space = xs_udp_write_space;
+		WRITE_ONCE(sk->sk_data_ready, xs_data_ready);
+		WRITE_ONCE(sk->sk_write_space, xs_udp_write_space);
 		sk->sk_use_task_frag = false;
 
 		xprt_set_connected(xprt);
@@ -2378,9 +2380,9 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		xs_save_old_callbacks(transport, sk);
 
 		sk->sk_user_data = xprt;
-		sk->sk_data_ready = xs_data_ready;
+		WRITE_ONCE(sk->sk_data_ready, xs_data_ready);
 		sk->sk_state_change = xs_tcp_state_change;
-		sk->sk_write_space = xs_tcp_write_space;
+		WRITE_ONCE(sk->sk_write_space, xs_tcp_write_space);
 		sk->sk_error_report = xs_error_report;
 		sk->sk_use_task_frag = false;
 
-- 
2.34.1
