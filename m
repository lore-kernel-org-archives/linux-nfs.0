Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A040576EDE;
	Wed, 23 Sep 2026 15:31:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790177500; cv=none; b=RHfJN29I2biWabcMbDRUWjDx4jAexmPjtiZ1/7M8MUFkgL5892WeBbJC8sk2EGbE1JeZNJNfPlAp+uM6+L13oGhyeBhx3ljzTuUDYSnYgpRuVpwFWNUbu5pyaB1L0y2Xj8i7MVGiQ8oD6R5i8O5xx/a3Ep7PiEI8A0gz+zBPUc4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790177500; c=relaxed/simple;
	bh=VWrZKKlwBUQnZ9QTX6wG4EJJIKYHXgKdXCFAHPb3pXQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tqNJKSliIfGSfa/JOXJsKtq/SOlK45Jpk1eqPmO4ytTENcWtdP9BLW0d3rzEGWC8hVzOm7Tg1DtlGxc371Uv7lg3vQYnZYeZQPByFpjCkMRTma/LiIOfgzFQ7oMlv1f6c1rVq6m4Nnj34UvYTfKsgQ8CG0IDX17DpAaCuiVXjxU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hou00lb0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hou00lb0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D68091F00893;
	Wed, 23 Sep 2026 15:31:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790177490;
	bh=zTc3lm1AYN+GTVbO1s1iJUzBIv8AvfRJtePi+33sr5A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hou00lb0ahBxcJcY/0NLse9G5JvPyO8mw1wpSq9fN9ZwY7QH3q3lq+POhnDR1YFFm
	 fOej6kK2+E9A8Jc+cl1WfZjDrd4vTROItkUvmaxEQ2Ks+jX+fgWOkXtLLujtoiHB96
	 1iHR9f0rITjWJsxvdHXXcSkP2iDQgjL3xPxpno1GY0NV8hsHHMkSs52CKLyg77gpx2
	 PABlbOionCD0FlM1bG+Y2WCm8fKZ5MTzZuXAElewzjdtG0TUEYcRdeAjx467SPC+Pv
	 h+Hy0VIMW77P6HsXC8rVGBNIEbVrtTmx/18gJ/j5fWewgtGqcwY3waYy0kGBA+1QCM
	 wqCY1eKj67sxQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 23 Sep 2026 11:30:51 -0400
Subject: [PATCH v2 2/2] selftests/nfsd: add lockd netlink configuration
 tests
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260923-nfsd-testing-v2-2-bfba431122c8@kernel.org>
References: <20260923-nfsd-testing-v2-0-bfba431122c8@kernel.org>
In-Reply-To: <20260923-nfsd-testing-v2-0-bfba431122c8@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=15919; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=VWrZKKlwBUQnZ9QTX6wG4EJJIKYHXgKdXCFAHPb3pXQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs/DPkTQM8pIj+kcC+0gVkT1aomt8q6c09ikAF
 y6GNh6m6BOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarPwzwAKCRAADmhBGVaC
 FZ75D/9BS5RU8pzEx6EUqMA5QqipZlIhiFZJMBBUP7TQhrfCvWOZrHiyhf63kbMaXNGzmWeWA8F
 XjxBL3qBmVqllhBR8ViLM0oBwTzInQDXc9vsozeDe+jUDVf6KTqZc6edGl26fh0qA4vE5LjmghX
 d91i9Tmi25iaFQBGXnjP0MjV+9LoDfHiaZCprbvNyROqK/hdXahNRiE13Hguwd8nE2bPXaX91/c
 jByUVMGZaQKyh2SL3YpWvhO1guJ1vQziY8YZ0UqfjpSxdROqtf5ArxLZJU83nfKdKouzpYoXZJh
 5yxVAfub4FguBG1KEj/0FnWDGVhlHaWIbwD4de4eKJeFQMl7YKDzCbkpqbUT60Ukpa4E85VwcbP
 uALAvziKbG3jN8YQNVxf5ceXh5tOHAhY92pf4dv35lRsuu4p8239LQorWnuiLc+rNL5UuwoZt7g
 uqWQRt5fLq7rGgDeSnCjbCcoidHk4zCIzx2TS813KnGr9EUvqy3v8hMlovt6bwoUowSkrW/xhlC
 kvYeEVW7+abKD/Mr4+yBoEOOzsferB0iHxQNKjCxIfLwf2fgqEXFPxPKFXu1NiLp6BVLCKofhO3
 RnlrbscnganXbn4vSwpXSEKjsLQ0hrefI/cxXzmbXB4TlVSnWKQ2GWoRr5ZSi8hszIvUPAB+u6O
 9HcJ3unk1kpgOTw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Cover LOCKD_CMD_SERVER_SET / SERVER_GET, in particular that each of the
