Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793630792;
	b=VNMPIixDPC7xnx24ImagaVLICgQ1oMfx0ZSj8HfYNYyHwlLhP7YynaWIRw/rdO94DuRp
	 kdNc+FDihW4918YH2n0gYoGk0wncFuJgHX2QOOwo3+vftnXS65KV754vX9cEiAnYODAwj
	 OearUcAC9GlUV4otqHGu1vKc4itb+pc8eLrPZ7SuI7vlAQ1GimTfx0qsKE4s8NvqU6XHz
	 er2aRiwxbS+Agxbv1vhK7n7EZTeyvAzIwVps/OdVkDV8+/v0+f2+0+jVUzW9srCbVRxpu
	 b2Z26etis4y5jkPeB95vYtOjKH428ACBiTkcp2EniAvYUo2q6oPdpv6hhtraEl9WvNA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793630792;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=8OUC3OpgPcYXff2v4b0WbdSVZE7XWpoJGNZRHA3e5A4=;
	b=XPllilg3r+tc0lz4rs3Ycu3pEWL6/1QcmOYKIOlLj5DZex9ihiB72LC/xdA1BJMmpyJA
	 Daz8EDNAOTGmeBVDakNa23FHfl5xESS22cFNK2PWm/ThJJroUU9ehmPesaVO3lNRRc/db
	 JVMjPzEAkNBjel06clXm4i9Yp8JRuiINX4brc0NgV1W3OhxWc3cRgMdKjTIr7nf+0+hFP
	 ytBbO8MbnukO+sPX2UXWKNdCOil6IproFhGVzyrrk2NqywuiTHttTaEv4LyI77ivh3QsP
	 3U94wMJYXB5HsfcWUl13LA9pXeB3qnHuJg1XZ6iEgk5ulQfOo+Y6NHj1DbRv1PfOZAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XWvDNXOE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60A07606C57C;
	Mon,  2 Nov 2026 14:46:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XWvDNXOE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5ACC31F00A1C;
	Mon,  2 Nov 2026 14:46:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793630792;
	bh=8OUC3OpgPcYXff2v4b0WbdSVZE7XWpoJGNZRHA3e5A4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XWvDNXOEbgzkyZSZLEEf/fLDGQTJKwF0ltSxY/EL3lo82Mkr/aDxZgyoDMPnEDdLr
	 5p9X0oQCHCkY63MlXypffIH/FgWzMKVYCEo4i3pEbfJuBXE7iGAORsSWwgE8jxQhAy
	 4NKKegcYQITsSSiB9ubx16WR7JIBFMAtYwmdkdE/Zzf6jzzLfZ7rDbpHNZ3omVKKWs
	 5YTo9uoKH3WQgJg5iglu6NkXshnM4oNeVvav8v5ihPYSLjDC/W/Dnb3rFkAiPkdkb/
	 knAVm1KzmCTPRmBb4tIwPxCsIua2TX2REoD5qySaeeWkURDqxkkuEp88D6dK5T0/43
	 GCmlt6X8Ltfhw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:43:27 +0100
Subject: [PATCH RFC 36/38] selftests/proc: check that faulting sysctl
 accesses don't hold up removal
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
Content-Transfer-Encoding: 7bit
Message-Id: <20261102-work-procfs-bugfixes-v1-36-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
 Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
 Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
 Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
 Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
 Greg Kroah-Hartman <gregkh@suse.de>, 
 Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, 
 Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
 coreteam@netfilter.org, kexec@lists.infradead.org, 
 linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
 ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
 linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
 linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
 linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
 linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
 sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, 
 linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
 linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, 
 linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
 linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
 linux-debuggers@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev

Read, write and list /proc/sys/net/ipv6/conf/<dev>/ of a tun device
with a buffer whose first page is backed by userfaultfd and remove the
device while the task sleeps in its copy from or to userspace:

- unregistering the table doesn't wait for a faulting read(), write()
  or getdents64()

- the read still gets the value that was produced before the removal
  and the next read fails with -ENOENT

- the write is copied in after the removal and fails with -ENOENT

- getdents64() still lists what it looked up before the removal and
  fails with -ENOENT afterwards

The tables are unregistered under RTNL, so a regression stalls each
test for five seconds before it fails.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 tools/testing/selftests/proc/.gitignore            |   1 +
 tools/testing/selftests/proc/Makefile              |   1 +
 tools/testing/selftests/proc/config                |   3 +
 .../selftests/proc/proc-remove-slow-sysctl.c       | 213 +++++++++++++++++++++
 4 files changed, 218 insertions(+)

