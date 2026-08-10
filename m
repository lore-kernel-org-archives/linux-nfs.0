Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABCCE4322F4;
	Mon, 10 Aug 2026 17:39:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383555; cv=none; b=oUTlGwCFchiIin54C7txGGeXv9myx363MlENvLGAfTvEeyA7DgnF8150WxTzycPVdOk4/IKuzInXM1QdCdZEKwxmnc5vv6LZgQ01UoHdYfq+Oc8eKU0TiDS5GariBgF9mpXfa1p8olO0JC1HNM6xyK6OBNtcDd1/E57RgkisZKg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383555; c=relaxed/simple;
	bh=R3woNQi9oGCf9GbRzPNsOP1NNIFGpQMUcmCS3wj4UXQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=k1Cy1Qit2AZg3gebREni9GmNTHOtTDHZP5fhCb3GJRz3uGREAqxBHiAOeeO5O+ouhlaqJPj9qoMPhhYBQzXQERKUrd3Inn5PjVrQwxpfm94pAaezP3GH4HMpr2IBZSl5G/mWGKHJ2Y8KIPtsEo/hKiKckuligja7xAVVktyZLkQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CbxefDuL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CbxefDuL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2250E1F00A3A;
	Mon, 10 Aug 2026 17:39:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383553;
	bh=UaWwWq3StU66+Eg/0V1UlDxQAXL7Uw/wC8/hFceq28o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CbxefDuLsOaoHRZjqe2VRmVramqwanUFnB1thzaSGyzT1Mfsr1MZ4qjJWPyWfbIMq
	 kxlTs0oSwL49jqVd4XVzdl73y7PED1Ioifmmn8tbgIAQFS370UjdZUZsnreLtXc4RJ
	 v6eW1k+296ehacd+1KBRYDOaFtvn0+RiPHQtBspNJUAlgUlK3U8i0nc7b9zEYvLJkv
	 Jaad6RQtMGu71Oq3aPklDMqNywjLzazWCUpOzgELMZLvHBk0RZLN4qbP3HnL0ZMERy
	 SHOFq0y4NPuKbZ49UAHJI93Zni/m7j8lh8Nnr4mZaosRsWwqA5+5keredXfOgdHjpa
	 zRlciNFAtCmQw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 10 Aug 2026 13:38:54 -0400
Subject: [PATCH 7/7] selftests/nfsd: add a per-netns rpcbind stub and the
 listener round-trips
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260810-nfsd-nl-hang-v1-7-2519fdd5bc1a@kernel.org>
References: <20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org>
In-Reply-To: <20260810-nfsd-nl-hang-v1-0-2519fdd5bc1a@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 "J. Bruce Fields" <bfields@fieldses.org>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Trond Myklebust <trondmy@gmail.com>, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=18843; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=R3woNQi9oGCf9GbRzPNsOP1NNIFGpQMUcmCS3wj4UXQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqegyzwnfR8omsjDt2uMOIq5iiST8x6PYf8KRFF
 CbN1HkCAYqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanoMswAKCRAADmhBGVaC
 FZzID/99Mt4cmw5GUOCDNAvGY1576EfcbTWBcOQVL93fh3NB35PBpN1S+AXBPRSIGP1QqWU+ov0
 huxF1FCE4D5TY1NOYutd21wCLfQ13DH65eiizD0lHbI5GHGMVfIWXtedetiHItHtIPf9k5+++kL
 1WkKnR+0C7K6+vJabhN0kxvavjpo4PYlS9N8GGs62xXe2y34qbl4/XAQsb+xK+VQmBf0/pbrt7F
 UfwKQnE54LWxBpvLHWhkphexI3xGajMtFCy/q98HMaA1LeBzoOs7VnoNcg1Bm5kPCE3IF6NDRMy
 sIN8YzBX2tK7eKH47N0BhqFFKnjF8v7lVASgpEc+4uGiIOGMGAwB4Ey1OUgmrRfqiJnesPDhhgE
 7aC6/jK4p/nrBxOfMy/pFrAwUWbjrSPT9ST1/wPM2XMGK+udCPbXIxo7wMIOqvl+pV3spgPywzd
 dQ0nbsdBPLZ5HcWJT+rL+wsK8tv/feppDZMLHDRDe5Ci156r4o3mYpQQkcq/WV1dk7a7nXMJ/gf
 1R608H1DdnKD9tzlIMfZHjJm2Znj2wJ5uC9R0gPbhjWl74feM7lBBDZphzB6V9NFBfgj2nM0qCF
 Pw+t9UdESb/Gx/Rv6s7ep7ZpQ4SZiYAhTYYcyfwMCpHbsz02t2gpvdxY94hlXxglALz3rDWwQpa
 SWhvAPrZOgdjyRw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Creating a listener registers with rpcbind: svc_xprt_create_from_sa() passes
