Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821524;
	b=vgKIPbQkVDrhwU/UrrugxvgsooQWLTjxn8opMdMALY1XfKCHJ7/qZnNoMlzW6JHpqmKk
	 86W4RsoF34v5cEc5uT1h2yVzuS2BHgFarMcRgd3aGBLcWcu6mL0U3jTXB3H72Ps1RHKXd
	 43TgcLxPaQU3z0VOoN4ZF0g8D9O1Hwdo3nCsFNxroKTpWtZLD7rT04hKYGzOSm0EOvBBC
	 PZZX24hKsnewg4pUDMmik4v1sVwBWnU2FFT5YJm4SVROZs+WyJ33FeBKoQtORNqmmYhiQ
	 YXHl+nJ5ibITTo4WEQ24hfms5ydY60KyCSqNGdlTRE1WDfTEqSEkci8BWSlKzMulwEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821524;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=E1OInNVm7rDZtBrb7UUeMGX99YfIJ2KTCRFW+s46a8o=;
	b=u/8wWZTWJWLUPpZ+9VTV7MWfIMX3n/H4h6BqfrpNl+jdtnyFPbCSWBL8afRKZ8igPxcH
	 mrcoC3Ey6douGyk/54T0yvOutrxgqGcSQUVW0k5Ten78hYheFjeivofKuMvQcu22dSiAT
	 Qi9/dXuTMauiR5qoA2rV2GepxLJZj4nSX7VOI4qlLuPt1dFxDag8lgPWBR/wvVb0Dh1m1
	 YSgS7mzmm8c2s3hYmUT/XYGh/EzZQ8vHXwIEc60RApCVvHS9JQQCF9uy/u5ldIrPOgTyE
	 F+V+lhKOEBb+NwKvwLI+L9s79bUS0QJRa3sLUWB6F49elNENRtMzpw5N6y1pho/94Yg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hg7TwfiA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6DEA26070AA1;
	Wed,  4 Nov 2026 19:45:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hg7TwfiA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D68C31F00A1A;
	Wed,  4 Nov 2026 19:45:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821524;
	bh=E1OInNVm7rDZtBrb7UUeMGX99YfIJ2KTCRFW+s46a8o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hg7TwfiAh/S+HZXwjJAnEjDkewVJnDjtQ15zWirXU9ybSWS9d5tFc6lb4Y46OnHUJ
	 k9OpxSnvE9RHefcLE70UegKD79VmvWjrEZWfFSASp8+F4OT7ezbj9J/gzzfOkq0eI0
	 JFptxedhnQpdfjNK2vocob1rAbfDUVpvb0e2aqCYrf3CiR/z9mhBdg5NCBNZAmV2TT
	 0Dy/0pgNhj91R4zKIrqK5q2xLhQ9eKBqhicbMV8LYJmRXvPmvWQmI5VRgk5kt4xFAy
	 R2uQeUdehiFWQWbmRdRp3WZQ9mmfU9nvCXWhciuLZYO4oxBvlZVPD8Q/HIy09vPmx5
	 Kl0SkzYGVBcDQ==
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
Subject: [PATCH RESEND v2 12/26] selftests/proc: check that a faulting writer doesn't hold up removal
Date: Wed,  4 Nov 2026 20:45:09 +0100
Message-ID: <20261104-work-procfs-drivers-v2-12-245e54e87116@kernel.org>
In-Reply-To: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
References: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=7944; i=brauner@kernel.org; h=from:subject:message-id; bh=7tbUK/izHUmHqxD4f5JqbQl58tytBiN6D5mHTNsUScI=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97mq0cehqmXnq4qvLqz+9ru8WDfz/gONZqbnvzrPXV Eo9tKbbdpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEwkOo7hn55UU7aKvdlzBtdr j+a0v7aKmVCU86s1Z779ZevXEZIVqxgZ7qZPv/h0+ez3JtXFv/lWVXzzb2Xe3qmjasKSvqYqb8s pDgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Write to /proc/scsi/scsi_debug/<host> from a buffer whose page is backed
by userfaultfd and remove the host while procfs copies in what is
written:

- removing the entry doesn't wait for the writer

- the write fails with -EIO once the fault is resolved

The test loads scsi_debug if it isn't there and skips without it or
without /proc/scsi.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 tools/testing/selftests/proc/.gitignore            |   1 +
 tools/testing/selftests/proc/Makefile              |   1 +
 tools/testing/selftests/proc/config                |   3 +
 .../selftests/proc/proc-remove-slow-writer.c       | 209 +++++++++++++++++++++
 4 files changed, 214 insertions(+)

