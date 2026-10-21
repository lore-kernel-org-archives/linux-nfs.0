Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792583064;
	b=2T9gcR+H3RkiCdYS/N0I8iMfltpyklicseDFfnP+h0HLo9pWIP1PgXFJ3vxiSnWbw8mu
	 0xNWugoyptOFq0kw3t2U8g92enadZDDqegFVW614jExRsyRTsrl5am8TPDiOYpCI5z2l1
	 hvXSfoTWf3GqNcEl9yK2M1x++8bTGbs54jKLktMg657KRSiJujxGymdCmxP+agLmPJmf+
	 AtiHyPbeUw4hlKrxT367E1YOSUdYIvOlpT4hN9lwrmllOOkfjBJRNYL/kH3pBJY1Mpl6B
	 HhV9hQBRA5HAEsoSe40/hF8c2710i4+z+x5VPgg/y12GutXrEtd7aCp6VALyax8xR1A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792583064;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TkZurcPKDZBZyfWIts4MEXVTWQ0qmZO4rf7ffzawFiI=;
	b=wPom2JJkhLxnRvbjmAji9BX52nzSSNzXJrXXSUaxFkFxCRon7nqnGzmd9V5hdGfKV883
	 AXVZ6st6ba4B7F43yoXXlmOUlbkAd5BCKNyBo1GjhcVPGzftERxuat1MD9lgUE5wEoYoa
	 39TdCXbhocjqnIJwjnPOpivdUA1QJtgIRIMDJy9L5W9mpY3m/RR7lZC6g/Mf/vR8NreT9
	 nqjrAWVMiwuBIf0vu+xLbW3iUamI18T3IMK7LxYGZ0YBJpgEUMebImhb21PApAvaYkkc0
	 4Fy2vs+uwwh/pIRpbMbM0UMLomAVNfde8cUJuPi/j0h50pFGk7gaWT7TGsTsiD7t8vA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kY4bYoAL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF3C7606A319;
	Wed, 21 Oct 2026 11:44:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kY4bYoAL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D24EB1F000C4;
	Wed, 21 Oct 2026 11:44:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792583063;
	bh=TkZurcPKDZBZyfWIts4MEXVTWQ0qmZO4rf7ffzawFiI=;
	h=From:Date:Subject:To:Cc;
	b=kY4bYoALLvEALm+6tyqbTmK8RQL59Es2+0eyxSnSimBxB6XRZ85zuUeOnhrDfEg87
	 w3p4zjGsofpWWufs5k7ye2O/jlLfFneKsylE/b7giHHyLa/x2MC/ya8DpNnUecnLNL
	 W6ADDWGlC0etWKLnKdyCy2Z/Wid7l8nN91W1tNYCnDXuLx0Yqdmyl1jgrLDJS33ahG
	 kY4rsJpwwbCqp9XOHVD1MjA8yCBATFZQfyoacFQafdpkomy9Dy+rsic8mnPZ76dtXm
	 K1oLu0cEAz4K7VrDJ5Xu1ecEFomzr3QY9RtY9ADQbLOG3QhglV8tEAeuxV6VGylFil
	 SBt8a1Ty0AjVA==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 21 Oct 2026 07:44:13 -0400
Subject: [PATCH v2] nfsd: add NFSD_CMD_FILEHANDLE_GET for root filehandle
 lookup
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
Message-Id: <20261021-nfsd-filehandle-get-v2-1-bd7fc8b1b783@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/32NQQ6CMBBFr0Jm7ZhpoUhceQ/DAssUJjbFtIRoS
 O9u5QAu3//57++QOAonuFY7RN4kyRIK6FMFdh7CxChjYdCkW0WaMLg0ohPPpR0948QrGst1Q81
 l0FRDWb4iO3kf1ntfeJa0LvFznGzql/73bQoVdtY0rtWmI3rcnhwD+/MSJ+hzzl965nG8twAAA
 A==
