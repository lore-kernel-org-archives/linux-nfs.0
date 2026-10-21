Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552647;
	b=Zeadt4ASzzKhjWfMP4jzRXPxhIa8qr22aVWUF1y5T7zXHL4N6tNa9DhpGQTa3TNkhk2S
	 DUhLkp/RDgwE484VU1qtQi6bq8NcNYMmJ+lNwCP/ywy+nD9/dtz+Mt8uihuiaIWIsbRVb
	 D7MKoQf0ELJJc2wIpGtovOqOhx/FnUQ6+JUae5Dd4qQe45dWT17IPgpjSgsEW/G9I8wPa
	 CyfWrXbrTQARWnWfNr0zBjG182zKkEVY0OmNnkgNxvB9qjgs5qTrDL2xLHcyf3HImp9kY
	 Ff009NaOTb5OPL2r/LuGdYG9LWoR5/8CCKbIMTINMW0ub4QXfMrcoz+PVRlII/OSw9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552647;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=nYvtmL4wrkVJW2qIXWmO4VjA3o4UGMFPsSNBZJb1a9Y=;
	b=MO/akkP6DHRBF9WH9pP0f/KO4VFYMzyg1ak0ta/yjYL32Jzch6hT9duSAgyrX1ABf/Ds
	 8uGA+Xtv2xrw9Yo2uI+s4IFDSEEpmCNcXDDNgwkBv2dPp2lI4glpU3fsRgm0RfVFjo6c2
	 2FRPZWSkw17pxpZulUohzBChvcqev/SvpK0BHMu6UtmNDilemiotpHCk9ujTjoKm6W/GO
	 IN6SZsF4GW5BDu1vV9byblIOpvYNeulx9QLcaWCRpJ19itSfLbPpp2XVRms/VfxFmaxQT
	 1Xfrnfi4wtI+JkyiIgZqPWQSEgGYYvUsT54fracwuFYdINo9qlu+vGqZxEeNxHba1aQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=XN0OLO62;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 267746078D3B;
	Wed, 21 Oct 2026 03:17:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 267746078D3B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=XN0OLO62
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552644; bh=H9IP7//wVhvJW0RbC7yZSLQoBRc6WrkeRtrQk+Lfapc=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=XN0OLO625a+T0QqIt7RN7bJRzrMypKmLJPh5RHzLnVpyp1AhANXNzB6Js/ZmDYB+c
	 HXTWzX9r7g4XSxUsT6lQQmd6lHjmVUBy6C/9Ztt8+E4+DG+jRR2SU//cabawGOX5Jc
	 CN3kgXzQFUPBV7YQYiyoSJPb2DW87Ukbv0WTIRGgnEL2Vh7EMbZPpB7IlAHMTzxz28
	 2Q0aZbOjmhVd/cg1C9PoI8BOOxtxocEmpYUJECe5gNTkDtbm5Y6IU0cStfPZIPpI2x
	 j5suB+XrPYjtw962E9ufb63pvEhat9EvnFpiCwZgN5xCRxVdG/KeKVGBt3uA3WLMKr
	 fWtAz4pzt5bRg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 4D8418A0651;
	Wed, 21 Oct 2026 05:17:23 +0200 (CEST)
Message-ID: <fe7cdf53b4cc8e404778fb91dc5e44e48197b48a.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 36/41] selftests: add tests for UUID and GUID ids
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
Date: Wed, 21 Oct 2026 05:15:56 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Test the *_r system calls (malformed ids, switching to a UUID user and
back through the saved uid, GUID groups, sorted supplementary groups,
chown_r() and statx() on tmpfs, creating files as a UUID fsuid,
-EOVERFLOW on sysfs) and the extended interfaces: SO_PEERCRED_R,
SO_PEERGROUPS_R, SCM_CREDENTIALS_R, ssi_uid_r, IPC_STAT_R/IPC_SET_R,
version 3 POSIX ACL xattrs, the Uid_r: line of /proc/<pid>/status, and
that the root of a user namespace has no privilege over UUID owners.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 tools/testing/selftests/Makefile           |   1 +
 tools/testing/selftests/uid_r/.gitignore   |   1 +
 tools/testing/selftests/uid_r/Makefile     |   6 +
 tools/testing/selftests/uid_r/config       |   4 +
 tools/testing/selftests/uid_r/uid_r_test.c | 535 +++++++++++++++++++++
 5 files changed, 547 insertions(+)
 create mode 100644 tools/testing/selftests/uid_r/.gitignore
 create mode 100644 tools/testing/selftests/uid_r/Makefile
 create mode 100644 tools/testing/selftests/uid_r/config
 create mode 100644 tools/testing/selftests/uid_r/uid_r_test.c

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index bc4fdb6f53..393eb18119 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -140,6 +140,7 @@ TARGETS += tpm2
 TARGETS += tty
 TARGETS += ublk
 TARGETS += uevent