flags of 0, so pmap_register is true in svc_setup_socket(), and
nfsd_version3 is enabled by default and does not set vs_rpcb_optnl, so a
registration failure aborts listener creation. A fresh netns has no rpcbind,
and reaching the host's is not an option -- svc_rpcb_setup() opens by
calling svc_unregister(), which would clear the host's nfsd entries.

Serve it from within the namespace instead. The abstract AF_LOCAL name the
kernel tries first is per-netns (unix_find_abstract() takes a struct net),
so bind "\0/run/rpcbind.sock" and fork a minimal responder:

- arguments are never decoded; the NULL procedure gets an empty success and
  SET/UNSET get TRUE
- RPCBVERS_4 is answered as well as RPCBVERS_2, because
  __svc_rpcb_register6() turns a v4 refusal into -EAFNOSUPPORT and that
  would fail every IPv6 listener
- PR_SET_PDEATHSIG plus an explicit kill in FIXTURE_TEARDOWN, so no stub
  outlives its test

With that in place, add the tests that need a serv: create/add/remove and
LISTENER_GET round-trips (tcp, udp, multi, idempotent re-set, subset
removal, empty-list serv destroy, IPv6), the empty-list request, and the
-EBUSY refusal once THREADS_SET has started threads.

Two of the new tests exist to catch a revert rather than to describe the
interface, since neither is visible in the errno alone:

- val_reject_keeps_listeners. An unknown transport name ends in
  -EPROTONOSUPPORT either way, because svc_xprt_create_from_sa() returns
  that too. What differs is that without the up-front check
  nfsd_nl_listener_set_doit() has already destroyed the listeners that did
  not match by the time the name fails.
- sem_register_refused, which restarts the stub in a mode that answers
  RPCBPROC_SET with FALSE. rpcb_register_call() turns that into -EACCES,
  which must reach userland and leave no listener behind. On
  CONFIG_NFS_LOCALIO=y it does not, unless svc_register() keeps the first
  error: nfslocalio is last in nfsd_programs and its NULL and vs_hidden
  versions both report success, overwriting the failure.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 444 ++++++++++++++++++++-
 1 file changed, 438 insertions(+), 6 deletions(-)

diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index ae28c224255f..3e3307680d7d 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -3,30 +3,40 @@
  * Regression tests for the NFSD generic-netlink listener interface
  * (NFSD_CMD_LISTENER_SET / NFSD_CMD_LISTENER_GET).
  *
- * These cover the request validation that nfsd_nl_validate_listeners() does
- * before nfsd_mutex is taken: bad or absent transport name, missing address,
- * truncated or unsupported sockaddr, oversized list. None of them reach
- * nfsd_create_serv(), so nothing here creates a serv or talks to rpcbind.
+ * Three groups:
+ *   validation  - malformed/abusive LISTENER_SET requests are rejected by
+ *                 nfsd_nl_validate_listeners(), before nfsd_mutex is taken.
+ *   functional  - create/add/remove listeners and verify LISTENER_GET
+ *                 reflects the set (round-trip of transport + addr:port).
+ *   semantics   - once threads are running (THREADS_SET) a listener change
+ *                 is refused with -EBUSY.
  *
  * Each test runs in its own private net + mount namespace (unshare in
  * FIXTURE_SETUP). /run is masked there: a pathname AF_LOCAL connect is not
  * scoped by the network namespace, since unix_find_bsd() resolves by inode
  * and takes no struct net, so the kernel's rpcbind client would otherwise be
- * able to reach the rpcbind running on the host.
+ * able to reach the rpcbind running on the host. Anything that creates a
+ * serv is served by the per-netns rpcbind stub below instead.
  */
 #define _GNU_SOURCE
 #include <errno.h>
