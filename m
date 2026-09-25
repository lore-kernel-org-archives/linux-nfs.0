Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 289DF4E66C8;
	Fri, 25 Sep 2026 19:16:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790363807; cv=none; b=NMwIRayVhqctQOLkXWHxhMUx7OE3OQRgoszvubliswmi8SVYXUaONfBa9PkiamZBfxa9ebKzEX4oHZcbzQeLE+mahPAH3ojVPMqyR5uXpwqlUkMm/zWwnkWSCZCCZLk8zgzFwz0yu74dNmRZsSI5rhGiFFqhaPD8YhM0vlSG2VM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790363807; c=relaxed/simple;
	bh=Tmw7Lyoy2BJSRBitllEK8LzSGFR+a6mKPOAvIUSKJ9s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mgcWlU4dwL4Yoqqe+4aFcqYU0kop1glhqCv4r1Y8nUocqvH49CAaIp3uJd135MFLdzKND+3RMBmJ/qWvAGHgh47DYDFavuI7eN9WzadB3hcd+VgicZ2J5J2jYI1/1Ps8ZagOf7NWjHNYgVbYCXqqS12//XgwD3VtF8E6xcy6xcw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TGJnfk3s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TGJnfk3s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FA671F00893;
	Fri, 25 Sep 2026 19:16:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790363806;
	bh=rLZ8omInzSMXOU9fAbmYNxiNW9WnUy1KNuwoxwPOBCI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TGJnfk3sjvRt4SHyxK7Bu+7gBr96ULn5ybdY3RjABktNOM/dJZypN8m0reqF1aCPp
	 xc0Q59Ee/ZXxi2qBRsBUPO5rJggXT2xEgwpIlT56TW7oJW6z9m8316uJuS67N9h30l
	 9USllWwAo/tUWJLMRRrWxl9c5MC3EOutwNIpLUD9rG5yaB5q5c8FGyMtQDCWc0Pke0
	 mOS4etV1bB14w7jDPCjw0A6CTwLqT0WAZE2eQ4vt5+VVKT9xVfPjYRfBmff+C19drM
	 kn/to5xE3aOZIgsUer2wJxHhvC92nU8WQEVOYCZpTqljquaH4Qslk7YkLWI9P7zM2i
	 ddfERsQO9RvOQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 25 Sep 2026 15:16:27 -0400
Subject: [PATCH RFC v2 5/5] NFS: add a key type that reveals the namespace
 .nfs keyring serial number
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260925-nfs-mtls-identity-v2-5-aa3ad17dd6c8@kernel.org>
References: <20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org>
In-Reply-To: <20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8981; i=cel@kernel.org;
 h=from:subject:message-id; bh=Tmw7Lyoy2BJSRBitllEK8LzSGFR+a6mKPOAvIUSKJ9s=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqtsiT1jFIQixm2CU0BYJCZ/7/LXpqr0b5KPgsI
 hkA8oqL9fOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarbIkwAKCRAzarMzb2Z/
 l+rjD/0UWyWVvVTyA7BSJDD78UlNoiccjwE6sPPPsT3FPIlA0SwLfDxOp7r7K3dWE0rCdrggOKG
 rXr2azvK8rya0f+IHxPw9jXbtvk2c9p1NYiLUZ6d586bS7eRR6BG0NMNLRpFHYX4Y1qk33szZej
 wOZ6N7LSjIcfFLknrsJiVjZwHrcfGzzgTYS5IbOFkNe17145PdaxFCrzRdTi1FT6LPUNrdzHWS7
 GYg/KB8xTowII1YNSM3cVgG9bXmx0zPgEPMXanh5HJgAusI48FDelIeTwk8Wts8IkPcrxKGLXA8
 oDoXO79i68UC6CyQNlJOG9eCnXlhQhioCT8yKnKSS7lFyZ1dze+Xi/73WiLptCANz0ZdNLIOD6h
 THY5gMeFP82ysJO7nY3+cxyz1dH18m6qpt+BBDWlTvrBiAaIXBow1hMb4mgieM3PCzQLVBe1hnx
 rANQbV2RAXCqp0pnN+w5N2kECPp0y/suRQONr5U7INY243jRDY6EMMrwXHUgAYZe0nVwNdhuCX3
 6zZOOdpEg8I4QwjbqOU/Ku6aDoVa1Uh7DJbEOnoGB6aIh8MNu49z5g0GIpULKXQyzyBQiC/EuKO
 r9ahNY9dsP2eXgqmRYy/68mxiyt+O9FMUaqDVBjVzbsOcK8J93NHtsa+EfmHN8DYd4VVBAhMeEY
 rToI6UDgh+tXZCw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The per-namespace .nfs keyring is linked into no keyring that
