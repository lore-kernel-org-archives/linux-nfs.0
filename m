Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2C38429005
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 14:14:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784556886; cv=none; b=pFt0otNyQA9l4Wo3gZwKDO/RL7+V+ov5b3xgqdLRJ7vFKxLRzMUjgcZ4PcYccjnRADZNHkNIpxe9Y/syHg3fC/08FNcSFn6q8cBymPZM/8UQFJmAH8Bqx2g8Og3rS5yT+rbJXRyohxB7lu+Za06IGR67agPIf3Vrttw76gPjOFM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784556886; c=relaxed/simple;
	bh=Ga+cN2htgL30ALkKiqkniLyTo03wT2GG4XqLJj8HYDA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=X910qCoBZ3tESydXXifiPu4id7zv6fiHOVKlMeOajBg7bq8+JNG/4Vx55RngHHTiR/tuFzEbZFU0s49389y/c7biQiz3vBo92vOKWU/KY8jdmmnqkP08ftQG5IPjDsaQk80zlVJR5u8RH3AifHe+xNXli6f5sn1AeCOPWuRrD6U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Fyhy8/ld; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fyhy8/ld"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E42631F00A3E;
	Mon, 20 Jul 2026 14:14:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784556884;
	bh=DPhW6A3QRHFjDS+pEuSB6ZMxmadGgwvqpIVml3gvtec=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Fyhy8/ldBq80AecdAJNkVTB07OuAzrVNfWLHSba9dHFibsJ3NQA+CZRSmA1J1Upkr
	 OmG/fo7Y9YNZie1isBIibXztVJYiYqS+yTsLvuPpRicwk9wCljiizop4YCvxqJwGEk
	 EAV1PNzMJT5JTr8281FUSmO02IGS8wg9lG8940BI+5/WA03sazMMq0Hou8rHE/yUrS
	 RV+g5em2EwvhdrKhEnc9zeJE9rM+/yod4qHGMCXrYDCijSgIgyLvRMArexHK6tlKvm
	 AXCSXitCfMh7iZdh71OIa1GeIrCTi1l+Me4/9KeDc5QAfr+Hn/fZU+Izo8QJpWL9OM
	 RSFVwH2ps+fqQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] NFS: Add linux/nfs_fh.h
Date: Mon, 20 Jul 2026 10:14:40 -0400
Message-ID: <20260720141442.783935-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260720141442.783935-1-cel@kernel.org>
References: <20260720141442.783935-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Plenty of spots around the kernel need the full definition of struct
nfs_fh but not the cred, sunrpc, and uapi dependencies that
linux/nfs.h pulls in along with it.

Relocate struct nfs_fh to its own header, and include that header in
linux/nfs.h so existing consumers keep building. Over time, consumers
can then replace

  #include <linux/nfs.h>

with

  #include <linux/nfs_fh.h>

While relocating the code, add kernel-doc comments for the FH
operations and convert nfs_compare_fh() to return bool.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/nfs.h    | 39 ++------------------------
 include/linux/nfs_fh.h | 63 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+), 37 deletions(-)
 create mode 100644 include/linux/nfs_fh.h

diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 0906a0b40c6a..0e2a0b1e3061 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -11,8 +11,8 @@
 #include <linux/cred.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/msg_prot.h>
-#include <linux/string.h>
-#include <linux/crc32.h>
+#include <linux/nfs_fh.h>
+
 #include <uapi/linux/nfs.h>
 
 /* The LOCALIO program is entirely private to Linux and is
@@ -22,30 +22,6 @@
 #define LOCALIOPROC_NULL		0
 #define LOCALIOPROC_UUID_IS_LOCAL	1
 
-/*
- * This is the kernel NFS client file handle representation
- */
-#define NFS_MAXFHSIZE		128
-struct nfs_fh {
-	unsigned short		size;
-	unsigned char		data[NFS_MAXFHSIZE];
-};
-
-/*
- * Returns a zero iff the size and data fields match.
- * Checks only "size" bytes in the data field.
- */
-static inline int nfs_compare_fh(const struct nfs_fh *a, const struct nfs_fh *b)
-{
-	return a->size != b->size || memcmp(a->data, b->data, a->size) != 0;
-}
-
-static inline void nfs_copy_fh(struct nfs_fh *target, const struct nfs_fh *source)
-{
-	target->size = source->size;
-	memcpy(target->data, source->data, source->size);
-}
-
 enum nfs3_stable_how {
 	NFS_UNSTABLE = 0,
 	NFS_DATA_SYNC = 1,
@@ -55,15 +31,4 @@ enum nfs3_stable_how {
 	NFS_INVALID_STABLE_HOW = -1
 };
 
-/**
- * nfs_fhandle_hash - calculate the crc32 hash for the filehandle
- * @fh - pointer to filehandle
- *
- * returns a crc32 hash for the filehandle that is compatible with
- * the one displayed by "wireshark".
- */
-static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
-{
-	return ~crc32_le(0xFFFFFFFF, &fh->data[0], fh->size);
-}
 #endif /* _LINUX_NFS_H */
diff --git a/include/linux/nfs_fh.h b/include/linux/nfs_fh.h
new file mode 100644
index 000000000000..49dfc5ec60fe
--- /dev/null
+++ b/include/linux/nfs_fh.h
@@ -0,0 +1,63 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * struct nfs_fh is an NFS version-agnostic data structure that
+ * stores an NFS file handle. It is also commonly used in NFS
+ * related APIs.
+ */
+#ifndef _LINUX_NFS_FH_H
+#define _LINUX_NFS_FH_H
+
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/crc32.h>
+
+/*
+ * The largest file handle size today is an NFSv4 file handle,
+ * which can be up to 128 octets long.
+ */
+#define NFS_MAXFHSIZE		128
+struct nfs_fh {
+	unsigned short		size;
+	unsigned char		data[NFS_MAXFHSIZE];
+};
+
+/**
+ * nfs_compare_fh - Compare two NFS file handles
+ * @a: An NFS file handle to be compared
+ * @b: An NFS file handle to be compared
+ *
+ * Checks only "size" bytes in each data field.
+ *
+ * Return: %false if the two file handles are equal, otherwise %true
+ */
+static inline bool nfs_compare_fh(const struct nfs_fh *a, const struct nfs_fh *b)
+{
+	return a->size != b->size || memcmp(a->data, b->data, a->size) != 0;
+}
+
+/**
+ * nfs_copy_fh - Copy an NFS file handle
+ * @target: Destination file handle
+ * @source: Source file handle
+ *
+ * Copies source->size bytes of file handle data into target.
+ */
+static inline void nfs_copy_fh(struct nfs_fh *target, const struct nfs_fh *source)
+{
+	target->size = source->size;
+	memcpy(target->data, source->data, source->size);
+}
+
+/**
+ * nfs_fhandle_hash - Calculate the crc32 hash for the filehandle
+ * @fh: An NFS file handle to hash
+ *
+ * Return: a crc32 hash for the filehandle that is compatible with
+ * the one displayed by "wireshark"
+ */
+static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
+{
+	return ~crc32_le(0xFFFFFFFF, &fh->data[0], fh->size);
+}
+
+#endif /* _LINUX_NFS_FH_H */
-- 
2.54.0

