Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597734;
	b=sovHdit2RqmLpWJkp0aEqdzFlnhxTdncLuYSvfEPfTECuzM3Fk26chCLc1MxUxYQQyJa
	 hBEVApbkSQSY6fNCKMqPL4aok0D8Iq1BQsHPMe/IQhR1CHFft9DGiSijm0CLm6y+FcfAd
	 OVsDIG1RPxhyj/UOmP2+f4fFbEi9WkExtln0azWwpxM0OWfCXn1P52lOspWrdn+pkusrb
	 vhayu+ken+MplxaA1fVccJk0+1XDUXKQqJ5Guti39iIg+Ow610Hxfz4/yYEo+6EMn+uGu
	 tp6oGFg4tqnqsTdGX956eoq9jrDo+/9R5SXC8YSYi7ZEHPLkA32Iz5/GL59tLvQ2Q/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597734;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=E0V3AyyWL6QZG90aiy2jEMAHEMmYHsBas5AW52wql4A=;
	b=yHTja2hpfTJlemvw8xehvaB3h9F/Sx4h2iIvLPRfBV/2deKv4nyvx1Fh2GJqfCT73Huv
	 JHfO3NuGNCWoGjAbYFoQnI5yKTc8MP2FxbXlEZq0P7syJkmzJvOwPDkEbLsZ7aN1AeSzH
	 fC+dgwOA7garuEgI90ie+4ihLzvRTk/QyvD1x/d9Vi3Ff612ZTKMgUgFdnPcVaL9v91iv
	 JUi8F6kceJ4fJL5nRVQnlTjo0eohEVOrWYHp+sAxy3+c5nF97dhp8uYox6O869WtjvJHL
	 kQzc98rvrtFb36eqyx/UqLcxJA/Or5ZuPvL++NmK4nJpqcCtAeX27jcefK+tJ8fa5ew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=A+v8axL5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 481B1606A898;
	Fri, 13 Nov 2026 19:22:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=A+v8axL5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D7451F000C6;
	Fri, 13 Nov 2026 19:22:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597733;
	bh=E0V3AyyWL6QZG90aiy2jEMAHEMmYHsBas5AW52wql4A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=A+v8axL5XJUbMExJtnlMGuVgQVClMVGfUnXz2K/6HqRWyxF+EgBq2nJr5P5rb44nw
	 uWjU+dOEPSE6oEQ+W2YYPYjvhZLYVk+BYw+7cZr8LGjEvEcomPWLq1qPpNw7Y7x/Ta
	 i4BeUPnsClhMGdFDfLHrIDXpGH8SIBgCQw4rfLihY0tAf8v4BZ/0DrUvsyAliUD4TV
	 urhc39QWqTzhJ7nAdWmcPeUkQVQVnnmMQxSlEL48vzx6KOOiolmZCWhTlc82f4nXe8
	 if7kJ3nhiheRr1lrXu+VMoTRKTrAGj25Pv0pRrqOBVaZ8r3Nr++JVrwlpKkQnDktOK
	 myIH1tAvLSz+Q==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:21:59 -0500
Subject: [PATCH net-next v3 01/10] handshake: Add tags to "done" downcall
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
Message-Id: <20261113-tls-session-tags-v3-1-91271964cdb0@kernel.org>
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
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Hannes Reinecke <hare@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4028; i=cel@kernel.org;
 h=from:subject:message-id; bh=rMFD/1BNRQW7ATk8syeRlVpVXC9iYUiuLZkECUvx0bk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92NfrdmxhlvPypvfugdPdrZBx6LIjKHYFTHZZ
 ZREgi0wsHuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjXwAKCRAzarMzb2Z/
 l9m1EACWbuppa6esWaDb3W/KxBerqeQmBDdYY3pzaQdimV7cknrXrPReYhKH4Sl+c1oVrHTRk9W
 JXjVNxVC1GjqpOqd1cO6hyfxH+PLiFt6cg0eff+VKyIPwwmFLJ1Ss5r9a8C1Da5D/WH+QybZ1lZ
 OI3xmEiR7EZHWY7FUDsyqYbTT8duAGWWK1KcIIg8/z/uXWqDHtmUWe8G1KP+enhuG1CmeEdqqdr
 AA2SZpJpK9+4/d+R57CHVeK8cUhY4NPZ2CbTh7iYORCeKrPcnFXyI79nIcaQinysiz26LoG8Vjj
 IulWFiMGk0dQ3wmvXTTfmI0arxlf7AUqarN4v1P5Hx1VnvEaPrLbY7hqsXAPKJXGz99T83v6wD+
 slFe16Kdr7GchwfyPJnktACh0TioFUEeSvARNSqaNOiDAMS7IVW6nrn6j3ucB8QnbD6hebLtFbq
 NOyv4jL5Uy+M7Rc3DfFgl15DXuXB7pKhM2EVBLdteBdn+a1AmnwbYBn9UhOdnyMdYSbZ/FoV9pN
 LrbhQ/fi6Mz/mqmNPV0XI2OP3JhdS0HY47CUbWVJBLN4QLgpci3pql2O6mcTDR0uBL8s6UnAxwC
 5zz+ida6X2vL5VN4YPrKPmUC3ORwg+lrCQ8ff3eQMUSFrh2bMqpoezRibsgkk2w/26ZDolRbvIg
 vS7R/3Mw1knukFQ==
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

