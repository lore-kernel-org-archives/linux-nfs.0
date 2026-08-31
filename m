Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 959DE5519B9;
	Mon, 31 Aug 2026 16:15:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192959; cv=none; b=Q3b/OMA6PqC7+vXvFBzohpJl1BcvlOAF7sR5L1HVPQVnwDE/VcTQJ5cviWy6bbbEYHXwufa35GxNxxttxFetjqxeNIV0KYW/YrTxQNOAnBdbgZTi/uw2Qy4RQtSYX5IJV8hTcpe7PG8NA0eOk5Ldbu7X7G3gQ7vcMvsI3k8SYA8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192959; c=relaxed/simple;
	bh=th48vMrVvf58O7nk4N1WnDhM2y9ibVFDXAp4BTCNaHc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=lN2pIoF1W0XL+Ov2xj7IEka1xprPcGNj9CudQ07g3YFzJ1WUdERv14u3icthOW45QUHf2goIFNbW8pzPLA8PSQxGNyFgSaY1Ya1sRPYEhthBZsVEik1F8M6EZ5qOKUwYMtTHXLTPTFfAMHhpc7Eznk+N1Z6Ijla3SEPtVotMPx0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Z9JZJSLj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Z9JZJSLj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F009F1F00A3D;
	Mon, 31 Aug 2026 16:15:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192957;
	bh=0wHkz9gKCDlM8SccDujfwP2D/PQWOv/mcr4bCZIAihY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Z9JZJSLjStkkLcjn7Tu5vJ75wyXtaz2bWRkEAYQs6U6doI3vpP7yry9/RrQ97jlhr
	 05X+gMY3soj3dCW56NNetxYUP/NPyXjBhMOz+eMMgjrVqhwBlTgQEI5nh3HgHPv7mf
	 hXRDQwTlnCLURMTMTlOQ07mrcYgYoxGtQMO+zMLBaIeVo3qK3TdRbnhWxJ7dtAyNkj
	 So5M2l0KqcPsPMRBB5inX+GjYzc+oopbXvhIJy6Imf+qaCayWWfyNjcKJkmuYbmm3W
	 hT12vTgm/fEGwaULx7I2340fPLLElxs3sJJrKk4kPkiM/MG4vg56AiVMSahWQBA0ff
	 j8MjfyLWGAEfA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:54 -0400
Subject: [PATCH v4 12/14] selftests/nfsd: add a per-netns rpcbind stub and
 the listener round-trips
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-12-0f4e89139409@kernel.org>
References: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
In-Reply-To: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=30213; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=th48vMrVvf58O7nk4N1WnDhM2y9ibVFDXAp4BTCNaHc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlailVLT8xklkF8MTH5K/17mMmY4OHevDaiKHp
 wUu0TUXtuOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWopQAKCRAADmhBGVaC
 FeQnEADH0anGgFIxEQOX4lrCU7R+TjChpWEYTLj8Y/n/eZiTW+rbxgHAJKn2h5BmVwSImFpj0CA
 MHkcVIKFfnM6HFaV85H3i4NspNsHSUCjaCOtmkjWwIJNWE3QJhpeteiQWGCuUIgITG9f9V0HDDU
 zasvRon1jS96C4ymQACgZoKphTeGCsE95DAvLTw0qlmc3WxbQhS2FJx7/9xsjxTxhAz3fzFWQsw
 3qdfdaIPMscJLvd/ydoa58boMdbEuCg3sCFfhD8GazaCyUI5W00XEnkhcPNu9xxsjD8+18njJjR
 QJp/ZMfZYRl9skS+OV/ZYtH2qFcSaluEz1t3kPAcRi/8oOUAIc0y8P7/EqDQ8lNI7KqoqgG7yhs
 RpeMNo9rismsWCZ6oHuP/+DBngnNeZHZYbzV86Eadr+dTh6pPrwMChvHYSGo94a2N299ZUU/aX6
 lBusIRYmcruu8gjrcfMoDRTCiDoV5HjwG+MUj5jIBameNATHZVap6/edGJQriMQ9HcL7QjpJ16u
 zRBODST5DIPH4aXi4tqgVFjEeTiE///CX/L2fE85IuO/o1lSrZyJ2phYI7TcI/N0SixTKxRIi8d
 DKRQ7CQq6BFpj22PrfOuJ1z0WzuiBoNn/I2uLnNdNBka91qgFSkSzKrkmijsLQjVxs6p0UYOaAQ
 f7j1uzAZx1kwRhw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The creation of a listener registers with rpcbind.
