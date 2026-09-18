Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49E0A4FECD4;
	Fri, 18 Sep 2026 14:05:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789740342; cv=none; b=U6IaMoD7PdmdjeymsP6DuNwk8APUOcTT8O2ROBEJhjNQVIgGPs2NKSt90U6XN/Rg1Chn4w0foPaH9GGafkChSuDQroCXEGRlP7SvT00NEp1aqcCrvBGakO6OAKNw2gDncIOFFu31HwzQRlDUN9+cygF57ModcvwdekVAeO9mczE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789740342; c=relaxed/simple;
	bh=1bIfVoIWv6BWPpMAmSy0ftrwlUnvPVTnTMRLrwobiJk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=XagoaxCDLWLPZgrlBRb7zuVjeWgwTtYck9aelJRTJIrjXmKDQ/Y62ibQug8f4v+S5WHLpTNar6ceWqi4dhBjPnm1cuBVW0fMsoCrOMJbsXW8bAJRmH7iOUaSxdRPrgYIq3VE1NKVDzQEsSNF2u1wUCJXP6+fjnXdrQ8PR+8ssYc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CGeVOutR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CGeVOutR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BACC01F00898;
	Fri, 18 Sep 2026 14:05:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789740341;
	bh=b1zwFNlVsB+SAuWdSZcWrQc4iiODuAOFHYO3T2Co73s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CGeVOutRUKzOA1ljaV45ux1qnEJpFrNp2DmObvwTQkXGV1dnY4CSPDvNpNwQJPd0H
	 s6cKGAzVIduIzh22vKroi37MeB2Yhy9ll90g8sDqTCvMR3KYvD1BJQ8qouiH+IfNNC
	 vo+5YXvG+nyuTTo2KaeB0SV6aW47NQJsBPvL50NVcXemMx9HchTEGf7sX+EiHYEKxR
	 N6tocdN3xw0y/dasmaU4OzOzNPsMuH251ZDTfOyEtG54MlwfmYhWMXBFeLKY/L26JX
	 WwLlxDlNIUo62C4UyWVMts8Tuh2jADBoWSV6ybFBY/a+dhLb/kEwAeetAjFqmj3LXV
	 4xKhpoD0hhOBw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 10:05:20 -0400
Subject: [PATCH RFC 5/5] NFS: add a key type that reveals the namespace
 .nfs keyring serial
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-nfs-mtls-identity-v1-5-197e568d78a7@kernel.org>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
In-Reply-To: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, 
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>, 
 Sagi Grimberg <sagi@grimberg.me>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org, 
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-doc@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=8832; i=cel@kernel.org;
 h=from:subject:message-id; bh=1bIfVoIWv6BWPpMAmSy0ftrwlUnvPVTnTMRLrwobiJk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrUUr5k/dXAyg557KDtsOQCjrRPZ71D86Op5F/
 qVHio8BjbuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1FKwAKCRAzarMzb2Z/
 l9S3EADByhcZCgl8RNUjTfQk1ed9OqOrzaetme/q5HyxUjAGGSLDrhnEBF+enVj09Zu5V1v7vWT
 LQ5q4JlSOnvN8tNnVR+XxibQINIi0bUWLi2yW0Pl9htDkXyi8q5rhcTBwSTGobes7Z4c08b/A9X
 mS+19BpFs+W6MVzQzotvSxWV5NV+rbcXE/0Om9AtDz/2SgkqLzVvmtT1ahmFibb4xNXKtfDDI5Z
 HC5qvd+lbBKOLHRVxg91rdvrsuuLwcYqSGtTcqZkhHGa/FktO9na+t+IcAIR0xJSHEkT6K10VeC
 YT/3QUE/FpU6PRvfrjZMSLGYDXNSgAWAhMcU37MDylOkQFD4hyYvHjJWcU5yKfHpvdqkeYC7szQ
 l09FxCURhPq8Pow+wQeCEvzqhl8atxMEOAGitoprL9UDh0ADaZzh5IGYm915W7vFPxflMheeOXo
 PpLa+5tU2yb7pi5IPYul6NJ8mJvisjm3F4PCv12iu54r55sE75RJl1UobBnywUYt4XUGPVPdkjD
 1dcRc/6RmdyhyZY3c5o2eHWv5pZGKYt91y3raAY2GnitOGrxLFlg2AwSPOk9d+vMX7SDAHdIMKm
 ORwIGp01v37wO9kNUQmoHDTdlMsVsfEVBOsb06UrTMTjIyZ0NWXuX+dR99nCfPxopGiDntF+gdF
 G1bjmJgIlFP79VA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The per-namespace .nfs keyring is linked into no keyring that
