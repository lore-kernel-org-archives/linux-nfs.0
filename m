Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495143;
	b=K1DmRHvrpxsma4DQZGXd6PtPU/8sdbFbBHwrSruSr8n+UzlOHnbhSvYRxC20U8lQW0wV
	 yLGmtrgGBFFQvJXw9+X4IixHbhHae1dMFnWg9+niVgXtXhlOYV3CUpAhxFUn4zgHMn/Vu
	 iGmD0UgdMZ1X3E34YZlv6cox4XfwBxjvbfV07i4sOdtYvZaytCiQvGftJXTi37ZLdTZal
	 RT+X1wehg4lF4Xs6W3IsQzEMhM944EuTv+uKvJgkJL7TnvdUG8jbxuG4iKljRKVkk2HF0
	 hNt9pMp167ID8ja2gdoxnl80W2dv+eHADGO+RMIJ0l4g5cW6k7GxSKgzI5mO7Gx/B+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495143;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=E0V3AyyWL6QZG90aiy2jEMAHEMmYHsBas5AW52wql4A=;
	b=pK4n+/VqiOZ7e1yknPKyjGpQLa5AMvThXccHO7Nb6Qw2jx6bba4hn4MTJeZMPSArsfKJ
	 I4buoUQ4Acmcmnvo4OzAnkXMFM/UGK4Jo/mEcrzN1iv1ETqGUEhsywVlfIXyU59q0FA9J
	 +6TAuWvbfql+GM3zaZQvAmxkIxmSb8hceuvfEnSD4SVXRPaZFIZUosabS79vW4xuPH82n
	 4gswhMu04A5K+K7+d3JDKVvSH1lSl8XZCm2a5yRomowcuFo3DryLcGy+W3rUjGqvpnr3b
	 nmFvKfVos2M4xLAVMTMTBNPrMBc/hJ4LQKJltR83vZJggWVrUlFWguqgQh1VbgWC3Nw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gBvVSWn6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16B1A606A31C;
	Thu, 12 Nov 2026 14:52:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gBvVSWn6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 213721F00A0A;
	Thu, 12 Nov 2026 14:52:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495142;
	bh=E0V3AyyWL6QZG90aiy2jEMAHEMmYHsBas5AW52wql4A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gBvVSWn6kyQwvFu2mpuSuXe5nMaNBIn/4CGEc6hdZxTtHG5ECrLDCDqcW3c7qOzIm
	 o9W12VGG5q8Tm0aJoKASE6m+bsTkCsqFMTX0MlBceRuUawKGZUC9yZIHa5ILC+xOpD
	 S7s/uBCbVJvgrO1MgPeJGtAiL5qFUij2IALgohtMhK/eT2mae7zvizZsaQj1x0w5ny
	 6kIb2uONzb6IM+hKzxdFaQeXIufXXssOla5O6WcK/Fb9vaQgs3bT1ktjkKkM4Lw7z+
	 lQqYVpdOGMA5IIc8P8uo7/hR5LCnqufMor2iwgYJbZI4vGhvwXMWlePSraXu1ICXVh
	 aLb0SqEGGudDw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:05 -0500
Subject: [PATCH net-next v2 01/10] handshake: Add tags to "done" downcall
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
Message-Id: <20261112-tls-session-tags-v2-1-a587a50de7fc@kernel.org>
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
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Hannes Reinecke <hare@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4028; i=cel@kernel.org;
 h=from:subject:message-id; bh=rMFD/1BNRQW7ATk8syeRlVpVXC9iYUiuLZkECUvx0bk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKgpyUWGZ4IOTTodhCQbaBmSwbcOxbdGtj3+
 5trYH5oCymJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 ly/DD/0YJZIakfAj72k94C2UskUuUW7PCPI68/HXH26G266GmS2W5VCUEOJn39rinNxTaXHfrLH
 Js+2pxzl9wswScBcgefnmJCRtMxWg29IocK0H9vRAMty+wUR+GxQrevWSQqWuyAEW1MphkY2cEg
 +NrIB9mkY5ns1VY670baP63JKcxw7dBlhflHRJuBNpBUxe6/1SEEiscMovp9/uFbQbbQlGcwZXf
 St+YWXMicF3QDsVYrKLpJ7HGIqaVtfqQH1Iz+vDRMjnXZaztXx+DfHgQaPJ8ihcOcDFd+39xymg
 3CBiPlWtylSGCRMXMAVI6kvjXjZZ7orgbLLuU1BFj0Sa5cBU9NGMO+cLS4Q2EFgTtQP13bQaxes
 W0xQhp77EdkUzrG44u+Hxvr5T6pO690JJbdm0XzkJD229U5MbZMQyHyYpyzl4ZiJjxntR6s8vAC
 j4ofC0rZlypnW9gAmmyiPa1iI+7XoIudatCNP5LZZ/Hax9Qo2BVOyxUJ6iJLNkYFyBgy5ianjLm
 5sm0eD9iTbka+VnmJBCT7IdKbytAB2pLaIux5tvxvrf/rJK3x0x+NhQTh2o/LzkgeVJ8RccKtLT
 ZMc+0BxSQ+/7NDBksAn2eO3r03I/SZhi+DUKKyRi/FIcGv112B0SC86+JZv9U/uJzqoa5nXE+pr
 i4ngSLJVj1DS8+w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

