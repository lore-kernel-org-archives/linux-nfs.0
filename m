Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 596474DDB51;
	Mon, 21 Sep 2026 16:32:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790008326; cv=none; b=IGll1ZuWompjjGq0PnQ8kH2EQs106QYqNoROLq6Ze37bQ+J9mLCBW8pX2Mu7WDKSYFdKNvQmMEZURfG+5pbTownCwx4E3CVM3lsmbOj4Pu9kHbllK4v9hLLNCsr1zb2D9/ehBz176ZYKiVP62Rm+V3mvfb4dxWhVpeueeXY9GBU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790008326; c=relaxed/simple;
	bh=glTfdhi/ZQdXDASof2vleG8naP1GahavBY8O7AYqMxM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=CA+3vZ9OwMuemb7HS2B9OVqdhr8MtDEVtuHJhfMdgTN+x/sQWGH0clksVvInT6VQS6uet01D1Juh//bQF6yEBYfikEKpgvmB/N5Gl//TG6Mt8iY0K1yxzkMceSWFMsSKiwxFbNbo6ysFPAZo+QXxCkgiFjEB6czHVj8GXtfc7JA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gt1gXCsv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gt1gXCsv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 813261F0089A;
	Mon, 21 Sep 2026 16:32:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790008324;
	bh=gTPAw6InXSRqEzunpKCEdsf1oeHg0brJ08VYykkm9Uw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gt1gXCsvVCnMzs0CspPdTXx6d+t0qwcC7P4+lItsdGoo3Lpw0lWNYB4HSxlcE7qlK
	 2zzUVEqHrjwNduCDtRcescuxL9z1a7ahWblY+MBgY6mmj4CTbRXTn0Nu27q74Ryk/m
	 YOp17eU/ijA/bfxIL5K39trWzbqfnVJqfYpnf02gefQ6Od33BVzG8xqBAqFW6ik6bb
	 6ej+rx1kb6hvLg3sfGCX5V+EebmDztweB7to0eyWwDN/Y6J8PCvFxriqug9Lg9CdgS
	 xngGrtFAFHoDpBOWDewv0XqRVdZb8Drl/g+b1T+7UG+L2BD2K3PxVSLZXng5y5vp+4
	 cxvOl8dInX/UA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 21 Sep 2026 12:31:46 -0400
Subject: [PATCH 7/8] selftests/nfsd: add cross-namespace isolation tests
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-nfsd-per-net-mutex-v1-7-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
In-Reply-To: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=15010; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=glTfdhi/ZQdXDASof2vleG8naP1GahavBY8O7AYqMxM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsVv8J+encNvN5rJ+vVwyVtU22v8P25VYo7hLu
 bbpwcq2WZ2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarFb/AAKCRAADmhBGVaC
 FXUoD/9KiDRAEHP+t9VgZLbF254UMSOeD1QqChcFRUZ47kEN7L71bmIuRhM4PpHylMnMc0RjZ4T
 4JpXDsqzlNg+m91Mnd2BcZrSMafZ9Nu14okmm0yyS7Nra0aOeQ9aUWkOG/MS3ZTga38iB/7vuJP
 SdZYP9qaxsjwbosvxPlcbsSlQSkN2HYo17j/U4zUdriwzM9XP7+VhrGM3ONoBcEFvjpVtpk01F2
 h16RGTYxNWgKCYv7CabQNfdRvzhsl/7f4dVTE65Jh83YHlk0VsrquiLwulbZhYWWBMxMSAGvBvy
 GCLxJGao95EqNN6GemzipcXi1a8mP4+Ywvvb8Qkj7EmbQEgVyeMxoE5BJQZvxe7GOBlacqn0DIN
 5IALXQA0L66bvGbvI0PzHMEBRdZ2bGDFnsKQW0jnXxhrwII8sZvb2mjIYXNmmWd/KA1CJpDjhJb
 LhsAUHWaTwGJbLW7nJMGDQlVBXcMV7wG6w5UCadOztHHAYCYn7C9BsEYj17vMEr7fHSqvvk9eRR
 moJTPGMUqb/zhT2Mx+vVKxBYE8t6bqXZ2WEsykBOn9wxTwEvGvpInitztw+KsakxpofsYseT7BF
 vK5+4BAckzjd6X6Sp9sDGXzPTrBVw/7fZmNauKYEoHAreb83I3t6eVraDa12ECTirRcARovRp7k
 hVfq1UGlYfDOBYw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Check that one namespace's NFSD settings and running server stay out of