diff --git a/tools/testing/selftests/proc/.gitignore b/tools/testing/selftests/proc/.gitignore
index cafd8c263c9a..a1994bda676c 100644
--- a/tools/testing/selftests/proc/.gitignore
+++ b/tools/testing/selftests/proc/.gitignore
@@ -25,6 +25,7 @@
 /proc-remove-slow-reader
 /proc-remove-mapped
 /proc-remove-slow-readlink
+/proc-remove-slow-writer
 /read
 /self
 /setns-dcache
diff --git a/tools/testing/selftests/proc/Makefile b/tools/testing/selftests/proc/Makefile
index c38297afc244..8fcab5af502b 100644
--- a/tools/testing/selftests/proc/Makefile
+++ b/tools/testing/selftests/proc/Makefile
@@ -36,5 +36,6 @@ TEST_GEN_PROGS += proc-remove-slow-sysctl
 TEST_GEN_PROGS += proc-remove-slow-reader
 TEST_GEN_PROGS += proc-remove-mapped
 TEST_GEN_PROGS += proc-remove-slow-readlink
+TEST_GEN_PROGS += proc-remove-slow-writer
 
 include ../lib.mk
diff --git a/tools/testing/selftests/proc/config b/tools/testing/selftests/proc/config
index 1504a761b39b..992577d15295 100644
--- a/tools/testing/selftests/proc/config
+++ b/tools/testing/selftests/proc/config
@@ -1,4 +1,7 @@
 CONFIG_PROC_FS=y
+CONFIG_SCSI=y
+CONFIG_SCSI_PROC_FS=y
+CONFIG_SCSI_DEBUG=m
 CONFIG_NET_NS=y
 CONFIG_IPV6=y
 CONFIG_TUN=y
