Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820525;
	b=DwtsAXtnTTWbqxFe/HyrJNPPvGdZsaNMXpB2xvZ9K9gSPQYxGsTE5/PNOudDLRZJ7Ei7
	 wTYUcZkyPfn411IuYM+IrEHZn2bbjBq8vgWaUKYyq5jknEE84sMShhdJPncAw5UoPJlWV
	 5KCEkYIOkyAbcqzu9k10QhXMVFAO18L7Y+oOfgEYeYTsPl66cUWqn4PAEguuXX1kVwNwC
	 rAT/W4mqGafAeG3SBXMf2wWg5Hpiq/S9pbM58IILPdhJLnOvb+7jgkKki3QcIl3aJpZmJ
	 rtOS/5RDBLL/jkVrm3UScV+jqb0Hj+2y/YUuAO+kwdgYNMbaWm2vWSTftZgQIiXqJ7Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820525;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=KE0FjFLg86Wqg2LOdvIKebjks/LaCpUOq5x1mMvJN8E=;
	b=40xIcFy5tLLNmYD0TxRpjO+ol9Fk5LWfIqWSV5+uBlWCVC+NPnald0wK/x0mu54N947+
	 UBwoI4O1p5ETIj3bRqi5EDMFFOc76eoNG6+aUO/8b+1usa5lEnli+ae0f8s3zN8Vcj/Ec
	 lcS5HXQez9lbwRqK6ahb9K4bbv2pEwhC58sTq8uwo/RbwVUQP3AF0Ul8QuML/ucDKaM24
	 fpr0ZTyNsprDPige5hDKeRTtOJHhmArgSUT7xYqVXHpJVn0pcaofsnICuCemXELHsN3FB
	 Z7eRZuZfqUjHPYRu0a9QKXrudiPZ3RMr1FOcR4ZDniDkUs7mIeOb0HVZ2i2kao0/plA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NJukzHF4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7542607524A;
	Wed,  4 Nov 2026 19:28:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NJukzHF4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DC5AB1F000C1;
	Wed,  4 Nov 2026 19:28:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820520;
	bh=KE0FjFLg86Wqg2LOdvIKebjks/LaCpUOq5x1mMvJN8E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NJukzHF4aV1KUnciVzdApjdNLx1CFG6CVAD2vCJ43JPCAnjjn1zUpxzmLM9SfrWre
	 gCGPTz2pnkhsoLDD0ufQYz7LJbRa17CKdFnkfKWFZpzCvx3VornSWUNThr1WFvwPGn
	 CADeWgCgoQP5K7ENKjJkvGY6u4437GknzfxpYekJnpL3cgHKr3XG5TRSEcefhaKP7V
	 nX57prmegY0CCerzsNzag/fJkXOMUpt/ed2ZwMst0kUSU+NPQt8+F88n3teURVqhXg
	 7vNgcQSCorU7kpZuBp2BFO4KHe0i6WajNcx/gISK920csNZ4jtjgQF1W1PAyzKkO5E
	 yV22BOQaWeKsQ==
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
Subject: [PATCH RESEND v2 51/51] selftests/proc: check that a faulting readlink() doesn't hold up removal
Date: Wed,  4 Nov 2026 20:28:26 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-51-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=7257; i=brauner@kernel.org; h=from:subject:message-id; bh=tBvbDpChuad7Gf34o7zrAy5GeGJ/8Uzeoj8ryWST3Tk=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9buLeeHbphO3/N55kVVv59tmN3VuetO2e/UrKp4azz iWph8NwQkcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEjIIZ/vAeD7jB+vdim/Jj tQ0hkWc2r77GNq27cuqvPzkuqa9flfYz/NOXCS3acGvTlZz++E+JTd/e+ny6wif2bUN30YcXfYm /q1kB
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Add the symlink case:

- readlink() /proc/asound/<id> of a dummy card into a buffer backed by
  userfaultfd

- change the card's id through sysfs while the reader faults, which
  removes the symlink with snd_card_mutex and info_mutex held

- expect that to finish without waiting for the reader

