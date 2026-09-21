Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A2854DE71B;
	Mon, 21 Sep 2026 16:32:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790008330; cv=none; b=IalivSpU1PNDSK9uh0+vbysHS9DLGyxtKhpaiXU0SuuElsq2NIJJ4djRCfspu0mvkYGep6V+snE8mp82NmGoVhhVuCiN5/eQuVNPESLijhfFtVM/TDUCM0zt/m+nzFC3dzhofqaVeSb3IWPEAVo/IFVkI2qkD0R5hTtlver2bkk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790008330; c=relaxed/simple;
	bh=cSceEtvIumftJOtNboDRDZDhfdeb4hDquuCP/1Cr6n0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=AjosZ39f5vHHIkPXTX1yBkhUmhkWBkFKnu6Pfhi9hW507FwCbc5a8COxhd8KjfL++kfY8I+Yiq5+aC5XNfITcMwdd54nZaODAA17beo1gYTRwCBX4em5NvamIaiX8Nco8sahPo96zfq84qZrbZutqB7WVx9zCcKVKupo8HMOaEU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IZsGezYO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IZsGezYO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7B10C1F000FF;
	Mon, 21 Sep 2026 16:32:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790008325;
	bh=IX65Me3gD0G8NvoDluDsrl71dmTpSOEVW+w2UIcLuD8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IZsGezYO1axocmu3Czi5A3EKB8AnN35eBNY7VWQkHK32YYjBl5KPYyRFKzAmj3IvU
	 ymZyiVh5mQoWoot6an/1Z8psZNO2OYEPfEXTjVw/xWglYX9cYQAzaNh5KD5RIeZqhx
	 GfacwAF3SGngADTtWbZt2SdA3YtipRulUXhY1oi8P4wQPDQ+SDPYS9WLYOR8oqD69K
	 22STSXS58V29UBFpKhU4bcxtjpdjs6TarDh9MKCARtjY7pLIsPOasMhUMHJi9n1Etw
	 lcuiGJlKcuPVSnX+z4T7ZM+etJCklSXbTxUTdia69xqIStAeYY0L2O0kD61ECkBHbN
	 EuFuwsO6h3lQw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 21 Sep 2026 12:31:47 -0400
Subject: [PATCH 8/8] selftests/nfsd: add a cross-namespace control-plane
 soak
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-nfsd-per-net-mutex-v1-8-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
In-Reply-To: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=65149; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=cSceEtvIumftJOtNboDRDZDhfdeb4hDquuCP/1Cr6n0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsVv8i0dQZqUOyAENAh0FBhU5Sm6ltLNeR9Seb
 MqIPDVL7VSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarFb/AAKCRAADmhBGVaC
 FRPgD/0VL5oBlDgEQ3iC/75DWx/Nql69KCphrw/F/6JdXU+K73b5SkGS658wbkOkBKlMp4cvH77
 TvgX2I6KJyg0RjA/oZUbdvSH0OOU4oyfFd0fa52ebxIj84M6+tWriPmAFtVcqapu0SLErVL6dLR
 r90NXI0IR9M2hnYKUgGZT2RDIJ5GW+OlOoZSMWhMMBbKCPrutUlwAIDCI8R4JqftfA00SWBv8y3
 svx8l8/OIEBv4FRqhMM5IWqQzj2+NMSkznjhK4zzI52mvqH6YpOGf4fu6iA9PGDVkjRKq0em9yR
 Af3pDBtRvzYN2h5sftQ9VlihP1Qe+EsGQdCsxWmzoZ5GQAfZXGqmNUo0V/0psl11NeUL8b63uN8
 1OPnADCYMQEo10oEfYaoUMi5UUBElpwkDdKCvixT0L2yZyt9GrIZVDTYxFKE68O/9KjzUJSaABy
 VvjYDNjJSdm7e1FN8OMk+oM7L0tc16P3YJWIv5zyhxl+YzRRjYm6C3KsPIzkFSLfFZ0kocptNa+
 JyNDtBTqMPduFJ5+aqW0ME1E90Ri8Jp1AWAw2qspdF2U+5NRJRqnEjEgFkvc+aVAwFl4OdvIu9i
 TM7xFJxwZjcasXyGHAzJ7UaDcqZCAfWWw4CIyh/C/IbTJzpkydK4YJsRpEpfrNvHWPghv2t0sZA
 VUPUvAZBgvQvivg==
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
 tools/testing/selftests/nfsd/Makefile             |   1 +
 tools/testing/selftests/nfsd/config               |   6 +
 tools/testing/selftests/nfsd/nfsd_netns_isolation | Bin 0 -> 49192 bytes
 tools/testing/selftests/nfsd/nfsd_netns_stress    | Bin 0 -> 39232 bytes
 tools/testing/selftests/nfsd/nfsd_netns_stress.c  | 572 ++++++++++++++++++++++
 tools/testing/selftests/nfsd/settings             |   2 +-
 6 files changed, 580 insertions(+), 1 deletion(-)

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
diff --git a/tools/testing/selftests/nfsd/nfsd_netns_isolation b/tools/testing/selftests/nfsd/nfsd_netns_isolation
new file mode 100755
index 0000000000000000000000000000000000000000..b1c391d8597749f7cb2cc5579c5fbd196a458fe4
GIT binary patch
literal 49192
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
Uz<#j&_iPtbxIf()GC=zO0MHR=#sB~S

literal 0
HcmV?d00001

diff --git a/tools/testing/selftests/nfsd/nfsd_netns_stress b/tools/testing/selftests/nfsd/nfsd_netns_stress
new file mode 100755
index 0000000000000000000000000000000000000000..40dbd4657471b223e1724761eb47031de75e57a1
GIT binary patch
literal 39232
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
O4+`<Fsn?7m>3;*}Jlo3v

literal 0
HcmV?d00001

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