userspace possesses, so a tool that provisions x509 credentials, or a
mount helper that searches for them, cannot reach it. Every keyring
operation from userspace takes a serial number, and nothing hands
this one out.

Register an "nfs_keyring" key type whose request_key handler runs in
the caller's context, without an upcall, and instantiates the key
with the serial number of the caller's namespace .nfs keyring.
Userspace reads the serial number with one request_key() and one
keyctl_read().

A keyring search runs before the handler does, and a task keeps its
session keyring across setns(). The type carries KEY_TYPE_NET_DOMAIN
so a key instantiated in one namespace does not answer a request from
another. Its preparse accepts no payload but the caller's own serial
number, so a key planted by add_key() cannot misdirect a later
request.

Register the type after register_pernet_subsys() has installed
nfs_net_id, and unregister it before the per-namespace state goes
away. unregister_key_type() waits for in-flight request_key() calls
to drain, so the handler never runs against a freed struct nfs_net.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/filesystems/nfs/index.rst   |  1 +
 Documentation/filesystems/nfs/keyring.rst | 69 +++++++++++++++++++++++
 fs/nfs/inode.c                            | 94 ++++++++++++++++++++++++++++++-
 3 files changed, 163 insertions(+), 1 deletion(-)

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
index 000000000000..29367e71a801
--- /dev/null
+++ b/Documentation/filesystems/nfs/keyring.rst
@@ -0,0 +1,69 @@
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
+The keyring is owned by the owner of the network namespace's user
+namespace, with KEY_POS_ALL and KEY_USR_ALL less SETATTR. It is not
+charged to any quota. Keys added to it by userspace are charged to
+the user that adds them.
+
+Finding the keyring serial number
+=================================
+
+The .nfs keyring is not linked into any keyring that userspace
+possesses, so a serial number is the only way to name it. The NFS
+client registers a key type, "nfs_keyring", whose sole purpose is to
+hand that serial number out. Its request_key handler runs in the
+caller's context and does not upcall to /sbin/request-key.
+
+To obtain the serial number, request a key of type "nfs_keyring" with
+the description ".nfs" and read its payload::
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
+ * The payload is the keyring serial number as decimal ASCII digits
+   with no terminating NUL. The return value of keyctl_read() gives
+   the length; a buffer of 12 bytes is sufficient.
+
+ * add_key() with this type accepts only that payload. A key carrying
+   any other value is rejected with EINVAL, so a key found in the
+   caller's keyrings always holds the serial number of the caller's
+   namespace.
+
+ * The key type carries KEY_TYPE_NET_DOMAIN. A key instantiated in one
+   network namespace does not answer a request made in another, so a
+   process that keeps its session keyring across setns() receives the
+   serial number of the namespace it is in at the time of the request.
+
+The serial number is not a secret. The keyring's own permissions
+decide what a caller can do with it.
+
+Provisioning credentials
+========================
+
+Add the client certificate and private key to the .nfs keyring as
+keys that grant no user read permission, then pass their serial
+numbers as cert_serial= and privkey_serial= mount options.
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2b494fa5ecc0..fe7a05dec02f 100644
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
@@ -2667,6 +2673,76 @@ static void nfs_exit_keyring(struct nfs_net *nn)
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
+ * runs. Accept only the serial number the handler would produce.
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
 static inline int nfs_init_keyring(struct net *net)
 {
@@ -2676,6 +2752,15 @@ static inline int nfs_init_keyring(struct net *net)
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
@@ -2740,10 +2825,14 @@ static int __init init_nfs_fs(void)
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
@@ -2787,6 +2876,8 @@ static int __init init_nfs_fs(void)
 	nfs_fs_proc_exit();
 err_nfsiod:
 	nfsiod_stop();
+err_keytype:
+	nfs_unregister_key_type();
 err_pernet:
 	unregister_pernet_subsys(&nfs_net_ops);
 err_sysfs:
@@ -2801,6 +2892,7 @@ static void __exit exit_nfs_fs(void)
 	nfs_destroy_readpagecache();
 	nfs_destroy_inodecache();
 	nfs_destroy_nfspagecache();
+	nfs_unregister_key_type();
 	unregister_pernet_subsys(&nfs_net_ops);
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();

-- 
2.55.0