Skipped without snd-dummy.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 tools/testing/selftests/proc/.gitignore            |   1 +
 tools/testing/selftests/proc/Makefile              |   1 +
 tools/testing/selftests/proc/config                |   5 +
 .../selftests/proc/proc-remove-slow-readlink.c     | 191 +++++++++++++++++++++
 4 files changed, 198 insertions(+)

diff --git a/tools/testing/selftests/proc/.gitignore b/tools/testing/selftests/proc/.gitignore
index 7b8133492782..3fa89f46b9c7 100644
--- a/tools/testing/selftests/proc/.gitignore
+++ b/tools/testing/selftests/proc/.gitignore
@@ -22,6 +22,7 @@
 /proc-uptime-002
 /proc-pidns
 /proc-remove-slow-sysctl
+/proc-remove-slow-readlink
 /read
 /self
 /setns-dcache
diff --git a/tools/testing/selftests/proc/Makefile b/tools/testing/selftests/proc/Makefile
index bce6beca7274..df02699a3587 100644
--- a/tools/testing/selftests/proc/Makefile
+++ b/tools/testing/selftests/proc/Makefile
@@ -33,5 +33,6 @@ TEST_GEN_PROGS += proc-fsconfig-hidepid
 TEST_GEN_PROGS += proc-sysctl-readdir-churn
 TEST_GEN_PROGS += proc-pidns
 TEST_GEN_PROGS += proc-remove-slow-sysctl
+TEST_GEN_PROGS += proc-remove-slow-readlink
 
 include ../lib.mk
diff --git a/tools/testing/selftests/proc/config b/tools/testing/selftests/proc/config
index 052e365af5a9..1504a761b39b 100644
--- a/tools/testing/selftests/proc/config
+++ b/tools/testing/selftests/proc/config
@@ -3,3 +3,8 @@ CONFIG_NET_NS=y
 CONFIG_IPV6=y
 CONFIG_TUN=y
 CONFIG_USERFAULTFD=y