+#include <poll.h>
 #include <sched.h>
+#include <signal.h>
+#include <stddef.h>
 #include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
 #include <sys/mount.h>
+#include <sys/prctl.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
 #include <sys/stat.h>
 #include <sys/time.h>
+#include <sys/un.h>
+#include <sys/wait.h>
 #include <net/if.h>
 #include <netinet/in.h>
 #include <linux/netlink.h>
@@ -36,8 +46,10 @@
 
 /* NFSD generic-netlink constants (from linux/nfsd_netlink.h). */
 #define NFSD_FAMILY_NAME		"nfsd"
+#define NFSD_CMD_THREADS_SET		2
 #define NFSD_CMD_LISTENER_SET		6
 #define NFSD_CMD_LISTENER_GET		7
+#define NFSD_A_SERVER_THREADS		1
 #define NFSD_A_SERVER_SOCK_ADDR		1	/* per-listener nest */
 #define NFSD_A_SOCK_ADDR		1	/* inside the nest */
 #define NFSD_A_SOCK_TRANSPORT_NAME	2	/* inside the nest */
@@ -327,10 +339,233 @@ static int listener_get(struct listener_ent *out, int max)
 	return parse_listener_get(rbuf, n, out, max);
 }
 
+static struct listener_ent *find_listener(struct listener_ent *e, int n,
+					  const char *xprt, int family,
+					  uint16_t port)
+{
+	int i;
+
+	for (i = 0; i < n; i++)
+		if (e[i].family == family && e[i].port == port &&
+		    !strcmp(e[i].xprt, xprt))
+			return &e[i];
+	return NULL;
+}
+
+/* Start (@n > 0) or stop (@n == 0) nfsd threads in this netns. */
+static int threads_set(int n)
+{
+	char attrs[64];
+	uint32_t v = n;
+	int off = put_attr(attrs, 0, NFSD_A_SERVER_THREADS, &v, sizeof(v));
+
+	return genl_request(NFSD_CMD_THREADS_SET, attrs, off);
+}
+
+/* ------------------- per-netns local rpcbind stub ------------------- */
+
+/*
+ * Creating a listener registers with rpcbind: svc_xprt_create_from_sa()
+ * passes flags of 0, so pmap_register is true in svc_setup_socket(), and
+ * nfsd_version3 is registerable by default and does not set vs_rpcb_optnl,
+ * so a registration failure aborts listener creation. The abstract AF_LOCAL
+ * name the kernel tries first is per-netns (unix_find_abstract() takes a
+ * struct net), so answer it here and stay out of the host's rpcbind.
+ *
+ * Arguments are never decoded. The NULL procedure gets an empty success and
+ * SET/UNSET get TRUE, for both RPCBVERS_2 and RPCBVERS_4. v4 has to be
+ * answered because __svc_rpcb_register6() turns a v4 refusal into
+ * -EAFNOSUPPORT, which would fail every IPv6 listener.
+ *
+ * In RPCB_STUB_REFUSE mode SET is answered FALSE instead, which
+ * rpcb_register_call() reports as -EACCES. UNSET is left alone: only
+ * svc_unregister() issues it, and it discards the result.
+ */
+#define RPCB_PROGRAM		100000
+#define RPCB_PROC_NULL		0
+#define RPCB_PROC_SET		1
+#define RPCB_PROC_UNSET		2
+#define RPCB_ABSTRACT_NAME	"/run/rpcbind.sock"
+#define RPCB_STUB_MAXCONN	4
+
+enum { RPCB_STUB_ACCEPT, RPCB_STUB_REFUSE };
+
+static int rpcb_stub_listen(void)
+{
+	struct sockaddr_un sun = { .sun_family = AF_UNIX };
+	size_t nlen = strlen(RPCB_ABSTRACT_NAME);
+	socklen_t alen;
+	int fd;
+
+	/* Abstract names are length-delimited, so the length must match. */
+	memcpy(sun.sun_path + 1, RPCB_ABSTRACT_NAME, nlen);
+	alen = offsetof(struct sockaddr_un, sun_path) + 1 + nlen;
+
+	fd = socket(AF_UNIX, SOCK_STREAM, 0);
+	if (fd < 0)
+		return -1;
+	if (bind(fd, (struct sockaddr *)&sun, alen) < 0 ||
+	    listen(fd, RPCB_STUB_MAXCONN) < 0) {
+		close(fd);
+		return -1;
+	}
+	return fd;
+}
+
+static int rpcb_stub_read(int fd, void *buf, size_t len)
+{
+	size_t done = 0;
+
+	while (done < len) {
+		ssize_t n = read(fd, (char *)buf + done, len - done);
+
+		if (n <= 0)
+			return -1;
+		done += n;
+	}
+	return 0;
+}
+
+/* Handle one record-marked RPC call. Returns -1 when the peer is done. */
+static int rpcb_stub_call(int fd, int mode)
+{
+	uint32_t mark, call[6], rep[7];
+	unsigned int len, nrep = 6;
+	size_t replen;
+
+	if (rpcb_stub_read(fd, &mark, sizeof(mark)))
+		return -1;
+	len = ntohl(mark) & 0x7fffffff;
+	if (len < sizeof(call) || len > 4096)
+		return -1;
+	if (rpcb_stub_read(fd, call, sizeof(call)))
+		return -1;
+
+	/* xid, msg_type, rpcvers, prog, vers, proc; the rest is discarded */
+	for (len -= sizeof(call); len; ) {
+		char sink[256];
+		unsigned int n = len > sizeof(sink) ? sizeof(sink) : len;
+
+		if (rpcb_stub_read(fd, sink, n))
+			return -1;
+		len -= n;
+	}
+
+	rep[0] = call[0];		/* xid */
+	rep[1] = htonl(1);		/* REPLY */
+	rep[2] = htonl(0);		/* MSG_ACCEPTED */
+	rep[3] = htonl(0);		/* verifier flavor AUTH_NULL */
+	rep[4] = htonl(0);		/* verifier length */
+	rep[5] = htonl(0);		/* SUCCESS */
+
+	if (ntohl(call[3]) != RPCB_PROGRAM) {
+		rep[5] = htonl(1);	/* PROG_UNAVAIL */
+	} else {
+		switch (ntohl(call[5])) {
+		case RPCB_PROC_NULL:
+			break;
+		case RPCB_PROC_SET:
+			rep[6] = htonl(mode == RPCB_STUB_REFUSE ? 0 : 1);
+			nrep = 7;
+			break;
+		case RPCB_PROC_UNSET:
+			rep[6] = htonl(1);	/* TRUE */
+			nrep = 7;
+			break;
+		default:
+			rep[5] = htonl(3);	/* PROC_UNAVAIL */
+		}
+	}
+
+	replen = nrep * sizeof(rep[0]);
+	mark = htonl(0x80000000 | replen);
+	if (write(fd, &mark, sizeof(mark)) != (ssize_t)sizeof(mark) ||
+	    write(fd, rep, replen) != (ssize_t)replen)
+		return -1;
+	return 0;
+}
+
+static void rpcb_stub_serve(int lfd, int mode)
+{
+	struct pollfd pfd[1 + RPCB_STUB_MAXCONN];
+	nfds_t n = 1, i;
+
+	pfd[0].fd = lfd;
+
+	for (;;) {
+		/* stop polling the listener when full, or poll() spins */
+		pfd[0].events = n < 1 + RPCB_STUB_MAXCONN ? POLLIN : 0;
+
+		if (poll(pfd, n, -1) < 0)
+			return;
+
+		if (pfd[0].revents & POLLIN) {
+			int c = accept(lfd, NULL, NULL);
+
+			if (c >= 0) {
+				pfd[n].fd = c;
+				pfd[n].events = POLLIN;
+				n++;
+			}
+		}
+
+		for (i = 1; i < n; i++) {
+			if (!(pfd[i].revents & (POLLIN | POLLHUP | POLLERR)))
+				continue;
+			if (rpcb_stub_call(pfd[i].fd, mode)) {
+				close(pfd[i].fd);
+				pfd[i] = pfd[--n];
+			}
+		}
+	}
+}
+
+/* Returns the stub's pid, or -1. The socket is listening before we fork. */
+static pid_t rpcb_stub_start(int mode)
+{
+	int lfd = rpcb_stub_listen();
+	pid_t pid;
+
+	if (lfd < 0)
+		return -1;
+
+	pid = fork();
+	if (pid < 0) {
+		close(lfd);
+		return -1;
+	}
+	if (pid == 0) {
+		signal(SIGPIPE, SIG_IGN);
+		prctl(PR_SET_PDEATHSIG, SIGKILL);
+		if (getppid() == 1)		/* raced with parent exit */
+			_exit(0);
+		rpcb_stub_serve(lfd, mode);
+		_exit(0);
+	}
+
+	close(lfd);
+	return pid;
+}
+
+/*
+ * Swap the stub for one in @mode. Safe before the first request: no serv
+ * exists yet, so the kernel has not connected and the abstract name is free
+ * again once the old stub has been reaped.
+ */
+static int rpcb_stub_restart(pid_t *pid, int mode)
+{
+	if (*pid > 0) {
+		kill(*pid, SIGKILL);
+		waitpid(*pid, NULL, 0);
+	}
+	*pid = rpcb_stub_start(mode);
+	return *pid > 0 ? 0 : -1;
+}
+
 /* --------------------------- fixture --------------------------- */
 
 FIXTURE(nfsd_listener) {
-	int placeholder;
+	pid_t rpcbd;
 };
 
 FIXTURE_SETUP(nfsd_listener)