three attributes can be set on its own. Without the preceding fix, four
of the eight tests fail with EINVAL -- every one that omits the grace
time, which is what nfsdctl sends for a [lockd] port with no
grace-time.

Also pinned down here:
- an empty SERVER_SET is a no-op, not an error
- a gracetime over nlm_grace_period_max is still rejected, and the
  rejected request applies none of the ports it came with
- the settings are per-netns

Everything runs under unshare(CLONE_NEWNET): the values are per-netns,
and a SERVER_SET in init_net would overwrite the host's module-wide
nlm_grace_period/nlm_tcpport/nlm_udpport.

nfsd_netlink.h grows genl_resolve() and *_to() request helpers that take
a family id, so the plumbing can drive the lockd family too;
genl_resolve_nfsd() and the existing helpers are thin wrappers and the
other tests are unchanged.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 tools/testing/selftests/nfsd/.gitignore           |   1 +
 tools/testing/selftests/nfsd/Makefile             |   1 +
 tools/testing/selftests/nfsd/nfsd_lockd_netlink.c | 268 ++++++++++++++++++++++
 tools/testing/selftests/nfsd/nfsd_netlink.h       |  90 ++++++--
 4 files changed, 345 insertions(+), 15 deletions(-)

diff --git a/tools/testing/selftests/nfsd/.gitignore b/tools/testing/selftests/nfsd/.gitignore
index 2347491c634d..7ac844d0fd57 100644
--- a/tools/testing/selftests/nfsd/.gitignore
+++ b/tools/testing/selftests/nfsd/.gitignore
@@ -1,3 +1,4 @@
+nfsd_lockd_netlink
 nfsd_netlink_listener
 nfsd_netns_isolation
 nfsd_netns_stress
diff --git a/tools/testing/selftests/nfsd/Makefile b/tools/testing/selftests/nfsd/Makefile
index b29bf642c0ad..e74bb3424d45 100644
--- a/tools/testing/selftests/nfsd/Makefile
+++ b/tools/testing/selftests/nfsd/Makefile
@@ -2,6 +2,7 @@
 CFLAGS += $(KHDR_INCLUDES) -Wall
 
 TEST_GEN_PROGS := nfsd_netlink_listener
+TEST_GEN_PROGS += nfsd_lockd_netlink
 TEST_GEN_PROGS += nfsd_netns_isolation
 TEST_GEN_PROGS += nfsd_netns_stress
 