X-Change-ID: 20261020-nfsd-filehandle-get-5ce34047a203
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nfs@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=21435; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=xLHi9Nux77lfcUz/azvdFk3AVI1fASFN2eZRj0r3EWc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq2KWQqnY/YWRhyXJIUv5Z1xnvHpC+zgFKYVrQu
 7tWaz9EVG+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatilkAAKCRAADmhBGVaC
 FYreD/9He9NREJdjEFAqG5657CQGunBRbAkzamdYZJ/lXjeBiehvMJL65WedntWRw9EKkuxbgvI
 6Ke6w5A76I+J9AizS0PnsRMXqAwRLogDY9hGFk0z0nDAgVuOu30nhSocpFuDCEK7N6niFHtBG4l
 yt9VOuhinuVWO3hVso8HSkSOPTi6ULaKb8re5Buc/iPItLZCsJ9r55HmbkKb4IvXZoQc9KWg0J6
 BeY4AOIQqM8F1/GTD/bBuXfDC9Ow0dks2LD9MfjjdN3iDVbbwbO02E/vMQ/B9f276IW4xm0WK2V
 wkuwspjivKXNJ2S5zFfoZ0nMvaLE3g/1GZT1aHDTcGXtMzL/tYR9HYpWjcUlaboPIQeCWb6lUNn
 L9h3UDS+5X9zEJ+kshXGULJn6LsvvGCHTzNmiVbq60Z1w5wVMI38QD+fiCT2Yym4Lk3Md1eb4sD
 6DTYDyGDhKpecFbN6oaFKOlg6OOrW9va5u0E1WQDGUVku0ErrsmY6UAS1GKapYwRTagvFGjytr7
 9dEy2506KfO1TwGpbLvy3t1kFDpTyo2O9nBEXHMZZGbqFuYCVU6/OnZNfk2AZ2Nchz6r4SNAGQx
 7gVsezTl05bYJXDMzsRnqjCNDU0+H98TyUNX9X4bAmMlEmI/OLzpzk8IHxghUxsmNJgkRJtKxWO
 FeCHLD5cCGm4QPw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

rpc.mountd still fetches export root filehandles via the
/proc/fs/nfsd/filehandle transaction interface to satisfy v2/3 MNT
requests.

Add a netlink equivalent:

FILEHANDLE_GET takes domain, path and maxsize and replies with the
composed handle, like write_filehandle(). Unlike /proc, which silently
clamps maxsize to NFS3_FHSIZE, maxsize outside [NFS_FHSIZE, NFS3_FHSIZE]
is rejected with -ERANGE. Include a kselftest covering validation and
byte-parity with the /proc interface.

Reviewed-by: Jakub Kicinski <kuba@kernel.org> # ynl
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
This update just fixes a few things that Chuck noticed in review.
---
Changes in v2:
- Reject maxsize > NFS3_FHSIZE (-ERANGE) instead of silently clamping
- selftest: skip the "\x" prefix when parsing the /proc reply
- selftest: remove the mount dir when mount(2) fails
- selftest: add nfsd_netlink_filehandle to .gitignore
- selftest: push an explicit fsid so provisioning works on a tmpfs /tmp
- Link to v1: https://patch.msgid.link/20261020-nfsd-filehandle-get-v1-1-8c54f625800b@kernel.org
---
 Documentation/netlink/specs/nfsd.yaml              |  50 +++
 fs/nfsd/netlink.c                                  |  15 +
 fs/nfsd/netlink.h                                  |   2 +
 fs/nfsd/nfsctl.c                                   |  62 ++++
 include/uapi/linux/nfsd_netlink.h                  |  11 +
 tools/testing/selftests/nfsd/.gitignore            |   1 +
 tools/testing/selftests/nfsd/Makefile              |   1 +
 .../selftests/nfsd/nfsd_netlink_filehandle.c       | 378 +++++++++++++++++++++
 8 files changed, 520 insertions(+)

diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 9ae37bf3ea71..a4991206b45e 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -51,6 +51,11 @@ definitions:
       so the caller must skip the udp and udp6 netids for it.
     entries:
       - no-udp
+  -
+    type: const
+    name: nfsclnt-idmax
+    value: 1024
+    header: linux/nfsd/export.h
 
 attribute-sets:
   -
@@ -460,6 +465,33 @@ attribute-sets:
         nested-attributes: server-proc-entry
         multi-attr: true
 
