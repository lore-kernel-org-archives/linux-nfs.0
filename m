Received: from mout.gmx.net (mout.gmx.net [212.227.15.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C68973E9C3C;
	Sun, 18 Oct 2026 18:01:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346500; cv=none; b=igOO2RdFeOdhq2jhPTSGXY+NXckXDoWITcFNPRAXtEnL54cyG3cJ+08gYGkx8L0BBO4nLyqUkur31DoXOvS/c4JjV6r5I9Gy10oCBlg5izfwhN1eTGBklqFFzkOQ4w23XQdM/+umByqVezTygHQfjh+EygEtrEav0MFgvGcu59c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346500; c=relaxed/simple;
	bh=eZUedBWf957L4vf3yJH5e1TzkkFiNTAAuz1Z6Ci5dDo=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=EkIB+mgLuL+MlTirIQ0VDIbTdYUq5lZ0SeUDkVts+lXADGNEuiuQHwP71uoL4+RRd5uF0XwNjrs/bz4/J7ZhlUnSzstD8nMQRMw8Lb1+MeJKI6mSs5xr5SurTeNGvjNLszepzlFCEG2tKtWzK4/f7LMZb1qjvLTdTHwEr8B8gUM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=U8ANwFf7; arc=none smtp.client-ip=212.227.15.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="U8ANwFf7"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346488; x=1792951288; i=jan.koester@gmx.net;
	bh=SFgWfv4a9mKBatZQK/Us/wk277ylW2oCFRHMYCRV4bc=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=U8ANwFf7frrcPkIXZS4nFJn0oD0o4EaF6RoI5/63FeVQYQt/dwnJt9tzEc2/JKhA
	 lnft5xYPi893yMksS76SIqysYTWgEm5cCyShYqmFBgd6awaXyE7p/i6UltaPtWg5N
	 QMNCoEaGR4TWOsL6CARKhDZY31lP2WVO43iY/P5E0yj5mNy+ZVhKfBZQ6V2k2h8/V
	 Lw1kgm26r8UuxMDBWab5l2Eh1d3Wnv0AfpNPcvgDDvV8Z/N9t6U4hZ12NXFbN3KYv
	 8l5au3DI6RXhVlHYzoBOQfSwfQCOHKRVQqLgyPAYTi2gtX8Rn5DoVhJQ2PScdkrFQ
	 i5uFU7KoQexLIzWyYQ==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1MvsIv-1wR5nb2Gu7-011eFI; Sun, 18
 Oct 2026 20:01:28 +0200
Message-ID: <96c4e6297469781b3bf67f133bb7de9897e45935.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 01/41] uuid: move uuid_t and guid_t into
 <linux/uuid_types.h>
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Sun, 18 Oct 2026 20:01:22 +0200
X-Provags-ID: V03:K1:Q7TBBKDeQWAfub1Y8AIwgyfdfZXqFH/lnZsJqQA+s86/E+f0jKI
 TGOuCq/Kmfrwvba9x0b8uQvmmCooEMVNCT0+ivpAxVlbRyteigQfVlaks+PGT1mQ0gnUOvz
 OD99IYWHIefLFjG1Y3GdZ/l9o1i/TPPklSNVSs2BCxtBVP0nCXL1ULoG8py0grxhVLxHI/J
 4Jdk1RnPGMvUlf3xpb1kQ==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:zwfBwa9ZjZQ=;7hRxiouCDZGpERm2+F8rwpDDnoG
 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
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

<linux/uuid.h> pulls in <linux/string.h> for its helpers, which makes it
unusable from headers low in the include chain. The next patches embed
UUIDs and GUIDs in kuid_t and kgid_t, whose <linux/uidgid_types.h> is
included by <linux/sched.h>.

Move the two types and UUID_SIZE into a header of their own that only
needs <linux/types.h>. <linux/uuid.h> includes it, so no user changes.

No functional change.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 include/linux/uuid.h       | 11 +----------
 include/linux/uuid_types.h | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/uuid_types.h

diff --git a/include/linux/uuid.h b/include/linux/uuid.h
index 43d4a79b27..cbdaf0ca45 100644
=2D-- a/include/linux/uuid.h
+++ b/include/linux/uuid.h
@@ -9,16 +9,7 @@
 #define _LINUX_UUID_H_
=20
 #include <linux/string.h>
-
-#define UUID_SIZE 16
-
-typedef struct {
-	__u8 b[UUID_SIZE];
-} guid_t;
-
-typedef struct {
-	__u8 b[UUID_SIZE];
-} uuid_t;
+#include <linux/uuid_types.h>
=20
 #define GUID_INIT(a, b, c, d0, d1, d2, d3, d4, d5, d6, d7)			\
 ((guid_t)								\
diff --git a/include/linux/uuid_types.h b/include/linux/uuid_types.h
new file mode 100644
index 0000000000..1e45b69571
=2D-- /dev/null
+++ b/include/linux/uuid_types.h
@@ -0,0 +1,21 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+/*
+ * UUID/GUID types, without the helpers of <linux/uuid.h>, for headers
+ * low in the include chain (such as <linux/uidgid_types.h>)
+ */
+#ifndef _LINUX_UUID_TYPES_H_
+#define _LINUX_UUID_TYPES_H_
+
+#include <linux/types.h>
+
+#define UUID_SIZE 16
+
+typedef struct {
+	__u8 b[UUID_SIZE];
+} guid_t;
+
+typedef struct {
+	__u8 b[UUID_SIZE];
+} uuid_t;
+
+#endif /* _LINUX_UUID_TYPES_H_ */
=2D-=20
2.56.0

