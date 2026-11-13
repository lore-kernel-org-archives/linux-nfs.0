Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597742;
	b=SM6tT6P9kETDmsxvrB5/lABOiwse0hO2Pxj5sQ0dg8DAswyPTEkgqgvE+VeMVq3/okPK
	 vgA3Y/0C8AO8UMixRyb3WtdmgfMTcKsBmkop3LTo0XQAy9zyvuHZ7etko0P5f3H7bjXiZ
	 Rm37kXE/CQ4Vlqi5wEFY/09M2fUwlKdowgKdUyCQAwjej0TcexfSXx/Tsx8zxoMmi7op1
	 SELKSLYMJ0Js3+DvC6o6YfAe21Uc/klkuQFbGevQ4NSlSttyB0Q/tJzqprmoQSelrz0P1
	 DKwBp4eJyuAW5R1SnsznLHiZn6innfVx8FgP7joTkF7KxAHckuafALXb+4dFOqII3UQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597742;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=w9nWleZzlt35y0AB6Peyb5uZmvSNbhq05kf6t/OgLN4=;
	b=jeUn+gmKUCZWA09lA3qwEkt8NmN7O4aQfDrVxTjn/GtCXptM10dO3YFlPxDeYAtE1OyA
	 tKf3eq4R9VSvgqQrTE8JMlprh7nVj7/AKPIFIMuiAmmgVntqkGlkgDWL5UGJbXVoRnoLT
	 Vblw1K4B4AT+RF3ElPUG5jvkaOWDGHOvlbULCv1ai/B7UDnCdsfZ1r9k7y3NhTkSJmfVe
	 u5HPbDGPlrN0Lk06QqBlameYuoSElEfcHy9hyOdOWXiz/+fW2QCsKrSxRtaGosNbDwQJD
	 KpeREQs4rocveQlejCwba431jkbVxSpNx4GtNT6V9Xi++bNP0u4uY14bsuAunGmIjDA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=d3thmonP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9309B60A260D;
	Fri, 13 Nov 2026 19:22:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=d3thmonP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 216941F000C5;
	Fri, 13 Nov 2026 19:22:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597742;
	bh=w9nWleZzlt35y0AB6Peyb5uZmvSNbhq05kf6t/OgLN4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=d3thmonPFq1j3T68R94ixKzQPwHKqAfesRHwIL+6Xt5WC2grdqBJk2G3WyD1vply/
	 NQvzX1IwggKt/FQTl4KONLANV3FvLriNQW1d/SC2C1If71NEgVTT6sa6ySmiibye+7
	 nOCZnGtvS8zNxPD+YTt28N3yyRfCVXT8VzaWtVaDbyXdBcwIy6em8+aBcLOYlIOyex
	 4Qczq+BdoesU3AT7hEa/0hyl9B7s6LoWya+dQDS0FTqy2ra83WixHgobRqwsDAH1xJ
	 10PAXtgJM0J0Q0TtWTt3CJRTnUxnQmmxPfCMsX9KTq6jN5dud7kSE4WEHAeqEDyUxd
	 Xpd9XqUvdhcUw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:22:02 -0500