diff --git a/tools/testing/selftests/nfsd/nfsd_lockd_netlink.c b/tools/testing/selftests/nfsd/nfsd_lockd_netlink.c
new file mode 100644
index 000000000000..47a1dee5a1f5
--- /dev/null
+++ b/tools/testing/selftests/nfsd/nfsd_lockd_netlink.c
@@ -0,0 +1,268 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Regression tests for lockd's generic-netlink configuration interface
+ * (LOCKD_CMD_SERVER_SET / LOCKD_CMD_SERVER_GET).
+ *
+ * All three attributes are optional in the spec and each is applied on its
+ * own by the kernel, but SERVER_SET used to demand a grace time and reject
+ * anything else with -EINVAL. That made the tcp and udp ports unsettable by
+ * themselves, which is exactly what nfsdctl asks for when /etc/nfs.conf has
+ * a [lockd] port but no grace-time -- "nfsdctl autostart" then failed before
+ * it had configured anything.
+ *
+ * Every test runs in a private network namespace. The settings are per-netns,
+ * and a SERVER_SET in init_net would also overwrite the host's module-wide
+ * nlm_grace_period/nlm_tcpport/nlm_udpport.
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <sched.h>
+#include <stdint.h>
+#include <string.h>
+#include <unistd.h>
+#include <linux/lockd_netlink.h>
+
+#include "../kselftest_harness.h"
+#include "nfsd_netlink.h"
+
+/* fs/lockd/svc.c: nlm_grace_period_max */
+#define GRACE_MAX		240
+
+#define TEST_TCP_PORT		32531
+#define TEST_UDP_PORT		32532
+
+struct lockd_cfg {
+	uint32_t gracetime;
+	uint16_t tcp_port;
+	uint16_t udp_port;
+};
+
+static int lockd_family = -1;
+
+static int lockd_set(const char *attrs, int len)
+{
+	return genl_request_to(lockd_family, LOCKD_CMD_SERVER_SET, attrs, len);
+}
+
+static int lockd_get(struct lockd_cfg *cfg)
+{
+	const struct nlattr *grace, *tcp, *udp;
+	char rbuf[4096];
+	int n;
+
+	n = genl_request_reply_attrs_to(lockd_family, LOCKD_CMD_SERVER_GET,
+					NULL, 0, rbuf, sizeof(rbuf));
+	if (n < 0)
+		return n;
+
+	grace = genl_find_attr(rbuf, n, LOCKD_A_SERVER_GRACETIME);
+	tcp = genl_find_attr(rbuf, n, LOCKD_A_SERVER_TCP_PORT);
+	udp = genl_find_attr(rbuf, n, LOCKD_A_SERVER_UDP_PORT);
+	if (!grace || !tcp || !udp)
+		return -ENOENT;
+
+	cfg->gracetime = nla_u32(grace);
+	cfg->tcp_port = nla_u16(tcp);
+	cfg->udp_port = nla_u16(udp);
+	return 0;
+}
+
+/* ------------------- SERVER_SET request builders ------------------- */
+
+static int put_gracetime(char *buf, int off, uint32_t grace)
+{
+	return put_attr(buf, off, LOCKD_A_SERVER_GRACETIME, &grace,
+			sizeof(grace));
+}
+
+static int put_tcp_port(char *buf, int off, uint16_t tcp)
+{
+	return put_attr(buf, off, LOCKD_A_SERVER_TCP_PORT, &tcp, sizeof(tcp));
+}
+
+static int put_udp_port(char *buf, int off, uint16_t udp)
+{
+	return put_attr(buf, off, LOCKD_A_SERVER_UDP_PORT, &udp, sizeof(udp));
+}
+
+static int put_ports(char *buf, int off, uint16_t tcp, uint16_t udp)
+{
+	off = put_tcp_port(buf, off, tcp);
+	return put_udp_port(buf, off, udp);
+}
+
+FIXTURE(lockd_netlink) {
+};
+
+FIXTURE_SETUP(lockd_netlink)
+{
+	if (geteuid() != 0)
+		SKIP(return, "must be run as root");
+	if (unshare(CLONE_NEWNET) < 0)
+		SKIP(return, "unshare(NEWNET): %s", strerror(errno));
+
+	lockd_family = genl_resolve(LOCKD_FAMILY_NAME, sizeof(LOCKD_FAMILY_NAME));
+	if (lockd_family < 0)
+		SKIP(return, "lockd netlink family not registered");
+}
+
+FIXTURE_TEARDOWN(lockd_netlink)
+{
+	/* Nothing to undo: the settings die with the namespace. */
+}
+
+/* A fresh namespace starts out with everything at zero. */
+TEST_F(lockd_netlink, defaults_are_zero)
+{
+	struct lockd_cfg cfg;
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(0, cfg.gracetime);
+	EXPECT_EQ(0, cfg.tcp_port);
+	EXPECT_EQ(0, cfg.udp_port);
+}
+
+/*
+ * The regression: ports on their own, no grace time. This is the request
+ * nfsdctl builds from a [lockd] section that only sets the ports.
+ */
+TEST_F(lockd_netlink, set_ports_without_gracetime)
+{
+	struct lockd_cfg cfg;
+	char attrs[64];
+	int off;
+
+	off = put_ports(attrs, 0, TEST_TCP_PORT, TEST_UDP_PORT);
+
+	ASSERT_EQ(0, lockd_set(attrs, off))
+		TH_LOG("SERVER_SET rejected a request with no gracetime");
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(TEST_TCP_PORT, cfg.tcp_port);
+	EXPECT_EQ(TEST_UDP_PORT, cfg.udp_port);
+	EXPECT_EQ(0, cfg.gracetime);
+}
+
+/* The mirror image: a grace time with no ports. */
+TEST_F(lockd_netlink, set_gracetime_without_ports)
+{
+	struct lockd_cfg cfg;
+	char attrs[64];
+	int off;
+
+	off = put_gracetime(attrs, 0, 90);
+
+	ASSERT_EQ(0, lockd_set(attrs, off));
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(90, cfg.gracetime);
+	EXPECT_EQ(0, cfg.tcp_port);
+	EXPECT_EQ(0, cfg.udp_port);
+}
+
+/* One attribute at a time leaves the others alone. */
+TEST_F(lockd_netlink, attributes_are_set_independently)
+{
+	struct lockd_cfg cfg;
+	char attrs[64];
+	int off;
+
+	off = put_tcp_port(attrs, 0, TEST_TCP_PORT);
+	ASSERT_EQ(0, lockd_set(attrs, off));
+
+	off = put_udp_port(attrs, 0, TEST_UDP_PORT);
+	ASSERT_EQ(0, lockd_set(attrs, off))
+		TH_LOG("SERVER_SET rejected a UDP-only request");
+
+	off = put_gracetime(attrs, 0, 30);
+	ASSERT_EQ(0, lockd_set(attrs, off));
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(30, cfg.gracetime);
+	EXPECT_EQ(TEST_TCP_PORT, cfg.tcp_port)
+		TH_LOG("a later SET clobbered the tcp port");
+	EXPECT_EQ(TEST_UDP_PORT, cfg.udp_port)
+		TH_LOG("a gracetime-only SET clobbered the udp port");
+}
+
+TEST_F(lockd_netlink, set_all_three)
+{
+	struct lockd_cfg cfg;
+	char attrs[64];
+	int off;
+
+	off = put_gracetime(attrs, 0, GRACE_MAX);
+	off = put_ports(attrs, off, TEST_TCP_PORT, TEST_UDP_PORT);
+
+	ASSERT_EQ(0, lockd_set(attrs, off));
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(GRACE_MAX, cfg.gracetime);
+	EXPECT_EQ(TEST_TCP_PORT, cfg.tcp_port);
+	EXPECT_EQ(TEST_UDP_PORT, cfg.udp_port);
+}
+
+/* An empty SERVER_SET has nothing to do, but is not an error. */
+TEST_F(lockd_netlink, empty_set_is_a_noop)
+{
+	struct lockd_cfg cfg;
+	char attrs[64];
+	int off;
+
+	off = put_gracetime(attrs, 0, 30);
+	off = put_ports(attrs, off, TEST_TCP_PORT, TEST_UDP_PORT);
+	ASSERT_EQ(0, lockd_set(attrs, off));
+
+	ASSERT_EQ(0, lockd_set(NULL, 0));
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(30, cfg.gracetime);
+	EXPECT_EQ(TEST_TCP_PORT, cfg.tcp_port);
+	EXPECT_EQ(TEST_UDP_PORT, cfg.udp_port);
+}
+
+/*
+ * The grace time is still range-checked, and the check runs before anything
+ * is stored: a rejected request must not apply the ports it came with.
+ */
+TEST_F(lockd_netlink, gracetime_above_max_rejected)
+{
+	struct lockd_cfg cfg;
+	char attrs[64];
+	int off;
+
+	off = put_gracetime(attrs, 0, GRACE_MAX + 1);
+	off = put_ports(attrs, off, TEST_TCP_PORT, TEST_UDP_PORT);
+
+	EXPECT_EQ(-EINVAL, lockd_set(attrs, off));
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(0, cfg.gracetime);
+	EXPECT_EQ(0, cfg.tcp_port)
+		TH_LOG("a rejected SERVER_SET applied the tcp port anyway");
+	EXPECT_EQ(0, cfg.udp_port);
+}
+
+/* Settings belong to the namespace that made them. */
+TEST_F(lockd_netlink, settings_are_per_netns)
+{
+	struct lockd_cfg cfg;
+	char attrs[64];
+	int off;
+
+	off = put_gracetime(attrs, 0, 30);
+	off = put_ports(attrs, off, TEST_TCP_PORT, TEST_UDP_PORT);
+	ASSERT_EQ(0, lockd_set(attrs, off));
+
+	if (unshare(CLONE_NEWNET) < 0)
+		SKIP(return, "second unshare(NEWNET): %s", strerror(errno));
+
+	ASSERT_EQ(0, lockd_get(&cfg));
+	EXPECT_EQ(0, cfg.gracetime)
+		TH_LOG("grace time leaked out of the namespace that set it");
+	EXPECT_EQ(0, cfg.tcp_port)
+		TH_LOG("tcp port leaked out of the namespace that set it");
+	EXPECT_EQ(0, cfg.udp_port);
+}
+
+TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/nfsd/nfsd_netlink.h b/tools/testing/selftests/nfsd/nfsd_netlink.h
index c66a980bfc01..bb9327109e8f 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink.h
+++ b/tools/testing/selftests/nfsd/nfsd_netlink.h
@@ -4,7 +4,9 @@
  *
  * Header-only: every helper is static inline, so each test binary gets its
  * own copy and there is nothing extra to link. nfsd_family must be set by
