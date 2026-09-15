Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47D314BD7B2;
	Tue, 15 Sep 2026 16:58:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789491509; cv=none; b=hJysyLaQpDZ2iDQxU7evhfo6sAzPbtAO7cHIjbthb00nzk660oeJu8DcVvccoFBknKdi5KtjJpuzmbWm6zp2lwCWrogBV/ga2atv6NGHs22vuasWdaDlc9GgBkU3hBphik168hmYFFKQdoVPlQnha209wuVmPPBnWxnZ3x3Ti1g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789491509; c=relaxed/simple;
	bh=dYm5b7B6dTvNKjVYzuF7/FkF8IDWphASM2cJV/5trG4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=qQI3IAF5XerXeH4lAunpf8U0wvUd5NGajfGy233/ZqDjTT8tH2guvOTuwaK2wmQ0kk+fzSJtJ+9JhcVBv9h9KKmrD3t0cnR/ZqMOzJvZmp7qRT3OzPFpaG8mALptTWYt5KFHWgygbhCb+k6JYUtcxPoCiPIr1vs+cv3kwtI7WqU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QwEPeT1G; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QwEPeT1G"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9A7F91F000FF;
	Tue, 15 Sep 2026 16:58:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789491504;
	bh=QH3G09fgNYNq57/vr1pk3tneJpQFCpXfha0cp9uQYVE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QwEPeT1G5yzGOEs6JBwSCHBG5dch1Tzz+85h6zZC6Y9IOenhqyKSHxCVbgWShAQ7c
	 +4nDgaITsiy85liG7dSftQxK1PnIZrPOC1Bnmct2AmkPiqZ/+I0UgJNEhpSYSNzqLx
	 /nM/fCeyF3Gx/4ezfkATRc3p2fEzsOfUILq4do8Turr27QK1tFAg77HHiCZE8kEIIG
	 UJGex8TjaaEVkwY3e1ingNct0b65ii5qmCgUrryBrtCjApcgACH32fmYb0LG9dk5wP
	 t9ht3FG+QMdF6plIWzgsHNf+31hD4513TCNwuLlh5QfroLA9sBVd10rnnR/y3uNlvs
	 4ij+RtQo8Xvmw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 15 Sep 2026 12:57:43 -0400
Subject: [PATCH v3 2/5] NFSD: add a userspace-rpcbind flag to listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260915-nfsd-norpcb-v3-2-3c60d49ade02@kernel.org>
References: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
In-Reply-To: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5624; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=dYm5b7B6dTvNKjVYzuF7/FkF8IDWphASM2cJV/5trG4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqXkqChjh9OPXC2JsyxmEeUx1A2eWY/elWVW6R
 SSUZwFwGLGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaql5KgAKCRAADmhBGVaC
 FfTuEAC67d83B7EffeZGDCzLcuZCZZgVK4eV7V7YF6icKZXxv9AFBm8Q9JF2h2uopkG9CsrOwLm
 g58HbXcSqzT+5M7mm8giNhgkxQObJAPXRGODJRNwOVOR8oDLBu+mFOUl025eGV5veYWmeWVn7nq
 rJfIo/sm38QCaSi8/p2HhjppXvU1/K4nRyRrS5Yzu0SlKh+cLBh4o6MU+Lq4z01+vRu220Oe/8y
 znndLfYBUcPIfBz7vNsMxQu2aohTR5D9hpVr6F80I2nUea7KwsrvdFG9jyPGwm2JdPZO8rab1Gw
 WQfBqKBCKKvakUCw9nH0AYFjM+d5K3p9zQnwFkPNHZ061ak7xG6YlHCy6eisO8sWC8ZXC5HySB3
 wo7ejcuEyrjg4KFHxGAUCRzB0DSramQ5Q7oaTwlRLXFebpAJ1TFtLGGDyOlwPRzX7reEFuNTHxt
 V+f/PlbNz0rEthOnhzOsWIsMl7M8qSVS8XfuGIqz3CtppXT8BuSiD7H40VEspSLP/kQe3jgfdqb
 rfv2DK8UpId7XPuoZTAnKM4SbJC4SbhSi/ipVEQt8/gBd5tBjfqdzzHbG4tr1LP84d2upHdcz13
 ACaoIO0IsiQ/JTHPpiQoI90HF2Pmb6f8cyL44QtezeCrToFZpSNs/8XFHXt+Uq9tF6FdSNhesDu
 qs3G5VdlHRj8Zug==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Describe the interface that lets a caller take over rpcbind registration.

The request gains a userspace-rpcbind flag. The reply echoes the flag,
lists the programs and versions that the caller should register, and
names the listeners that came up.

NLM is absent. lockd owns its own svc_serv and still registers itself.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 Documentation/netlink/specs/nfsd.yaml | 55 ++++++++++++++++++++++++++++++++++-
 fs/nfsd/netlink.c                     |  5 ++--
 include/uapi/linux/nfsd_netlink.h     | 20 +++++++++++++
 3 files changed, 77 insertions(+), 3 deletions(-)

diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 642268819c6f..9ae37bf3ea71 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -42,6 +42,15 @@ definitions:
       - none
       - tls
       - mtls