Subject: [PATCH net-next v3 04/10] handshake: Add a session-tags argument
 to the TLS done callback
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261113-tls-session-tags-v3-4-91271964cdb0@kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
In-Reply-To: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6425; i=cel@kernel.org;
 h=from:subject:message-id; bh=rhwy0XqO0S/M76i3i9VLH4Bdu/i8zn4NgMolJCM2XZs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92NfGdwO9/YIsngSYU0q4cefdI//6VVrhTOEV
 yoERjGKrouJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjXwAKCRAzarMzb2Z/
 l/F+D/9tdcGXGO9Iipn6Rny0S5v4EEbfrIWwE4yrr5+832f3/DE1QYlBmX2jMU1HgPW9uRexl3t
 2Ep6/ygfuOqtG6w5oMR6l+HS0Eo3ceFHKLnmHyCaVh4aeB9tpTTQN0Uj80h8ygmukMKKHCp03f6
 VnYSz5jsvgjMebJn2UPGA+u3Gms+/fvADtXUCX72DG9No3Rbmw80hOIi8Tydtlz5YvFEKTOkdMX
 D3ihuqq6om1pXjfwPk72fm8t/2pQ06tVG/IPVqC7G9/2nXeP8uXg5JJy4OjMXxXQIup5KSR6mVP
 URs3ul+0KFCEWg0q/dWAbErX+7XGZTXNLVlWbpg6FTyoKfmUj/7OlgPLJfVRRxpnId4nDQPbiy2
 xyprj9ZWVd1JaVw9DVa44Wm2jJEG5rlYywttQCZwD2ujwvok8hcALMlOjBi6JDSK9ElWdyQku/j
 YewfzpL8AJr0krEM3iskrFZuiIueI0thQ6pTk5IKvdrnoNhcMN1yhV4PGHpumQTENsC77oc134j
 v2vEsf/qfhU0oSDOQO21JL+k/I6IcBA2dzNlNDkBxSJZ383fBb8SaqMlxx+MZqde/sF1ynbWBX7
 tMsA7r90CaZ+5aY3LcnHmJTCtKZmf88pLaiShQNJUnFscQl+niHHI50a9/bLoUsil0vlNStSg4t
 SR0XPuKJ6VDAOlA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Session tags arriving in the DONE downcall have to reach handshake
consumers for authorization decisions. The completion callback is
the only path to a consumer, so carrying the tags there requires a
new argument on tls_done_func_t. That signature change ripples
through every existing TLS handshake consumer in the tree.

Add the @tags parameter ahead of the functional change. No consumer
reads it yet and the handshake core passes NULL, so behavior is
unchanged. Isolating the mechanical signature churn confines the
tag-collection patch that follows to the handshake core.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/networking/tls-handshake.rst |  3 ++-
 drivers/nvme/host/tcp.c                    |  3 ++-
 drivers/nvme/target/tcp.c                  |  3 ++-
 include/net/handshake.h                    | 16 +++++++++++++++-
 net/handshake/tlshd.c                      |  5 +++--
 net/sunrpc/svcsock.c                       |  4 +++-
 net/sunrpc/xprtsock.c                      |  4 +++-
 7 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/tls-handshake.rst b/Documentation/networking/tls-handshake.rst
index 4f7bc1087df9..7e9f4bd659b4 100644
--- a/Documentation/networking/tls-handshake.rst
+++ b/Documentation/networking/tls-handshake.rst
@@ -169,7 +169,8 @@ The synopsis of this function is:
 .. code-block:: c
 
   typedef void	(*tls_done_func_t)(void *data, int status,
-                                   key_serial_t peerid);
+                                   key_serial_t peerid,
+                                   const struct stringset *tags);
 
 The consumer provides a cookie in the @ta_data field of the
 tls_handshake_args structure that is returned in the @data parameter of
diff --git a/drivers/nvme/host/tcp.c b/drivers/nvme/host/tcp.c
index 7ecc6c007f8d..5956b176e936 100644
--- a/drivers/nvme/host/tcp.c
+++ b/drivers/nvme/host/tcp.c
@@ -1920,7 +1920,8 @@ static void nvme_tcp_set_queue_io_cpu(struct nvme_tcp_queue *queue)
 		qid, queue->io_cpu);
 }
 
