Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820860;
	b=QO+KDV9/JEYtMqhhsBEhh198aPKHBkfZqEZCk9HHWIIe+SDm3dga6oI43zZhotoagQ24
	 fSwB0GmIptvUOyAFU8hLh7MXiWrQVLz03z2vzBYT/GiQ6/U8qXufudiPrucnG2XnERy5j
	 s6iqJGBL4kM81m9co/IiQKJ7TK6sWLh39guIZlMNEAiwzO5xiGGt1uRbkcj7yqjsT5uLY
	 uQCSvpctCS4UFIiGj0JivGrDp0KSVCuuWDMKqrNQWnZZ/NocqwYazbBhl/aURVTYEvkkn
	 v5ftumZQM2vsvtAcfhzxbUzz7GDU3oIgXEydUZZ6DzS1GDtOFY80X8PsuM1/FWyyrvA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820860;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=XPRk8xa2iNqVsjjcUeI0mWPc+8Y/qNwvFsdP9QcHm+Y=;
	b=INv6CAvfcDL9tL0tBubmouI8P585iiqN7jEfBBiPAIsYD5FDqzQvCDbbj/svpAP/2okW
	 8Qsy9o5uksZwDa8nbQciIv3lC5qi794qwTDAvPwbhvT3VRS3OXQ7x1aAvMVp66QMOyfhn
	 TCXM9r72J/P5XL/D0+FZiOWXh5C8UBbJTjjl1ZzD57SPCx+u/tJJaAmVDobKkAeuaC77q
	 LpwDC4Mz2BTWMzjtNbwTmQe51MZN0y+zZ0aTZshAXhxHonMqOZWrmt1wuPfummUNkEXxN
	 wQ+9Y13/tVIVXi13hWpxHvWiQQ77riXW2hO3dslQEE64pQRALLVxFVUjOSx6r/KUgeg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UNhMpYi9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B403606E813;
	Wed,  4 Nov 2026 19:34:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UNhMpYi9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6EAED1F000C1;
	Wed,  4 Nov 2026 19:34:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820859;
	bh=XPRk8xa2iNqVsjjcUeI0mWPc+8Y/qNwvFsdP9QcHm+Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UNhMpYi9iBi3sSb8K6vRL3AVudJYWbzQuMGR/ICND1KoaHjOskUuqvumDcfcjfd6K
	 ijYufZXYFtMMXKypD4aHqfrjcDJ5P9E7mGA88Bbc5XKwZS4J2G6bgAUbtjzgydCj5c
	 CMbGq978DMlUEIVBNwLUkmICilkcpIuILUWlDTO9oBqCop6Q2rT2BrBKj9tSMvpI5f
	 mIfr0sAmHMehrxEf8R1Vxd1nxFT9mY8+v+LmVChZXn8FLaY6Ek9gVtZVyHvJ7Cd5NB
	 lpPZDeCXrjw4w6xWu6pGAbvluUnAnWZKtALorygHi4AAnDmt2IczUeBmgec1AG7dqW
	 U2/sWDkdd6LGA==
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
Subject: [PATCH RESEND v2 20/23] selftests/proc: check that a mapped entry can be removed
Date: Wed,  4 Nov 2026 20:34:05 +0100
Message-ID: <20261104-work-procfs-core-v2-20-76ace653a773@kernel.org>
In-Reply-To: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
References: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=6487; i=brauner@kernel.org; h=from:subject:message-id; bh=jPDbXGY4cbCvO3GA1X2/Ctdyj/e7Mw7ZeqOfGQfxULg=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bu/8xLCt3Udlh9rJxEtBLOuvKWxb7B30qu+8xJIGm /Db96fUd5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEwkQ4mR4fwquSyvtz3Ne746 HTn1fX1AAaOl3YVTD7n+Heo0WvX+kQPDfyf/Xm+TiXFyJoacvlEsv149+Fb4tz9xPvfn/NiLR3d aMwAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Map a memory BAR of a PCI device through /proc/bus/pci and remove the
device through sysfs:

