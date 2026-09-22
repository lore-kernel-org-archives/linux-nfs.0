Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78FE653CA6F;
	Tue, 22 Sep 2026 11:34:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076870; cv=none; b=JkYnlh63/50G4Afy6ebMwHWmKvmrgdgnzgPap//dKIl0mLPRX8YUNZOgBtdw41A7QGX2jzJMc1VkgfvIcCJQl0yRhgWhw+USSm9AsMJhoGB6sIGp7tlSmPao1U+Wf/Rmk1p1vhXM2myO95B/C+pa04TMET8GuNhWfcUB0gXZ+FI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076870; c=relaxed/simple;
	bh=5bC76uAgFEI9MAOPPthi086OiyQQuDkGEYMVljJe+nk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=hutBhVmq0lNZt8dY5g/8UCH4PkWiUPjZFIzeLg1CzN4iQalWgOiVFFyD6Rd5b/zrLdMCE3ghoujV51+Bd0Ij+tXY6OotMC3HfXzmAMpf6Ql1znukvORuItcTgI7Fi7mBxmF3kfnbO3UaKD780mp7EeoeGwQoKCcJE56k1QDX5Dg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LXa+EwF8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LXa+EwF8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9CD841F00893;
	Tue, 22 Sep 2026 11:34:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076867;
	bh=psN55JlUjKry1U9zL6IGxQltn13iuretpNa5H1Ltl08=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LXa+EwF8D1i8ylvvtkoiT/iPjsXhoIr5cGof/L0zKIznkP/X/L6Acvrzo8vfnFl7B
	 1fZLQHx8Di8rVpTiRlqZ8jDcQcVyXcYLISxPH8b1GGCkAH0hP2xMapa9oOEFb6GCkI
	 o38UY09d6loJmwzinXtiflbVK9TY3M4ftEl1lA9/mDkOzHhoTx3RUFmLPGf5x+qZzE
	 2zmO3YIqth5WqrN20Wn46FPhxwDxNUqU+2azmae3vaVZ9PVJSLks5QmHFx7XFX49mK
	 4PBI4c/fOCrOFfyfruZULpvFFCbbtQjARlodRtdIHE6xxXqTJbt85f/w8I7F9YzGms
	 O+YDVr0zx5WdQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 22 Sep 2026 07:34:09 -0400
Subject: [PATCH v2 8/8] selftests/nfsd: add a cross-namespace control-plane
 soak
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260922-nfsd-per-net-mutex-v2-8-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=20610; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=5bC76uAgFEI9MAOPPthi086OiyQQuDkGEYMVljJe+nk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsme6rOrlLITcd4zUW2BUyyzzmANgTrUdAAxIr
 hUPuoCVrN2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnugAKCRAADmhBGVaC
 FVKgEADA5NDw63V8xKnFFcJIPAWwAH3KcUoUU+v9eFN1mOL766AjraogHoEbpuKIrXQdFpYS+mo
 Tsh8DkTtTmLlQqDupz/FFziBbfQ9W2t18TvH/TRkU7EQiZCK73/MCIVWzjkwtL9iaNeC/RCzRz2
 /e+jaE0Uabyzl+v9xbhtsRCoYKi3HKe3JNIoW/8UaWp779oxD39GMZ6Zr7h2krdK2COzTOdNZys
 OyFZ2MOMoKXjhXjGqiQsgQ8tgXaba02A5jqv7SOUlkuVQmn2pRu1XrcZMpcQ48LaK5nVZ8tEZUs
 JUzSaRLOQWw8BEsoO8hi5IYZBDborMefdAhRGcVHyyPQftGxHX0rpbEXS6gD+O6GVMdcI+UDcK8
 qQTHyYJNtBh2v8QXMnUdTJQ4HJ5Xh7ccT+YjjlV7klJGFLXM1qrVZ8NU/n+kuVt9sRh2DOThiUM
 CERUZCK/Wiubn61ASycz+BYCgT85wmpHwbijKzThWiTlqVR7aHhpnYeW1nSQc7ILSuQ0yISO+or
 hSLVCnqSclf1sFZe1XusHWlhPBe/cfRfX+skzdfHmelAxgCOSKJdou2xI+fxH4Z/HAKHKFZh1gJ
 PTWV2ZP0KRnYuUBeLT4N2SHlPMGs8fMGr++A1y1A2N/JaHiHYrquqVlB5j2YtEJ07eKm7jjNL4e
 av3rl+H6ygntqLA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Drive the NFSD control plane from many namespaces at once, to exercise