svc_xprt_create_from_sa() passes flags of 0, so pmap_register is true in
svc_setup_socket(). A fresh netns has no rpcbind. Every registration
therefore waits out the local rpcbind timeout, once for each program and
version, and the registration failure then takes the listener down. The
host's rpcbind is not an option either. svc_rpcb_setup() opens with a call
to svc_unregister(), which would clear the host's nfsd entries.

Serve rpcbind from inside the namespace instead. The abstract AF_LOCAL
name that the kernel tries first is per-netns, because
unix_find_abstract() takes a struct net. Bind "\0/run/rpcbind.sock" and
fork a minimal responder:

- the responder never decodes arguments. The NULL procedure gets an empty
  success, and SET and UNSET get TRUE.
- the responder answers RPCBVERS_4 as well as RPCBVERS_2. A v4 refusal
  makes __svc_rpcb_register6() return -EAFNOSUPPORT, which would leave
  every IPv6 listener unregistered.
- the responder counts accepted connections and received calls in a page
  that it shares with the test, and reads its mode from that page on every
  call. The mode lives there rather than in the child so that a test can
  change it with a serv already up: killing and restarting the stub would
  close the connection the kernel holds, and rpcb_register_call() issues
  UNSET over AF_LOCAL with RPC_TASK_NOCONNECT, so the next call would fail
  at once with -ENOTCONN instead of waiting out a timeout.
- PR_SET_PDEATHSIG plus an explicit kill in FIXTURE_TEARDOWN make sure that
  no stub outlives its test.

With the stub in place, add the tests that need a serv. These cover the
create, add and remove paths and the LISTENER_GET round trips: tcp, udp,
several listeners at once, an idempotent re-set, the removal of a subset,
the destruction of a serv from an empty list, and IPv6. Two more tests
cover the empty-list request and the -EBUSY refusal after THREADS_SET has
started threads.

The netlink socket asks for NETLINK_EXT_ACK, so that the tests can read the
extack message. It also asks for NETLINK_CAP_ACK, so that the kernel does
not echo the request back and the TLVs sit at a fixed offset.

FIXTURE_TEARDOWN drops whatever a test left running. A listener holds a
reference to the netns, and that netns outlives the test process. Threads
pin the listeners. Anything left up therefore leaks the namespace.

Several of these tests exist to catch a revert, not to describe the
interface. The errno alone shows none of them:

- val_reject_keeps_listeners. An unknown transport name ends in
  -EPROTONOSUPPORT either way, because svc_xprt_create_from_sa() returns
  that error too. The difference is the state that it leaves. Without the
  up-front check, nfsd_nl_listener_set_doit() has already destroyed the
  listeners that did not match by the time the name fails.
- val_bad_transport. This test now also requires that the stub saw no
  traffic. A request that reaches svc_xprt_create_from_sa() has run
  nfsd_create_serv(). svc_bind() then pings rpcbind at client creation and
  sweeps stale entries with svc_unregister(). Silence at the stub is
  therefore what shows that the kernel refused the request up front.
- val_second_entry_bad. This test now also sends a LISTENER_GET.
  svc_xprt_create_from_sa() also returns -EAFNOSUPPORT for the bad entry,
  and the doit keeps the listeners that it did create. The well-formed tcp
  entry ahead of it would otherwise still be up.
- sem_register_refused. This test puts the stub in a mode that answers
  RPCBPROC_SET with FALSE. rpcb_register_call() turns that answer into
  -EACCES, svc_register() then fails, and svc_setup_socket() creates no
  listener. The bare errno does not show that, because a bind can return
  -EACCES too, so the test reads the listener set back and requires that
  it is empty.
- sem_create_failure_extack. This test squats on the port first, so the
  listener cannot bind. The extack must then name the transport that
  failed.
- func_empty_destroys. This test uses the connection count. LISTENER_GET
  replies empty both for a destroyed serv and for a live serv with no
  permsocks. But only nfsd_destroy_serv() reaches
  svc_xprt_destroy_all(..., unregister=true) -> svc_rpcb_cleanup() ->
  rpcb_put_local(), which drops the last user and shuts the local client
  down. The next serv has to connect again.
- sem_busy_on_change and sem_busy_on_remove read the listeners back,
  because -EBUSY says nothing about what the doit did before it returned.

find_listener() matches the address as well as the transport, the family
and the port. Every listener here is created on loopback, so a reply that
names 0.0.0.0 has to fail.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 637 ++++++++++++++++++++-
 1 file changed, 627 insertions(+), 10 deletions(-)

diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index ae28c224255f..99c320e2f7c2 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -3,30 +3,41 @@
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
+#include <sys/mman.h>
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
@@ -36,8 +47,10 @@
 
 /* NFSD generic-netlink constants (from linux/nfsd_netlink.h). */
 #define NFSD_FAMILY_NAME		"nfsd"
+#define NFSD_CMD_THREADS_SET		2
 #define NFSD_CMD_LISTENER_SET		6
 #define NFSD_CMD_LISTENER_GET		7
+#define NFSD_A_SERVER_THREADS		1
 #define NFSD_A_SERVER_SOCK_ADDR		1	/* per-listener nest */
 #define NFSD_A_SOCK_ADDR		1	/* inside the nest */
 #define NFSD_A_SOCK_TRANSPORT_NAME	2	/* inside the nest */
@@ -47,7 +60,10 @@
 #define MAX_LISTENERS			8
 #define RECV_TIMEO_SEC			30
 
-static int nfsd_family;			/* set per-test in FIXTURE_SETUP */
+static int nfsd_family = -1;		/* set per-test in FIXTURE_SETUP */
+
+/* Extack message from the last genl_request(); empty if there was none. */
+static char last_extack[128];
 
 static void die(const char *msg)
 {
@@ -62,15 +78,50 @@ static int genl_open(void)
 	struct sockaddr_nl sa = { .nl_family = AF_NETLINK };
 	struct timeval tv = { .tv_sec = RECV_TIMEO_SEC };
 	int fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
+	int on = 1;
 
 	if (fd < 0)
 		die("socket(NETLINK_GENERIC)");
 	if (bind(fd, (void *)&sa, sizeof(sa)) < 0)
 		die("bind(netlink)");
 	setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
+	/*
+	 * Ask for extack, and cap the ack so the request is not echoed back:
+	 * the TLVs then always follow the fixed part of the error message.
+	 */
+	setsockopt(fd, SOL_NETLINK, NETLINK_EXT_ACK, &on, sizeof(on));
+	setsockopt(fd, SOL_NETLINK, NETLINK_CAP_ACK, &on, sizeof(on));
 	return fd;
 }
 
+/* Stash the extack message of an ack, if it carries one. */
+static void parse_extack(const char *rbuf)
+{
+	const struct nlmsghdr *nlh = (const void *)rbuf;
+	const struct nlattr *na;
+	int off, left;
+
+	last_extack[0] = '\0';
+	if (nlh->nlmsg_type != NLMSG_ERROR ||
+	    !(nlh->nlmsg_flags & NLM_F_ACK_TLVS))
+		return;
+
+	off = NLMSG_HDRLEN + NLMSG_ALIGN(sizeof(struct nlmsgerr));
+	left = nlh->nlmsg_len - off;
+	na = (const void *)(rbuf + off);
+
+	while (left >= (int)NLA_HDRLEN) {
+		if ((na->nla_type & NLA_TYPE_MASK) == NLMSGERR_ATTR_MSG) {
+			strncpy(last_extack, (const char *)na + NLA_HDRLEN,
+				sizeof(last_extack) - 1);
+			last_extack[sizeof(last_extack) - 1] = '\0';
+			return;
+		}
+		left -= NLA_ALIGN4(na->nla_len);
+		na = (const void *)((const char *)na + NLA_ALIGN4(na->nla_len));
+	}
+}
+
 /* Append an attribute at @off; return the new (aligned) offset. */
 static int put_attr(char *buf, int off, uint16_t type,
 		    const void *data, int len)
@@ -117,13 +168,16 @@ static int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
 	if (send(fd, buf, off, 0) < 0)
 		die("send(genl)");
 
+	last_extack[0] = '\0';
 	n = recv(fd, rbuf, sizeof(rbuf), 0);
-	if (n < 0)
+	if (n < 0) {
 		ret = (errno == EAGAIN || errno == EWOULDBLOCK) ? -ETIMEDOUT : -errno;
-	else if (((struct nlmsghdr *)rbuf)->nlmsg_type == NLMSG_ERROR)
+	} else if (((struct nlmsghdr *)rbuf)->nlmsg_type == NLMSG_ERROR) {
 		ret = ((struct nlmsgerr *)NLMSG_DATA(rbuf))->error;
-	else
+		parse_extack(rbuf);
+	} else {
 		ret = 0;
+	}
 	close(fd);
 	return ret;
 }