- the removal doesn't wait for the mapped file

- the entry is gone

- and reading the file fails with -EIO

The mapping itself survives. /proc/bus/pci maps through the iomem
address space of /dev/mem and procfs leaves that alone, like the sysfs
resource files leave theirs, so the test doesn't touch the mapping
after the removal. What the BAR of a removed device reads like is
between the reader and the hardware.

Nothing in the test can know which device is safe to remove, so it
takes the device from PROC_PCI_DEV, skips without it and rescans the bus
afterwards. It also skips where PCI files can't be mapped or that isn't
allowed.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 tools/testing/selftests/proc/.gitignore           |   1 +
 tools/testing/selftests/proc/Makefile             |   1 +
 tools/testing/selftests/proc/proc-remove-mapped.c | 160 ++++++++++++++++++++++
 3 files changed, 162 insertions(+)

diff --git a/tools/testing/selftests/proc/.gitignore b/tools/testing/selftests/proc/.gitignore
index e2566cc0ae07..cafd8c263c9a 100644
--- a/tools/testing/selftests/proc/.gitignore
+++ b/tools/testing/selftests/proc/.gitignore
@@ -23,6 +23,7 @@
 /proc-pidns
 /proc-remove-slow-sysctl
 /proc-remove-slow-reader
+/proc-remove-mapped
 /proc-remove-slow-readlink
 /read
 /self
diff --git a/tools/testing/selftests/proc/Makefile b/tools/testing/selftests/proc/Makefile
index 6a9bdc999f54..c38297afc244 100644
--- a/tools/testing/selftests/proc/Makefile
+++ b/tools/testing/selftests/proc/Makefile
@@ -34,6 +34,7 @@ TEST_GEN_PROGS += proc-sysctl-readdir-churn
 TEST_GEN_PROGS += proc-pidns
 TEST_GEN_PROGS += proc-remove-slow-sysctl
 TEST_GEN_PROGS += proc-remove-slow-reader
+TEST_GEN_PROGS += proc-remove-mapped
 TEST_GEN_PROGS += proc-remove-slow-readlink
 
 include ../lib.mk