-static void nvme_tcp_tls_done(void *data, int status, key_serial_t pskid)
+static void nvme_tcp_tls_done(void *data, int status, key_serial_t pskid,
+			      const struct stringset *tags)
 {
 	struct nvme_tcp_queue *queue = data;
 	struct nvme_tcp_ctrl *ctrl = queue->ctrl;
diff --git a/drivers/nvme/target/tcp.c b/drivers/nvme/target/tcp.c
index 5105317cc61e..40f0cd9d9960 100644
--- a/drivers/nvme/target/tcp.c
+++ b/drivers/nvme/target/tcp.c
@@ -1871,7 +1871,8 @@ static int nvmet_tcp_tls_key_lookup(struct nvmet_tcp_queue *queue,
 }
 
 static void nvmet_tcp_tls_handshake_done(void *data, int status,
-					 key_serial_t peerid)
+					 key_serial_t peerid,
+					 const struct stringset *tags)
 {
 	struct nvmet_tcp_queue *queue = data;
 
diff --git a/include/net/handshake.h b/include/net/handshake.h
index 8ebd4f9ed26e..c227d42bd767 100644
--- a/include/net/handshake.h
+++ b/include/net/handshake.h
@@ -10,6 +10,8 @@
 #ifndef _NET_HANDSHAKE_H
 #define _NET_HANDSHAKE_H
 
+#include <linux/stringset.h>
+
 enum {
 	TLS_NO_KEYRING = 0,
 	TLS_NO_PEERID = 0,
@@ -17,8 +19,20 @@ enum {
 	TLS_NO_PRIVKEY = 0,
 };
 
+/**
+ * typedef tls_done_func_t - TLS handshake completion callback
+ * @data: opaque context pointer set via tls_handshake_args.ta_data
+ * @status: zero on success, otherwise a negative errno
+ * @peerid: serial number of peer identity key, or TLS_NO_PEERID
+ * @tags: session tags assigned by the handshake agent
+ *
+ * The @tags pointer is valid only for the duration of this callback.
+ * A consumer requiring persistent access must copy the set with
+ * stringset_copy().
+ */
 typedef void	(*tls_done_func_t)(void *data, int status,
-				   key_serial_t peerid);
+				   key_serial_t peerid,
+				   const struct stringset *tags);
 
 struct tls_handshake_args {
 	struct socket		*ta_sock;
diff --git a/net/handshake/tlshd.c b/net/handshake/tlshd.c
index 7567150c2a4f..997edc3fe31c 100644
--- a/net/handshake/tlshd.c
+++ b/net/handshake/tlshd.c
@@ -26,7 +26,8 @@
 
 struct tls_handshake_req {
 	void			(*th_consumer_done)(void *data, int status,
-						    key_serial_t peerid);
+						    key_serial_t peerid,
+						    const struct stringset *tags);
 	void			*th_consumer_data;
 
 	int			th_type;
@@ -105,7 +106,7 @@ static void tls_handshake_done(struct handshake_req *req,
 		set_bit(HANDSHAKE_F_REQ_SESSION, &req->hr_flags);
 
 	treq->th_consumer_done(treq->th_consumer_data, status,
-			       treq->th_peerid[0]);
+			       treq->th_peerid[0], NULL);
 }
 
 #if IS_ENABLED(CONFIG_KEYS)
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 498c5096eef9..f21522dd51f2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -414,13 +414,15 @@ static void svc_tcp_kill_temp_xprt(struct svc_xprt *xprt)
  * @data: address of xprt to wake
  * @status: status of handshake
  * @peerid: serial number of key containing the remote peer's identity
+ * @tags: session tags assigned by the handshake agent
  *
  * If a security policy is specified as an export option, we don't
  * have a specific export here to check. So we set a "TLS session
  * is present" flag on the xprt and let an upper layer enforce local
  * security policy.
  */
-static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid)
+static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid,
+				   const struct stringset *tags)
 {
 	struct svc_xprt *xprt = data;
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 027b37de694b..ade473f1a312 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2593,9 +2593,11 @@ static int xs_tcp_tls_finish_connecting(struct rpc_xprt *lower_xprt,
  * @data: address of xprt to wake
  * @status: status of handshake
  * @peerid: serial number of key containing the remote's identity
+ * @tags: session tags assigned by the handshake agent
  *
  */
-static void xs_tls_handshake_done(void *data, int status, key_serial_t peerid)
+static void xs_tls_handshake_done(void *data, int status, key_serial_t peerid,
+				  const struct stringset *tags)
 {
 	struct rpc_xprt *lower_xprt = data;
 	struct sock_xprt *lower_transport =

-- 
2.56.0