+  -
+    name: filehandle
+    attributes:
+      -
+        name: domain
+        type: string
+        doc: Client domain name the export is visible to.
+        checks:
+          max-len: nfsclnt-idmax
+      -
+        name: path
+        type: string
+        doc: Pathname of the export whose root filehandle is requested.
+        checks:
+          max-len: 4095 # PATH_MAX - 1
+      -
+        name: maxsize
+        type: u32
+        doc: Largest filehandle the caller can accept, in bytes.
+        checks:
+          min: 32 # NFS_FHSIZE
+          max: 64 # NFS3_FHSIZE
+      -
+        name: handle
+        type: binary
+        doc: The composed root filehandle. Reply only.
+
 operations:
   list:
     -
@@ -681,6 +713,24 @@ operations:
             - proc4ops-ops
             - proc4cb-ops
 
+    -
+      name: filehandle-get
+      doc: >-
+        Look up the root filehandle of an export for a client domain.
+        Netlink equivalent of the /proc/fs/nfsd/filehandle transaction
+        interface used by rpc.mountd.
+      attribute-set: filehandle
+      flags: [admin-perm]
+      do:
+        request:
+          attributes:
+            - domain
+            - path
+            - maxsize
+        reply:
+          attributes:
+            - handle
+
 mcast-groups:
   list:
     -
diff --git a/fs/nfsd/netlink.c b/fs/nfsd/netlink.c
index 88a4a4ffcb7f..4ea6a7c1ce7f 100644
--- a/fs/nfsd/netlink.c
+++ b/fs/nfsd/netlink.c
@@ -10,6 +10,7 @@
 #include "netlink.h"
 
 #include <uapi/linux/nfsd_netlink.h>