@@ -369,14 +604,28 @@ FIXTURE_SETUP(nfsd_listener)
 	nfsd_family = genl_resolve_nfsd();
 	if (nfsd_family < 0)
 		SKIP(return, "nfsd genl family not found (modprobe nfsd?)");
+
+	self->rpcbd = rpcb_stub_start(RPCB_STUB_ACCEPT);
+	if (self->rpcbd < 0)
+		SKIP(return, "cannot start the rpcbind stub: %s",
+		     strerror(errno));
 }
 
 FIXTURE_TEARDOWN(nfsd_listener)
 {
+	if (self->rpcbd > 0) {
+		kill(self->rpcbd, SIGKILL);
+		waitpid(self->rpcbd, NULL, 0);
+	}
 }
 
 /* ===================== validation / negative ===================== */
 
+TEST_F(nfsd_listener, val_empty_list_ok)
+{
+	EXPECT_EQ(0, listener_set(NULL, 0));
+}
+
 TEST_F(nfsd_listener, val_too_many)
 {
 	static char attrs[1 << 20];
@@ -477,6 +726,33 @@ TEST_F(nfsd_listener, val_second_entry_bad)
 	EXPECT_EQ(-EAFNOSUPPORT, listener_set(attrs, off));
 }
 
+/*
+ * A rejected request must leave the listeners that are already up alone.
+ * The errno alone does not show that: svc_xprt_create_from_sa() returns
+ * -EPROTONOSUPPORT for an unknown name too. What differs is how far the
+ * request gets -- without the check in nfsd_nl_validate_listeners(),
+ * nfsd_nl_listener_set_doit() has already moved the unmatched tcp listener
+ * off sv_permsocks and run svc_xprt_destroy_all() on it by the time the
+ * name fails.
+ */
+TEST_F(nfsd_listener, val_reject_keeps_listeners)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char good[64], bad[64];
+	int og = put_listener(good, 0, "tcp", TEST_PORT);
+	int ob = put_listener(bad, 0, "bogus_xprt", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(good, og));
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+
+	EXPECT_EQ(-EPROTONOSUPPORT, listener_set(bad, ob));
+
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET, TEST_PORT));
+}
+
+/* ===================== functional / round-trip ===================== */
+
 /* LISTENER_GET with no serv in this netns returns an empty list. */
 TEST_F(nfsd_listener, func_get_empty)
 {
@@ -485,4 +761,160 @@ TEST_F(nfsd_listener, func_get_empty)
 	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
 }
 