tlshd has no way to report certificate characteristics to the
kernel. An Upper Layer Protocol (such as NFS) therefore cannot
authorize access based on what a client's certificate contains.

For example, an export might be restricted to clients that present
certificates whose issuer DN contains "O=Oracle". tlshd can parse
incoming certificates, and add an "oraclegroup" tag to handshakes
where a client presents a certificate with "O=Oracle" somewhere in
its Issuer field. NFSD can then be configured to look for that tag
and permit access only when it is present. NFSD needs no knowledge
of x.509 certificates.

Plumb in the netlink protocol elements for tlshd to return a list
of tags to the kernel when a handshake succeeds. Subsequent patches
add tag extraction and storage in the handshake layer.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Hannes Reinecke <hare@kernel.org>
---
 Documentation/netlink/specs/handshake.yaml | 15 +++++++++++++++
 include/uapi/linux/handshake.h             |  3 +++
 net/handshake/genl.c                       |  5 +++--
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/Documentation/netlink/specs/handshake.yaml b/Documentation/netlink/specs/handshake.yaml
index 0498ada2dd97..17521b159e89 100644
--- a/Documentation/netlink/specs/handshake.yaml
+++ b/Documentation/netlink/specs/handshake.yaml
@@ -18,6 +18,10 @@ definitions:
     value: 4095
     header: linux/err.h
     scope: kernel
+  -
+    name: session-tag-max-len
+    type: const
+    value: 255
   -
     type: enum
     name: handler-class
@@ -96,6 +100,16 @@ attribute-sets:
         name: remote-auth
         type: s32
         multi-attr: true
+      -
+        name: tag
+        type: string
+        doc: >-
+          A tag the handshake agent assigns to this handshake. The
+          payload may omit the trailing NUL. An embedded NUL is
+          rejected.
+        checks:
+          max-len: session-tag-max-len
+        multi-attr: true
 
 operations:
   list:
@@ -133,6 +147,7 @@ operations:
             - status
             - sockfd
             - remote-auth
+            - tag
 
 mcast-groups:
   list:
diff --git a/include/uapi/linux/handshake.h b/include/uapi/linux/handshake.h
index f907aa082520..bbb9ea2fa4fb 100644
--- a/include/uapi/linux/handshake.h
+++ b/include/uapi/linux/handshake.h
@@ -10,6 +10,8 @@
 #define HANDSHAKE_FAMILY_NAME		"handshake"
 #define HANDSHAKE_FAMILY_VERSION	1
 
+#define HANDSHAKE_SESSION_TAG_MAX_LEN	255
+
 enum handshake_handler_class {
 	HANDSHAKE_HANDLER_CLASS_NONE,
 	HANDSHAKE_HANDLER_CLASS_TLSHD,
@@ -59,6 +61,7 @@ enum {
 	HANDSHAKE_A_DONE_STATUS = 1,
 	HANDSHAKE_A_DONE_SOCKFD,
 	HANDSHAKE_A_DONE_REMOTE_AUTH,
+	HANDSHAKE_A_DONE_TAG,
 
 	__HANDSHAKE_A_DONE_MAX,
 	HANDSHAKE_A_DONE_MAX = (__HANDSHAKE_A_DONE_MAX - 1)
diff --git a/net/handshake/genl.c b/net/handshake/genl.c
index 26e3efec64ca..7150b32a54c4 100644
--- a/net/handshake/genl.c
+++ b/net/handshake/genl.c
@@ -18,10 +18,11 @@ static const struct nla_policy handshake_accept_nl_policy[HANDSHAKE_A_ACCEPT_HAN
 };
 
 /* HANDSHAKE_CMD_DONE - do */
-static const struct nla_policy handshake_done_nl_policy[HANDSHAKE_A_DONE_REMOTE_AUTH + 1] = {
+static const struct nla_policy handshake_done_nl_policy[HANDSHAKE_A_DONE_TAG + 1] = {
 	[HANDSHAKE_A_DONE_STATUS] = NLA_POLICY_MAX(NLA_U32, MAX_ERRNO),
 	[HANDSHAKE_A_DONE_SOCKFD] = { .type = NLA_S32, },
 	[HANDSHAKE_A_DONE_REMOTE_AUTH] = { .type = NLA_S32, },
+	[HANDSHAKE_A_DONE_TAG] = { .type = NLA_STRING, .len = HANDSHAKE_SESSION_TAG_MAX_LEN, },
 };
 
 /* Ops table for handshake */
@@ -37,7 +38,7 @@ static const struct genl_split_ops handshake_nl_ops[] = {
 		.cmd		= HANDSHAKE_CMD_DONE,
 		.doit		= handshake_nl_done_doit,
 		.policy		= handshake_done_nl_policy,
-		.maxattr	= HANDSHAKE_A_DONE_REMOTE_AUTH,
+		.maxattr	= HANDSHAKE_A_DONE_TAG,
 		.flags		= GENL_ADMIN_PERM | GENL_CMD_CAP_DO,
 	},
 };

-- 
2.56.0