every edge of the lock nesting:

	nn->nfsd_mutex -> nfsd_global_mutex -> nfsd_file_cache_mutex

Each worker owns a namespace and churns between "no serv" and "serv with
threads", mixing in the operations that cross into the host-wide locks:

  start/stop a server	nn -> global (nfsd_users 0->1->0, notifiers)
			   -> cache (cache init/shutdown)
  empty LISTENER_SET	creates and destroys a serv in one call, so the
			   host-wide refcount goes 0->1->0 on its own
  nfsd.fh/flush		the cache lock with nothing else held
  read filecache	likewise
  read pool_stats	nn, reached through svc_info.mutex

Random churn alone is a weak race finder, so the run ends with
synchronized rounds where every namespace attempts the host-wide 0->1
transition at the same instant. That window only opened up once the
per-namespace lock stopped serializing namespaces against each other.

The test asserts little by itself; the result that matters is that the
kernel did not warn. The taint word is sampled before and after and a
newly set TAINT_WARN fails the run, which catches lockdep splats,
WARN_ON()s and refcount saturation alike. Add PROVE_LOCKING and friends
to the config, and log a note if lockdep looks absent.

Two things can silently gut the coverage, so both are reported rather
than left to look like a pass:

  - without lockdep there is very little for the kernel to complain
    about;
  - a server already running outside these namespaces pins the
    host-wide refcount above zero for the whole run, so the 0->1
    transition the synchronized rounds are built around never happens.

Each worker leaves only NFSv4.1 enabled. A fresh namespace has v3 on,
which makes nfsd_needs_lockd() true, and the lockd that comes up then
waits out an RPC timeout against an rpcbind that is not there on every
single server start.

Every namespace binds the same port; they are isolated, so that must
work, and a bind failure is a louder signal than a silent pass. Sized
from nproc, capped at 8 namespaces and 5s of churn by default, and
tunable with NFSD_STRESS_WORKERS and NFSD_STRESS_SECS. The barrier waits
with a deadline so a worker that dies cannot wedge the run, and the test
carries an explicit timeout because the harness otherwise caps it at
TEST_TIMEOUT_DEFAULT.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 tools/testing/selftests/nfsd/.gitignore          |   1 +
 tools/testing/selftests/nfsd/Makefile            |   1 +
 tools/testing/selftests/nfsd/config              |   6 +
 tools/testing/selftests/nfsd/nfsd_netns_stress.c | 572 +++++++++++++++++++++++
 tools/testing/selftests/nfsd/settings            |   2 +-
 5 files changed, 581 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/nfsd/.gitignore b/tools/testing/selftests/nfsd/.gitignore
index 0304b80eb844..2347491c634d 100644
--- a/tools/testing/selftests/nfsd/.gitignore
+++ b/tools/testing/selftests/nfsd/.gitignore
@@ -1,2 +1,3 @@
 nfsd_netlink_listener
 nfsd_netns_isolation
+nfsd_netns_stress
diff --git a/tools/testing/selftests/nfsd/Makefile b/tools/testing/selftests/nfsd/Makefile
index 2b7c44c3fb00..b29bf642c0ad 100644
--- a/tools/testing/selftests/nfsd/Makefile
+++ b/tools/testing/selftests/nfsd/Makefile
@@ -3,5 +3,6 @@ CFLAGS += $(KHDR_INCLUDES) -Wall
 
 TEST_GEN_PROGS := nfsd_netlink_listener
 TEST_GEN_PROGS += nfsd_netns_isolation
+TEST_GEN_PROGS += nfsd_netns_stress
 
 include ../lib.mk
