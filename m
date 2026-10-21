Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552533;
	b=Q5tT85JXkxM07yxDaqyUqW8mb8N5XGMa+UlmM66LdbrIPpuwhifjBMs+8hKQxQ5I9vuM
	 7UbYOZouJYp4NQQs1QKijqmQ3FkcD/SDyAznK6jbke5wnUb3s5pjeVF2XE0Rg1C91v7bp
	 R6IlfbSmROQ1+x3eSfQHluqtBWHMe5ge3Ex9kp2ZsV2mtiFSYTG6gPmzItkJ3rUOyVll4
	 UpZx8fJQH7pgSrQjm1HFIvXbyCcGZkoS16vPzz5F2LnjpHH8qCcBv32Huz9LZ8jUmRvB4
	 c50YZn4NwT8V2kVNKUFqVsrfmsUzDPQMMZpg7Znh0lRocu99aej2TcVlTvDc1FbTVWA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552533;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=FvxvwlvKQW68/Q46PbVvX5Gth8lANFfaBxD+MUBSiqA=;
	b=1voq7PHFB1oIHgdI9evCS+B6d5VAFpTZmhaIoGS3gjtc8m7p3WMhR3CpMif9v91cCxSI
	 mB8C8hTAH3GyI0fvlRhGv5c4zb3AyczqHuExnn1dBnpH7C4A2RVwyLmqfGtzvPAcQAugu
	 Bd+ske/YdYd+M2VKwmLyClif0YvTNFiJtfNkkjQpvkNZqazJTbGY7Mqg41oUihpUsnK8U
	 sOuzvgP/BR0JpCZFUxB2qdqY0Uya318rZbKxin7H4pPpyHtj7CS5eiXADlVlYffyClcdw
	 A2T88sckHNWDDNmmSvVJGj/+rLuhePYL+HuYLUZG7cXfft1Eq2NeFutDg5dE9JhAuOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=DLr84FcC;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B52E6606A330;
	Wed, 21 Oct 2026 03:15:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B52E6606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=DLr84FcC
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552524; bh=zoj44Jn2GUZMczwZ9hQnuecG1LPZ9VCxV5H+Lk+SCV8=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=DLr84FcCfsuixPZZgeYUPDPPrKfFt+HtUh74bTSjvuIXCbQYWCDlyDLkaXZNkV536
	 1JVhuuQUpL/bDgOf8YjW9rVhl/nkzyVwydBFhK53WWFvgqDo+wJQpCfD6IsBW23zTc
	 jhJHyMxRqqInisKWuUsxf/r74xONglicrzuGyWGmve5FYnl/+D+AL4fXp0Lpfh/RYe
	 iEOa7hUeY5j/GAGffrMqL0GtNTijHyHGSjI/BRynMzQ9gfSvCDkDp+mXCl9WfmYHZz
	 P7Xq2KoJnYBHOkBDtXAAjMvNJcjkDDHeYn9SD+HbSFI0qvbcl1p1prtBByKsLWxaLr
	 4GquWOhyPIEKQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id DF2078A07DE;
	Wed, 21 Oct 2026 05:15:23 +0200 (CEST)
Message-ID: <cbbfec8ce428602e02814d258aa5e516b11b30a1.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 01/41] uuid: move uuid_t and guid_t into
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
Date: Wed, 21 Oct 2026 05:15:21 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

<linux/uuid.h> pulls in <linux/string.h> for its helpers, which makes it
unusable from headers low in the include chain. The next patches embed
UUIDs and GUIDs in kuid_t and kgid_t, whose <linux/uidgid_types.h> is
included by <linux/sched.h>.

Move the two types and UUID_SIZE into a header of their own that only
needs <linux/types.h>. <linux/uuid.h> includes it, so no user changes.

No functional change.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/uuid.h       | 11 +----------
 include/linux/uuid_types.h | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/uuid_types.h

diff --git a/include/linux/uuid.h b/include/linux/uuid.h
index 43d4a79b27..cbdaf0ca45 100644
--- a/include/linux/uuid.h
+++ b/include/linux/uuid.h
@@ -9,16 +9,7 @@
 #define _LINUX_UUID_H_
 
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
 
 #define GUID_INIT(a, b, c, d0, d1, d2, d3, d4, d5, d6, d7)			\
 ((guid_t)								\
diff --git a/include/linux/uuid_types.h b/include/linux/uuid_types.h
new file mode 100644
index 0000000000..1e45b69571
--- /dev/null
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
-- 
2.56.0