+  -
+    type: flags
+    name: rpcbind-flags
+    doc: >-
+      Constraints that apply to an rpcbind registration. no-udp means the
+      kernel would not have registered this program and version over UDP,
+      so the caller must skip the udp and udp6 netids for it.
+    entries:
+      - no-udp
 
 attribute-sets:
   -
@@ -159,6 +168,23 @@ attribute-sets:
       -
         name: transport-name
         type: string
+  -
+    name: rpcbind
+    attributes:
+      -
+        name: program
+        type: u32
+        doc: RPC program number to register.
+      -
+        name: version
+        type: u32
+        doc: RPC version number to register.
+      -
+        name: flags
+        type: u32
+        enum: rpcbind-flags
+        enum-as-flags: true
+        doc: Constraints on the listeners this entry applies to.
   -
     name: server-sock
     attributes:
@@ -167,6 +193,24 @@ attribute-sets:
         type: nest
         nested-attributes: sock
         multi-attr: true
+      -
+        name: userspace-rpcbind
+        type: flag
+        doc: >-
+          The caller registers the listeners with rpcbind itself, so the
+          kernel must not do it. The kernel echoes this attribute in the
+          reply when it accepts the request. Ownership cannot change while
+          a server exists.
+      -
+        name: rpcbind
+        type: nest
+        nested-attributes: rpcbind
+        multi-attr: true
+        doc: >-
+          A program and version that the caller should register for every
+          listener reported in the same reply, except the netids that flags
+          rules out. Reply only. NLM is absent because lockd still
+          registers itself.
   -
     name: pool-mode
     attributes:
@@ -483,13 +527,22 @@ operations:
             - version
     -
       name: listener-set
-      doc: set nfs running sockets
+      doc: >-
+        set nfs running sockets. A request that carries userspace-rpcbind
+        is answered with a reply rather than a bare ack, and the addr list
+        in that reply names only the listeners that have an rpcbind netid.
       attribute-set: server-sock
       flags: [admin-perm]
       do:
         request:
           attributes:
             - addr
+            - userspace-rpcbind
+        reply:
+          attributes:
+            - addr
+            - userspace-rpcbind
+            - rpcbind
     -
       name: listener-get
       doc: get nfs running listeners
diff --git a/fs/nfsd/netlink.c b/fs/nfsd/netlink.c
index eba8b353f412..88a4a4ffcb7f 100644
--- a/fs/nfsd/netlink.c
+++ b/fs/nfsd/netlink.c
@@ -79,8 +79,9 @@ static const struct nla_policy nfsd_version_set_nl_policy[NFSD_A_SERVER_PROTO_VE
 };
 
 /* NFSD_CMD_LISTENER_SET - do */
-static const struct nla_policy nfsd_listener_set_nl_policy[NFSD_A_SERVER_SOCK_ADDR + 1] = {
+static const struct nla_policy nfsd_listener_set_nl_policy[NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND + 1] = {
 	[NFSD_A_SERVER_SOCK_ADDR] = NLA_POLICY_NESTED(nfsd_sock_nl_policy),
+	[NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND] = { .type = NLA_FLAG, },
 };
 
 /* NFSD_CMD_POOL_MODE_SET - do */
@@ -153,7 +154,7 @@ static const struct genl_split_ops nfsd_nl_ops[] = {
 		.cmd		= NFSD_CMD_LISTENER_SET,
 		.doit		= nfsd_nl_listener_set_doit,
 		.policy		= nfsd_listener_set_nl_policy,
-		.maxattr	= NFSD_A_SERVER_SOCK_ADDR,
+		.maxattr	= NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
 		.flags		= GENL_ADMIN_PERM | GENL_CMD_CAP_DO,
 	},
 	{
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index 87da1d0bb21e..c125af0cc6a5 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -50,6 +50,15 @@ enum nfsd_xprtsec_mode {
 	NFSD_XPRTSEC_MODE_MTLS = 4,
 };
 
+/*
+ * Constraints that apply to an rpcbind registration. no-udp means the kernel
+ * would not have registered this program and version over UDP, so the caller
+ * must skip the udp and udp6 netids for it.
+ */
+enum nfsd_rpcbind_flags {
+	NFSD_RPCBIND_FLAGS_NO_UDP = 1,
+};
+
 enum {
 	NFSD_A_CACHE_NOTIFY_CACHE_TYPE = 1,
 
@@ -113,8 +122,19 @@ enum {
 	NFSD_A_SOCK_MAX = (__NFSD_A_SOCK_MAX - 1)
 };
 
+enum {
+	NFSD_A_RPCBIND_PROGRAM = 1,
+	NFSD_A_RPCBIND_VERSION,
+	NFSD_A_RPCBIND_FLAGS,
+
+	__NFSD_A_RPCBIND_MAX,
+	NFSD_A_RPCBIND_MAX = (__NFSD_A_RPCBIND_MAX - 1)
+};
+
 enum {
 	NFSD_A_SERVER_SOCK_ADDR = 1,
+	NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
+	NFSD_A_SERVER_SOCK_RPCBIND,
 
 	__NFSD_A_SERVER_SOCK_MAX,
 	NFSD_A_SERVER_SOCK_MAX = (__NFSD_A_SERVER_SOCK_MAX - 1)

-- 
2.55.0