diff --git a/tools/testing/selftests/proc/.gitignore b/tools/testing/selftests/proc/.gitignore
index 5b5e24e39cbd..7b8133492782 100644
--- a/tools/testing/selftests/proc/.gitignore
+++ b/tools/testing/selftests/proc/.gitignore
@@ -21,6 +21,7 @@
 /proc-uptime-001
 /proc-uptime-002
 /proc-pidns
+/proc-remove-slow-sysctl
 /read
 /self
 /setns-dcache
diff --git a/tools/testing/selftests/proc/Makefile b/tools/testing/selftests/proc/Makefile
index dae09f333455..bce6beca7274 100644
--- a/tools/testing/selftests/proc/Makefile
+++ b/tools/testing/selftests/proc/Makefile
@@ -32,5 +32,6 @@ TEST_GEN_PROGS += proc-multiple-procfs
 TEST_GEN_PROGS += proc-fsconfig-hidepid
 TEST_GEN_PROGS += proc-sysctl-readdir-churn
 TEST_GEN_PROGS += proc-pidns
+TEST_GEN_PROGS += proc-remove-slow-sysctl
 
 include ../lib.mk
diff --git a/tools/testing/selftests/proc/config b/tools/testing/selftests/proc/config
index 68fbd2b35884..3edd3c437fe4 100644
--- a/tools/testing/selftests/proc/config
+++ b/tools/testing/selftests/proc/config
@@ -1 +1,4 @@
 CONFIG_PROC_FS=y
