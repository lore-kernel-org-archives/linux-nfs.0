Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820435;
	b=xWhxCiki6OaHOwkl/n/xcBfaC9c/5F0FsmmBpm/G5rPqoKgC0BYqhYaBko/y+ZUty+FB
	 fndWQHzz3+MoStvvLLYBTaMYlzeyfp8NrTjk0oVbAQQU03/JJojOl32jeFlVjns0dOaOH
	 n1Ro106woeWZ6AhHwKJXe4KnvDbKpVKQJ2l8pC6gfKQPJ3uE7CIE8qn16BxhfYzI9Nwp+
	 llQVyatp18GFiZ3USeYtpBLf3C7DvFYJbEuuLwYHMEnEnQuFYjJbpiLBQd0GXTxRr3Ca4
	 4LBi5HnIGajEv+RW9zawFr3D7fuFCsJG1cT2fbEWfGU9KJ8ICdqgbltqKAIVexmQqbQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820435;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=r5+oZHp7BRrXwItSZJfGO9IDNpMhGDSeaixBJWzgZo8=;
	b=4pz6gdVR9uZaroG8nEbej1ZP2W+9UonfAMEt8EJTxiDVpeCOtVbjv8RBoAFAjJXcYpmA
	 GdVQKLRC4jnyuu3in0gTV3DNiC9RN+HZSuwbe69Rv5TJUzgmSNAlByqVfHfxXNzR2pZI+
	 q5L0prlVivPPlAbS5TPVxosGWKJT+SC7ISsIoogyXYCf0YSTTP8AEfpedPgEyTgqwdonZ
	 m50JX8EJzTXHJQ50YCl0N75PtAEJmgBJEhIHMCShGhTl+wIhFwk6Ginha7B6SYj9jHCPH
	 zlEGb9DjeUbckxrZC3d49WbDSsPCQSF4ygyIsQNFADwFVmVpvgEvLyLIswrWgmw+dJw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fZMD0huu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC5A1607264F;
	Wed,  4 Nov 2026 19:27:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fZMD0huu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E0AAB1F00A02;
	Wed,  4 Nov 2026 19:27:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820434;
	bh=r5+oZHp7BRrXwItSZJfGO9IDNpMhGDSeaixBJWzgZo8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fZMD0huuUQp5LSr9n7+L0WCkQqKPzyWmpwqfqg+XzsqNRlIuKtlf3Iar8GeYyXaoh
	 Duy1KTIkLZPd4wpyWSeEROyKAch5aD1WchnGy/bdzHJBKTDW5fUbZVdDqnccb3ML1S
	 ynk82YbCOwpdp9OfHLn4Hk4TAslcNPy+3iNGpY8Onlv8nBJw5pFj50Y4poa5zyKxIw
	 OVO6zjJj0L1s71YhuEz2nNM9sGb2RL+EkTlUz3tA5wau2YU3GduBQbxH1kPyHOemIX
	 jzrV1tyP5WTyanlHmpiwciBJbTfxSsr8dPDlHohaL0lhPAdIlgdQvP+X/AxRNITsuF
	 bSYKsfrnb9SrA==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	"Christian Brauner (Amutable)" <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: [PATCH RESEND v2 45/51] selftests/proc: check a sysctl listing while entries come and go
Date: Wed,  4 Nov 2026 20:27:00 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-45-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=5901; i=brauner@kernel.org; h=from:subject:message-id; bh=PpkRsqulHaX8LI6MUrkW65va02k7nMeISt9l3ZnWEgo=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bmK23C5Vd0CJeVXYmud2s9Pn+J3m37HmVpnFi7ow2 bTfWdpXOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYyeRLDfw/N+y99eaf/2OCk /PjiV39BNqFbYdWnZD3mCaZ8OpuwbArDb9buj/tfO6Qb3GbVUb7QsZ5hkv1nv0KD0viMIPmMExu SGQE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

List /proc/sys/net/ipv4/conf of a new network namespace in two pieces:

- with a buffer that holds the dots and "all", register a tun device
  whose name sorts first, finish the listing: "all" is listed once

- with that device registered and a buffer that holds the dots and it,
  unregister it, finish the listing: "all" is still listed

Both fail without the fix, the first lists "all" twice, the second not
at all.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 tools/testing/selftests/proc/.gitignore            |   1 +
 tools/testing/selftests/proc/Makefile              |   1 +
 .../selftests/proc/proc-sysctl-readdir-churn.c     | 152 +++++++++++++++++++++
 3 files changed, 154 insertions(+)

diff --git a/tools/testing/selftests/proc/.gitignore b/tools/testing/selftests/proc/.gitignore
index 8520c7878ea2..5b5e24e39cbd 100644
--- a/tools/testing/selftests/proc/.gitignore
+++ b/tools/testing/selftests/proc/.gitignore
@@ -25,4 +25,5 @@
 /self
 /setns-dcache
 /setns-sysvipc
+/proc-sysctl-readdir-churn
 /thread-self
diff --git a/tools/testing/selftests/proc/Makefile b/tools/testing/selftests/proc/Makefile
index e0c0d313f4d0..dae09f333455 100644
--- a/tools/testing/selftests/proc/Makefile
+++ b/tools/testing/selftests/proc/Makefile
@@ -30,6 +30,7 @@ TEST_GEN_PROGS += setns-sysvipc
 TEST_GEN_PROGS += thread-self
 TEST_GEN_PROGS += proc-multiple-procfs
 TEST_GEN_PROGS += proc-fsconfig-hidepid
+TEST_GEN_PROGS += proc-sysctl-readdir-churn
 TEST_GEN_PROGS += proc-pidns
 
 include ../lib.mk