diff --git a/tools/testing/selftests/nfsd/config b/tools/testing/selftests/nfsd/config
index 0eef03af3503..c6407806b58b 100644
--- a/tools/testing/selftests/nfsd/config
+++ b/tools/testing/selftests/nfsd/config
@@ -12,3 +12,9 @@ CONFIG_INOTIFY_USER=y
 CONFIG_SUNRPC=y
 CONFIG_NFSD=y
 CONFIG_NFSD_V4=y
+
+# nfsd_netns_stress leans on lockdep to find anything; without these the
+# soak still runs but proves very little.
+CONFIG_PROVE_LOCKING=y
+CONFIG_DEBUG_MUTEXES=y
+CONFIG_DEBUG_ATOMIC_SLEEP=y
diff --git a/tools/testing/selftests/nfsd/nfsd_netns_stress.c b/tools/testing/selftests/nfsd/nfsd_netns_stress.c
new file mode 100644
index 000000000000..7ca278a5d4a0
--- /dev/null
+++ b/tools/testing/selftests/nfsd/nfsd_netns_stress.c
@@ -0,0 +1,572 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Concurrency soak for the NFSD control plane across network namespaces.
+ *
+ * NFSD's control plane is serialized by three locks, nested in this order:
+ *
+ *	nn->nfsd_mutex  ->  nfsd_global_mutex  ->  nfsd_file_cache_mutex
+ *
+ * Most of what used to be one module-wide mutex is now per-namespace, so
+ * namespaces run their control planes in parallel and only meet on the
+ * host-wide bits: the refcount that brings the open file cache and the
+ * NFSv4 global tables up and down, and the address-notifier registration.
+ *
+ * This test exists to drive every one of those edges at once from many
+ * namespaces. It asserts little by itself -- the point is to give lockdep
+ * something to work with, so it is close to worthless without
+ * CONFIG_PROVE_LOCKING=y. What it does check is that the kernel did not
+ * warn: the taint word is sampled before and after, and a newly set
+ * TAINT_WARN fails the run. That catches lockdep splats, WARN_ON()s and
+ * refcount saturation alike.
+ *
+ * Each worker drives these, which between them cover every edge:
+ *
+ *   start a server	nn -> global (nfsd_users 0->1, notifiers 0->1)
+ *			   -> cache (nfsd_file_cache_init)
+ *   stop a server	nn -> global (1->0) -> cache (cache_shutdown)
+ *   empty LISTENER_SET	creates and destroys a serv in one call, so the
+ *			   host-wide refcount goes 0->1->0 on its own
+ *   nfsd.fh/flush	the cache lock with nothing else held
+ *   read filecache	likewise
+ *   read pool_stats	nn, reached through svc_info.mutex
+ *
+ * Random churn alone is a weak race finder, so the run ends with
+ * synchronized rounds where every worker attempts the host-wide 0->1
+ * transition at the same instant. That is the window that only opened up
+ * once the per-namespace lock stopped serializing namespaces against each
+ * other.
+ *
+ * Tunable with NFSD_STRESS_WORKERS and NFSD_STRESS_SECS.
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <sched.h>
+#include <signal.h>
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <time.h>
+#include <unistd.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/mount.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/wait.h>
+#include <net/if.h>
+#include <netinet/in.h>
+
+#include "../kselftest_harness.h"
+#include "nfsd_netlink.h"
+
+#define NFSD_MNT		"/mnt/nfsd"
+#define EXPKEY_FLUSH		"/proc/net/rpc/nfsd.fh/flush"
+
+/*
+ * Every worker binds the same port. They are in different namespaces, so
+ * that has to work; if isolation ever breaks, the second bind fails loudly
+ * rather than the test quietly passing.
+ */
+#define STRESS_PORT		20049
+
+#define DEFAULT_WORKERS		8
+#define DEFAULT_SECS		5
+#define MAX_WORKERS		64
+#define SYNC_ROUNDS		20
+#define BARRIER_TIMEOUT_SEC	30
+
+/*
+ * Generous: the harness caps a test at TEST_TIMEOUT_DEFAULT otherwise, and
+ * the churn duration is tunable.
+ */
+#define SOAK_TIMEOUT_SEC	600
+
+#define TAINT_WARN_BIT		(1UL << 9)
+
+/* Worker exit codes. */
+#define WORKER_OK		0
+#define WORKER_FAIL		1
+#define WORKER_NO_SETUP		2
+
+/* ------------------- cross-process barrier ------------------- */
+
+struct barrier {
+	unsigned int n;
+	unsigned int count;
+	unsigned int generation;
+	unsigned int aborted;	/* latched: a rendezvous was never completed */
+};
+
+/*
+ * Spin with a deadline rather than blocking, so a worker that dies cannot
+ * wedge the run.
+ *
+ * The first waiter to give up latches ->aborted, which kills the barrier
+ * for good: every later call returns at once instead of waiting out its
+ * own deadline. Without that latch a single missing worker costs
+ * BARRIER_TIMEOUT_SEC on every remaining rendezvous -- three per round,
+ * SYNC_ROUNDS rounds -- which runs into tens of minutes before the
+ * harness timeout fires.
+ *
+ * A giving-up waiter leaves its ->count increment behind. That is fine:
+ * once ->aborted is set nothing reads ->count again.
+ *
+ * Returns false if the rendezvous did not happen.
+ */
+static bool barrier_wait(struct barrier *b)
+{
+	unsigned int gen = __atomic_load_n(&b->generation, __ATOMIC_ACQUIRE);
+	time_t deadline = time(NULL) + BARRIER_TIMEOUT_SEC;
+
+	if (__atomic_load_n(&b->aborted, __ATOMIC_ACQUIRE))
+		return false;
+
+	if (__atomic_add_fetch(&b->count, 1, __ATOMIC_ACQ_REL) == b->n) {
+		__atomic_store_n(&b->count, 0, __ATOMIC_RELEASE);
+		__atomic_add_fetch(&b->generation, 1, __ATOMIC_ACQ_REL);
+		return true;
+	}
+	while (__atomic_load_n(&b->generation, __ATOMIC_ACQUIRE) == gen) {
+		if (__atomic_load_n(&b->aborted, __ATOMIC_ACQUIRE))
+			return false;
+		if (time(NULL) > deadline) {
+			__atomic_store_n(&b->aborted, 1, __ATOMIC_RELEASE);
+			return false;
+		}
+		sched_yield();
+	}
+	return true;
+}
+
+/* ------------------- namespace setup ------------------- */
+
+static int netns_enter(void)
+{
+	struct ifreq ifr = {0};
+	int s;
+
+	if (unshare(CLONE_NEWNET | CLONE_NEWNS) < 0)
+		return -errno;
+	if (mount("", "/", NULL, MS_REC | MS_PRIVATE, NULL) < 0)
+		return -errno;
+	if (mount("tmpfs", "/mnt", "tmpfs", 0, NULL) < 0)
+		return -errno;
+	if (mkdir(NFSD_MNT, 0755) < 0)
+		return -errno;
+	if (mount("nfsd", NFSD_MNT, "nfsd", 0, NULL) < 0)
+		return -errno;
+
+	s = socket(AF_INET, SOCK_DGRAM, 0);
+	if (s < 0)
+		return -errno;
+	strcpy(ifr.ifr_name, "lo");
+	if (ioctl(s, SIOCGIFFLAGS, &ifr) < 0) {
+		close(s);
+		return -errno;
+	}
+	ifr.ifr_flags |= IFF_UP | IFF_RUNNING;
+	if (ioctl(s, SIOCSIFFLAGS, &ifr) < 0) {
+		close(s);
+		return -errno;
+	}
+	close(s);
+
+	nfsd_family = genl_resolve_nfsd();
+	if (nfsd_family < 0)
+		return -ENOENT;
+	return 0;
+}
+
+/* ------------------- the operations ------------------- */
+
+static int read_nfsd_file(const char *name)
+{
+	char path[128], buf[4096];
+	int fd, n;
+
+	snprintf(path, sizeof(path), "%s/%s", NFSD_MNT, name);
+	fd = open(path, O_RDONLY);
+	if (fd < 0)
+		return -errno;
+	do {
+		n = read(fd, buf, sizeof(buf));
+	} while (n > 0);
+	close(fd);
+	return n < 0 ? -errno : 0;
+}
+
+/*
+ * The only userspace trigger that reaches nfsd_file_cache_purge(), and so
+ * the only one that takes the file cache lock with no other nfsd lock
+ * held. NFSD_CMD_CACHE_FLUSH does not get there: cache_purge() never calls
+ * the cache_detail's ->flush hook.
+ */
+static int expkey_flush(void)
+{
+	int fd = open(EXPKEY_FLUSH, O_WRONLY);
+	int n;
+
+	if (fd < 0)
+		return -errno;
+	n = write(fd, "1\n", 2);
+	close(fd);
+	return n < 0 ? -errno : 0;
+}
+
+/* Create a serv and tear it straight back down inside one call. */
+static int serv_cycle(void)
+{
+	return listener_set(NULL, 0);
+}
+
+static int server_up(int nthreads)
+{
+	char attrs[128];
+	int off, ret;
+
+	off = put_listener(attrs, 0, "tcp", STRESS_PORT);
+	off = put_attr(attrs, off, NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
+		       NULL, 0);
+	ret = listener_set(attrs, off);
+	if (ret)
+		return ret;
+	return threads_set(nthreads);
+}
+
+/* threads_set(0) drops the last thread, which destroys the serv with it. */
+static int server_down(void)
+{
+	return threads_set(0);
+}
+
+/* ------------------- the worker ------------------- */
+
+struct worker_err {
+	const char *op;
+	int err;
+};
+
+static struct worker_err worker_fault;
+
+static bool fail(const char *op, int err)
+{
+	if (err == 0)
+		return false;
+	worker_fault.op = op;
+	worker_fault.err = err;
+	return true;
+}
+
+/*
+ * Random churn between "no serv" and "serv with threads", with the
+ * lock-crossing reads and flushes mixed in at both ends. Every call here
+ * is one that must succeed in the state it is issued from, so any error is
+ * a real failure rather than an expected race.
+ */
+static bool worker_churn(time_t deadline)
+{
+	bool up = false;
+
+	while (time(NULL) < deadline) {
+		int r = random() % 8;
+
+		if (!up) {
+			switch (r) {
+			case 0:
+			case 1:
+				if (fail("serv_cycle", serv_cycle()))
+					return false;
+				break;
+			case 2:
+				if (fail("version_set", version_set_only(4, 1)))
+					return false;
+				break;
+			case 3:
+				if (fail("flush", expkey_flush()))
+					return false;
+				break;
+			case 4:
+				if (fail("filecache", read_nfsd_file("filecache")))
+					return false;
+				break;
+			case 5:
+				if (fail("pool_stats", read_nfsd_file("pool_stats")))
+					return false;
+				break;
+			default:
+				if (fail("server_up", server_up(1 + random() % 3)))
+					return false;
+				up = true;
+				break;
+			}
+		} else {
+			switch (r) {
+			case 0:
+				if (fail("flush", expkey_flush()))
+					return false;
+				break;
+			case 1:
+				if (fail("filecache", read_nfsd_file("filecache")))
+					return false;
+				break;
+			case 2:
+				if (fail("pool_stats", read_nfsd_file("pool_stats")))
+					return false;
+				break;
+			case 3:
+				if (fail("threads_set", threads_set(1 + random() % 3)))
+					return false;
+				break;
+			default:
+				if (fail("server_down", server_down()))
+					return false;
+				up = false;
+				break;
+			}
+		}
+	}
+
+	if (up && fail("server_down", server_down()))
+		return false;
+	return true;
+}
+
+/*
+ * Every worker arrives at the barrier with no serv, so the host-wide
+ * refcount is at zero, then they all try to take it to one together. The
+ * second barrier lines up the drop back to zero the same way.
+ */
+static bool worker_sync_rounds(struct barrier *b)
+{
+	int i;
+
+	for (i = 0; i < SYNC_ROUNDS; i++) {
+		/*
+		 * A failed rendezvous means a peer is gone, which its own
+		 * exit status already reports. Stop the rounds rather than
+		 * stalling on every remaining barrier.
+		 */
+		if (!barrier_wait(b))
+			return true;
+		if (fail("sync server_up", server_up(1)))
+			return false;
+
+		if (!barrier_wait(b))
+			return true;
+		if (fail("sync flush", expkey_flush()))
+			return false;
+
+		if (!barrier_wait(b))
+			return true;
+		if (fail("sync server_down", server_down()))
+			return false;
+	}
+	return true;
+}
+
+static int worker(int idx, struct barrier *b, unsigned int secs)
+{
+	int ret = netns_enter();
+
+	if (ret) {
+		/*
+		 * Report setup trouble rather than a failure: a restricted
+		 * environment is not a kernel bug.
+		 */
+		fprintf(stderr, "netns %d: setup: %s\n", idx, strerror(-ret));
+		return WORKER_NO_SETUP;
+	}
+
+	/*
+	 * Leave only NFSv4.1 enabled. A fresh namespace has v3 on, which
+	 * makes nfsd_needs_lockd() true, and the lockd that comes up then
+	 * tries to reach an rpcbind that is not there -- so every server
+	 * start waits out an RPC timeout and floods the log. The version
+	 * set sticks across serv teardown, so once is enough.
+	 */
+	ret = version_set_only(4, 1);
+	if (ret) {
+		fprintf(stderr, "netns %d: version_set: %s\n", idx,
+			strerror(-ret));
+		return WORKER_FAIL;
+	}
+
+	srandom(getpid() ^ (unsigned int)time(NULL));
+
+	if (!worker_churn(time(NULL) + secs))
+		goto fault;
+	if (!worker_sync_rounds(b))
+		goto fault;
+	return WORKER_OK;
+
+fault:
+	fprintf(stderr, "netns %d: %s: %s\n", idx, worker_fault.op,
+		strerror(-worker_fault.err));
+	server_down();
+	return WORKER_FAIL;
+}
+
+/*
+ * Threads running outside the test's namespaces. Any at all pin the
+ * host-wide refcount above zero for the whole run, so the 0->1 transition
+ * the synchronized rounds are built around never happens.
+ */
+static int nfsd_threads_here(void)
+{
+	char buf[32] = "";
+	int fd = open("/proc/fs/nfsd/threads", O_RDONLY);
+	int n = 0;
+
+	if (fd < 0)
+		return 0;
+	if (read(fd, buf, sizeof(buf) - 1) > 0)
+		n = atoi(buf);
+	close(fd);
+	return n;
+}
+
+/* ------------------- taint ------------------- */
+
+static unsigned long read_taint(void)
+{
+	unsigned long v = 0;
+	FILE *f = fopen("/proc/sys/kernel/tainted", "r");
+
+	if (!f)
+		return 0;
+	if (fscanf(f, "%lu", &v) != 1)
+		v = 0;
+	fclose(f);
+	return v;
+}
+
+/* ------------------- the test ------------------- */
+
+static unsigned int env_uint(const char *name, unsigned int def, unsigned int max)
+{
+	const char *s = getenv(name);
+	unsigned long v;
+
+	if (!s || !*s)
+		return def;
+	v = strtoul(s, NULL, 0);
+	if (v == 0 || v > max)
+		return def;
+	return (unsigned int)v;
+}
+
+FIXTURE(soak) {
+	int unused;
+};
+
+FIXTURE_SETUP(soak) { }
+FIXTURE_TEARDOWN(soak) { }
+
+TEST_F_TIMEOUT(soak, netns_control_plane_soak, SOAK_TIMEOUT_SEC)
+{
+	unsigned long taint_before, taint_after;
+	unsigned int workers, secs;
+	pid_t pid[MAX_WORKERS];
+	int failed = 0, skipped = 0;
+	unsigned int aborted;
+	struct barrier *b;
+	unsigned int i;
+	long ncpu;
+
+	if (geteuid() != 0)
+		SKIP(return, "must be run as root");
+
+	ncpu = sysconf(_SC_NPROCESSORS_ONLN);
+	if (ncpu < 2)
+		ncpu = 2;
+	workers = env_uint("NFSD_STRESS_WORKERS",
+			   ncpu < DEFAULT_WORKERS ? (unsigned int)ncpu
+						  : DEFAULT_WORKERS,
+			   MAX_WORKERS);
+	secs = env_uint("NFSD_STRESS_SECS", DEFAULT_SECS, 3600);
+
+	b = mmap(NULL, sizeof(*b), PROT_READ | PROT_WRITE,
+		 MAP_SHARED | MAP_ANONYMOUS, -1, 0);
+	ASSERT_NE(MAP_FAILED, b);
+	b->n = workers;
+	b->count = 0;
+	b->generation = 0;
+	b->aborted = 0;
+
+	TH_LOG("%u namespaces, %us of churn then %d synchronized rounds",
+	       workers, secs, SYNC_ROUNDS);
+
+	/*
+	 * A server already running outside these namespaces holds the
+	 * host-wide refcount above zero for the whole run, so the 0->1
+	 * transition the synchronized rounds are built around never
+	 * happens. Worth saying out loud rather than reporting coverage
+	 * that was not there.
+	 */
+	if (nfsd_threads_here() > 0)
+		TH_LOG("note: nfsd runs outside these namespaces; refcount never hits 0");
+
+	taint_before = read_taint();
+
+	for (i = 0; i < workers; i++) {
+		pid[i] = fork();
+		ASSERT_GE(pid[i], 0);
+		if (pid[i] == 0)
+			_exit(worker(i, b, secs));
+	}
+
+	for (i = 0; i < workers; i++) {
+		int status = 0;
+
+		waitpid(pid[i], &status, 0);
+		if (!WIFEXITED(status)) {
+			failed++;
+			continue;
+		}
+		if (WEXITSTATUS(status) == WORKER_FAIL)
+			failed++;
+		else if (WEXITSTATUS(status) == WORKER_NO_SETUP)
+			skipped++;
+	}
+
+	taint_after = read_taint();
+	aborted = __atomic_load_n(&b->aborted, __ATOMIC_ACQUIRE);
+	munmap(b, sizeof(*b));
+
+	if (skipped == (int)workers)
+		SKIP(return, "no worker could set up a private nfsd namespace");
+
+	EXPECT_EQ(0, failed)
+		TH_LOG("%d of %u namespaces reported an error", failed, workers);
+
+	/*
+	 * A namespace that never reached the rounds -- one that could not
+	 * set up, say -- leaves the rest with nobody to meet. Say so: the
+	 * synchronized part did not run to completion.
+	 */
+	if (aborted)
+		TH_LOG("note: synchronized rounds cut short; a namespace did not arrive");
+
+	/*
+	 * The real result. Without CONFIG_PROVE_LOCKING there is very little
+	 * here for the kernel to complain about, so say so rather than
+	 * letting a quiet pass look like coverage.
+	 */
+	EXPECT_EQ(0, (taint_after & ~taint_before) & TAINT_WARN_BIT)
+		TH_LOG("kernel warned during the run (taint %#lx -> %#lx); check dmesg",
+		       taint_before, taint_after);
+
+	/*
+	 * lockdep_proc_init() puts these in procfs, not debugfs, and
+	 * lockdep_chains is the one that appears only with
+	 * CONFIG_PROVE_LOCKING -- the part that validates ordering rather
+	 * than merely tracking. Root-only, but so is this test.
+	 */
+	if (access("/proc/lockdep_chains", R_OK) != 0)
+		TH_LOG("note: CONFIG_PROVE_LOCKING looks absent; this proves little");
+}
+
+TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/nfsd/settings b/tools/testing/selftests/nfsd/settings
index 694d70710ff0..a62d2fa1275c 100644
--- a/tools/testing/selftests/nfsd/settings
+++ b/tools/testing/selftests/nfsd/settings
@@ -1 +1 @@
-timeout=300
+timeout=600

-- 
2.55.0