userspace possesses, so a tool that provisions x509 credentials, or a
mount helper that searches for them, cannot reach it. Every keyring
operation from userspace takes a serial, and nothing hands this one
out.

Register an "nfs_keyring" key type whose request_key handler runs in
the caller's context, without an upcall, and instantiates the key
with the serial of the caller's namespace .nfs keyring. Userspace
reads the serial with one request_key() and one keyctl_read().

A keyring search runs before the handler does, and a task keeps its
session keyring across setns(). The type carries KEY_TYPE_NET_DOMAIN
so a key instantiated in one namespace does not answer a request from
another. Its preparse accepts no payload but the caller's own serial,
so a key planted by add_key() cannot misdirect a later request.

Register the type after register_pernet_subsys() has installed
nfs_net_id, and unregister it before the per-namespace state goes
away. unregister_key_type() waits for in-flight request_key() calls
to drain, so the handler never runs against a freed struct nfs_net.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/filesystems/nfs/index.rst   |  1 +
 Documentation/filesystems/nfs/keyring.rst | 67 ++++++++++++++++++++++
 fs/nfs/inode.c                            | 94 ++++++++++++++++++++++++++++++-
 3 files changed, 161 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/nfs/index.rst b/Documentation/filesystems/nfs/index.rst
index a29a212b5b4d..dab5f16aaad1 100644
--- a/Documentation/filesystems/nfs/index.rst
+++ b/Documentation/filesystems/nfs/index.rst
@@ -7,6 +7,7 @@ NFS
    :maxdepth: 1
 
    client-identifier
+   keyring
    exporting
    localio
    pnfs
diff --git a/Documentation/filesystems/nfs/keyring.rst b/Documentation/filesystems/nfs/keyring.rst
new file mode 100644
index 000000000000..5b3d3d0f5f91
--- /dev/null
+++ b/Documentation/filesystems/nfs/keyring.rst
@@ -0,0 +1,67 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+====================================
+The per-namespace NFS client keyring
+====================================
+
+The NFS client holds one keyring, named ".nfs", per network
+namespace. An xprtsec=mtls mount presents the client certificate and
+private key named by its cert_serial= and privkey_serial= mount
+options, and the handshake links the mount's namespace .nfs keyring
+into tlshd before tlshd reads those keys. Keys placed on the .nfs
+keyring therefore need not grant user read permission: tlshd reaches
+them as a possessor, and a tlshd in another network namespace never
+possesses them.
+
+The keyring is owned by global root, with KEY_POS_ALL and KEY_USR_ALL
+less SETATTR. It is not charged to any quota. Keys added to it by
+userspace are charged to the user that adds them.
+
+Finding the keyring serial
+==========================
+
+The .nfs keyring is not linked into any keyring that userspace
+possesses, so a serial is the only way to name it. The NFS client
+registers a key type, "nfs_keyring", whose sole purpose is to hand
+that serial out. Its request_key handler runs in the caller's context
+and does not upcall to /sbin/request-key.
+
+To obtain the serial, request a key of type "nfs_keyring" with the
+description ".nfs" and read its payload::
+
+	id=$(keyctl request2 nfs_keyring .nfs "" @s)
+	serial=$(keyctl print $id)
+
+The contract of the key type is:
+
+ * The description is the string ".nfs". Any other description is
+   rejected with EINVAL before a key is allocated.
+
+ * The callout info must be present. request_key() with a NULL
+   callout_info never invokes a handler and returns ENOKEY when no
+   matching key exists, so use request_key() with an empty string, or
+   ``keyctl request2`` rather than ``keyctl request``. The content of
+   the callout info is ignored.
+
+ * The payload is the keyring serial as decimal ASCII digits with no
+   terminating NUL. The return value of keyctl_read() gives the
+   length; a buffer of 12 bytes is sufficient.
+
+ * add_key() with this type accepts only that payload. A key carrying
+   any other value is rejected with EINVAL, so a key found in the
+   caller's keyrings always holds the serial of the caller's namespace.
+
+ * The key type carries KEY_TYPE_NET_DOMAIN. A key instantiated in one
+   network namespace does not answer a request made in another, so a
+   process that keeps its session keyring across setns() receives the
+   serial of the namespace it is in at the time of the request.
+
+The serial is not a secret. The keyring's own permissions decide what
+a caller can do with it.
+
+Provisioning credentials
+========================
+
+Add the client certificate and private key to the .nfs keyring as
+keys that grant no user read permission, then pass their serials as
+cert_serial= and privkey_serial= mount options.
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bd327fbb12d8..19e644746bab 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -42,6 +42,12 @@
 #include <linux/uaccess.h>
 #include <linux/iversion.h>
 #include <linux/fileattr.h>