diff --git a/tools/testing/selftests/proc/proc-sysctl-readdir-churn.c b/tools/testing/selftests/proc/proc-sysctl-readdir-churn.c
new file mode 100644
index 000000000000..b2ad097b464a
--- /dev/null
+++ b/tools/testing/selftests/proc/proc-sysctl-readdir-churn.c
@@ -0,0 +1,152 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * A listing of a /proc/sys directory that takes more than one getdents64()
+ * must not show an entry twice or skip one when an entry is registered or
+ * unregistered in between. /proc/sys/net/ipv4/conf/<dev> of a tun device
+ * comes and goes with the device.
+ */
+#define _GNU_SOURCE
+#include <dirent.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <linux/if.h>
+#include <linux/if_tun.h>
+#include <sched.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+#include "../kselftest_harness.h"
+
+#define CONF_DIR	"/proc/sys/net/ipv4/conf"
+#define TUN_NAME	"a0"		/* sorts before "all" */
+#define TUN_PATH	CONF_DIR "/" TUN_NAME
+#define SMALL_BUF	80		/* ".", ".." and one short name */
+#define NAMES		64
+
+static int tun_open(const char *name)
+{
+	struct ifreq ifr = {};
+	int fd;
+
+	fd = open("/dev/net/tun", O_RDWR | O_CLOEXEC);
+	if (fd < 0)
+		return -1;
+	strncpy(ifr.ifr_name, name, IFNAMSIZ - 1);
+	ifr.ifr_flags = IFF_TUN | IFF_NO_PI;
+	if (ioctl(fd, TUNSETIFF, &ifr)) {
+		close(fd);
+		return -1;
+	}
+	return fd;
+}
+
+/* one getdents64() into @buf, the names appended to @names */
+static int list(int fd, char *buf, size_t size, char names[][NAME_MAX + 1],
+		int *n)
+{
+	long ret, off;
+	int got = 0;
+
+	ret = syscall(__NR_getdents64, fd, buf, size);
+	if (ret < 0)
+		return -errno;
+	for (off = 0; off < ret;) {
+		struct dirent64 *d = (void *)(buf + off);
+
+		if (*n < NAMES)
+			strcpy(names[(*n)++], d->d_name);
+		got++;
+		off += d->d_reclen;
+	}
+	return got;
+}
+
+static int count(char names[][NAME_MAX + 1], int n, const char *name)
+{
+	int i, c = 0;
+
+	for (i = 0; i < n; i++)
+		if (!strcmp(names[i], name))
+			c++;
+	return c;
+}
+
+FIXTURE(sysctl_readdir) {
+	int dir;
+	int n;
+	char names[NAMES][NAME_MAX + 1];
+	char buf[65536];
+};
+
+FIXTURE_SETUP(sysctl_readdir)
+{
+	int tun;
+
+	if (unshare(CLONE_NEWNET))
+		SKIP(return, "unshare(CLONE_NEWNET): %s", strerror(errno));
+	tun = open("/dev/net/tun", O_RDWR | O_CLOEXEC);
+	if (tun < 0)
+		SKIP(return, "/dev/net/tun: %s", strerror(errno));
+	close(tun);
+	self->dir = open(CONF_DIR, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
+	if (self->dir < 0)
+		SKIP(return, CONF_DIR ": %s", strerror(errno));
+	self->n = 0;
+}
+
+FIXTURE_TEARDOWN(sysctl_readdir)
+{
+	close(self->dir);
+}
+
+/* a device registered in front of the position doesn't repeat an entry */
+TEST_F(sysctl_readdir, register_in_front)
+{
+	int tun;
+
+	/* ".", ".." and "all", "default" doesn't fit */
+	ASSERT_EQ(list(self->dir, self->buf, SMALL_BUF, self->names, &self->n), 3);
+	ASSERT_EQ(count(self->names, self->n, "all"), 1);
+
+	tun = tun_open(TUN_NAME);
+	ASSERT_GE(tun, 0);
+	ASSERT_EQ(access(TUN_PATH, F_OK), 0);
+
+	while (list(self->dir, self->buf, sizeof(self->buf), self->names,
+		    &self->n) > 0)
+		;
+	EXPECT_EQ(count(self->names, self->n, "all"), 1);
+	EXPECT_EQ(count(self->names, self->n, "default"), 1);
+	EXPECT_EQ(count(self->names, self->n, "lo"), 1);
+	close(tun);
+}
+
+/* a device unregistered in front of the position doesn't skip an entry */
+TEST_F(sysctl_readdir, unregister_in_front)
+{
+	int tun;
+
+	tun = tun_open(TUN_NAME);
+	ASSERT_GE(tun, 0);
+	ASSERT_EQ(access(TUN_PATH, F_OK), 0);
+
+	/* ".", ".." and the device, "all" doesn't fit */
+	ASSERT_EQ(list(self->dir, self->buf, SMALL_BUF, self->names, &self->n), 3);
+	ASSERT_EQ(count(self->names, self->n, TUN_NAME), 1);
+
+	/* closing the device unregisters its sysctls under RTNL */
+	close(tun);
+	ASSERT_EQ(access(TUN_PATH, F_OK), -1);
+
+	while (list(self->dir, self->buf, sizeof(self->buf), self->names,
+		    &self->n) > 0)
+		;
+	EXPECT_EQ(count(self->names, self->n, "all"), 1);
+	EXPECT_EQ(count(self->names, self->n, "default"), 1);
+	EXPECT_EQ(count(self->names, self->n, "lo"), 1);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

