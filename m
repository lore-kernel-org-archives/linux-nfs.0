Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495150;
	b=rnCH72dLSq05lyHx7E9OFPqJZpDbEA42D3pzKu8qQt34/l8LJFFA8DK/p8L1hPQCKN9E
	 Hqcyxrhodlkz3x4SPuKCrCp6QvCUMgdMa7hi5mYK0H7u/C8KGJxwXh3YCvV4j4cSHUkno
	 B9QSSAJ7HAQwBfsK4o2V8kex+M+PVakH8m4Ej4dRhct/ngdR3WBRyWlVL4GqIwxYZNlyI
	 AOfKsw0bvOiYtZOetNegBfTpgMrdpJv4OEZDX5zbOoby5zDQ2x2RHXwaPKRsKO35yPOx3
	 /0THQ3NUgt2VsXR+JUGf1amuOOi73d0qNLLdpjisbTTGIpqa3Z8AR/40QGMQ0pScXlg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495150;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=wFhoqXgYMWt3Fq99iuC3P9N51U08a+2UJApHOOEUO5A=;
	b=SnP1QE3AN53Uxxudbttl9OaDYwFciH97OmRouPkSP+F7NC98HfgQiJHVLEA+fe3Tj/v1
	 JpqcNb3x0wImK+3EYUsfVh03bqD3o+zriiKWwLAAvyt7T/MIKFv4qztJHQldtRvSnX20J
	 qBsGcs/qAIu49QaNDWbk0+IgSAQwXLIBrbmDz+oDB54oJygXZ6yiQFbftcIij4SvwfDyS
	 iMfJU3JKoXb6SoU08MEAT5kUZnG/PcBnDNruYoOvOROP+HaxSPCPOJtT3RGcFZPyxBgDl
	 oErHhuzDJkFdFIjCb/7MUlEOOHjCxHI8ZDP9x+VyYPbVNyVjDbDSEPP8+tu4KroBd1A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GxbWXcYW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E122E606A31C;
	Thu, 12 Nov 2026 14:52:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GxbWXcYW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD22F1F00A0D;
	Thu, 12 Nov 2026 14:52:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495149;
	bh=wFhoqXgYMWt3Fq99iuC3P9N51U08a+2UJApHOOEUO5A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GxbWXcYWbA7xFjN9rM3F0PtGEKQ30ZofK255oHai8nsMA0otHCu6tYHjS5XY4hPAT
	 LJ/IxbnDSQq5RTpzJg0a3MRv4LujpoNOS8tLJORhIZWe6MdTXzpHHehC2etoyg4epv
	 fTfVVSQrMNZ0aORCrx7YJrPo11OP0iKp6CBxj+lt/zFlu5wSAkJS251xSjmOTxPhfY
	 adYe7BG/PIgwHj7ORUwsP7OZIWlSDfh6Sbr2tZMl9XQsZ2fgR5r0PpaFcv1WXu71w3
	 2JfX68HQ8eFlspBTMrzhG0c+bB4FM2H+RFv9FnclVqCXMX+trAKRdYgA6cCvmA8AFE
	 yUj77mLgyAamQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:08 -0500
Subject: [PATCH net-next v2 04/10] handshake: Add a session-tags argument
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
Message-Id: <20261112-tls-session-tags-v2-4-a587a50de7fc@kernel.org>
References: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
In-Reply-To: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
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
 h=from:subject:message-id; bh=TrKpLsYSnUBTQ+eSZXkbDYZrEL3/QrsYvQ0xILjo8vE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKgIaO1QMmNr1VLg5xlLxLrbSjoJZ6nTWgF6
 jO9D0eXRh6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 l+D7D/4xpMDlgduooKtcqz5ceezMNdo4nR9izKoPLgdolC1E8X0X9yYH+5xJw1rQuVk/5faxnZA
 vycsNYkVMv5fEGTjUHD+39oAUbcBlwbnLjC6ofBD/vAQHBXSt6D6sFMyWtwY60g3ZUUiFE+TgDB
 RFT+xPFJ6e47MoQqVBSunUcu8+6Asw9DHO/JweNfzYDeFVgSHAFBlnx4uMBh/IZhdZ1ABXiu42p
 hyyM/D5/Ml3iVoTA1jW2daiCQhatAxrA/aXdhtxHv9rcy8+F0YJvZgjOQW5yZC/HbnbftIdOJWw
 ChlQLqCBB1uPi9az49UkRm+C6jfCg74QUnI/nQR08msYA2cVADG7sEZH1Ov8GDJW5P9sec6VE93
 jzLMDqAA6bWyRysWZzk6odEwIeFIUBKcBio7FVyoXvLR3BWFG5P2hObvVtITQhU3xX9uukYy+Vu
 URR5j/xkBCy3A4wQqNHjWZOxqWtr7g6CLSAOunXeV0Ha6Ws44LCr0kTvrAMHDwOBsbIu7Kt1tIi
 9/hOqqyFW2dzi9+y4QLnlK5iBoBr7DoEQwu/Ucgu+iJjglNE8hZ0cKgzK1UqJ6Q/UtdNit/ZFSU
 xz63rJCFJptgQj/DAa9YCfUIlLigQfjYCLUHqjM/ELCMRtiRVAKSvkXAbduNS2DI0YwhWL92s/g
 xWyDYSZRsCKNEJQ==
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
index bc46e5f3eaa7..c792ac1c3c6d 100644
--- a/drivers/nvme/host/tcp.c
+++ b/drivers/nvme/host/tcp.c
@@ -1919,7 +1919,8 @@ static void nvme_tcp_set_queue_io_cpu(struct nvme_tcp_queue *queue)
 		qid, queue->io_cpu);
 }
 
-static void nvme_tcp_tls_done(void *data, int status, key_serial_t pskid)
+static void nvme_tcp_tls_done(void *data, int status, key_serial_t pskid,
+			      const struct stringset *tags)
 {
 	struct nvme_tcp_queue *queue = data;
 	struct nvme_tcp_ctrl *ctrl = queue->ctrl;
diff --git a/drivers/nvme/target/tcp.c b/drivers/nvme/target/tcp.c
index 8092ce4914b6..5064d1f6c28e 100644
--- a/drivers/nvme/target/tcp.c
+++ b/drivers/nvme/target/tcp.c
@@ -1865,7 +1865,8 @@ static int nvmet_tcp_tls_key_lookup(struct nvmet_tcp_queue *queue,
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

