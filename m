Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A33B9577E41;
	Thu, 10 Sep 2026 18:00:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789063256; cv=none; b=X9IykVJ09MbQh2BCKCXj3WS2OjQSqyxnLm0VTOOVuXsVmhDOT1cNtB7P531e9LQ7CvWbmNNMNVLcUEJV8aiRRyRNba7BHh6Z5PhjHg8h8LIX4BmJyAmTJvAZB3xtxIwpzzxBVBSP86e5q5JdbTV7+9mE80kKAQt0r9qYxC+EQBw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789063256; c=relaxed/simple;
	bh=dYm5b7B6dTvNKjVYzuF7/FkF8IDWphASM2cJV/5trG4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=kWBtCKn1Q87rT4ymdW+KEr7yCn679+DdWWOOG1N1ZAFDgEvUjJU6VT5efUUDn5o2EOIYFAHLfEecP9wOTdg+m+CI6J4WY9FOlyl94nJHqf4sbMolCYozBemiFBCgJJN7kY/MpS3jwmKRQrurQ+JVD5dYzMqOnh3WUDmhHHokd1M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Q/morVwf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Q/morVwf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C3D871F0089A;
	Thu, 10 Sep 2026 18:00:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789063254;
	bh=QH3G09fgNYNq57/vr1pk3tneJpQFCpXfha0cp9uQYVE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Q/morVwfPM5FKSX/dcLsyMDO/e12v9+T3J11hCysgzSLB589D7QZ10gxtmqrJAG/b
	 5K9k6xR/j4Mw0dcZSFmC6Kq2KelfydKltrrn5OcX0IxuWI5wSG4nElHEedzk9/rngb
	 YgFMexodG/DrDdkxXCsy9QeDF60/0/+dO6QEcM0kpGlg7l1YkIdp5xij8Q6PW85vGW
	 GVfLioSMGgALzzreDpMgnAQy2ykZSMSc5Sv1ptWEwbBHKOZ15SNm2UVFRUIx7A+tYU
	 yOKMtFn8eaJ0YjsNpUsmyoWJ8RO0PLdiyOAvE7UVrwhpSgTS4vWp4ltJTzr4S+ZXnA
	 trIi0Omfkv5OA==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:00:35 -0400
Subject: [PATCH 2/5] NFSD: add a userspace-rpcbind flag to listener_set
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsd-norpcb-v1-2-b4d5182d634c@kernel.org>
References: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
In-Reply-To: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
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
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovBPj/3xfeqAtK2malIwl/EFi7tMqrHBdBUsM
 bigld4kDDyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqLwTwAKCRAADmhBGVaC
 FbQxEACA+tPV6VAkVXrCrfqK3o0ASvd4vQyEHinNptRbc0OwwnCXDvHmqknhGH8QztPkxp83SQT
 A/+GOmCXq4Od+FFeKQ6qL9/gZqPA7bejsSt89cGKVNoOgit5Z9gx5al782YO/WEkADBiWBEreL/
 RtFOUIzJTi6roDPfMCyAazQtk5jjNWOhbZ/o5QcJaKOXds2s1hb6PhxQOgQibc3Ipzqtv+mrdZF
 Aqx1RLHVjreHRkjKqKbUbeuTjTvgFM+STJV8YueLk7acDvnva8BsF057mCHnkrRF4cDtfQjovDV
 D0gOtQQWS1mZt9lnQTzfoVnRGQ+KFawO7nPa5v1/Cj62/8k3rhuM5X4OhPLory/aUPVa/ITqIro
 PlOJZu+jZpH208fajwWy9XANgBqRZuI+svHbruDnH4TfRoc80o1kYhxPyFQnZVaU2AX1fV/2MYW
 yAf3ajkXiahCVxHKKAg8mnrkjVRPpLZ4E2Nwo98buZmwoQkmQucB7T7OYcdC7+YBjyPEcvska06
 +AWxUcQJnHkxdZ6wmY8eDZ/2aBXNl0fbO9Sq8d7lB6SG3usk9MRNWNYJ7cR8YErOFSqfJ0yzn8Q
 kkSo3wo4t1AnV46v1+7Y6tOzbT7Fnv76oC9zARssmTu9LgoI3QJ/zONT2/IOrUKJAZiyTxsc5pD
 KkoLAwyk6fZuIkw==
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