- * calling genl_resolve_nfsd() before any of the request helpers are used.
+ * calling genl_resolve_nfsd() before any of the request helpers are used;
+ * the *_to() variants take a family id instead, for the other families in
+ * the NFS server stack.
  */
 #ifndef __SELFTESTS_NFSD_NETLINK_H__
 #define __SELFTESTS_NFSD_NETLINK_H__
@@ -100,6 +102,45 @@ static inline int put_attr(char *buf, int off, uint16_t type,
 	return off + NLA_ALIGN4(NLA_HDRLEN + len);
 }
 
+/* Payload accessors; the payload is only 4-byte aligned, so no direct load. */
+static inline uint32_t nla_u32(const struct nlattr *na)
+{
+	uint32_t v;
+
+	memcpy(&v, (const char *)na + NLA_HDRLEN, sizeof(v));
+	return v;
+}
+
+static inline uint16_t nla_u16(const struct nlattr *na)
+{
+	uint16_t v;
+
+	memcpy(&v, (const char *)na + NLA_HDRLEN, sizeof(v));
+	return v;
+}
+
+/* Find top-level attribute @type in a genl reply of @len bytes; NULL if absent. */
+static inline const struct nlattr *genl_find_attr(const char *rbuf, int len,
+						  uint16_t type)
+{
+	const struct nlmsghdr *nlh = (const void *)rbuf;
+	const struct nlattr *na;
+	int left;
+
+	if (len < (int)(NLMSG_HDRLEN + GENL_HDRLEN))
+		return NULL;
+	na = (const void *)(rbuf + NLMSG_HDRLEN + GENL_HDRLEN);
+	left = nlh->nlmsg_len - NLMSG_HDRLEN - GENL_HDRLEN;
+
+	while (left >= (int)NLA_HDRLEN) {
+		if ((na->nla_type & NLA_TYPE_MASK) == type)
+			return na;
+		left -= NLA_ALIGN4(na->nla_len);
+		na = (const void *)((const char *)na + NLA_ALIGN4(na->nla_len));
+	}
+	return NULL;
+}
+
 /* Build a genl message header into @buf; return the offset past it. */
 static inline int genl_hdr(char *buf, uint16_t type, uint16_t flags, uint8_t cmd)
 {
@@ -115,15 +156,16 @@ static inline int genl_hdr(char *buf, uint16_t type, uint16_t flags, uint8_t cmd
 	return NLMSG_HDRLEN + GENL_HDRLEN;
 }
 
-/* Send an nfsd command with an ACK; return the ACK errno (<= 0). */
-static inline int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
+/* Send a command to @family with an ACK; return the ACK errno (<= 0). */
+static inline int genl_request_to(uint16_t family, uint8_t cmd,
+				  const char *attrs, int attrs_len)
 {
 	char buf[1 << 20], rbuf[4096];
 	struct nlmsghdr *nlh = (void *)buf;
 	int fd = genl_open();
 	int off, n, ret;
 
-	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST | NLM_F_ACK, cmd);
+	off = genl_hdr(buf, family, NLM_F_REQUEST | NLM_F_ACK, cmd);
 	if (attrs_len) {
 		memcpy(buf + off, attrs, attrs_len);
 		off += attrs_len;
@@ -147,21 +189,27 @@ static inline int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
 	return ret;
 }
 
+static inline int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
+{
+	return genl_request_to(nfsd_family, cmd, attrs, attrs_len);
+}
+
 /*
- * Send a command with attributes and return the full reply message; -errno
- * on failure. NLM_F_ACK is left off: the kernel reports an error either way,
- * so the first message back is the reply whenever there is one.
+ * Send a command to @family with attributes and return the full reply
+ * message; -errno on failure. NLM_F_ACK is left off: the kernel reports an
+ * error either way, so the first message back is the reply whenever there
+ * is one.
  */
-static inline int genl_request_reply_attrs(uint8_t cmd, const char *attrs,
-					   int attrs_len, char *rbuf,
-					   size_t rlen)
+static inline int genl_request_reply_attrs_to(uint16_t family, uint8_t cmd,
+					      const char *attrs, int attrs_len,
+					      char *rbuf, size_t rlen)
 {
 	char buf[1 << 20];
 	struct nlmsghdr *nlh = (void *)buf;
 	int fd = genl_open();
 	int off, n, ret;
 
-	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST, cmd);
+	off = genl_hdr(buf, family, NLM_F_REQUEST, cmd);
 	if (attrs_len) {
 		memcpy(buf + off, attrs, attrs_len);
 		off += attrs_len;
@@ -182,13 +230,21 @@ static inline int genl_request_reply_attrs(uint8_t cmd, const char *attrs,
 	return ret;
 }
 
+static inline int genl_request_reply_attrs(uint8_t cmd, const char *attrs,
+					   int attrs_len, char *rbuf,
+					   size_t rlen)
+{
+	return genl_request_reply_attrs_to(nfsd_family, cmd, attrs, attrs_len,
+					   rbuf, rlen);
+}
+
 static inline int genl_request_reply(uint8_t cmd, char *rbuf, size_t rlen)
 {
 	return genl_request_reply_attrs(cmd, NULL, 0, rbuf, rlen);
 }
 
-/* Resolve the "nfsd" genl family id; -1 if not registered. */
-static inline int genl_resolve_nfsd(void)
+/* Resolve a genl family id by name; -1 if not registered. */
+static inline int genl_resolve(const char *name, size_t namelen)
 {
 	char buf[1024], rbuf[4096];
 	struct nlmsghdr *nlh = (void *)buf;
@@ -198,8 +254,7 @@ static inline int genl_resolve_nfsd(void)
 
 	fd = genl_open();
 	off = genl_hdr(buf, GENL_ID_CTRL, NLM_F_REQUEST, CTRL_CMD_GETFAMILY);
-	off = put_attr(buf, off, CTRL_ATTR_FAMILY_NAME,
-		       NFSD_FAMILY_NAME, sizeof(NFSD_FAMILY_NAME));
+	off = put_attr(buf, off, CTRL_ATTR_FAMILY_NAME, name, namelen);
 	nlh->nlmsg_len = off;
 
 	if (send(fd, buf, off, 0) < 0)
@@ -224,6 +279,11 @@ static inline int genl_resolve_nfsd(void)
 	return id;
 }
 
+static inline int genl_resolve_nfsd(void)
+{
+	return genl_resolve(NFSD_FAMILY_NAME, sizeof(NFSD_FAMILY_NAME));
+}
+
 /* ------------------- listener request builders ------------------- */
 
 /* Fine-grained control for negative tests: any field can be omitted/malformed. */

-- 
2.55.0

