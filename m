Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793631127;
	b=wixn1Ngf6mfA7ImPrdA0Xxlze+nOAKuy/n3N1iGCzQXlf+22yE6sxAHJgfL8gQa5Rtpm
	 A8duKrl+6zqpJNUgpGXlkq5X1VBZKYj78g/EjXBwIWVg9rxvHcooddFJHfl2tbNxmr7Di
	 IlPDzYkfVmsX6jkqBe1P9eVsiQ25mVZUsjooQ7MUz8mPmKDq7VV0gLFyvk6QlrqXMwYE9
	 gKOsh3T+XpGHOj3T8EvRz2UqFoJDRxeZkH0ki5eYxzFGVIgyOEEs0E/Xtqf4pRszYhXgB
	 JNVHrOYnaBqFJy+T5tQK90ILhQGjvk5JcUl2k1zULrW5Xo5XtiIiVfrBKHkm4/1wuhg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793631127;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer;
	bh=iJ84nEP4YY4K28kLfEZAA/6j0sLXVTf/aEe1LCZ8e14=;
	b=20hci1IwC9KOOhXLoLmFEzmVaLvIiUfKxToBHPDqMQhMGOXzDvQz5ot22hB7N+/kiGbK
	 wkFll8l2EUSkUVQIOIIituG4jADJoFbWeGbEMRItc/ArgatVQFTqTvE3F/mMSV5bviyE6
	 VpFHyWCuPoJu3f5qfajmSfCMpD+nXvRyOfHp6Q/uarZi/+lgHSi1js2nwhfMfsIeCgfsC
	 gknE5un0JvYiHm7DLUaIwCSog8TTqj0zwMkVxgxgu0i6jITxHQinfcHw0qCZxRYDOlFtY
	 FITfRDHLAjQhUJgpHLmF+24b0/G+cRGSctTfJ0KZU6mPzZHBm7iin+g6jc30FJouxfQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PR4eStJu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36A71606D830;
	Mon,  2 Nov 2026 14:52:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PR4eStJu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9FECC1F00A1B;
	Mon,  2 Nov 2026 14:51:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793631126;
	bh=iJ84nEP4YY4K28kLfEZAA/6j0sLXVTf/aEe1LCZ8e14=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PR4eStJuCoR+mECGMaIVXtQASozW+a7AOmyTO4iG4xy4nIzb4PWW2BKxvYmoNRuHs
	 x2Lm2Rfp+v90UcW719VC0BYV4O8DTyukQ9z+uecUIg7pY28G7drnWgQgVWiNUS+/ck
	 xxhSirH9ZyCaYNU7/1qRcYlti7eFvPDGGsReRJYcEPKXsJ5iSGH7SZJURK2R0hC4aT
	 hXX/7O0Tf8cPki+pg2H6SZ7pXnNxkptKTlJYs8cIZrx/PHwXHyzeBPMp/y/AzKyvOE
	 N8mqzLmWmEBFNIMmXqg5H4OevB0bDwM2UM7fMf6GDHFGBq7FkN5sBI9EBYQrhUrLbY
	 N6tJxPjUYmLBA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:48:48 +0100
Subject: [PATCH RFC 08/16] selftests/proc: check that a faulting reader
 doesn't hold up removal
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
Message-Id: <20261102-work-procfs-core-v1-8-75df35e4f8b8@kernel.org>
References: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
In-Reply-To: <20261102-work-procfs-core-v1-0-75df35e4f8b8@kernel.org>
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

Read /proc/net/dev_snmp6/<dev> of a tun device into a buffer whose first
page is backed by userfaultfd and remove the device while the reader
sleeps in its copy to userspace:

- removing the entry doesn't wait for the reader

- the reader still gets what was printed before the removal

- and the next read fails with -EIO

The entry is removed under RTNL, so a regression stalls the test for
five seconds before it fails.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 .../selftests/proc/proc-remove-slow-reader.c       | 133 +++++++++++++++++++++
 1 file changed, 133 insertions(+)