+CONFIG_SOUND=y
+CONFIG_SND=y
+CONFIG_SND_DUMMY=m
+CONFIG_MODULES=y
+CONFIG_MODULE_UNLOAD=y
diff --git a/tools/testing/selftests/proc/proc-remove-slow-readlink.c b/tools/testing/selftests/proc/proc-remove-slow-readlink.c
new file mode 100644
index 000000000000..3290225daecd
--- /dev/null
+++ b/tools/testing/selftests/proc/proc-remove-slow-readlink.c
@@ -0,0 +1,191 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * A readlink() that faults while copying out the link must not hold up
+ * removal of the /proc symlink. Changing a sound card's id removes
+ * /proc/asound/<id> with snd_card_mutex and info_mutex held.
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
+#define CARD_ID		"Dummy"
+#define NEW_ID		"procslow"
+#define LINK_PATH	"/proc/asound/" CARD_ID
+#define TIMEOUT_MS	5000
+
+struct reader {
+	char *buf;
+	size_t len;
+	ssize_t ret;
+};
+
+struct renamer {
+	const char *id_path;
+	const char *id;
+	int done;
+	int ret;
+};
+
+static void *readlink_thread(void *arg)
+{
+	struct reader *r = arg;
+
+	r->ret = readlink(LINK_PATH, r->buf, r->len);
+	return NULL;
+}
+
+/* a new id removes the card's old /proc/asound/<id> link */
+static int set_id(const char *id_path, const char *id)
+{
+	int fd, ret;
+
+	fd = open(id_path, O_WRONLY | O_CLOEXEC);
+	if (fd < 0)
+		return -errno;
+	ret = write(fd, id, strlen(id)) < 0 ? -errno : 0;
+	close(fd);
+	return ret;
+}
+
+static void *rename_thread(void *arg)
+{
+	struct renamer *r = arg;
+	ssize_t ret;
+
+	r->ret = set_id(r->id_path, r->id);
+	ret = write(r->done, "x", 1);
+	return (void *)ret;
+}
+
+/* the sysfs id file of the card with @id */
+static int find_card(const char *id, char *id_path, size_t size)
+{
+	struct dirent *d;
+	int ret = -1;
+	DIR *dir;
+
+	dir = opendir("/sys/class/sound");
+	if (!dir)
+		return -1;
+	while (ret && (d = readdir(dir))) {
+		char cur[32];
+		FILE *f;
+
+		if (strncmp(d->d_name, "card", 4))
+			continue;
+		snprintf(id_path, size, "/sys/class/sound/%s/id", d->d_name);
+		f = fopen(id_path, "r");
+		if (!f)
+			continue;
+		if (fgets(cur, sizeof(cur), f)) {
+			cur[strcspn(cur, "\n")] = '\0';
+			if (!strcmp(cur, id))
+				ret = 0;
+		}
+		fclose(f);
+	}
+	closedir(dir);
+	return ret;
+}
+
+FIXTURE(dummy) {
+	char id_path[PATH_MAX];
+	bool renamed;
+};
+
+FIXTURE_SETUP(dummy)
+{
+	self->renamed = false;
+	if (access(LINK_PATH, F_OK) && system("modprobe -q snd-dummy"))
+		SKIP(return, "no snd-dummy");
+	if (access(LINK_PATH, F_OK))
+		SKIP(return, LINK_PATH ": %s", strerror(errno));
+	if (find_card(CARD_ID, self->id_path, sizeof(self->id_path)))
+		SKIP(return, "no sysfs id file for " CARD_ID);
+	if (access(self->id_path, W_OK))
+		SKIP(return, "%s: %s", self->id_path, strerror(errno));
+}
+
+FIXTURE_TEARDOWN(dummy)
+{
+	if (self->renamed && set_id(self->id_path, CARD_ID))
+		TH_LOG("couldn't name the card " CARD_ID " again");
+}
+
+TEST_F(dummy, remove_while_readlink_faults)
+{
+	struct uffdio_api api = { .api = UFFD_API };
+	struct uffdio_register reg = {};
+	struct uffdio_zeropage zero = {};
+	long psz = sysconf(_SC_PAGESIZE);
+	struct renamer rn = {};
+	struct reader r = {};
+	struct uffd_msg msg;
+	struct pollfd pfd;
+	pthread_t rt, nt;
+	int uffd, done[2];
+	char *buf;
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
+	r.buf = buf;
+	r.len = psz;
+	ASSERT_EQ(pthread_create(&rt, NULL, readlink_thread, &r), 0);
+
+	/* The reader now sleeps in the copy of the link to userspace. */
+	pfd = (struct pollfd){ .fd = uffd, .events = POLLIN };
+	ASSERT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1);
+	ASSERT_EQ(read(uffd, &msg, sizeof(msg)), sizeof(msg));
+	ASSERT_EQ(msg.event, UFFD_EVENT_PAGEFAULT);
+
+	/* Renaming the card removes the link that is being read. */
+	ASSERT_EQ(pipe2(done, O_CLOEXEC), 0);
+	rn.id_path = self->id_path;
+	rn.id = NEW_ID;
+	rn.done = done[1];
+	self->renamed = true;
+	ASSERT_EQ(pthread_create(&nt, NULL, rename_thread, &rn), 0);
+	pfd = (struct pollfd){ .fd = done[0], .events = POLLIN };
+	EXPECT_EQ(poll(&pfd, 1, TIMEOUT_MS), 1) {
+		TH_LOG("removing " LINK_PATH " waited for the reader");
+	}
+
+	zero.range.start = (unsigned long)buf;
+	zero.range.len = psz;
+	ASSERT_EQ(ioctl(uffd, UFFDIO_ZEROPAGE, &zero), 0);
+	ASSERT_EQ(pthread_join(rt, NULL), 0);
+	ASSERT_EQ(pthread_join(nt, NULL), 0);
+	EXPECT_EQ(rn.ret, 0);
+
+	/* The link was read before it went away. */
+	EXPECT_GT(r.ret, 0);
+	EXPECT_EQ(readlink(LINK_PATH, buf, psz), -1);
+	EXPECT_EQ(errno, ENOENT);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