+CONFIG_IPV6=y
+CONFIG_TUN=y
+CONFIG_USERFAULTFD=y
diff --git a/tools/testing/selftests/proc/proc-remove-slow-sysctl.c b/tools/testing/selftests/proc/proc-remove-slow-sysctl.c
new file mode 100644
index 000000000000..e1b1fd19a07a
--- /dev/null
+++ b/tools/testing/selftests/proc/proc-remove-slow-sysctl.c
@@ -0,0 +1,213 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * A read(), write() or getdents64() of /proc/sys that faults while copying
+ * from or to userspace must not hold up unregistering the sysctl table.
+ * /proc/sys/net/ipv6/conf/<dev>/ of a tun device is unregistered under RTNL
+ * when the device's file is closed.
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <fcntl.h>
+#include <linux/if.h>
+#include <linux/if_tun.h>
+#include <linux/userfaultfd.h>
+#include <poll.h>
+#include <pthread.h>
+#include <sched.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+#include "../kselftest_harness.h"
+
+#define TUN_NAME	"procslow0"
+#define CONF_PATH	"/proc/sys/net/ipv6/conf/" TUN_NAME
+#define MTU_PATH	CONF_PATH "/mtu"
+#define BUF_PAGES	16
+#define TIMEOUT_MS	5000
+
+enum sysctl_op {
+	SYSCTL_READ,
+	SYSCTL_WRITE,
+	SYSCTL_GETDENTS,
+};
+
+struct worker {
+	enum sysctl_op op;
+	int fd;
+	char *buf;
+	size_t len;
+	ssize_t ret;
+	int err;
+};
+
+struct closer {
+	int tun;
+	int done;
+};
+
+static void *work_thread(void *arg)
+{
+	struct worker *w = arg;
+
+	switch (w->op) {
+	case SYSCTL_READ:
+		w->ret = read(w->fd, w->buf, w->len);
+		break;
+	case SYSCTL_WRITE:
+		w->ret = write(w->fd, w->buf, w->len);
+		break;
+	case SYSCTL_GETDENTS:
+		w->ret = syscall(__NR_getdents64, w->fd, w->buf, w->len);
+		break;
+	}
+	w->err = errno;
+	return NULL;
+}
+
+static void *close_thread(void *arg)
+{
+	struct closer *c = arg;
+	ssize_t ret;
+
+	close(c->tun);
+	ret = write(c->done, "x", 1);
+	return (void *)ret;
+}
+
+FIXTURE(proc_sys_slow) {
+	int tun;
+	int uffd;
+	char *buf;
+	long psz;
+};
+
+FIXTURE_SETUP(proc_sys_slow)
+{
+	struct uffdio_api api = { .api = UFFD_API };
+	struct uffdio_register reg = {};
+	struct ifreq ifr = {};
+
+	if (unshare(CLONE_NEWNET))
+		SKIP(return, "unshare(CLONE_NEWNET): %s", strerror(errno));
+
+	self->tun = open("/dev/net/tun", O_RDWR | O_CLOEXEC);
+	if (self->tun < 0)
+		SKIP(return, "/dev/net/tun: %s", strerror(errno));
+	strncpy(ifr.ifr_name, TUN_NAME, IFNAMSIZ - 1);
+	ifr.ifr_flags = IFF_TUN | IFF_NO_PI;
+	ASSERT_EQ(ioctl(self->tun, TUNSETIFF, &ifr), 0);
+	if (access(CONF_PATH, F_OK))
+		SKIP(return, CONF_PATH ": %s", strerror(errno));
+
+	self->uffd = syscall(__NR_userfaultfd, O_CLOEXEC | O_NONBLOCK);
+	if (self->uffd < 0)
+		SKIP(return, "userfaultfd: %s", strerror(errno));
+	ASSERT_EQ(ioctl(self->uffd, UFFDIO_API, &api), 0);
+
+	/* Only the first page of the buffer goes through userfaultfd. */
+	self->psz = sysconf(_SC_PAGESIZE);
+	self->buf = mmap(NULL, BUF_PAGES * self->psz, PROT_READ | PROT_WRITE,
+			 MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	ASSERT_NE(self->buf, MAP_FAILED);
+	reg.range.start = (unsigned long)self->buf;
+	reg.range.len = self->psz;
+	reg.mode = UFFDIO_REGISTER_MODE_MISSING;
+	ASSERT_EQ(ioctl(self->uffd, UFFDIO_REGISTER, &reg), 0);
+}
+
+FIXTURE_TEARDOWN(proc_sys_slow)
+{
+}
+
+/*
+ * Let @w sleep in its copy from or to the first page of the buffer, then
+ * close the device. Unregistering the table must not wait for @w.
+ */
+static void stall_and_remove(struct __test_metadata *_metadata,
+			     FIXTURE_DATA(proc_sys_slow) *self,
+			     struct worker *w)
+{
+	struct closer c = { .tun = self->tun };
+	struct uffdio_zeropage zero = {};
+	struct uffd_msg msg;
+	struct pollfd pfd;
+	pthread_t wt, ct;
+	int done[2];
+
+	w->buf = self->buf;
+	ASSERT_EQ(pthread_create(&wt, NULL, work_thread, w), 0);
+
+	pfd = (struct pollfd){ .fd = self->uffd, .events = POLLIN };
+	ASSERT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1);
+	ASSERT_EQ(read(self->uffd, &msg, sizeof(msg)), sizeof(msg));
+	ASSERT_EQ(msg.event, UFFD_EVENT_PAGEFAULT);
+
+	ASSERT_EQ(pipe2(done, O_CLOEXEC), 0);
+	c.done = done[1];
+	ASSERT_EQ(pthread_create(&ct, NULL, close_thread, &c), 0);
+	pfd = (struct pollfd){ .fd = done[0], .events = POLLIN };
+	EXPECT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1) {
+		TH_LOG("unregistering " CONF_PATH " waited for the faulting task");
+	}
+
+	zero.range.start = (unsigned long)self->buf;
+	zero.range.len = self->psz;
+	ASSERT_EQ(ioctl(self->uffd, UFFDIO_ZEROPAGE, &zero), 0);
+	ASSERT_EQ(pthread_join(wt, NULL), 0);
+	ASSERT_EQ(pthread_join(ct, NULL), 0);
+}
+
+TEST_F(proc_sys_slow, read)
+{
+	struct worker w = {
+		.op	= SYSCTL_READ,
+		.len	= BUF_PAGES * self->psz,
+	};
+
+	w.fd = open(MTU_PATH, O_RDONLY | O_CLOEXEC);
+	ASSERT_GE(w.fd, 0);
+	stall_and_remove(_metadata, self, &w);
+
+	/* The value was produced before the table went away, then nothing. */
+	EXPECT_GT(w.ret, 0);
+	EXPECT_EQ(read(w.fd, self->buf, self->psz), -1);
+	EXPECT_EQ(errno, ENOENT);
+}
+
+TEST_F(proc_sys_slow, write)
+{
+	struct worker w = {
+		.op	= SYSCTL_WRITE,
+		.len	= 5,
+	};
+
+	w.fd = open(MTU_PATH, O_WRONLY | O_CLOEXEC);
+	ASSERT_GE(w.fd, 0);
+	stall_and_remove(_metadata, self, &w);
+
+	/* The table went away while the value was copied in. */
+	EXPECT_EQ(w.ret, -1);
+	EXPECT_EQ(w.err, ENOENT);
+}
+
+TEST_F(proc_sys_slow, getdents)
+{
+	struct worker w = {
+		.op	= SYSCTL_GETDENTS,
+		.len	= BUF_PAGES * self->psz,
+	};
+
+	w.fd = open(CONF_PATH, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
+	ASSERT_GE(w.fd, 0);
+	stall_and_remove(_metadata, self, &w);
+
+	/* What was looked up before the removal still arrives, then nothing. */
+	EXPECT_GT(w.ret, 0);
+	EXPECT_EQ(syscall(__NR_getdents64, w.fd, self->buf, self->psz), -1);
+	EXPECT_EQ(errno, ENOENT);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