diff --git a/tools/testing/selftests/proc/proc-remove-mapped.c b/tools/testing/selftests/proc/proc-remove-mapped.c
new file mode 100644
index 000000000000..92860fb2a8f4
--- /dev/null
+++ b/tools/testing/selftests/proc/proc-remove-mapped.c
@@ -0,0 +1,160 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Removing a /proc entry with a mapped file open must not wait for that file
+ * and must leave the file dead. Map a memory BAR of a PCI device through
+ * /proc/bus/pci and remove the device, which removes its entry. Nothing here
+ * can know which device is safe to remove and rescan, so it is named in
+ * PROC_PCI_DEV, e.g. PROC_PCI_DEV=0000:00:03.0.
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <linux/pci.h>
+#include <setjmp.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <unistd.h>
+
+#include "../kselftest_harness.h"
+
+#define DEV_ENV		"PROC_PCI_DEV"
+#define SYSFS_DEVICES	"/sys/bus/pci/devices/"
+#define SYSFS_RESCAN	"/sys/bus/pci/rescan"
+#define PROC_PCI	"/proc/bus/pci/"
+#define IORESOURCE_MEM	0x00000200
+
+static sigjmp_buf fault;
+
+static void on_sigbus(int sig)
+{
+	siglongjmp(fault, 1);
+}
+
+/* the first memory BAR of @dev */
+static int mem_bar(const char *dev, unsigned long long *start,
+		   unsigned long long *len)
+{
+	unsigned long long s, e, flags;
+	char path[PATH_MAX];
+	int ret = -ENODEV;
+	FILE *f;
+
+	snprintf(path, sizeof(path), SYSFS_DEVICES "%s/resource", dev);
+	f = fopen(path, "r");
+	if (!f)
+		return -errno;
+	while (fscanf(f, "%llx %llx %llx", &s, &e, &flags) == 3) {
+		if ((flags & IORESOURCE_MEM) && e >= s) {
+			*start = s;
+			*len = e - s + 1;
+			ret = 0;
+			break;
+		}
+	}
+	fclose(f);
+	return ret;
+}
+
+static int write_one(const char *path)
+{
+	int fd, ret;
+
+	fd = open(path, O_WRONLY | O_CLOEXEC);
+	if (fd < 0)
+		return -errno;
+	ret = write(fd, "1", 1) < 0 ? -errno : 0;
+	close(fd);
+	return ret;
+}
+
+FIXTURE(pci) {
+	char dev[16];
+	char path[64];
+	bool removed;
+};
+
+FIXTURE_SETUP(pci)
+{
+	const char *dev = getenv(DEV_ENV);
+
+	self->removed = false;
+	if (!dev)
+		SKIP(return, DEV_ENV " isn't set");
+	/* 0000:BB:DD.F is /proc/bus/pci/BB/DD.F */
+	if (strlen(dev) != 12 || strncmp(dev, "0000:", 5))
+		SKIP(return, "%s: not a device in PCI domain 0", dev);
+	strcpy(self->dev, dev);
+	snprintf(self->path, sizeof(self->path), PROC_PCI "%.2s/%s",
+		 dev + 5, dev + 8);
+	if (access(self->path, R_OK))
+		SKIP(return, "%s: %s", self->path, strerror(errno));
+}
+
+FIXTURE_TEARDOWN(pci)
+{
+	if (self->removed && write_one(SYSFS_RESCAN))
+		TH_LOG("couldn't rescan the PCI bus for %s", self->dev);
+}
+
+TEST_F(pci, remove_while_mapped)
+{
+	long psz = sysconf(_SC_PAGESIZE);
+	unsigned long long start = 0, len = 0;
+	char path[PATH_MAX];
+	volatile unsigned int *p;
+	unsigned int v;
+	int fd;
+
+	if (mem_bar(self->dev, &start, &len))
+		SKIP(return, "%s has no memory BAR", self->dev);
+
+	fd = open(self->path, O_RDONLY | O_CLOEXEC);
+	ASSERT_GE(fd, 0);
+	if (ioctl(fd, PCIIOC_MMAP_IS_MEM)) {
+		/* no PCI mmap on this architecture, or locked down */
+		if (errno == EINVAL || errno == EPERM) {
+			close(fd);
+			SKIP(return, "PCIIOC_MMAP_IS_MEM: %s", strerror(errno));
+		}
+		ASSERT_TRUE(false) {
+			TH_LOG("PCIIOC_MMAP_IS_MEM: %s", strerror(errno));
+		}
+	}
+	p = mmap(NULL, psz, PROT_READ, MAP_SHARED, fd, start);
+	if (p == MAP_FAILED)
+		SKIP(return, "mmap: %s", strerror(errno));
+
+	/* The BAR can be read while the device is there. */
+	ASSERT_NE(signal(SIGBUS, on_sigbus), SIG_ERR);
+	if (sigsetjmp(fault, 1) == 0) {
+		v = *p;
+	} else {
+		ASSERT_TRUE(false) {
+			TH_LOG("reading the mapping faulted before the removal");
+		}
+	}
+
+	/* Removing the device removes its entry. */
+	snprintf(path, sizeof(path), SYSFS_DEVICES "%s/remove", self->dev);
+	ASSERT_EQ(write_one(path), 0);
+	self->removed = true;
+	EXPECT_EQ(access(self->path, F_OK), -1);
+
+	/*
+	 * The file is dead. The mapping isn't procfs's to unmap, it lives in
+	 * the iomem address space of /dev/mem, see proc_bus_pci_open(), and
+	 * is left alone like a sysfs resource file's.
+	 */
+	EXPECT_EQ(pread(fd, &v, sizeof(v), 0), -1);
+	EXPECT_EQ(errno, EIO);
+
+	munmap((void *)p, psz);
+	close(fd);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

