Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756130Ab2BHLDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 06:03:23 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/9] KEYS: Move the key config into security/keys/Kconfig
To: steved@redhat.com, jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 08 Feb 2012 11:03:16 +0000
Message-ID: <20120208110316.4050.7280.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the key config into security/keys/Kconfig as there are going to be a lot
of key-related options.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Mimi Zohar <zohar@us.ibm.com>
---

 security/Kconfig      |   68 +----------------------------------------------
 security/keys/Kconfig |   71 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+), 67 deletions(-)
 create mode 100644 security/keys/Kconfig

diff --git a/security/Kconfig b/security/Kconfig
index 51bd5a0..1c5a7a4 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -4,73 +4,7 @@
 
 menu "Security options"
 
-config KEYS
-	bool "Enable access key retention support"
-	help
-	  This option provides support for retaining authentication tokens and
-	  access keys in the kernel.
-
-	  It also includes provision of methods by which such keys might be
-	  associated with a process so that network filesystems, encryption
-	  support and the like can find them.
-
-	  Furthermore, a special type of key is available that acts as keyring:
-	  a searchable sequence of keys. Each process is equipped with access
-	  to five standard keyrings: UID-specific, GID-specific, session,
-	  process and thread.
-
-	  If you are unsure as to whether this is required, answer N.
-
-config TRUSTED_KEYS
-	tristate "TRUSTED KEYS"
-	depends on KEYS && TCG_TPM
-	select CRYPTO
-	select CRYPTO_HMAC
-	select CRYPTO_SHA1
-	help
-	  This option provides support for creating, sealing, and unsealing
-	  keys in the kernel. Trusted keys are random number symmetric keys,
-	  generated and RSA-sealed by the TPM. The TPM only unseals the keys,
-	  if the boot PCRs and other criteria match.  Userspace will only ever
-	  see encrypted blobs.
-
-	  If you are unsure as to whether this is required, answer N.
-
-config ENCRYPTED_KEYS
-	tristate "ENCRYPTED KEYS"
-	depends on KEYS
-	select CRYPTO
-	select CRYPTO_HMAC
-	select CRYPTO_AES
-	select CRYPTO_CBC
-	select CRYPTO_SHA256
-	select CRYPTO_RNG
-	help
-	  This option provides support for create/encrypting/decrypting keys
-	  in the kernel.  Encrypted keys are kernel generated random numbers,
-	  which are encrypted/decrypted with a 'master' symmetric key. The
-	  'master' key can be either a trusted-key or user-key type.
-	  Userspace only ever sees/stores encrypted blobs.
-
-	  If you are unsure as to whether this is required, answer N.
-
-config KEYS_DEBUG_PROC_KEYS
-	bool "Enable the /proc/keys file by which keys may be viewed"
-	depends on KEYS
-	help
-	  This option turns on support for the /proc/keys file - through which
-	  can be listed all the keys on the system that are viewable by the
-	  reading process.
-
-	  The only keys included in the list are those that grant View
-	  permission to the reading process whether or not it possesses them.
-	  Note that LSM security checks are still performed, and may further
-	  filter out keys that the current process is not authorised to view.
-
-	  Only key attributes are listed here; key payloads are not included in
-	  the resulting table.
-
-	  If you are unsure as to whether this is required, answer N.
+source security/keys/Kconfig
 
 config SECURITY_DMESG_RESTRICT
 	bool "Restrict unprivileged access to the kernel syslog"
diff --git a/security/keys/Kconfig b/security/keys/Kconfig
new file mode 100644
index 0000000..a90d6d3
--- /dev/null
+++ b/security/keys/Kconfig
@@ -0,0 +1,71 @@
+#
+# Key management configuration
+#
+
+config KEYS
+	bool "Enable access key retention support"
+	help
+	  This option provides support for retaining authentication tokens and
+	  access keys in the kernel.
+
+	  It also includes provision of methods by which such keys might be
+	  associated with a process so that network filesystems, encryption
+	  support and the like can find them.
+
+	  Furthermore, a special type of key is available that acts as keyring:
+	  a searchable sequence of keys. Each process is equipped with access
+	  to five standard keyrings: UID-specific, GID-specific, session,
+	  process and thread.
+
+	  If you are unsure as to whether this is required, answer N.
+
+config TRUSTED_KEYS
+	tristate "TRUSTED KEYS"
+	depends on KEYS && TCG_TPM
+	select CRYPTO
+	select CRYPTO_HMAC
+	select CRYPTO_SHA1
+	help
+	  This option provides support for creating, sealing, and unsealing
+	  keys in the kernel. Trusted keys are random number symmetric keys,
+	  generated and RSA-sealed by the TPM. The TPM only unseals the keys,
+	  if the boot PCRs and other criteria match.  Userspace will only ever
+	  see encrypted blobs.
+
+	  If you are unsure as to whether this is required, answer N.
+
+config ENCRYPTED_KEYS
+	tristate "ENCRYPTED KEYS"
+	depends on KEYS
+	select CRYPTO
+	select CRYPTO_HMAC
+	select CRYPTO_AES
+	select CRYPTO_CBC
+	select CRYPTO_SHA256
+	select CRYPTO_RNG
+	help
+	  This option provides support for create/encrypting/decrypting keys
+	  in the kernel.  Encrypted keys are kernel generated random numbers,
+	  which are encrypted/decrypted with a 'master' symmetric key. The
+	  'master' key can be either a trusted-key or user-key type.
+	  Userspace only ever sees/stores encrypted blobs.
+
+	  If you are unsure as to whether this is required, answer N.
+
+config KEYS_DEBUG_PROC_KEYS
+	bool "Enable the /proc/keys file by which keys may be viewed"
+	depends on KEYS
+	help
+	  This option turns on support for the /proc/keys file - through which
+	  can be listed all the keys on the system that are viewable by the
+	  reading process.
+
+	  The only keys included in the list are those that grant View
+	  permission to the reading process whether or not it possesses them.
+	  Note that LSM security checks are still performed, and may further
+	  filter out keys that the current process is not authorised to view.
+
+	  Only key attributes are listed here; key payloads are not included in
+	  the resulting table.
+
+	  If you are unsure as to whether this is required, answer N.