@@ -327,10 +381,296 @@ static int listener_get(struct listener_ent *out, int max)
 	return parse_listener_get(rbuf, n, out, max);
 }
 
+/*
+ * Every listener these tests create comes from put_listener_af(), so the
+ * address is always loopback. Match on it too: without that, a reply that
+ * gave the right transport and port on the wrong address (0.0.0.0, say)
+ * would pass.
+ */
+static struct listener_ent *find_listener(struct listener_ent *e, int n,
+					  const char *xprt, int family,
+					  uint16_t port)
+{
+	int i;
+
+	for (i = 0; i < n; i++) {
+		if (e[i].family != family || e[i].port != port ||
+		    strcmp(e[i].xprt, xprt))
+			continue;
+		if (family == AF_INET6) {
+			if (memcmp(&e[i].a6, &in6addr_loopback, sizeof(e[i].a6)))
+				continue;
+		} else if (e[i].a4.s_addr != htonl(INADDR_LOOPBACK)) {
+			continue;
+		}
+		return &e[i];
+	}
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
+ * Creating a listener registers with rpcbind: nfsd_nl_listener_set_doit()
+ * passes no SVC_SOCK_ANONYMOUS for the first entry of a request, so
+ * pmap_register is true in svc_setup_socket(). The fixture's server has v3
+ * enabled, and nfsd_version3 does not set vs_rpcb_optnl, so a failure there
+ * comes back out of svc_register() and takes the listener down with it.
+ * With nothing listening, every attempt first waits out the local rpcbind
+ * timeout. The abstract AF_LOCAL name the kernel tries first is per-netns
+ * (unix_find_abstract() takes a struct net), so answer it here and stay out
+ * of the host's rpcbind.
+ *
+ * Arguments are never decoded. The NULL procedure gets an empty success and
+ * SET/UNSET get TRUE, for both RPCBVERS_2 and RPCBVERS_4. v4 has to be
+ * answered because __svc_rpcb_register6() turns a v4 refusal into
+ * -EAFNOSUPPORT, which would leave every IPv6 listener unregistered.
+ *
+ * In RPCB_STUB_REFUSE mode SET is answered FALSE instead, which
+ * rpcb_register_call() reports as -EACCES. UNSET is left alone: only
+ * svc_unregister() issues it, and it discards the result.
+ *
+ * The stub also keeps counters and the mode in a page shared with the test, so
+ * a test can assert that the kernel never talked to rpcbind at all, or that it
+ * dropped the local rpcbind client and had to reconnect.
+ *
+ * The mode lives there rather than in the child so that a test can change it
+ * with a serv already up. Killing and restarting the stub would close the
+ * connection the kernel holds, and rpcb_register_call() issues UNSET over
+ * AF_LOCAL with RPC_TASK_NOCONNECT, so the next call would fail at once with
+ * -ENOTCONN instead of waiting out a timeout.
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
+struct rpcb_stub_stats {
+	unsigned int conns;		/* connections accepted */
+	unsigned int calls;		/* calls received */
+	unsigned int mode;		/* RPCB_STUB_*, read on every call */
+};
+
+static volatile struct rpcb_stub_stats *rpcb_stats;	/* MAP_SHARED */
+
+static int rpcb_stats_alloc(void)
+{
+	void *p = mmap(NULL, sizeof(*rpcb_stats), PROT_READ | PROT_WRITE,
+		       MAP_SHARED | MAP_ANONYMOUS, -1, 0);
+
+	if (p == MAP_FAILED)
+		return -1;
+	rpcb_stats = p;
+	return 0;
+}
+
+/*
+ * The stub bumps these before it replies and the kernel waits for that reply,
+ * so whatever a netlink request provoked is visible once it returns.
+ */
+static int rpcb_calls(void)
+{
+	return rpcb_stats ? (int)rpcb_stats->calls : 0;
+}
+
+static int rpcb_conns(void)
+{
+	return rpcb_stats ? (int)rpcb_stats->conns : 0;
+}
+
+/* Takes effect on the stub's next call; the caller has not sent one yet. */
+static void rpcb_stub_set_mode(int mode)
+{
+	rpcb_stats->mode = mode;
+}
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
+static int rpcb_stub_call(int fd)
+{
+	unsigned int len, nrep = 6, mode = rpcb_stats->mode;
+	uint32_t mark, call[6], rep[7];
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
+	if (rpcb_stats)
+		rpcb_stats->calls++;
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
+static void rpcb_stub_serve(int lfd)
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
+				/*
+				 * poll() ran with the old n, so it did not
+				 * write this revents. The loop below reads it.
+				 */
+				pfd[n].revents = 0;
+				n++;
+				if (rpcb_stats)
+					rpcb_stats->conns++;
+			}
+		}
+
+		for (i = 1; i < n; i++) {
+			if (!(pfd[i].revents & (POLLIN | POLLHUP | POLLERR)))
+				continue;
+			if (rpcb_stub_call(pfd[i].fd)) {
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
+	rpcb_stats->mode = mode;
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
+		rpcb_stub_serve(lfd);
+		_exit(0);
+	}
+
+	close(lfd);
+	return pid;
+}
+
 /* --------------------------- fixture --------------------------- */
 
 FIXTURE(nfsd_listener) {
-	int placeholder;
+	pid_t rpcbd;
 };
 
 FIXTURE_SETUP(nfsd_listener)