+#include <linux/nfsd/export.h>
 
 /* Common nested types */
 const struct nla_policy nfsd_auth_flavor_nl_policy[NFSD_A_AUTH_FLAVOR_FLAGS + 1] = {
@@ -119,6 +120,13 @@ static const struct nla_policy nfsd_unlock_export_nl_policy[NFSD_A_UNLOCK_EXPORT
 	[NFSD_A_UNLOCK_EXPORT_PATH] = { .type = NLA_NUL_STRING, },
 };
 
+/* NFSD_CMD_FILEHANDLE_GET - do */
+static const struct nla_policy nfsd_filehandle_get_nl_policy[NFSD_A_FILEHANDLE_MAXSIZE + 1] = {
+	[NFSD_A_FILEHANDLE_DOMAIN] = { .type = NLA_NUL_STRING, .len = NFSCLNT_IDMAX, },
+	[NFSD_A_FILEHANDLE_PATH] = { .type = NLA_NUL_STRING, .len = 4095, },
+	[NFSD_A_FILEHANDLE_MAXSIZE] = NLA_POLICY_RANGE(NLA_U32, 32, 64),
+};
+
 /* Ops table for nfsd */
 static const struct genl_split_ops nfsd_nl_ops[] = {
 	{
@@ -231,6 +239,13 @@ static const struct genl_split_ops nfsd_nl_ops[] = {
 		.dumpit	= nfsd_nl_server_stats_get_dumpit,
 		.flags	= GENL_CMD_CAP_DUMP,
 	},
+	{
+		.cmd		= NFSD_CMD_FILEHANDLE_GET,
+		.doit		= nfsd_nl_filehandle_get_doit,
+		.policy		= nfsd_filehandle_get_nl_policy,
+		.maxattr	= NFSD_A_FILEHANDLE_MAXSIZE,
+		.flags		= GENL_ADMIN_PERM | GENL_CMD_CAP_DO,
+	},
 };
 
 static const struct genl_multicast_group nfsd_nl_mcgrps[] = {
diff --git a/fs/nfsd/netlink.h b/fs/nfsd/netlink.h
index 027e2953db26..57fc86c63b1d 100644
--- a/fs/nfsd/netlink.h
+++ b/fs/nfsd/netlink.h
@@ -11,6 +11,7 @@
 #include <net/genetlink.h>
 
 #include <uapi/linux/nfsd_netlink.h>
+#include <linux/nfsd/export.h>
 
 /* Common nested types */
 extern const struct nla_policy nfsd_auth_flavor_nl_policy[NFSD_A_AUTH_FLAVOR_FLAGS + 1];
@@ -44,6 +45,7 @@ int nfsd_nl_unlock_filesystem_doit(struct sk_buff *skb, struct genl_info *info);
 int nfsd_nl_unlock_export_doit(struct sk_buff *skb, struct genl_info *info);
 int nfsd_nl_server_stats_get_dumpit(struct sk_buff *skb,
 				    struct netlink_callback *cb);
+int nfsd_nl_filehandle_get_doit(struct sk_buff *skb, struct genl_info *info);
 
 enum {
 	NFSD_NLGRP_NONE,
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9327b6289904..85f0ad7429fa 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2943,6 +2943,68 @@ int nfsd_nl_unlock_export_doit(struct sk_buff *skb, struct genl_info *info)
 	return error;
 }
 
+/**
+ * nfsd_nl_filehandle_get_doit - look up the root filehandle of an export
+ * @skb: reply buffer
+ * @info: netlink metadata and command arguments
+ *
+ * Netlink equivalent of the /proc/fs/nfsd/filehandle transaction interface:
+ * compose the root filehandle for @path as visible to client @domain,
+ * no larger than @maxsize bytes.
+ *
+ * Return: 0 on success or a negative errno.
+ */
+int nfsd_nl_filehandle_get_doit(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct auth_domain *dom;
+	struct knfsd_fh fh;
+	char *dname, *path;
+	u32 maxsize;
+	void *hdr;
+	int err;
+
+	if (GENL_REQ_ATTR_CHECK(info, NFSD_A_FILEHANDLE_DOMAIN) ||
+	    GENL_REQ_ATTR_CHECK(info, NFSD_A_FILEHANDLE_PATH) ||
+	    GENL_REQ_ATTR_CHECK(info, NFSD_A_FILEHANDLE_MAXSIZE))
+		return -EINVAL;
+
+	dname = nla_data(info->attrs[NFSD_A_FILEHANDLE_DOMAIN]);
+	path = nla_data(info->attrs[NFSD_A_FILEHANDLE_PATH]);
+	maxsize = nla_get_u32(info->attrs[NFSD_A_FILEHANDLE_MAXSIZE]);
+
+	trace_nfsd_ctl_filehandle(net, dname, path, maxsize);
+
+	dom = unix_domain_find(dname);
+	if (!dom)
+		return -ENOMEM;
+
+	err = exp_rootfh(net, dom, path, &fh, maxsize);
+	auth_domain_put(dom);
+	if (err)
+		return err;
+
+	skb = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	err = -EMSGSIZE;
+	hdr = genlmsg_iput(skb, info);
+	if (!hdr)
+		goto err_free_msg;
+
+	err = nla_put(skb, NFSD_A_FILEHANDLE_HANDLE, fh.fh_size, fh.fh_raw);
+	if (err)
+		goto err_free_msg;
+
+	genlmsg_end(skb, hdr);
+	return genlmsg_reply(skb, info);
+
+err_free_msg:
+	nlmsg_free(skb);
+	return err;
+}
+
 /**
  * nfsd_net_init - Prepare the nfsd_net portion of a new net namespace
  * @net: a freshly-created network namespace
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index c125af0cc6a5..dcd2126d848b 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -280,6 +280,16 @@ enum {
 	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)
 };
 
+enum {
+	NFSD_A_FILEHANDLE_DOMAIN = 1,
+	NFSD_A_FILEHANDLE_PATH,
+	NFSD_A_FILEHANDLE_MAXSIZE,
+	NFSD_A_FILEHANDLE_HANDLE,
+
+	__NFSD_A_FILEHANDLE_MAX,
+	NFSD_A_FILEHANDLE_MAX = (__NFSD_A_FILEHANDLE_MAX - 1)
+};
+
 enum {
 	NFSD_CMD_RPC_STATUS_GET = 1,
 	NFSD_CMD_THREADS_SET,
@@ -300,6 +310,7 @@ enum {
 	NFSD_CMD_UNLOCK_FILESYSTEM,
 	NFSD_CMD_UNLOCK_EXPORT,
 	NFSD_CMD_SERVER_STATS_GET,
+	NFSD_CMD_FILEHANDLE_GET,
 
 	__NFSD_CMD_MAX,
 	NFSD_CMD_MAX = (__NFSD_CMD_MAX - 1)
diff --git a/tools/testing/selftests/nfsd/.gitignore b/tools/testing/selftests/nfsd/.gitignore
index 7ac844d0fd57..93a8f31ae2ea 100644
--- a/tools/testing/selftests/nfsd/.gitignore
+++ b/tools/testing/selftests/nfsd/.gitignore
@@ -1,4 +1,5 @@
 nfsd_lockd_netlink
+nfsd_netlink_filehandle
 nfsd_netlink_listener
 nfsd_netns_isolation
 nfsd_netns_stress
diff --git a/tools/testing/selftests/nfsd/Makefile b/tools/testing/selftests/nfsd/Makefile
index e74bb3424d45..25c9346954be 100644
--- a/tools/testing/selftests/nfsd/Makefile
+++ b/tools/testing/selftests/nfsd/Makefile
@@ -2,6 +2,7 @@
 CFLAGS += $(KHDR_INCLUDES) -Wall
 
 TEST_GEN_PROGS := nfsd_netlink_listener
+TEST_GEN_PROGS += nfsd_netlink_filehandle
 TEST_GEN_PROGS += nfsd_lockd_netlink
 TEST_GEN_PROGS += nfsd_netns_isolation
 TEST_GEN_PROGS += nfsd_netns_stress
diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_filehandle.c b/tools/testing/selftests/nfsd/nfsd_netlink_filehandle.c
new file mode 100644
index 000000000000..356f087fbcfb
--- /dev/null
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_filehandle.c
@@ -0,0 +1,378 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Regression tests for NFSD_CMD_FILEHANDLE_GET: root filehandle lookup
+ * over generic netlink.
+ *
+ * validation  - missing attributes are rejected with -EINVAL, an out-of-range
+ *               maxsize with -ERANGE; a domain with no pushed export fails.
+ * functional  - push an ip_map + svc_export pair the way mountd does, then
+ *               check the lookup returns a stable handle that matches the
+ *               legacy filehandle transaction interface byte for byte.
+ *
+ * Each test runs in a private net + mount namespace. The pushed export
+ * lives in the per-netns svc_export cache and dies with the namespace;
+ * the client domain itself is created in sunrpc's global auth_domain
+ * table, like any real client name would be.
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <fcntl.h>
+#include <sched.h>
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <time.h>
+#include <unistd.h>
+#include <sys/mount.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <linux/netlink.h>
+#include <linux/genetlink.h>
+#include <linux/nfsd/export.h>
+#include <linux/nfsd_netlink.h>
+#include <linux/sunrpc_netlink.h>
+
+#include "../kselftest_harness.h"
+#include "nfsd_netlink.h"
+
+#define FH_DOMAIN	"nfsd-fh-selftest"
+#define FH_MAXSIZE	64
+#define FH_TTL		3600
+#define FH_FSID		4242
+
+static int sunrpc_family = -1;
+
+/* Push one ip_map entry the way mountd's cache_export() does. */
+static int ip_map_set(const char *domain)
+{
+	char attrs[256];
+	struct nlattr *nest = (void *)attrs;
+	uint64_t expiry = (uint64_t)time(NULL) + FH_TTL;
+	static const char class[] = "nfsd";
+	static const char addr[] = "127.0.0.2";
+	int inner = NLA_HDRLEN;
+
+	inner = put_attr(attrs, inner, SUNRPC_A_IP_MAP_CLASS,
+			 class, sizeof(class));
+	inner = put_attr(attrs, inner, SUNRPC_A_IP_MAP_ADDR,
+			 addr, sizeof(addr));
+	inner = put_attr(attrs, inner, SUNRPC_A_IP_MAP_DOMAIN,
+			 domain, strlen(domain) + 1);
+	inner = put_attr(attrs, inner, SUNRPC_A_IP_MAP_EXPIRY,
+			 &expiry, sizeof(expiry));
+	nest->nla_type = SUNRPC_A_IP_MAP_REQS_REQUESTS | NLA_F_NESTED;
+	nest->nla_len = inner;
+
+	return genl_request_to(sunrpc_family, SUNRPC_CMD_IP_MAP_SET_REQS,
+			       attrs, NLA_ALIGN4(inner));
+}
+
+/*
+ * Push one positive svc_export entry for @domain/@path. An explicit fsid
+ * lets this work when @path is on tmpfs or another fs without a device.
+ */
+static int export_set(const char *domain, const char *path)
+{
+	char attrs[512];
+	struct nlattr *nest = (void *)attrs;
+	uint64_t expiry = (uint64_t)time(NULL) + FH_TTL;
+	uint32_t anon = 65534, flags = NFSEXP_FSID;
+	int32_t fsid = FH_FSID;
+	int inner = NLA_HDRLEN;
+
+	inner = put_attr(attrs, inner, NFSD_A_SVC_EXPORT_CLIENT,
+			 domain, strlen(domain) + 1);
+	inner = put_attr(attrs, inner, NFSD_A_SVC_EXPORT_PATH,
+			 path, strlen(path) + 1);
+	inner = put_attr(attrs, inner, NFSD_A_SVC_EXPORT_EXPIRY,
+			 &expiry, sizeof(expiry));
+	inner = put_attr(attrs, inner, NFSD_A_SVC_EXPORT_ANON_UID,
+			 &anon, sizeof(anon));
+	inner = put_attr(attrs, inner, NFSD_A_SVC_EXPORT_ANON_GID,
+			 &anon, sizeof(anon));
+	inner = put_attr(attrs, inner, NFSD_A_SVC_EXPORT_FLAGS,
+			 &flags, sizeof(flags));
+	inner = put_attr(attrs, inner, NFSD_A_SVC_EXPORT_FSID,
+			 &fsid, sizeof(fsid));
+	nest->nla_type = NFSD_A_SVC_EXPORT_REQS_REQUESTS | NLA_F_NESTED;
+	nest->nla_len = inner;
+
+	return genl_request(NFSD_CMD_SVC_EXPORT_SET_REQS, attrs,
+			    NLA_ALIGN4(inner));
+}
+
+/* Provision @domain/@path exactly like a mountd MOUNT would. */
+static int provision(const char *domain, const char *path)
+{
+	int ret = ip_map_set(domain);
+
+	if (ret)
+		return ret;
+	return export_set(domain, path);
+}
+
+/* Fine-grained control for negative tests: any field can be omitted. */
+struct raw_fh_req {
+	const char *domain;	/* NULL -> omit NFSD_A_FILEHANDLE_DOMAIN */
+	const char *path;	/* NULL -> omit NFSD_A_FILEHANDLE_PATH */
+	int emit_maxsize;
+	uint32_t maxsize;
+};
+
+/* FILEHANDLE_GET into @fh; returns handle length or -errno. */
+static int filehandle_get_raw(const struct raw_fh_req *r, char *fh,
+			      size_t fhsize)
+{
+	char attrs[256], rbuf[512];
+	const struct nlattr *na;
+	int off = 0, ret, len;
+
+	if (r->domain)
+		off = put_attr(attrs, off, NFSD_A_FILEHANDLE_DOMAIN,
+			       r->domain, strlen(r->domain) + 1);
+	if (r->path)
+		off = put_attr(attrs, off, NFSD_A_FILEHANDLE_PATH,
+			       r->path, strlen(r->path) + 1);
+	if (r->emit_maxsize)
+		off = put_attr(attrs, off, NFSD_A_FILEHANDLE_MAXSIZE,
+			       &r->maxsize, sizeof(r->maxsize));
+
+	ret = genl_request_reply_attrs(NFSD_CMD_FILEHANDLE_GET, attrs, off,
+				       rbuf, sizeof(rbuf));
+	if (ret <= 0)
+		return ret ? ret : -EIO;
+
+	na = genl_find_attr(rbuf, ret, NFSD_A_FILEHANDLE_HANDLE);
+	if (!na)
+		return -EIO;
+	len = na->nla_len - NLA_HDRLEN;
+	if (len <= 0 || (size_t)len > fhsize)
+		return -EIO;
+	memcpy(fh, (const char *)na + NLA_HDRLEN, len);
+	return len;
+}
+
+static int filehandle_get(const char *domain, const char *path,
+			  char *fh, size_t fhsize)
+{
+	struct raw_fh_req r = { .domain = domain, .path = path,
+				.emit_maxsize = 1, .maxsize = FH_MAXSIZE };
+
+	return filehandle_get_raw(&r, fh, fhsize);
+}
+
+static int hexval(char c)
+{
+	if (c >= '0' && c <= '9')
+		return c - '0';
+	if (c >= 'a' && c <= 'f')
+		return c - 'a' + 10;
+	if (c >= 'A' && c <= 'F')
+		return c - 'A' + 10;
+	return -1;
+}
+
+/* Legacy transaction interface: write "domain path maxsize", read "\x<hex>". */
+static int proc_filehandle(const char *mnt, const char *domain,
+			   const char *path, char *fh, size_t fhsize)
+{
+	char file[128], req[256], rsp[512];
+	int fd, i, n, len;
+
+	snprintf(file, sizeof(file), "%s/filehandle", mnt);
+	fd = open(file, O_RDWR);
+	if (fd < 0)
+		return -errno;
+	n = snprintf(req, sizeof(req), "%s %s %u\n", domain, path, FH_MAXSIZE);
+	if (write(fd, req, n) != n) {
+		n = -errno;
+		close(fd);
+		return n;
+	}
+	n = read(fd, rsp, sizeof(rsp) - 1);
+	close(fd);
+	if (n <= 0)
+		return n ? -errno : -EIO;
+	rsp[n] = '\0';
+
+	if (n < 2 || rsp[0] != '\\' || rsp[1] != 'x')
+		return -EIO;
+
+	len = 0;
+	for (i = 2; i + 1 < n && rsp[i] != '\n'; i += 2) {
+		int hi = hexval(rsp[i]), lo = hexval(rsp[i + 1]);
+
+		if (hi < 0 || lo < 0)
+			return -EIO;
+		if ((size_t)len >= fhsize)
+			return -EIO;
+		fh[len++] = (hi << 4) | lo;
+	}
+	return len ? len : -EIO;
+}
+
+/* --------------------------- fixture --------------------------- */
+
+FIXTURE(nfsd_filehandle) {
+	char tmpdir[64];
+	char mnt[80];
+	int mounted;
+};
+
+FIXTURE_SETUP(nfsd_filehandle)
+{
+	if (geteuid() != 0)
+		SKIP(return, "must be run as root");
+	if (unshare(CLONE_NEWNET | CLONE_NEWNS) < 0)
+		SKIP(return, "unshare(NEWNET|NEWNS): %s", strerror(errno));
+	if (mount("", "/", NULL, MS_REC | MS_PRIVATE, NULL) < 0)
+		SKIP(return, "mount(/ private): %s", strerror(errno));
+
+	nfsd_family = genl_resolve_nfsd();
+	if (nfsd_family < 0)
+		SKIP(return, "nfsd genl family not found (modprobe nfsd?)");
+	sunrpc_family = genl_resolve(SUNRPC_FAMILY_NAME,
+				     sizeof(SUNRPC_FAMILY_NAME));
+	if (sunrpc_family < 0)
+		SKIP(return, "sunrpc genl family not found");
+
+	/*
+	 * Probe for FILEHANDLE_GET: an empty request must fail attribute
+	 * validation on a patched kernel, while an unpatched one answers
+	 * -EOPNOTSUPP for the unknown command.
+	 */
+	if (genl_request(NFSD_CMD_FILEHANDLE_GET, NULL, 0) == -EOPNOTSUPP)
+		SKIP(return, "NFSD_CMD_FILEHANDLE_GET not supported");
+
+	strcpy(self->tmpdir, "/tmp/nfsd-fh-XXXXXX");
+	if (!mkdtemp(self->tmpdir))
+		SKIP(return, "mkdtemp: %s", strerror(errno));
+	self->mounted = 0;
+}
+
+FIXTURE_TEARDOWN(nfsd_filehandle)
+{
+	if (self->mounted) {
+		umount(self->mnt);
+		rmdir(self->mnt);
+	}
+	rmdir(self->tmpdir);
+}
+
+/* Mount this netns's nfsd filesystem for the legacy comparison. */
+static int fh_proc_mount(FIXTURE_DATA(nfsd_filehandle) * self)
+{
+	snprintf(self->mnt, sizeof(self->mnt), "%s/mnt", self->tmpdir);
+	if (mkdir(self->mnt, 0700) < 0)
+		return -errno;
+	if (mount("nfsd", self->mnt, "nfsd", 0, NULL) < 0) {
+		int err = -errno;
+
+		rmdir(self->mnt);
+		return err;
+	}
+	self->mounted = 1;
+	return 0;
+}
+
+/* ===================== validation / negative ===================== */
+
+TEST_F(nfsd_filehandle, val_missing_domain)
+{
+	struct raw_fh_req r = { .path = self->tmpdir,
+				.emit_maxsize = 1, .maxsize = FH_MAXSIZE };
+	char fh[FH_MAXSIZE];
+
+	EXPECT_EQ(-EINVAL, filehandle_get_raw(&r, fh, sizeof(fh)));
+}
+
+TEST_F(nfsd_filehandle, val_missing_path)
+{
+	struct raw_fh_req r = { .domain = FH_DOMAIN,
+				.emit_maxsize = 1, .maxsize = FH_MAXSIZE };
+	char fh[FH_MAXSIZE];
+
+	EXPECT_EQ(-EINVAL, filehandle_get_raw(&r, fh, sizeof(fh)));
+}
+
+TEST_F(nfsd_filehandle, val_missing_maxsize)
+{
+	struct raw_fh_req r = { .domain = FH_DOMAIN, .path = self->tmpdir };
+	char fh[FH_MAXSIZE];
+
+	EXPECT_EQ(-EINVAL, filehandle_get_raw(&r, fh, sizeof(fh)));
+}
+
+TEST_F(nfsd_filehandle, val_maxsize_small)
+{
+	struct raw_fh_req r = { .domain = FH_DOMAIN, .path = self->tmpdir,
+				.emit_maxsize = 1, .maxsize = 31 };
+	char fh[FH_MAXSIZE];
+
+	EXPECT_EQ(-ERANGE, filehandle_get_raw(&r, fh, sizeof(fh)));
+	r.maxsize = 0;
+	EXPECT_EQ(-ERANGE, filehandle_get_raw(&r, fh, sizeof(fh)));
+}
+
+TEST_F(nfsd_filehandle, val_maxsize_large)
+{
+	struct raw_fh_req r = { .domain = FH_DOMAIN, .path = self->tmpdir,
+				.emit_maxsize = 1, .maxsize = 65 };
+	char fh[FH_MAXSIZE];
+
+	EXPECT_EQ(-ERANGE, filehandle_get_raw(&r, fh, sizeof(fh)));
+}
+
+TEST_F(nfsd_filehandle, val_no_export)
+{
+	char fh[FH_MAXSIZE];
+
+	/* Well-formed but nothing was ever pushed for this domain. */
+	EXPECT_LT(filehandle_get("nfsd-fh-noexport", self->tmpdir,
+				 fh, sizeof(fh)), 0);
+}
+
+/* ===================== functional ===================== */
+
+TEST_F(nfsd_filehandle, func_roundtrip)
+{
+	char fh1[FH_MAXSIZE], fh2[FH_MAXSIZE];
+	int len1, len2;
+
+	ASSERT_EQ(0, provision(FH_DOMAIN, self->tmpdir));
+
+	len1 = filehandle_get(FH_DOMAIN, self->tmpdir, fh1, sizeof(fh1));
+	ASSERT_GT(len1, 0);
+	EXPECT_LE(len1, FH_MAXSIZE);
+
+	/* The same lookup must compose the same handle. */
+	len2 = filehandle_get(FH_DOMAIN, self->tmpdir, fh2, sizeof(fh2));
+	EXPECT_EQ(len1, len2);
+	EXPECT_EQ(0, memcmp(fh1, fh2, len1));
+}
+
+TEST_F(nfsd_filehandle, func_matches_proc)
+{
+	char fh_nl[FH_MAXSIZE], fh_proc[FH_MAXSIZE];
+	int len_nl, len_proc, ret;
+
+	ASSERT_EQ(0, provision(FH_DOMAIN, self->tmpdir));
+
+	ret = fh_proc_mount(self);
+	if (ret)
+		SKIP(return, "mount(nfsd): %s", strerror(-ret));
+
+	len_proc = proc_filehandle(self->mnt, FH_DOMAIN, self->tmpdir,
+				   fh_proc, sizeof(fh_proc));
+	ASSERT_GT(len_proc, 0);
+
+	len_nl = filehandle_get(FH_DOMAIN, self->tmpdir, fh_nl, sizeof(fh_nl));
+	ASSERT_GT(len_nl, 0);
+
+	EXPECT_EQ(len_proc, len_nl);
+	EXPECT_EQ(0, memcmp(fh_proc, fh_nl, len_nl));
+}
+
+TEST_HARNESS_MAIN

---
base-commit: b4e06bef38843c8b909d0b4317dfaaf87dba6d72
change-id: 20261020-nfsd-filehandle-get-5ce34047a203

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