another's, now that the control plane is serialized per namespace.

  max_blksize_is_per_netns
	max_block_size is reachable only through a per-netns nfsd
	filesystem but used to live in a module-wide variable. Read it in
	a throwaway namespace, change it in a second, read it again in a
	third; the two reads must agree. No value is hardcoded -- the
	default is derived from the size of memory, so the test picks a
	target that differs from whatever this machine reports.

  *_busy_is_per_netns, pool_stats_readable_with_foreign_server,
  listener_get_does_not_show_foreign_listeners
	max_block_size, VERSION_SET and nfsv4leasetime all refuse with
	-EBUSY once that namespace has a serv. A peer namespace holds a
	server up while the test pokes its own, which must not be
	affected. LISTENER_GET must not report the peer's listener.

  expkey_flush_with_foreign_server
	writing /proc/net/rpc/nfsd.fh/flush is the one userspace path that
	reaches nfsd_file_cache_purge(), and so the one that takes the
	file cache lock with nothing else held.

Servers are created with NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND so nothing
calls out to rpcbind, and restricted to NFSv4.1 so nfsd_needs_lockd()
stays false. Each namespace mounts its own nfsd filesystem on a private
tmpfs; the module creates /proc/fs/nfs, not /proc/fs/nfsd, so there is no
mountpoint to borrow.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 tools/testing/selftests/nfsd/Makefile              |   1 +
 .../testing/selftests/nfsd/nfsd_netns_isolation.c  | 450 +++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |   2 +-
 3 files changed, 452 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/nfsd/Makefile b/tools/testing/selftests/nfsd/Makefile
index 15ac65549d25..2b7c44c3fb00 100644
--- a/tools/testing/selftests/nfsd/Makefile
+++ b/tools/testing/selftests/nfsd/Makefile
@@ -2,5 +2,6 @@
 CFLAGS += $(KHDR_INCLUDES) -Wall
 
 TEST_GEN_PROGS := nfsd_netlink_listener
+TEST_GEN_PROGS += nfsd_netns_isolation
 
 include ../lib.mk