@@ -369,14 +709,43 @@ FIXTURE_SETUP(nfsd_listener)
 	nfsd_family = genl_resolve_nfsd();
 	if (nfsd_family < 0)
 		SKIP(return, "nfsd genl family not found (modprobe nfsd?)");
+
+	if (rpcb_stats_alloc() < 0)
+		SKIP(return, "mmap(rpcbind stub counters): %s", strerror(errno));
+
+	self->rpcbd = rpcb_stub_start(RPCB_STUB_ACCEPT);
+	if (self->rpcbd < 0)
+		SKIP(return, "cannot start the rpcbind stub: %s",
+		     strerror(errno));
 }
 
 FIXTURE_TEARDOWN(nfsd_listener)
 {
+	/*
+	 * A listener holds a reference to this netns, which outlives the test
+	 * process, so anything still up leaks it. Threads pin the listeners in
+	 * turn; dropping them destroys the serv and everything under it.
+	 */
+	if (nfsd_family >= 0 && listener_set(NULL, 0) == -EBUSY)
+		threads_set(0);
+
+	if (self->rpcbd > 0) {
+		kill(self->rpcbd, SIGKILL);
+		waitpid(self->rpcbd, NULL, 0);
+	}
+	if (rpcb_stats) {
+		munmap((void *)rpcb_stats, sizeof(*rpcb_stats));
+		rpcb_stats = NULL;
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
@@ -411,13 +780,21 @@ TEST_F(nfsd_listener, val_missing_transport)
  * A name matching no transport class must be refused before nfsd_mutex is
  * taken, so it never reaches svc_xprt_create_from_sa() and its
  * request_module("svc%s", name) upcall.
+ *
+ * The errno cannot show that -- svc_xprt_create_from_sa() returns
+ * -EPROTONOSUPPORT for an unknown name too. The rpcbind traffic can:
+ * getting that far means nfsd_create_serv() ran, and svc_bind() pings
+ * rpcbind at client creation and then sweeps stale entries with
+ * svc_unregister(). A silent stub is the proof nothing was created.
  */
 TEST_F(nfsd_listener, val_bad_transport)
 {
 	char attrs[64];
 	int off = put_listener(attrs, 0, "bogus_xprt", TEST_PORT);
 
+	ASSERT_EQ(0, rpcb_calls());
 	EXPECT_EQ(-EPROTONOSUPPORT, listener_set(attrs, off));
+	EXPECT_EQ(0, rpcb_calls());
 }
 
 TEST_F(nfsd_listener, val_addr_too_short)
@@ -469,14 +846,49 @@ TEST_F(nfsd_listener, val_second_entry_bad)
 	struct sockaddr_storage ss = { .ss_family = AF_UNIX };
 	struct raw_listener bad = { .xprt = "tcp", .emit_addr = 1, .addr = &ss,
 				    .addr_len = sizeof(struct sockaddr_in) };
+	struct listener_ent got[MAX_LISTENERS];
 	char attrs[128];
 	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
 
 	off = put_raw_listener(attrs, off, &bad);
 	/* The whole request is rejected during validation; nothing applied. */
 	EXPECT_EQ(-EAFNOSUPPORT, listener_set(attrs, off));
+	/*
+	 * Again the errno alone does not say so: svc_xprt_create_from_sa()
+	 * also returns -EAFNOSUPPORT, and the doit keeps the listeners it did
+	 * manage to create, so the well-formed tcp entry ahead of the bad one
+	 * would still be up.
+	 */
+	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
+}
+
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
 }
 
