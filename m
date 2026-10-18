Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61AD939EF3F;
	Sun, 18 Oct 2026 18:01:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346500; cv=none; b=apXqyyI9+1dhZvodnzU4ni1OIxifUUmQuW/lzz4/GJdyrA9BRbr99HIhWwn+aXvVlaGw/B8Dbt5IfAkeBXHofjGOj8ZE/lbz2R4re1JD2ciphc++I9gSGEdSTyA76r63jaRabPC2Ktx3Mx7XuMC14Bf1ahu1AjrjkcKwYx0T8RQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346500; c=relaxed/simple;
	bh=JSzp40E+RZbuSoTPRUcmsScBfQJOz6CyvlO2npqjnuQ=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=UCC3IInR+tOOPDEO2xFr3p1QTQSnN7pnHIlHRvI11I7NZ57tiE64l/de2+DHsqSdtWCCweYPLFl3aw1gzIbhGXSwLARhhc0xWjUO8xwcGokdEkNy0RPw5FyhyHkAtu3fD0UBFHaooz9UAom/VTl3WNWz+6IxY/kR30MPJ7+U2Tk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=cYP0VQN0; arc=none smtp.client-ip=212.227.15.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="cYP0VQN0"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346491; x=1792951291; i=jan.koester@gmx.net;
	bh=N1f0Gex4t4u5NvZRl0F71ptgdyUSFA8qEykUd0ghyGg=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=cYP0VQN0wGzuViQd+yN7rzGtQOAkmJ8c4QUbApCb4dg3FSfp9DE43hU1xVrpDfci
	 KNUmr+WJ974MPx0Ycr7PbgkAyYoRfiV7ekR/9h9m/MqbUf+8HoigOGr7vboJGQEcP
	 R9z+KOqghWjxWRfd5RdXYMt8HJ7IXjM98MqCVh7u6YBcUvwwPybSotAfIWuGuZXZR
	 bVrwF4S24a0yO8i79HQE4mtVXCgmCwKS8y/18/lUmvqh7xrioHVKUZmXRKBU4sRzZ
	 dt58Vqe57iOffTYRJTPAapidplWG8y9eNMLspgfoSl3zfbeyAjW8FFBeIxyuhToc7
	 Mhj/TfcJ3Nrbe3T8GQ==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1N1fis-1wcw9j2vjk-00t5ff; Sun, 18
 Oct 2026 20:01:31 +0200
Message-ID: <228e51d9de6fbe822c247aad062e09e6c3d95de4.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 02/41] uapi: add <linux/uidgid_r.h> for 128 bit capable
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
Date: Sun, 18 Oct 2026 20:01:23 +0200
X-Provags-ID: V03:K1:45YvIM9R/FMOmL+eWTsKBO/1ya4MYFvz/DyAmmzME0t52/ryPUA
 TzYmobVPGFmmuyjxy4xRHUp0D2DiUHBzzcLlcLyXVOHAsH2aOLT6mJ+BCSA/GPP7Efz5c9K
 29Lr+1skE9t2EPg2T0dEqbXObzyNT5bn7JEQmWHSB/Gn2IxiEgbS3iXgd93kzYjrLrDnie5
 pJEY2JIlYkkw0PMLUISrg==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:SSGNFdvTtE0=;0a8RJi+pD2BA4NGdkuJtDFT5QIa
 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
 OXWLGynVfyw=
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

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

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 include/uapi/linux/uidgid_r.h | 45 +++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)
 create mode 100644 include/uapi/linux/uidgid_r.h

diff --git a/include/uapi/linux/uidgid_r.h b/include/uapi/linux/uidgid_r.h
new file mode 100644
index 0000000000..c3b1cb2ae2
=2D-- /dev/null
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
+ * Kinds of id (__kernel_uid_r_t.type). An all-zero id is UID_R_NONE, so =
a
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
+ * .guid holds the GUID as Windows stores it: Data1, Data2 and Data3 litt=
le
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
=2D-=20
2.56.0