diff --git a/tools/testing/selftests/nfsd/nfsd_netns_isolation.c b/tools/testing/selftests/nfsd/nfsd_netns_isolation.c
new file mode 100644
index 000000000000..6cb8d7e76df1
--- /dev/null
+++ b/tools/testing/selftests/nfsd/nfsd_netns_isolation.c
@@ -0,0 +1,450 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Namespace-isolation tests for the NFSD control plane.
+ *
+ * NFSD's per-namespace settings used to sit behind one module-wide mutex,
+ * and one of them -- the maximum READ/WRITE payload -- was a module-wide
+ * variable reachable through a per-netns file. These tests pin down the
+ * boundary: what one namespace does to its own server must not be visible
+ * to, or block, another.
+ *
+ * Every namespace here gets a private net + mount namespace, a tmpfs on
+ * /mnt so nothing escapes, and its own nfsd filesystem mounted on
+ * /mnt/nfsd. The module creates /proc/fs/nfs, not /proc/fs/nfsd, so the
+ * mount has to be made by hand; it is also what ties a running server to
+ * this test, since nfsd_umount() stops the threads.
+ *
+ * Servers are created with NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND so nothing
+ * ever calls out to rpcbind, and restricted to NFSv4.1 so that
+ * nfsd_needs_lockd() stays false and no lockd instance is started.
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
+#include <unistd.h>
+#include <sys/ioctl.h>
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
+#define TEST_PORT		20049
+
+/* netns_enter() could not build a usable namespace; not a test failure. */
+#define NETNS_NO_SETUP		INT_MIN
+
+/*
+ * Build a private net + mount namespace with an nfsd filesystem on
+ * /mnt/nfsd and loopback up. Returns 0, or NETNS_NO_SETUP when the
+ * environment will not allow it.
+ */
+static int netns_enter(void)
+{
+	struct ifreq ifr = {0};
+	int s;
+
+	if (unshare(CLONE_NEWNET | CLONE_NEWNS) < 0)
+		return NETNS_NO_SETUP;
+	if (mount("", "/", NULL, MS_REC | MS_PRIVATE, NULL) < 0)
+		return NETNS_NO_SETUP;
+
+	/*
+	 * Everything below is created inside this mount namespace only, so
+	 * the mkdir cannot leave anything behind on the host.
+	 */
+	if (mount("tmpfs", "/mnt", "tmpfs", 0, NULL) < 0)
+		return NETNS_NO_SETUP;
+	if (mkdir(NFSD_MNT, 0755) < 0)
+		return NETNS_NO_SETUP;
+	if (mount("nfsd", NFSD_MNT, "nfsd", 0, NULL) < 0)
+		return NETNS_NO_SETUP;
+
+	s = socket(AF_INET, SOCK_DGRAM, 0);
+	if (s < 0)
+		return NETNS_NO_SETUP;
+	strcpy(ifr.ifr_name, "lo");
+	if (ioctl(s, SIOCGIFFLAGS, &ifr) < 0) {
+		close(s);
+		return NETNS_NO_SETUP;
+	}
+	ifr.ifr_flags |= IFF_UP | IFF_RUNNING;
+	if (ioctl(s, SIOCSIFFLAGS, &ifr) < 0) {
+		close(s);
+		return NETNS_NO_SETUP;
+	}
+	close(s);
+
+	nfsd_family = genl_resolve_nfsd();
+	if (nfsd_family < 0)
+		return NETNS_NO_SETUP;
+	return 0;
+}
+
+/* ------------------- nfsdfs file access ------------------- */
+
+static int nfsd_file_read(const char *name, char *buf, size_t len)
+{
+	char path[128];
+	int fd, n;
+
+	snprintf(path, sizeof(path), "%s/%s", NFSD_MNT, name);
+	fd = open(path, O_RDONLY);
+	if (fd < 0)
+		return -errno;
+	n = read(fd, buf, len - 1);
+	close(fd);
+	if (n < 0)
+		return -errno;
+	buf[n] = '\0';
+	return n;
+}
+
+static int nfsd_file_read_int(const char *name)
+{
+	char buf[64];
+	int n = nfsd_file_read(name, buf, sizeof(buf));
+
+	if (n < 0)
+		return n;
+	return atoi(buf);
+}
+
+static int nfsd_file_write_int(const char *name, int val)
+{
+	char path[128], buf[64];
+	int fd, n, len;
+
+	snprintf(path, sizeof(path), "%s/%s", NFSD_MNT, name);
+	len = snprintf(buf, sizeof(buf), "%d\n", val);
+	fd = open(path, O_WRONLY);
+	if (fd < 0)
+		return -errno;
+	n = write(fd, buf, len);
+	close(fd);
+	return n < 0 ? -errno : 0;
+}
+
+/* ------------------- server lifecycle ------------------- */
+
+/*
+ * Bring up a v4.1-only server on a loopback listener, owning rpcbind
+ * registration in userspace so the kernel never issues an rpcbind call.
+ */
+static int server_start(uint16_t port, int nthreads)
+{
+	char attrs[128];
+	int off;
+	int ret;
+
+	ret = version_set_only(4, 1);
+	if (ret)
+		return ret;
+
+	off = put_listener(attrs, 0, "tcp", port);
+	off = put_attr(attrs, off, NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
+		       NULL, 0);
+	ret = listener_set(attrs, off);
+	if (ret)
+		return ret;
+
+	return threads_set(nthreads);
+}
+
+static void server_stop(void)
+{
+	threads_set(0);
+	listener_set(NULL, 0);
+}
+
+/* ------------------- run a callback in a fresh namespace ------------------- */
+
+/*
+ * Fork a child into its own namespace, run @fn there and hand back what it
+ * returned. Used for the checks that only need one namespace at a time.
+ */
+static int netns_run(int (*fn)(long), long arg)
+{
+	int p[2], ret = -EIO;
+	pid_t pid;
+
+	if (pipe(p) < 0)
+		return -errno;
+
+	pid = fork();
+	if (pid < 0) {
+		close(p[0]);
+		close(p[1]);
+		return -errno;
+	}
+	if (pid == 0) {
+		int r = netns_enter();
+
+		if (r == 0)
+			r = fn(arg);
+		if (write(p[1], &r, sizeof(r)) != sizeof(r))
+			_exit(1);
+		_exit(0);
+	}
+
+	close(p[1]);
+	if (read(p[0], &ret, sizeof(ret)) != sizeof(ret))
+		ret = -EIO;
+	close(p[0]);
+	waitpid(pid, NULL, 0);
+	return ret;
+}
+
+/* ------------------- a peer namespace held open ------------------- */
+
+/*
+ * A second namespace running a server for as long as the test needs it.
+ * The peer reports readiness on a pipe and waits for a byte before tearing
+ * down, so the test can be sure the server is up while it pokes its own
+ * namespace.
+ */
+struct peer {
+	pid_t pid;
+	int wake;		/* write here to let the peer exit */
+	int ready;		/* peer writes its status here */
+};
+
+static int peer_start(struct peer *pr, uint16_t port)
+{
+	int wake[2], ready[2];
+	char status;
+
+	if (pipe(wake) < 0)
+		return -errno;
+	if (pipe(ready) < 0) {
+		close(wake[0]);
+		close(wake[1]);
+		return -errno;
+	}
+
+	pr->pid = fork();
+	if (pr->pid < 0) {
+		close(wake[0]); close(wake[1]);
+		close(ready[0]); close(ready[1]);
+		return -errno;
+	}
+	if (pr->pid == 0) {
+		char c;
+		int r = netns_enter();
+
+		if (r == 0)
+			r = server_start(port, 1);
+		status = r == NETNS_NO_SETUP ? 'S' : (r ? 'E' : 'R');
+		if (write(ready[1], &status, 1) != 1)
+			_exit(1);
+		/* Hold the namespace open until the test is done with it. */
+		if (read(wake[0], &c, 1) == 1 && status == 'R')
+			server_stop();
+		_exit(0);
+	}
+
+	close(wake[0]);
+	close(ready[1]);
+	pr->wake = wake[1];
+	pr->ready = ready[0];
+
+	if (read(pr->ready, &status, 1) != 1)
+		status = 'E';
+	if (status == 'S')
+		return NETNS_NO_SETUP;
+	return status == 'R' ? 0 : -EIO;
+}
+
+static void peer_stop(struct peer *pr)
+{
+	char c = 'x';
+
+	if (pr->pid <= 0)
+		return;
+	if (write(pr->wake, &c, 1) != 1)
+		kill(pr->pid, SIGKILL);
+	close(pr->wake);
+	close(pr->ready);
+	waitpid(pr->pid, NULL, 0);
+	pr->pid = 0;
+}
+
+/* ===================== max_block_size is per-namespace ===================== */
+
+static int read_max_blksize(long unused)
+{
+	(void)unused;
+	return nfsd_file_read_int("max_block_size");
+}
+
+static int write_max_blksize(long val)
+{
+	int ret = nfsd_file_write_int("max_block_size", (int)val);
+
+	if (ret)
+		return ret;
+	/* Report what stuck, so the caller knows the write was accepted. */
+	return nfsd_file_read_int("max_block_size");
+}
+
+/*
+ * max_block_size is reachable only through a per-netns nfsd filesystem, so
+ * a write in one namespace must not be visible in another. Read it in a
+ * throwaway namespace, change it in a second, then read it again in a
+ * third: the two reads have to agree.
+ *
+ * No value is hardcoded. The default is derived from the size of memory,
+ * so the test picks a target that differs from whatever this machine uses.
+ */
+TEST(max_blksize_is_per_netns)
+{
+	int before, after, wrote, target;
+
+	before = netns_run(read_max_blksize, 0);
+	if (before == NETNS_NO_SETUP)
+		SKIP(return, "cannot set up a private nfsd namespace");
+	ASSERT_GE(before, 0);
+
+	/* Any legal value that is not the one this machine already reports. */
+	target = (before == 262144) ? 131072 : 262144;
+
+	wrote = netns_run(write_max_blksize, target);
+	ASSERT_EQ(target, wrote)
+		TH_LOG("second namespace did not accept max_block_size=%d",
+		       target);
+
+	after = netns_run(read_max_blksize, 0);
+	ASSERT_GE(after, 0);
+	EXPECT_EQ(before, after)
+		TH_LOG("max_block_size leaked between namespaces: %d -> %d",
+		       before, after);
+}
+
+/* ===================== a busy namespace does not busy others ===================== */
+
+FIXTURE(nfsd_peer) {
+	struct peer pr;
+};
+
+FIXTURE_SETUP(nfsd_peer)
+{
+	int ret;
+
+	if (geteuid() != 0)
+		SKIP(return, "must be run as root");
+
+	/* The peer namespace comes first; it must not be ours. */
+	memset(&self->pr, 0, sizeof(self->pr));
+	ret = peer_start(&self->pr, TEST_PORT);
+	if (ret == NETNS_NO_SETUP)
+		SKIP(return, "cannot set up a private nfsd namespace");
+	if (ret)
+		SKIP(return, "peer namespace could not start a server: %d", ret);
+
+	/* Now put this process in a namespace of its own, with no server. */
+	if (netns_enter() != 0)
+		SKIP(return, "cannot set up a private nfsd namespace");
+}
+
+FIXTURE_TEARDOWN(nfsd_peer)
+{
+	if (nfsd_family >= 0)
+		server_stop();
+	peer_stop(&self->pr);
+}
+
+/*
+ * write_maxblksize() refuses with -EBUSY while that namespace has a serv.
+ * The check is on nn->nfsd_serv, so a server belonging to someone else must
+ * not trip it.
+ */
+TEST_F(nfsd_peer, maxblksize_busy_is_per_netns)
+{
+	int cur = nfsd_file_read_int("max_block_size");
+
+	ASSERT_GE(cur, 0);
+	EXPECT_EQ(0, nfsd_file_write_int("max_block_size",
+					 cur == 262144 ? 131072 : 262144))
+		TH_LOG("max_block_size refused while another netns has a server");
+}
+
+/*
+ * NFSD_CMD_VERSION_SET returns -EBUSY once the namespace has a serv. A
+ * server in the peer namespace must not reach us.
+ */
+TEST_F(nfsd_peer, version_set_busy_is_per_netns)
+{
+	EXPECT_EQ(0, version_set_only(4, 1))
+		TH_LOG("VERSION_SET refused while another netns has a server");
+}
+
+/*
+ * The grace and lease times are per-namespace too, and gated on the same
+ * nn->nfsd_serv check.
+ */
+TEST_F(nfsd_peer, leasetime_busy_is_per_netns)
+{
+	EXPECT_EQ(0, nfsd_file_write_int("nfsv4leasetime", 60))
+		TH_LOG("nfsv4leasetime refused while another netns has a server");
+}
+
+/*
+ * pool_stats runs its seq_file under the mutex that also guards the serv.
+ * Reading it here must not be affected by the peer's server, and must
+ * report this namespace, which has no threads at all.
+ */
+TEST_F(nfsd_peer, pool_stats_readable_with_foreign_server)
+{
+	char buf[4096];
+	int n = nfsd_file_read("pool_stats", buf, sizeof(buf));
+
+	ASSERT_GE(n, 0)
+		TH_LOG("pool_stats unreadable: %s", strerror(-n));
+	EXPECT_NE(NULL, strstr(buf, "packets-arrived"));
+}
+
+/*
+ * LISTENER_GET reports this namespace's listeners. With a server running
+ * next door and none here, the list must come back empty rather than
+ * showing the peer's.
+ */
+TEST_F(nfsd_peer, listener_get_does_not_show_foreign_listeners)
+{
+	char rbuf[8192];
+	int n = genl_request_reply(NFSD_CMD_LISTENER_GET, rbuf, sizeof(rbuf));
+
+	ASSERT_GT(n, 0);
+	EXPECT_EQ(NULL, memmem(rbuf, n, "tcp", 4))
+		TH_LOG("LISTENER_GET leaked a listener from another netns");
+}
+
+/*
+ * The file cache is one host-wide object, but the flush that reaches it is
+ * driven from a per-netns file. Doing it here while the peer has a server
+ * up must be harmless -- this is the path that takes the cache lock with
+ * nothing else held.
+ */
+TEST_F(nfsd_peer, expkey_flush_with_foreign_server)
+{
+	int fd = open("/proc/net/rpc/nfsd.fh/flush", O_WRONLY);
+
+	if (fd < 0)
+		SKIP(return, "no /proc/net/rpc/nfsd.fh/flush: %s",
+		     strerror(errno));
+	EXPECT_EQ(2, write(fd, "1\n", 2));
+	close(fd);
+}
+
+TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/nfsd/settings b/tools/testing/selftests/nfsd/settings
index 6091b45d226b..694d70710ff0 100644
--- a/tools/testing/selftests/nfsd/settings
+++ b/tools/testing/selftests/nfsd/settings
@@ -1 +1 @@
-timeout=120
+timeout=300

-- 
2.55.0