+/* ===================== functional / round-trip ===================== */
+
 /* LISTENER_GET with no serv in this netns returns an empty list. */
 TEST_F(nfsd_listener, func_get_empty)
 {
@@ -485,4 +897,209 @@ TEST_F(nfsd_listener, func_get_empty)
 	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
 }
 
+TEST_F(nfsd_listener, func_create_tcp)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(attrs, off));
+	EXPECT_STREQ("", last_extack);		/* nothing to warn about */
+	ASSERT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET, TEST_PORT));
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
+/*
+ * LISTENER_GET cannot tell a destroyed serv from a live one with no
+ * permsocks: nfsd_nl_listener_get_doit() replies empty either way. The
+ * rpcbind client can. nfsd_destroy_serv() is the only path that reaches
+ * svc_xprt_destroy_all(..., unregister=true) -> svc_rpcb_cleanup() ->
+ * rpcb_put_local(), which drops the last user and shuts the local client
+ * down; the next serv then has to connect again. Leaving the serv in place
+ * would keep the first connection and the stub would see just the one.
+ */
+TEST_F(nfsd_listener, func_empty_destroys)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	int conns;
+
+	ASSERT_EQ(0, listener_set(attrs, off));
+	conns = rpcb_conns();
+	ASSERT_GT(conns, 0);
+
+	EXPECT_EQ(0, listener_set(NULL, 0));		/* empty -> destroy serv */
+	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
+
+	ASSERT_EQ(0, listener_set(attrs, off));
+	EXPECT_GT(rpcb_conns(), conns);
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
+}
+
+/* ===================== rpcbind registration ===================== */
+
+/*
+ * A rpcbind that refuses the registration takes the listener down with it.
+ * svc_register() fails, so svc_setup_socket() fails, so no listener is
+ * created. -EACCES alone does not show that, since a bind can return it
+ * too, so read the listener set back as well.
+ */
+TEST_F(nfsd_listener, sem_register_refused)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	rpcb_stub_set_mode(RPCB_STUB_REFUSE);
+
+	EXPECT_EQ(-EACCES, listener_set(attrs, off));
+	EXPECT_STRNE("", last_extack);
+	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
+}
+
+/*
+ * A listener that cannot be created reports which one it was: the errno
+ * alone does not name the entry in a multi-listener request.
+ */
+TEST_F(nfsd_listener, sem_create_failure_extack)
+{
+	struct sockaddr_in s4 = { .sin_family = AF_INET,
+				  .sin_port = htons(TEST_PORT),
+				  .sin_addr.s_addr = htonl(INADDR_LOOPBACK) };
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	int s;
+
+	/* squat on the port so the listener cannot bind */
+	s = socket(AF_INET, SOCK_STREAM, 0);
+	ASSERT_GE(s, 0);
+	ASSERT_EQ(0, bind(s, (struct sockaddr *)&s4, sizeof(s4)));
+
+	EXPECT_EQ(-EADDRINUSE, listener_set(attrs, off));
+	EXPECT_STRNE("", last_extack);
+	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
+	close(s);
+}
+
+/* ===================== threads / -EBUSY semantics ===================== */
+
+TEST_F(nfsd_listener, sem_busy_on_change)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char one[64], two[128];
+	int o1 = put_listener(one, 0, "tcp", TEST_PORT);
+	int o2 = put_listener(two, 0, "tcp", TEST_PORT);
+
+	o2 = put_listener(two, o2, "udp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(one, o1));
+	ASSERT_EQ(0, threads_set(1));			/* threads now running */
+	EXPECT_EQ(-EBUSY, listener_set(two, o2));	/* add refused */
+
+	/* refused means refused: the udp listener must not have been added */
+	EXPECT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET, TEST_PORT));
+
+	threads_set(0);					/* stop before netns exit */
+}
+
+TEST_F(nfsd_listener, sem_busy_on_remove)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char one[64];
+	int o1 = put_listener(one, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(one, o1));
+	ASSERT_EQ(0, threads_set(1));
+	EXPECT_EQ(-EBUSY, listener_set(NULL, 0));	/* remove refused */
+
+	/* the doit moves the permsocks to a temp list before it can fail */
+	EXPECT_EQ(1, listener_get(got, MAX_LISTENERS));
+	EXPECT_NE(NULL, find_listener(got, 1, "tcp", AF_INET, TEST_PORT));
+
+	threads_set(0);
+}
+
 TEST_HARNESS_MAIN

-- 
2.55.0