+TEST_F(nfsd_listener, func_create_tcp)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(attrs, off));
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET, TEST_PORT));
+	EXPECT_EQ(htonl(INADDR_LOOPBACK), got[0].a4.s_addr);
+}
+
+TEST_F(nfsd_listener, func_create_udp)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "udp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(attrs, off));
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "udp", AF_INET, TEST_PORT));
+}
+
+TEST_F(nfsd_listener, func_create_multi)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[128];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	off = put_listener(attrs, off, "udp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(attrs, off));
+	ASSERT_EQ(2, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 2, "tcp", AF_INET, TEST_PORT));
+	EXPECT_NE(NULL, find_listener(got, 2, "udp", AF_INET, TEST_PORT));
+}
+
+TEST_F(nfsd_listener, func_idempotent)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(attrs, off));
+	EXPECT_EQ(0, listener_set(attrs, off));		/* re-set same list */
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET, TEST_PORT));
+}
+
+TEST_F(nfsd_listener, func_add)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char one[64], two[128];
+	int o1 = put_listener(one, 0, "tcp", TEST_PORT);
+	int o2 = put_listener(two, 0, "tcp", TEST_PORT);
+
+	o2 = put_listener(two, o2, "udp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(one, o1));
+	ASSERT_EQ(0, listener_set(two, o2));		/* add udp, keep tcp */
+	ASSERT_EQ(2, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 2, "tcp", AF_INET, TEST_PORT));
+	EXPECT_NE(NULL, find_listener(got, 2, "udp", AF_INET, TEST_PORT));
+}
+
+TEST_F(nfsd_listener, func_remove_subset)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char both[128], one[64];
+	int ob = put_listener(both, 0, "tcp", TEST_PORT);
+	int oo = put_listener(one, 0, "tcp", TEST_PORT);
+
+	ob = put_listener(both, ob, "udp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(both, ob));
+	ASSERT_EQ(0, listener_set(one, oo));		/* drop udp */
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET, TEST_PORT));
+}
+
+TEST_F(nfsd_listener, func_empty_destroys)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(attrs, off));
+	EXPECT_EQ(0, listener_set(NULL, 0));		/* empty -> destroy serv */
+	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
+}
+
+TEST_F(nfsd_listener, func_ipv6)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off, s;
+
+	s = socket(AF_INET6, SOCK_STREAM, 0);
+	if (s < 0)
+		SKIP(return, "IPv6 unavailable: %s", strerror(errno));
+	close(s);
+
+	off = put_listener_af(attrs, 0, "tcp", AF_INET6, TEST_PORT);
+	ASSERT_EQ(0, listener_set(attrs, off));
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET6, TEST_PORT));
+	EXPECT_EQ(0, memcmp(&got[0].a6, &in6addr_loopback, sizeof(in6addr_loopback)));
+}
+
+/* ===================== rpcbind registration ===================== */
+
+/*
+ * A rpcbind that refuses the registration must fail listener creation,
+ * whatever CONFIG_NFS_LOCALIO is set to.
+ *
+ * The error has to survive svc_register()'s walk over sv_programs to get
+ * here. With CONFIG_NFS_LOCALIO=y the trailing nfslocalio program has only
+ * a NULL and a vs_hidden version, and svc_generic_rpcbind_set() reports 0
+ * for both, so an svc_register() that keeps the last result rather than the
+ * first hands back success and the listener comes up regardless.
+ */
+TEST_F(nfsd_listener, sem_register_refused)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, rpcb_stub_restart(&self->rpcbd, RPCB_STUB_REFUSE));
+
+	EXPECT_EQ(-EACCES, listener_set(attrs, off));
+	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
+}
+
+/* ===================== threads / -EBUSY semantics ===================== */
+
+TEST_F(nfsd_listener, sem_busy_on_change)
+{
+	char one[64], two[128];
+	int o1 = put_listener(one, 0, "tcp", TEST_PORT);
+	int o2 = put_listener(two, 0, "tcp", TEST_PORT);
+
+	o2 = put_listener(two, o2, "udp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(one, o1));
+	ASSERT_EQ(0, threads_set(1));			/* threads now running */
+	EXPECT_EQ(-EBUSY, listener_set(two, o2));	/* add refused */
+	threads_set(0);					/* stop before netns exit */
+}
+
+TEST_F(nfsd_listener, sem_busy_on_remove)
+{
+	char one[64];
+	int o1 = put_listener(one, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(one, o1));
+	ASSERT_EQ(0, threads_set(1));
+	EXPECT_EQ(-EBUSY, listener_set(NULL, 0));	/* remove refused */
+	threads_set(0);
+}
+
 TEST_HARNESS_MAIN

-- 
2.55.0