+#include <linux/nsproxy.h>
+#include <linux/key-type.h>
+#include <keys/user-type.h>
+#ifdef CONFIG_KEYS
+#include <keys/request_key_auth-type.h>
+#endif
 
 #include "nfs4_fs.h"
 #include "callback.h"
@@ -2665,6 +2671,76 @@ static void nfs_exit_keyring(struct nfs_net *nn)
 {
 	key_put(nn->nfs_keyring);
 }
+
+static int nfs_keyring_vet_description(const char *desc)
+{
+	return strcmp(desc, ".nfs") ? -EINVAL : 0;
+}
+
+static int nfs_keyring_format_serial(char *buf, size_t len)
+{
+	struct key *keyring = nfs_net_keyring(current->nsproxy->net_ns);
+
+	return snprintf(buf, len, "%d", key_serial(keyring));
+}
+
+/*
+ * A key planted by add_key() answers request_key() before the handler
+ * runs. Accept only the serial the handler would produce.
+ */
+static int nfs_keyring_preparse(struct key_preparsed_payload *prep)
+{
+	char serial[12];
+	int len;
+
+	len = nfs_keyring_format_serial(serial, sizeof(serial));
+	if (prep->datalen != len || !prep->data ||
+	    memcmp(prep->data, serial, len))
+		return -EINVAL;
+	return user_preparse(prep);
+}
+
+static int nfs_keyring_request_key(struct key *authkey, void *aux)
+{
+	struct request_key_auth *rka = get_request_key_auth(authkey);
+	char serial[12];
+	int len, ret;
+
+	len = nfs_keyring_format_serial(serial, sizeof(serial));
+	ret = key_instantiate_and_link(rka->target_key, serial, len,
+				       rka->dest_keyring, authkey);
+	if (ret < 0)
+		complete_request_key(authkey, ret);
+	return ret;
+}
+
+/*
+ * A session keyring survives setns(). Without the net domain tag, a
+ * key instantiated in one namespace answers a request from another.
+ */
+static struct key_type key_type_nfs_keyring = {
+	.name		= "nfs_keyring",
+	.flags		= KEY_TYPE_NET_DOMAIN,
+	.vet_description = nfs_keyring_vet_description,
+	.preparse	= nfs_keyring_preparse,
+	.free_preparse	= user_free_preparse,
+	.instantiate	= generic_key_instantiate,
+	.revoke		= user_revoke,
+	.destroy	= user_destroy,
+	.describe	= user_describe,
+	.read		= user_read,
+	.request_key	= nfs_keyring_request_key,
+};
+
+static int __init nfs_register_key_type(void)
+{
+	return register_key_type(&key_type_nfs_keyring);
+}
+
+static void nfs_unregister_key_type(void)
+{
+	unregister_key_type(&key_type_nfs_keyring);
+}
 #else
 static inline int nfs_init_keyring(struct nfs_net *nn)
 {
@@ -2674,6 +2750,15 @@ static inline int nfs_init_keyring(struct nfs_net *nn)
 static inline void nfs_exit_keyring(struct nfs_net *nn)
 {
 }
+
+static inline int nfs_register_key_type(void)
+{
+	return 0;
+}
+
+static inline void nfs_unregister_key_type(void)
+{
+}
 #endif /* CONFIG_KEYS */
 
 static int nfs_net_init(struct net *net)
@@ -2738,10 +2823,14 @@ static int __init init_nfs_fs(void)
 	if (err < 0)
 		goto err_sysfs;
 
-	err = nfsiod_start();
+	err = nfs_register_key_type();
 	if (err)
 		goto err_pernet;
 
+	err = nfsiod_start();
+	if (err)
+		goto err_keytype;
+
 	err = nfs_fs_proc_init();
 	if (err)
 		goto err_nfsiod;
@@ -2785,6 +2874,8 @@ static int __init init_nfs_fs(void)
 	nfs_fs_proc_exit();
 err_nfsiod:
 	nfsiod_stop();
+err_keytype:
+	nfs_unregister_key_type();
 err_pernet:
 	unregister_pernet_subsys(&nfs_net_ops);
 err_sysfs:
@@ -2799,6 +2890,7 @@ static void __exit exit_nfs_fs(void)
 	nfs_destroy_readpagecache();
 	nfs_destroy_inodecache();
 	nfs_destroy_nfspagecache();
+	nfs_unregister_key_type();
 	unregister_pernet_subsys(&nfs_net_ops);
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();

-- 
2.55.0