+TARGETS += uid_r
 TARGETS += user_events
 TARGETS += vDSO
 TARGETS += mm
diff --git a/tools/testing/selftests/uid_r/.gitignore b/tools/testing/selftests/uid_r/.gitignore
new file mode 100644
index 0000000000..5855e85e33
--- /dev/null
+++ b/tools/testing/selftests/uid_r/.gitignore
@@ -0,0 +1 @@
+uid_r_test
diff --git a/tools/testing/selftests/uid_r/Makefile b/tools/testing/selftests/uid_r/Makefile
new file mode 100644
index 0000000000..d5dc3e6aa5
--- /dev/null
+++ b/tools/testing/selftests/uid_r/Makefile
@@ -0,0 +1,6 @@
+# SPDX-License-Identifier: GPL-2.0
+CFLAGS += -g -Wall $(KHDR_INCLUDES) $(TOOLS_INCLUDES)
+
+TEST_GEN_PROGS := uid_r_test
+
+include ../lib.mk
diff --git a/tools/testing/selftests/uid_r/config b/tools/testing/selftests/uid_r/config
new file mode 100644
index 0000000000..424ac0a2ca
--- /dev/null
+++ b/tools/testing/selftests/uid_r/config
@@ -0,0 +1,4 @@
+CONFIG_TMPFS=y
+CONFIG_TMPFS_POSIX_ACL=y
+CONFIG_SYSVIPC=y
+CONFIG_SIGNALFD=y
diff --git a/tools/testing/selftests/uid_r/uid_r_test.c b/tools/testing/selftests/uid_r/uid_r_test.c
new file mode 100644
index 0000000000..88397bf3da
--- /dev/null
+++ b/tools/testing/selftests/uid_r/uid_r_test.c
@@ -0,0 +1,535 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Tests of UUID and GUID user and group ids: the *_r system calls and the
+ * interfaces extended for them. Needs root in the initial user namespace;
+ * every test runs in a child process, file tests on a private tmpfs.
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <fcntl.h>
+#include <sched.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/ipc.h>
+#include <sys/mount.h>
+#include <sys/shm.h>
+#include <sys/signalfd.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/syscall.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/xattr.h>
+#include <linux/uidgid_r.h>
+
+#include "../kselftest_harness.h"
+
+#ifndef __NR_getuid_r
+#define __NR_getuid_r		473
+#define __NR_geteuid_r		474
+#define __NR_getgid_r		475
+#define __NR_getegid_r		476
+#define __NR_setuid_r		477
+#define __NR_setgid_r		478
+#define __NR_setreuid_r		479
+#define __NR_setregid_r		480
+#define __NR_setresuid_r	481
+#define __NR_getresuid_r	482
+#define __NR_setresgid_r	483
+#define __NR_getresgid_r	484
+#define __NR_setfsuid_r		485
+#define __NR_setfsgid_r		486
+#define __NR_getgroups_r	487
+#define __NR_setgroups_r	488
+#define __NR_chown_r		489
+#define __NR_lchown_r		490
+#define __NR_fchown_r		491
+#define __NR_fchownat_r		492
+#endif
+
+#ifndef STATX_UID_R
+#define STATX_UID_R		0x00040000U
+#define STATX_GID_R		0x00080000U
+#endif
+#ifndef SO_PEERCRED_R
+#define SO_PEERCRED_R		86
+#define SO_PEERGROUPS_R		87
+#define SO_PASSCRED_R		88
+#endif
+#ifndef SCM_CREDENTIALS_R
+#define SCM_CREDENTIALS_R	0x05
+#endif
+#ifndef IPC_STAT_R
+#define IPC_SET_R		21
+#define IPC_STAT_R		22
+#endif
+
+typedef __kernel_uid_r_t id_r;
+
+struct ucred_r {
+	__u32 pid;
+	id_r uid, gid;
+};
+
+struct ipc_perm_r_t {
+	int key;
+	__u32 mode;
+	id_r uid, gid, cuid, cgid;
+};
+
+/*
+ * Reserved bytes must be zero, and an initializer of one union member
+ * leaves the others undefined: always clear the whole id first.
+ */
+static id_r legacy(unsigned int v)
+{
+	id_r id;
+
+	memset(&id, 0, sizeof(id));
+	id.type = UID_R_LEGACY;
+	id.legacy = v;
+	return id;
+}
+
+/* a version 4 UUID, made distinct by @tag */
+static id_r uuid(unsigned char tag)
+{
+	static const unsigned char b[16] = {
+		0x6f, 0x1c, 0x2a, 0x3b, 0x4d, 0x5e, 0x4f, 0x60,
+		0x8a, 0x7b, 0x0c, 0x1d, 0x2e, 0x3f, 0x4a, 0x00 };
+	id_r id;
+
+	memset(&id, 0, sizeof(id));
+	id.type = UID_R_UUID;
+	memcpy(id.uuid, b, sizeof(b));
+	id.uuid[15] = tag;
+	return id;
+}
+
+static id_r guid(unsigned char tag)
+{
+	id_r id;
+
+	memset(&id, 0, sizeof(id));
+	id.type = UID_R_GUID;
+	for (int i = 0; i < 16; i++)
+		id.guid[i] = 0x10 + i;
+	id.guid[15] = tag;
+	return id;
+}
+
+static int ideq(const id_r *a, const id_r *b)
+{
+	return !memcmp(a, b, sizeof(*a));
+}
+
+static long sys(long nr, long a, long b, long c, long d, long e)
+{
+	long ret = syscall(nr, a, b, c, d, e);
+
+	return ret < 0 ? -errno : ret;
+}
+
+/* a private tmpfs at a fresh directory, for file tests */
+static void private_tmpfs(struct __test_metadata *_metadata, char *dir)
+{
+	strcpy(dir, "/tmp/uid_r.XXXXXX");
+	ASSERT_EQ(0, unshare(CLONE_NEWNS));
+	ASSERT_EQ(0, mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL));
+	ASSERT_NE(NULL, mkdtemp(dir));
+	ASSERT_EQ(0, mount("tmpfs", dir, "tmpfs", 0, "mode=1777"));
+}
+
+static int statx_owner(const char *path, id_r *uid, id_r *gid)
+{
+	struct statx stx;
+
+	memset(&stx, 0, sizeof(stx));
+	if (statx(AT_FDCWD, path, 0, STATX_UID_R | STATX_GID_R, &stx))
+		return -errno;
+	if ((stx.stx_mask & (STATX_UID_R | STATX_GID_R)) !=
+	    (STATX_UID_R | STATX_GID_R))
+		return -ENODATA;
+	/* stx_uid_r and stx_gid_r at 0xc0 */
+	memcpy(uid, (char *)&stx + 0xc0, sizeof(*uid));
+	memcpy(gid, (char *)&stx + 0xc0 + sizeof(*uid), sizeof(*gid));
+	return 0;
+}
+
+FIXTURE(uid_r) {
+	char dir[64];
+};
+
+FIXTURE_SETUP(uid_r)
+{
+	id_r id;
+
+	if (geteuid() != 0)
+		SKIP(return, "needs root");
+	if (sys(__NR_getuid_r, (long)&id, 0, 0, 0, 0) == -ENOSYS)
+		SKIP(return, "no *_r system calls");
+	self->dir[0] = 0;
+}
+
+FIXTURE_TEARDOWN(uid_r)
+{
+}
+
+TEST_F(uid_r, malformed_ids)
+{
+	id_r id;
+
+	id = uuid(1);
+	id.uuid[6] = 0x14;			/* version 1 */
+	EXPECT_EQ(-EINVAL, sys(__NR_setuid_r, (long)&id, 0, 0, 0, 0));
+	id = uuid(1);
+	id.type = 9;
+	EXPECT_EQ(-EINVAL, sys(__NR_setuid_r, (long)&id, 0, 0, 0, 0));
+	id = legacy(5);
+	id.uuid[10] = 1;			/* reserved byte */
+	EXPECT_EQ(-EINVAL, sys(__NR_setuid_r, (long)&id, 0, 0, 0, 0));
+	memset(&id, 0, sizeof(id));
+	id.type = UID_R_GUID;			/* nil GUID */
+	EXPECT_EQ(-EINVAL, sys(__NR_setuid_r, (long)&id, 0, 0, 0, 0));
+	EXPECT_EQ(-EINVAL, sys(__NR_setuid_r, 0, 0, 0, 0, 0));
+	EXPECT_EQ(-EFAULT, sys(__NR_getuid_r, 1, 0, 0, 0, 0));
+}
+
+TEST_F(uid_r, setresuid_r)
+{
+	id_r u = uuid(1), s0 = legacy(0), r, e, s;
+
+	ASSERT_EQ(0, sys(__NR_setresuid_r, (long)&u, (long)&u, (long)&s0, 0, 0));
+	EXPECT_EQ(65534, getuid());
+	EXPECT_EQ(65534, geteuid());
+	ASSERT_EQ(0, sys(__NR_getresuid_r, (long)&r, (long)&e, (long)&s, 0, 0));
+	EXPECT_TRUE(ideq(&r, &u));
+	EXPECT_TRUE(ideq(&e, &u));
+	EXPECT_TRUE(ideq(&s, &s0));
+
+	/* without euid 0 no capabilities: no other UUID */
+	r = uuid(2);
+	EXPECT_EQ(-EPERM, sys(__NR_setuid_r, (long)&r, 0, 0, 0, 0));
+
+	/* back through the saved uid */
+	ASSERT_EQ(0, sys(__NR_setresuid_r, 0, (long)&s0, 0, 0, 0));
+	EXPECT_EQ(0, geteuid());
+}
+
+TEST_F(uid_r, guid_group)
+{
+	id_r g = guid(7), e;
+
+	ASSERT_EQ(0, sys(__NR_setresgid_r, 0, (long)&g, 0, 0, 0));
+	EXPECT_EQ(65534, getegid());
+	ASSERT_EQ(0, sys(__NR_getegid_r, (long)&e, 0, 0, 0, 0));
+	EXPECT_TRUE(ideq(&e, &g));
+}
+
+TEST_F(uid_r, groups_r)
+{
+	id_r in[3] = { guid(9), legacy(10), uuid(4) }, out[4];
+	gid_t classic[4];
+
+	ASSERT_EQ(0, sys(__NR_setgroups_r, 3, (long)in, 0, 0, 0));
+	ASSERT_EQ(3, sys(__NR_getgroups_r, 4, (long)out, 0, 0, 0));
+	/* sorted: legacy, UUID, GUID */
+	EXPECT_TRUE(ideq(&out[0], &in[1]));
+	EXPECT_TRUE(ideq(&out[1], &in[2]));
+	EXPECT_TRUE(ideq(&out[2], &in[0]));
+	ASSERT_EQ(3, getgroups(4, classic));
+	EXPECT_EQ(10, classic[0]);
+	EXPECT_EQ(65534, classic[1]);
+	memset(&in[0], 0, sizeof(in[0]));
+	EXPECT_EQ(-EINVAL, sys(__NR_setgroups_r, 1, (long)in, 0, 0, 0));
+}
+
+TEST_F(uid_r, chown_r_statx)
+{
+	id_r u = uuid(5), g = guid(6), r, rg;
+	char path[96];
+	struct stat st;
+	int fd;
+
+	private_tmpfs(_metadata, self->dir);
+	snprintf(path, sizeof(path), "%s/f", self->dir);
+	fd = open(path, O_CREAT | O_WRONLY, 0644);
+	ASSERT_LE(0, fd);
+	ASSERT_EQ(0, sys(__NR_fchown_r, fd, (long)&u, (long)&g, 0, 0));
+	close(fd);
+	ASSERT_EQ(0, stat(path, &st));
+	EXPECT_EQ(65534, st.st_uid);
+	ASSERT_EQ(0, statx_owner(path, &r, &rg));
+	EXPECT_TRUE(ideq(&r, &u));
+	EXPECT_TRUE(ideq(&rg, &g));
+
+	/* NULL leaves the owner, UID_R_NONE too */
+	r = legacy(42);
+	memset(&rg, 0, sizeof(rg));
+	ASSERT_EQ(0, sys(__NR_chown_r, (long)path, 0, (long)&r, 0, 0));
+	ASSERT_EQ(0, sys(__NR_fchownat_r, AT_FDCWD, (long)path, (long)&rg, 0, 0));
+	ASSERT_EQ(0, statx_owner(path, &r, &rg));
+	EXPECT_TRUE(ideq(&r, &u));
+	EXPECT_EQ(UID_R_LEGACY, rg.type);
+	EXPECT_EQ(42, rg.legacy);
+}
+
+TEST_F(uid_r, create_as_uuid_fsuid)
+{
+	id_r u = uuid(3), s0 = legacy(0), old, r, rg;
+	char path[96];
+	int fd;
+
+	private_tmpfs(_metadata, self->dir);
+	snprintf(path, sizeof(path), "%s/byuuid", self->dir);
+	ASSERT_EQ(0, sys(__NR_setfsuid_r, (long)&u, (long)&old, 0, 0, 0));
+	EXPECT_TRUE(ideq(&old, &s0));
+	fd = open(path, O_CREAT | O_WRONLY, 0644);
+	ASSERT_EQ(0, sys(__NR_setfsuid_r, (long)&s0, 0, 0, 0, 0));
+	ASSERT_LE(0, fd);
+	close(fd);
+	ASSERT_EQ(0, statx_owner(path, &r, &rg));
+	EXPECT_TRUE(ideq(&r, &u));
+}
+
+TEST_F(uid_r, classic_only_fs)
+{
+	id_r u = uuid(5);
+
+	/* sysfs (kernfs) can't store UUID owners */
+	EXPECT_EQ(-EOVERFLOW, sys(__NR_chown_r, (long)"/sys/kernel",
+				  (long)&u, 0, 0, 0));
+}
+
+TEST_F(uid_r, peercred_r)
+{
+	id_r u = uuid(8), s0 = legacy(0), g = guid(10), groups[2];
+	struct ucred_r pc;
+	struct ucred lc;
+	socklen_t len;
+	int sv[2];
+
+	groups[0] = g;
+	groups[1] = legacy(7);
+	ASSERT_EQ(0, sys(__NR_setgroups_r, 2, (long)groups, 0, 0, 0));
+	ASSERT_EQ(0, sys(__NR_setresuid_r, 0, (long)&u, (long)&s0, 0, 0));
+	ASSERT_EQ(0, socketpair(AF_UNIX, SOCK_STREAM, 0, sv));
+	ASSERT_EQ(0, sys(__NR_setresuid_r, 0, (long)&s0, 0, 0, 0));
+
+	len = sizeof(pc);
+	ASSERT_EQ(0, getsockopt(sv[1], SOL_SOCKET, SO_PEERCRED_R, &pc, &len));
+	EXPECT_TRUE(ideq(&pc.uid, &u));
+	len = sizeof(lc);
+	ASSERT_EQ(0, getsockopt(sv[1], SOL_SOCKET, SO_PEERCRED, &lc, &len));
+	EXPECT_EQ(65534, lc.uid);
+	len = sizeof(groups);
+	ASSERT_EQ(0, getsockopt(sv[1], SOL_SOCKET, SO_PEERGROUPS_R, groups, &len));
+	EXPECT_EQ(2 * sizeof(id_r), len);
+	EXPECT_TRUE(ideq(&groups[1], &g));
+}
+
+TEST_F(uid_r, scm_credentials_r)
+{
+	id_r u = uuid(9), s0 = legacy(0);
+	char data = 'x', cbuf[256];
+	struct iovec iov = { &data, 1 };
+	struct msghdr mh = { 0 };
+	struct cmsghdr *c;
+	int sv[2], one = 1, got_r = 0, got_l = 0;
+
+	ASSERT_EQ(0, socketpair(AF_UNIX, SOCK_STREAM, 0, sv));
+	ASSERT_EQ(0, setsockopt(sv[1], SOL_SOCKET, SO_PASSCRED, &one, sizeof(one)));
+	ASSERT_EQ(0, setsockopt(sv[1], SOL_SOCKET, SO_PASSCRED_R, &one, sizeof(one)));
+	/* SCM credentials carry the real ids */
+	ASSERT_EQ(0, sys(__NR_setresuid_r, (long)&u, 0, (long)&s0, 0, 0));
+	ASSERT_EQ(1, write(sv[0], &data, 1));
+	ASSERT_EQ(0, sys(__NR_setresuid_r, (long)&s0, 0, 0, 0, 0));
+
+	mh.msg_iov = &iov;
+	mh.msg_iovlen = 1;
+	mh.msg_control = cbuf;
+	mh.msg_controllen = sizeof(cbuf);
+	ASSERT_EQ(1, recvmsg(sv[1], &mh, 0));
+	EXPECT_FALSE(mh.msg_flags & MSG_CTRUNC);
+	for (c = CMSG_FIRSTHDR(&mh); c; c = CMSG_NXTHDR(&mh, c)) {
+		if (c->cmsg_level != SOL_SOCKET)
+			continue;
+		if (c->cmsg_type == SCM_CREDENTIALS_R) {
+			struct ucred_r pc;
+
+			memcpy(&pc, CMSG_DATA(c), sizeof(pc));
+			got_r = ideq(&pc.uid, &u);
+		} else if (c->cmsg_type == SCM_CREDENTIALS) {
+			struct ucred lc;
+
+			memcpy(&lc, CMSG_DATA(c), sizeof(lc));
+			got_l = lc.uid == 65534;
+		}
+	}
+	EXPECT_TRUE(got_r);
+	EXPECT_TRUE(got_l);
+}
+
+TEST_F(uid_r, signalfd_uid_r)
+{
+	id_r u = uuid(11), s0 = legacy(0), got;
+	struct signalfd_siginfo ssi;
+	sigset_t mask;
+	int sfd;
+
+	sigemptyset(&mask);
+	sigaddset(&mask, SIGUSR1);
+	ASSERT_EQ(0, sigprocmask(SIG_BLOCK, &mask, NULL));
+	sfd = signalfd(-1, &mask, 0);
+	ASSERT_LE(0, sfd);
+	ASSERT_EQ(0, sys(__NR_setresuid_r, (long)&u, 0, 0, 0, 0));
+	ASSERT_EQ(0, kill(getpid(), SIGUSR1));
+	ASSERT_EQ(0, sys(__NR_setresuid_r, (long)&s0, 0, 0, 0, 0));
+	ASSERT_EQ(sizeof(ssi), read(sfd, &ssi, sizeof(ssi)));
+	EXPECT_EQ(65534, ssi.ssi_uid);
+	/* ssi_uid_r follows ssi_arch */
+	memcpy(&got, (char *)&ssi + 100, sizeof(got));
+	EXPECT_TRUE(ideq(&got, &u));
+}
+
+TEST_F(uid_r, ipc_stat_r)
+{
+	id_r u = uuid(12), g = guid(13);
+	struct ipc_perm_r_t pr;
+	struct shmid_ds ds;
+	int id;
+
+	memset(&pr, 0, sizeof(pr));
+	pr.mode = 0640;
+	pr.uid = u;
+	pr.gid = g;
+
+	id = shmget(IPC_PRIVATE, 4096, IPC_CREAT | 0600);
+	ASSERT_LE(0, id);
+	ASSERT_EQ(0, shmctl(id, IPC_SET_R, (void *)&pr));
+	memset(&pr, 0, sizeof(pr));
+	ASSERT_EQ(0, shmctl(id, IPC_STAT_R, (void *)&pr));
+	EXPECT_TRUE(ideq(&pr.uid, &u));
+	EXPECT_TRUE(ideq(&pr.gid, &g));
+	EXPECT_EQ(0640, pr.mode & 0777);
+	ASSERT_EQ(0, shmctl(id, IPC_STAT, &ds));
+	EXPECT_EQ(65534, ds.shm_perm.uid);
+	shmctl(id, IPC_RMID, NULL);
+}
+
+/* user::rw- user:<u>:r-- group::--- mask::r-- other::--- in version 3 */
+static size_t acl_v3(unsigned char *buf, const id_r *u)
+{
+	static const unsigned short ent[5][2] = {
+		{ 0x01, 6 }, { 0x02, 4 }, { 0x04, 0 }, { 0x10, 4 }, { 0x20, 0 } };
+	unsigned char *e = buf + 4;
+	unsigned int ver = 3;
+
+	memcpy(buf, &ver, 4);
+	for (int i = 0; i < 5; i++, e += 24) {
+		unsigned int type = 0;
+
+		memset(e, 0, 24);
+		memcpy(e, &ent[i][0], 2);
+		memcpy(e + 2, &ent[i][1], 2);
+		if (ent[i][0] == 0x02) {
+			type = u->type;
+			memcpy(e + 8, u->uuid, 16);
+		}
+		memcpy(e + 4, &type, 4);
+	}
+	return 4 + 5 * 24;
+}
+
+TEST_F(uid_r, posix_acl_v3)
+{
+	unsigned char buf[256], got[256];
+	id_r u = uuid(20), s0 = legacy(0);
+	char path[96];
+	size_t len;
+	int fd;
+
+	private_tmpfs(_metadata, self->dir);
+	snprintf(path, sizeof(path), "%s/acl", self->dir);
+	fd = open(path, O_CREAT | O_WRONLY, 0600);
+	ASSERT_LE(0, fd);
+	close(fd);
+	len = acl_v3(buf, &u);
+	if (setxattr(path, "system.posix_acl_access", buf, len, 0) &&
+	    errno == EOPNOTSUPP)
+		SKIP(return, "tmpfs without POSIX ACLs");
+	ASSERT_EQ(len, getxattr(path, "system.posix_acl_access", got, sizeof(got)));
+	EXPECT_EQ(3, got[0]);
+	EXPECT_EQ(0, memcmp(got + 4 + 24 + 8, u.uuid, 16));
+
+	/* the ACL lets the UUID user read the 0600 root file */
+	ASSERT_EQ(0, sys(__NR_setfsuid_r, (long)&u, 0, 0, 0, 0));
+	fd = open(path, O_RDONLY);
+	ASSERT_EQ(0, sys(__NR_setfsuid_r, (long)&s0, 0, 0, 0, 0));
+	EXPECT_LE(0, fd);
+}
+
+TEST_F(uid_r, proc_status)
+{
+	id_r u = uuid(6), s0 = legacy(0);
+	char buf[4096], line[160];
+	int fd, n;
+
+	ASSERT_EQ(0, sys(__NR_setresuid_r, 0, (long)&u, (long)&s0, 0, 0));
+	fd = open("/proc/self/status", O_RDONLY);
+	n = fd < 0 ? -1 : read(fd, buf, sizeof(buf) - 1);
+	ASSERT_EQ(0, sys(__NR_setresuid_r, 0, (long)&s0, 0, 0, 0));
+	ASSERT_LT(0, n);
+	buf[n] = 0;
+	close(fd);
+	EXPECT_NE(NULL, strstr(buf, "Uid:\t0\t65534\t0\t65534\n"));
+	snprintf(line, sizeof(line),
+		 "Uid_r:\t0\t6f1c2a3b-4d5e-4f60-8a7b-0c1d2e3f4a06\t0\t"
+		 "6f1c2a3b-4d5e-4f60-8a7b-0c1d2e3f4a06\n");
+	EXPECT_NE(NULL, strstr(buf, line));
+}
+
+TEST_F(uid_r, user_namespace)
+{
+	id_r u = uuid(21), r;
+	char path[96];
+	int fd, status;
+	pid_t pid;
+
+	private_tmpfs(_metadata, self->dir);
+	snprintf(path, sizeof(path), "%s/nsfile", self->dir);
+	fd = open(path, O_CREAT | O_WRONLY, 0644);
+	ASSERT_LE(0, fd);
+	close(fd);
+	ASSERT_EQ(0, sys(__NR_chown_r, (long)path, (long)&u, 0, 0, 0));
+
+	pid = fork();
+	ASSERT_LE(0, pid);
+	if (pid == 0) {
+		int bad = 0;
+
+		if (unshare(CLONE_NEWUSER))
+			_exit(100);
+		/* from inside, only the own id can be mapped */
+		fd = open("/proc/self/uid_map", O_WRONLY);
+		if (fd < 0 || write(fd, "0 0 1", 5) != 5)
+			bad |= 1;
+		close(fd);
+		if (sys(__NR_setuid_r, (long)&u, 0, 0, 0, 0) != -EINVAL)
+			bad |= 2;
+		/* CAP_FOWNER in the namespace gives nothing over a UUID */
+		if (chmod(path, 0600) == 0 || errno != EPERM)
+			bad |= 4;
+		(void)r;
+		_exit(bad);
+	}
+	ASSERT_EQ(pid, waitpid(pid, &status, 0));
+	if (WEXITSTATUS(status) == 100)
+		SKIP(return, "no user namespaces");
+	EXPECT_EQ(0, WEXITSTATUS(status));
+}
+
+TEST_HARNESS_MAIN
-- 
2.56.0

