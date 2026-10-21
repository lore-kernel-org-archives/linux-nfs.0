Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552532;
	b=mVdkdy5yEJMiqQex+oUab0nurPZzLG0x8TIz6+JdILr2k7P0oinX5Aj/NyB1t/gk8CwO
	 COcL+4TzSozMLWstYr0H5dU8fGMVT3fbS65JOOoJK+fK4JyRos0L/40M65+975/bORB4y
	 YSb8LmL4Jk8s9G58VD7h042AVcMegMz6jojhyAU9toEeZmBOF0X+TqE4DkFZR3wnEBAZv
	 el7AGt2RE0Mc61IXINB/Rxrmnxom75ZCZbbslELfKh3XSBL/0h6GGvYf6768r4Z29jOuE
	 7NoKmGPFXXAvBAb/TK7n14g0ERk5U6NG3JNqV57Pd0I4J+anQWCLH5hCzhhBbhHv8UA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552532;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=2Rr2bO9okDTnKQK7n2lk4waHPtLw2M+XqSbjGvsVjiU=;
	b=kxJ1KQE/8J0FNYE0omUAQpsrrErDAHQUXyNjbgCjDuGhgYwlxxZeDvJZM5ndKSOJddXA
	 PSHnh6+DW3Nx9oQIWE4HdCopMxnDgKLwUcymFKjwUIEfNEPJI+tRUSxRKdfDP8xFdZp+b
	 JSrdYdptZGplT+wMqmLKg7cjUBpPCmeZ5z+4njpO1kB0VbIWw43wtyDFni0qrpY0nFx+7
	 4YxiFRfRFYNeGOmA15VVESqrLUP6GvxpyQRjdBCEz1DvjlelOhI2iTwNh/FfO64PyZj2A
	 mxxG+wDbwEGWY3UhTo0KgzXxIzckZKPgBWm7aqbIxzc0dtichn5nZ52ev3j3bApmu/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=G6WTKipf;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14D25606A31B;
	Wed, 21 Oct 2026 03:15:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 14D25606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=G6WTKipf
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552527; bh=ZfG1SosqlxBe8ziMkADyGjmN09svT+4JHhKhTcpS7n0=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=G6WTKipfrRpsgqmp7VeEQmAz1k+70ZU6flTO7Z4P5DVP0Ogu11+Hvw/c3+wVLm5Mg
	 Epk9RoKjnjmkOX3ZYMsICS8LmzzMc488Ty4pxYQIzZx24rafgNgb56wp0ehNDWyU8i
	 x1juHOsrDZThhoYETUw7hdXH14EUWOnEaq3qfoGueNajXZFnneUDlnGNBkpalIXTPe
	 fYKKbmo1n7O0T1syFNB6V5cD3DVH7hk0ZZELsEeLICiP3OHi3rPPHnXuQM1vEmr8Ok
	 XUqJltcsbj0ISJGCGgmQgWy0fvQkzPt9KloCgjiA+n63+5ETdXc+77Cn8nTNq8aJdD
	 vUqP3agDGkZ0Q==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id F17EB8A08DF;
	Wed, 21 Oct 2026 05:15:26 +0200 (CEST)
Message-ID: <423713b22f1cfa384f3df8cddc91e81d35c52d8a.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 02/41] uapi: add <linux/uidgid_r.h> for 128 bit capable
 user and group ids
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
Date: Wed, 21 Oct 2026 05:15:22 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

User and group ids are 32 bit numbers. Identities that come from
elsewhere -- UUIDs handed out by a directory service, or the GUIDs of a
Windows domain -- have to be squeezed into that range through mapping
tables kept in userspace, and the kernel never sees who a process really
is.

Add a tagged id for a new family of system calls (named after the
classic ones with an _r suffix): a classic 32 bit id, an RFC 9562
version 4 UUID, or a Microsoft GUID in the byte order Windows stores it
in. Type 0 is "no id", so a zero-initialized id is never root, and lets
the set*id_r() calls express "unchanged" without a magic number.

The struct has no 64 bit members and the same layout on all ABIs, so
none of the new calls needs a compat entry point.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/uapi/linux/uidgid_r.h | 45 +++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)
 create mode 100644 include/uapi/linux/uidgid_r.h

diff --git a/include/uapi/linux/uidgid_r.h b/include/uapi/linux/uidgid_r.h
new file mode 100644
index 0000000000..c3b1cb2ae2
--- /dev/null
+++ b/include/uapi/linux/uidgid_r.h
@@ -0,0 +1,45 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
+/*
+ * User and group ids for the *_r system calls: a classic 32 bit id, a
+ * UUID or a Microsoft GUID.
+ *
+ * The classic system calls (getuid(), chown(), ...) keep their 32 bit
+ * ids; for an id that has no 32 bit form they see the overflow id
+ * (/proc/sys/kernel/overflowuid and overflowgid), like the 16 bit system
+ * calls do for ids above 65535.
+ */
+#ifndef _UAPI_LINUX_UIDGID_R_H
+#define _UAPI_LINUX_UIDGID_R_H
+
+#include <linux/types.h>
+
+/*
+ * Kinds of id (__kernel_uid_r_t.type). An all-zero id is UID_R_NONE, so a
+ * zero-initialized id never stands for root.
+ */
+#define UID_R_NONE	0	/* no id: "unchanged" or "not set" */
+#define UID_R_LEGACY	1	/* classic 32 bit id in .legacy */
+#define UID_R_UUID	2	/* RFC 9562 UUID, version 4, in .uuid */
+#define UID_R_GUID	3	/* Microsoft GUID in .guid */
+
+#define UID_R_SIZE	16	/* bytes of .uuid and .guid */
+
+/*
+ * .uuid holds the UUID in network byte order, as RFC 9562 lays it out.
+ * .guid holds the GUID as Windows stores it: Data1, Data2 and Data3 little
+ * endian, Data4 as is.
+ *
+ * Bytes past the member .type selects are reserved and must be zero.
+ */
+typedef struct __kernel_uid_r {
+	__u32 type;
+	union {
+		__u32 legacy;
+		__u8 uuid[UID_R_SIZE];
+		__u8 guid[UID_R_SIZE];
+	};
+} __kernel_uid_r_t;
+
+typedef __kernel_uid_r_t __kernel_gid_r_t;
+
+#endif /* _UAPI_LINUX_UIDGID_R_H */
-- 
2.56.0