diff --git a/tools/testing/selftests/proc/proc-remove-slow-writer.c b/tools/testing/selftests/proc/proc-remove-slow-writer.c
new file mode 100644
index 000000000000..3539293d353f
--- /dev/null
+++ b/tools/testing/selftests/proc/proc-remove-slow-writer.c
@@ -0,0 +1,209 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * A write that faults while procfs copies it in must not hold up removal of
+ * the /proc entry. Removing a scsi_debug host removes its
+ * /proc/scsi/scsi_debug/<host> file.
+ */
+#define _GNU_SOURCE
+#include <dirent.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <linux/userfaultfd.h>
+#include <poll.h>
+#include <pthread.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+#include "../kselftest_harness.h"
+
+#define ADD_HOST	"/sys/bus/pseudo/drivers/scsi_debug/add_host"
+#define HOST_DIR	"/proc/scsi/scsi_debug"
+#define TIMEOUT_MS	5000
+#define MAX_HOSTS	4096
+#define HOST_BITS	(8 * sizeof(unsigned long))
+
+struct writer {
+	int fd;
+	char *buf;
+	ssize_t ret;
+	int err;
+};
+
+struct remover {
+	int done;
+	int ret;
+};
+
+/* a positive @nr adds hosts, a negative one removes the last ones added */
+static int add_host(int nr)
+{
+	char s[16];
+	int fd, len, ret;
+
+	fd = open(ADD_HOST, O_WRONLY | O_CLOEXEC);
+	if (fd < 0)
+		return -errno;
+	len = snprintf(s, sizeof(s), "%d", nr);
+	ret = write(fd, s, len) == len ? 0 : -errno;
+	close(fd);
+	return ret;
+}
+
+/* the numbers of the hosts in /proc/scsi/scsi_debug as a bitmap */
+static int list_hosts(unsigned long *hosts)
+{
+	struct dirent *d;
+	DIR *dir;
+
+	memset(hosts, 0, MAX_HOSTS / 8);
+	dir = opendir(HOST_DIR);
+	if (!dir)
+		/* the directory comes with the first host and goes with the last */
+		return errno == ENOENT ? 0 : -errno;
+	while ((d = readdir(dir))) {
+		char *end;
+		long nr = strtol(d->d_name, &end, 10);
+
+		if (end != d->d_name && !*end && nr >= 0 && nr < MAX_HOSTS)
+			hosts[nr / HOST_BITS] |= 1UL << (nr % HOST_BITS);
+	}
+	closedir(dir);
+	return 0;
+}
+
+/* the host that is in @after but wasn't in @before */
+static int new_host(const unsigned long *before, const unsigned long *after)
+{
+	for (int i = 0; i < MAX_HOSTS / HOST_BITS; i++) {
+		unsigned long new = after[i] & ~before[i];
+
+		if (new)
+			return i * HOST_BITS + __builtin_ctzl(new);
+	}
+	return -1;
+}
+
+static void *write_thread(void *arg)
+{
+	struct writer *w = arg;
+
+	w->ret = write(w->fd, w->buf, 2);
+	w->err = errno;
+	return NULL;
+}
+
+static void *remove_thread(void *arg)
+{
+	struct remover *r = arg;
+	ssize_t ret;
+
+	r->ret = add_host(-1);
+	ret = write(r->done, "x", 1);
+	return (void *)ret;
+}
+
+FIXTURE(host) {
+	char path[PATH_MAX];
+	int host;
+};
+
+FIXTURE_SETUP(host)
+{
+	unsigned long before[MAX_HOSTS / HOST_BITS];
+	unsigned long after[MAX_HOSTS / HOST_BITS];
+
+	self->host = -1;
+	if (access(ADD_HOST, W_OK) && system("modprobe -q scsi_debug add_host=0"))
+		SKIP(return, "no scsi_debug");
+	if (access(ADD_HOST, W_OK))
+		SKIP(return, ADD_HOST ": %s", strerror(errno));
+	/* the host files need CONFIG_SCSI_PROC_FS */
+	if (access("/proc/scsi", F_OK))
+		SKIP(return, "/proc/scsi: %s", strerror(errno));
+
+	/* host numbers are reused, so look for the one that's new */
+	ASSERT_EQ(list_hosts(before), 0);
+	ASSERT_EQ(add_host(1), 0);
+	if (!list_hosts(after))
+		self->host = new_host(before, after);
+	/* the teardown doesn't run when the setup fails */
+	if (self->host < 0)
+		add_host(-1);
+	ASSERT_GE(self->host, 0);
+	snprintf(self->path, sizeof(self->path), HOST_DIR "/%d", self->host);
+}
+
+FIXTURE_TEARDOWN(host)
+{
+	if (self->host >= 0 && !access(self->path, F_OK))
+		add_host(-1);
+}
+
+TEST_F(host, remove_while_writer_faults)
+{
+	struct uffdio_api api = { .api = UFFD_API };
+	struct uffdio_register reg = {};
+	struct uffdio_zeropage zero = {};
+	long psz = sysconf(_SC_PAGESIZE);
+	struct writer w = {};
+	struct remover r = {};
+	struct uffd_msg msg;
+	struct pollfd pfd;
+	pthread_t wt, rt;
+	int uffd, done[2];
+	char *buf;
+
+	w.fd = open(self->path, O_WRONLY | O_CLOEXEC);
+	if (w.fd < 0)
+		SKIP(return, "%s: %s", self->path, strerror(errno));
+
+	uffd = syscall(__NR_userfaultfd, O_CLOEXEC | O_NONBLOCK);
+	if (uffd < 0)
+		SKIP(return, "userfaultfd: %s", strerror(errno));
+	ASSERT_EQ(ioctl(uffd, UFFDIO_API, &api), 0);
+
+	buf = mmap(NULL, psz, PROT_READ | PROT_WRITE,
+		   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	ASSERT_NE(buf, MAP_FAILED);
+	reg.range.start = (unsigned long)buf;
+	reg.range.len = psz;
+	reg.mode = UFFDIO_REGISTER_MODE_MISSING;
+	ASSERT_EQ(ioctl(uffd, UFFDIO_REGISTER, &reg), 0);
+
+	w.buf = buf;
+	ASSERT_EQ(pthread_create(&wt, NULL, write_thread, &w), 0);
+
+	/* The writer now sleeps while what it writes is copied in. */
+	pfd = (struct pollfd){ .fd = uffd, .events = POLLIN };
+	ASSERT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1);
+	ASSERT_EQ(read(uffd, &msg, sizeof(msg)), sizeof(msg));
+	ASSERT_EQ(msg.event, UFFD_EVENT_PAGEFAULT);
+
+	/* Removing the host removes the file that is being written. */
+	ASSERT_EQ(pipe2(done, O_CLOEXEC), 0);
+	r.done = done[1];
+	ASSERT_EQ(pthread_create(&rt, NULL, remove_thread, &r), 0);
+	pfd = (struct pollfd){ .fd = done[0], .events = POLLIN };
+	EXPECT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1) {
+		TH_LOG("removing %s waited for the writer", self->path);
+	}
+
+	zero.range.start = (unsigned long)buf;
+	zero.range.len = psz;
+	ASSERT_EQ(ioctl(uffd, UFFDIO_ZEROPAGE, &zero), 0);
+	ASSERT_EQ(pthread_join(wt, NULL), 0);
+	ASSERT_EQ(pthread_join(rt, NULL), 0);
+	EXPECT_EQ(r.ret, 0);
+
+	/* The entry was gone by the time the write got to it. */
+	EXPECT_EQ(w.ret, -1);
+	EXPECT_EQ(w.err, EIO);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