diff --git a/tools/testing/selftests/proc/proc-remove-slow-reader.c b/tools/testing/selftests/proc/proc-remove-slow-reader.c
new file mode 100644
index 000000000000..a201645beca9
--- /dev/null
+++ b/tools/testing/selftests/proc/proc-remove-slow-reader.c
@@ -0,0 +1,133 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * A read that faults while copying to userspace must not hold up removal of
+ * the /proc entry. /proc/net/dev_snmp6/<dev> of a tun device is removed under
+ * RTNL when the device's file is closed.
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
+#define SNMP6_PATH	"/proc/net/dev_snmp6/" TUN_NAME
+#define READ_PAGES	16
+#define TIMEOUT_MS	5000
+
+struct reader {
+	int fd;
+	char *buf;
+	size_t len;
+	ssize_t ret;
+};
+
+struct closer {
+	int tun;
+	int done;
+};
+
+static void *read_thread(void *arg)
+{
+	struct reader *r = arg;
+
+	r->ret = read(r->fd, r->buf, r->len);
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
+TEST(remove_while_reader_faults)
+{
+	struct uffdio_api api = { .api = UFFD_API };
+	struct uffdio_register reg = {};
+	struct uffdio_zeropage zero = {};
+	long psz = sysconf(_SC_PAGESIZE);
+	struct ifreq ifr = {};
+	struct reader r = {};
+	struct closer c = {};
+	struct uffd_msg msg;
+	struct pollfd pfd;
+	pthread_t rt, ct;
+	int uffd, done[2];
+	char *buf;
+
+	if (unshare(CLONE_NEWNET))
+		SKIP(return, "unshare(CLONE_NEWNET): %s", strerror(errno));
+
+	c.tun = open("/dev/net/tun", O_RDWR | O_CLOEXEC);
+	if (c.tun < 0)
+		SKIP(return, "/dev/net/tun: %s", strerror(errno));
+	strncpy(ifr.ifr_name, TUN_NAME, IFNAMSIZ - 1);
+	ifr.ifr_flags = IFF_TUN | IFF_NO_PI;
+	ASSERT_EQ(ioctl(c.tun, TUNSETIFF, &ifr), 0);
+
+	r.fd = open(SNMP6_PATH, O_RDONLY | O_CLOEXEC);
+	if (r.fd < 0)
+		SKIP(return, SNMP6_PATH ": %s", strerror(errno));
+
+	uffd = syscall(__NR_userfaultfd, O_CLOEXEC | O_NONBLOCK);
+	if (uffd < 0)
+		SKIP(return, "userfaultfd: %s", strerror(errno));
+	ASSERT_EQ(ioctl(uffd, UFFDIO_API, &api), 0);
+
+	/* Only the first page of the buffer goes through userfaultfd. */
+	buf = mmap(NULL, READ_PAGES * psz, PROT_READ | PROT_WRITE,
+		   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	ASSERT_NE(buf, MAP_FAILED);
+	reg.range.start = (unsigned long)buf;
+	reg.range.len = psz;
+	reg.mode = UFFDIO_REGISTER_MODE_MISSING;
+	ASSERT_EQ(ioctl(uffd, UFFDIO_REGISTER, &reg), 0);
+
+	r.buf = buf;
+	r.len = READ_PAGES * psz;
+	ASSERT_EQ(pthread_create(&rt, NULL, read_thread, &r), 0);
+
+	/* The reader now sleeps in its copy to userspace. */
+	pfd = (struct pollfd){ .fd = uffd, .events = POLLIN };
+	ASSERT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1);
+	ASSERT_EQ(read(uffd, &msg, sizeof(msg)), sizeof(msg));
+	ASSERT_EQ(msg.event, UFFD_EVENT_PAGEFAULT);
+
+	/* Closing the device removes the file that is being read. */
+	ASSERT_EQ(pipe2(done, O_CLOEXEC), 0);
+	c.done = done[1];
+	ASSERT_EQ(pthread_create(&ct, NULL, close_thread, &c), 0);
+	pfd = (struct pollfd){ .fd = done[0], .events = POLLIN };
+	EXPECT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1) {
+		TH_LOG("removing " SNMP6_PATH " waited for the reader");
+	}
+
+	zero.range.start = (unsigned long)buf;
+	zero.range.len = psz;
+	ASSERT_EQ(ioctl(uffd, UFFDIO_ZEROPAGE, &zero), 0);
+	ASSERT_EQ(pthread_join(rt, NULL), 0);
+	ASSERT_EQ(pthread_join(ct, NULL), 0);
+
+	/* What was printed before the removal still arrives, then nothing. */
+	EXPECT_GT(r.ret, 0);
+	EXPECT_EQ(read(r.fd, buf, psz), -1);
+	EXPECT_EQ(errno, EIO);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

