Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D219A551995;
	Mon, 31 Aug 2026 16:15:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192957; cv=none; b=EHfLmD9caZJwqw58Mjd+goAsTuW76Z82rdYm8QBJVRd7s/n/iy5lA3zJ/4oDIIYe/hehDx1JDpI///6v3kUb/4fR1/m5dZepnSYgCyRHAOQXtxV8YJDPQoOVnTutTbqLOUBjbuHg3UQuASqfMlf/q4rEBjIMZKgyFol8JvO2OQY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192957; c=relaxed/simple;
	bh=qKb2bweuqy9GehslCZtN22n6bjX8AkfXkJJ9gCHcsS8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=thnl0X+CfO0KZGUVZqurB1xOpYZKM+fGlrF9CybUgbXdcd9zc47zOdEsUfR13uerlB1qUV7j2BW0OaRJg+w6twZsUhI7NDrx11cLgffGKwEiVNz9qWFPQMSzzVmhYWg/fSdYwGwP3zlAugf7km5f9WnPQDtHnhlMwuKo1UEZiv0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TEceLQR8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TEceLQR8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 493161F000E9;
	Mon, 31 Aug 2026 16:15:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192955;
	bh=Ww9aE1CgZAnMjvFIp83svlEAgt5oJyxEdaaWiGYit60=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TEceLQR81OWVT38JuxxYlL5sDNp14UZKh4LZI6C8cmTtq6FpNPHh3kh6YTWnGevVW
	 a7eAUdEqHhLcx8yZbexOfc9lOZEVbbx6aBynvxAApC1ssg5rl38ZO7WzjWlvZQrw+b
	 TZeRV8inchWSjtreS/6j4U+JrsuTw7ok+7dSKVjFCJTji69GiUHn7jP8eRjFiAOk4T
	 QGvcIpKQGWaWJ5TzKcdBMHjLSsv42OBvKN63FfFig9LsCLg8CSCOXWdmO2Yf4cGWJ9
	 isXNFtD8h5SMU58iKZXCtq6p6Mu2vlASKCmM6aK329EfUu2vv1CXjR0t3AdLvgWRcR
	 ya0bk6apdZZuA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:53 -0400
Subject: [PATCH v4 11/14] selftests/nfsd: exercise listener_set request
 validation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-11-0f4e89139409@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=19166; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=qKb2bweuqy9GehslCZtN22n6bjX8AkfXkJJ9gCHcsS8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaikY7NfdxLTdClAGfstCqosT/OcdqstrLAXk
 k36oMAE0SuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWopAAKCRAADmhBGVaC
 FQBQD/4kPrLwSU89GObFOK8/QdNOU3vIEvfMUrC/sOCROobfysrbkdMV1rNz8l0UwaAHFGK86VZ
 5dJ0/TOd81XnYSkWGM1VOrn8YZnFtIH81T73sO4IeeGBp31sX6IAF6yZqFQEZOg4RkngNRXseUu
 mYzviZfpxlFn/hAxxZckkycooWbLjSghivB+15JWh+Cm4R/pO5rqrNzb5+kBJQfcd88+Z+tkuSp
 0CY7gpHeCNEWKyDLnBfTrBnPPjij4VVx/UPHBX4eaWY3oif9+yGM2jtytXiUnl6P9V7ZYsMt2jt
 t6sORsOvwu7L+Oq0y1DKJdekXbmHSwNhDdFLC600+hK1THx+mv6woSE0LdVLKMcuex/I1Y3/mB/
 C2UwwtnxI0zSW5G/PlfuTuepCzplTBaUFLyPm3uCbMQp9pnXyrkyrQfL5ayqFXFiX9h7gKlP8LG
 Jbnosk30+xeZM1qn+xneLMf46auKR1YoJZXtnH0IitaFZ9B9OFYKN1PIYfNk9UupJ51DXuBPXRf
 pwqOzXAHxzTkcBpeQx2nQwsnH1qk65AWCnK/w1d3GaelLj0o8/ZzfknLdgzl+CjafwrzMmpB5UY
 gnSZ/Jl+RwooR/vjfhbYXSg/ZudB2u1bNDqkkxTlPEo/68yRQsB4hq2GAVDd54cWKS8Dv0uSADl
 EeopfehoZ6fWuog==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Add regression tests for the NFSD_CMD_LISTENER_SET checks that
nfsd_nl_validate_listeners() runs before the code takes nfsd_mutex. The
tests cover a bad transport name, an absent transport name, a missing
address, a truncated or unsupported sockaddr, a bad address family, a
malformed entry behind a well-formed one, and more than
NFSD_NL_LISTENER_MAX entries. One more test sends a LISTENER_GET to an
empty netns.

None of these requests reach nfsd_create_serv(), so nothing here creates a
serv or registers with rpcbind. The tests that do need a serv come next,
with a stub.

The tests use kselftest_harness.h, so each test runs in its own net and
mount namespace. /run is masked there. unix_find_bsd() resolves by inode
and takes no struct net, so a connect to "/var/run/rpcbind.sock" from this
netns would otherwise reach the rpcbind on the host. svc_rpcb_setup()
opens with a call to svc_unregister(), which would then clear the host's
nfsd registrations.

The config fragment must therefore cover the fixture as well as nfsd:
NAMESPACES and NET_NS for the unshare(), SHMEM and TMPFS for the mask, and
UNIX for the AF_LOCAL rpcbind client. Without them, every test skips.

Add the new directory to the NFSD MAINTAINERS entry, which does not cover
tools/testing/selftests/ today.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 MAINTAINERS                                        |   1 +
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/nfsd/.gitignore            |   1 +
 tools/testing/selftests/nfsd/Makefile              |   6 +
 tools/testing/selftests/nfsd/config                |   8 +
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 488 +++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |   1 +
 7 files changed, 506 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index be63cb3844db..9d97df56cad6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -14163,6 +14163,7 @@ F:	include/uapi/linux/nfsd/
 F:	include/uapi/linux/sunrpc/
 F:	net/sunrpc/
 F:	tools/net/sunrpc/
+F:	tools/testing/selftests/nfsd/
 
 KERNEL NFSD BLOCK and SCSI LAYOUT DRIVER
 R:	Christoph Hellwig <hch@lst.de>
diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index c62642302c84..edaf3c932011 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -89,6 +89,7 @@ TARGETS += net/packetdrill
 TARGETS += net/ppp
 TARGETS += net/rds
 TARGETS += net/tcp_ao
+TARGETS += nfsd
 TARGETS += nolibc
 TARGETS += pci_endpoint
 TARGETS += pcie_bwctrl
diff --git a/tools/testing/selftests/nfsd/.gitignore b/tools/testing/selftests/nfsd/.gitignore
new file mode 100644
index 000000000000..19e6dec04d8e
--- /dev/null
+++ b/tools/testing/selftests/nfsd/.gitignore
@@ -0,0 +1 @@
+nfsd_netlink_listener
diff --git a/tools/testing/selftests/nfsd/Makefile b/tools/testing/selftests/nfsd/Makefile
new file mode 100644
index 000000000000..15ac65549d25
--- /dev/null
+++ b/tools/testing/selftests/nfsd/Makefile
@@ -0,0 +1,6 @@
+# SPDX-License-Identifier: GPL-2.0
+CFLAGS += $(KHDR_INCLUDES) -Wall
+
+TEST_GEN_PROGS := nfsd_netlink_listener
+
+include ../lib.mk
diff --git a/tools/testing/selftests/nfsd/config b/tools/testing/selftests/nfsd/config
new file mode 100644
index 000000000000..ab84523fbedf
--- /dev/null
+++ b/tools/testing/selftests/nfsd/config
@@ -0,0 +1,8 @@
+CONFIG_NAMESPACES=y
+CONFIG_NET_NS=y
+CONFIG_SHMEM=y
+CONFIG_TMPFS=y
+CONFIG_UNIX=y
+CONFIG_IPV6=y
+CONFIG_NFSD=y
+CONFIG_NFSD_V4=y
diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
new file mode 100644
index 000000000000..ae28c224255f
--- /dev/null
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -0,0 +1,488 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Regression tests for the NFSD generic-netlink listener interface
+ * (NFSD_CMD_LISTENER_SET / NFSD_CMD_LISTENER_GET).
+ *
+ * These cover the request validation that nfsd_nl_validate_listeners() does
+ * before nfsd_mutex is taken: bad or absent transport name, missing address,
+ * truncated or unsupported sockaddr, oversized list. None of them reach
+ * nfsd_create_serv(), so nothing here creates a serv or talks to rpcbind.
+ *
+ * Each test runs in its own private net + mount namespace (unshare in
+ * FIXTURE_SETUP). /run is masked there: a pathname AF_LOCAL connect is not
+ * scoped by the network namespace, since unix_find_bsd() resolves by inode
+ * and takes no struct net, so the kernel's rpcbind client would otherwise be
+ * able to reach the rpcbind running on the host.
+ */
+#define _GNU_SOURCE
+#include <errno.h>
+#include <sched.h>
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/mount.h>
+#include <sys/socket.h>
+#include <sys/ioctl.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <net/if.h>
+#include <netinet/in.h>
+#include <linux/netlink.h>
+#include <linux/genetlink.h>
+
+#include "../kselftest_harness.h"
+
+/* NFSD generic-netlink constants (from linux/nfsd_netlink.h). */
+#define NFSD_FAMILY_NAME		"nfsd"
+#define NFSD_CMD_LISTENER_SET		6
+#define NFSD_CMD_LISTENER_GET		7
+#define NFSD_A_SERVER_SOCK_ADDR		1	/* per-listener nest */
+#define NFSD_A_SOCK_ADDR		1	/* inside the nest */
+#define NFSD_A_SOCK_TRANSPORT_NAME	2	/* inside the nest */
+
+#define NLA_ALIGN4(len)			(((len) + 3) & ~3)
+#define TEST_PORT			20049
+#define MAX_LISTENERS			8
+#define RECV_TIMEO_SEC			30
+
+static int nfsd_family;			/* set per-test in FIXTURE_SETUP */
+
+static void die(const char *msg)
+{
+	perror(msg);
+	exit(1);
+}
+
+/* ------------------- minimal generic-netlink plumbing ------------------- */
+
+static int genl_open(void)
+{
+	struct sockaddr_nl sa = { .nl_family = AF_NETLINK };
+	struct timeval tv = { .tv_sec = RECV_TIMEO_SEC };
+	int fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
+
+	if (fd < 0)
+		die("socket(NETLINK_GENERIC)");
+	if (bind(fd, (void *)&sa, sizeof(sa)) < 0)
+		die("bind(netlink)");
+	setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
+	return fd;
+}
+
+/* Append an attribute at @off; return the new (aligned) offset. */
+static int put_attr(char *buf, int off, uint16_t type,
+		    const void *data, int len)
+{
+	struct nlattr *na = (void *)(buf + off);
+
+	na->nla_type = type;
+	na->nla_len = NLA_HDRLEN + len;
+	if (len)
+		memcpy(buf + off + NLA_HDRLEN, data, len);
+	return off + NLA_ALIGN4(NLA_HDRLEN + len);
+}
+
+/* Build a genl message header into @buf; return the offset past it. */
+static int genl_hdr(char *buf, uint16_t type, uint16_t flags, uint8_t cmd)
+{
+	struct nlmsghdr *nlh = (void *)buf;
+	struct genlmsghdr *gnl = (void *)(buf + NLMSG_HDRLEN);
+
+	memset(buf, 0, NLMSG_HDRLEN + GENL_HDRLEN);
+	nlh->nlmsg_type = type;
+	nlh->nlmsg_flags = flags;
+	nlh->nlmsg_seq = 1;
+	gnl->cmd = cmd;
+	gnl->version = 1;
+	return NLMSG_HDRLEN + GENL_HDRLEN;
+}
+
+/* Send an nfsd command with an ACK; return the ACK errno (<= 0). */
+static int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
+{
+	char buf[1 << 20], rbuf[4096];
+	struct nlmsghdr *nlh = (void *)buf;
+	int fd = genl_open();
+	int off, n, ret;
+
+	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST | NLM_F_ACK, cmd);
+	if (attrs_len) {
+		memcpy(buf + off, attrs, attrs_len);
+		off += attrs_len;
+	}
+	nlh->nlmsg_len = off;
+
+	if (send(fd, buf, off, 0) < 0)
+		die("send(genl)");
+
+	n = recv(fd, rbuf, sizeof(rbuf), 0);
+	if (n < 0)
+		ret = (errno == EAGAIN || errno == EWOULDBLOCK) ? -ETIMEDOUT : -errno;
+	else if (((struct nlmsghdr *)rbuf)->nlmsg_type == NLMSG_ERROR)
+		ret = ((struct nlmsgerr *)NLMSG_DATA(rbuf))->error;
+	else
+		ret = 0;
+	close(fd);
+	return ret;
+}
+
+/* Send a command and return the full reply message; -errno on failure. */
+static int genl_request_reply(uint8_t cmd, char *rbuf, size_t rlen)
+{
+	char buf[256];
+	struct nlmsghdr *nlh = (void *)buf;
+	int fd = genl_open();
+	int off, n, ret;
+
+	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST, cmd);
+	nlh->nlmsg_len = off;
+
+	if (send(fd, buf, off, 0) < 0)
+		die("send(genl reply)");
+
+	n = recv(fd, rbuf, rlen, 0);
+	if (n < 0)
+		ret = (errno == EAGAIN || errno == EWOULDBLOCK) ? -ETIMEDOUT : -errno;
+	else if (((struct nlmsghdr *)rbuf)->nlmsg_type == NLMSG_ERROR)
+		ret = ((struct nlmsgerr *)NLMSG_DATA(rbuf))->error;
+	else
+		ret = n;
+	close(fd);
+	return ret;
+}
+
+/* Resolve the "nfsd" genl family id; -1 if not registered. */
+static int genl_resolve_nfsd(void)
+{
+	char buf[1024], rbuf[4096];
+	struct nlmsghdr *nlh = (void *)buf;
+	struct nlmsghdr *rh = (void *)rbuf;
+	struct nlattr *na;
+	int fd, off, left, id = -1;
+
+	fd = genl_open();
+	off = genl_hdr(buf, GENL_ID_CTRL, NLM_F_REQUEST, CTRL_CMD_GETFAMILY);
+	off = put_attr(buf, off, CTRL_ATTR_FAMILY_NAME,
+		       NFSD_FAMILY_NAME, sizeof(NFSD_FAMILY_NAME));
+	nlh->nlmsg_len = off;
+
+	if (send(fd, buf, off, 0) < 0)
+		die("send(GETFAMILY)");
+	if (recv(fd, rbuf, sizeof(rbuf), 0) < 0)
+		die("recv(GETFAMILY)");
+	close(fd);
+
+	if (rh->nlmsg_type == NLMSG_ERROR)
+		return -1;
+
+	na = (void *)((char *)NLMSG_DATA(rh) + GENL_HDRLEN);
+	left = rh->nlmsg_len - NLMSG_HDRLEN - GENL_HDRLEN;
+	while (left >= (int)NLA_HDRLEN) {
+		if (na->nla_type == CTRL_ATTR_FAMILY_ID) {
+			id = *(uint16_t *)((char *)na + NLA_HDRLEN);
+			break;
+		}
+		left -= NLA_ALIGN4(na->nla_len);
+		na = (void *)((char *)na + NLA_ALIGN4(na->nla_len));
+	}
+	return id;
+}
+
+/* ------------------- listener request builders ------------------- */
+
+/* Fine-grained control for negative tests: any field can be omitted/malformed. */
+struct raw_listener {
+	const char *xprt;	/* NULL -> omit NFSD_A_SOCK_TRANSPORT_NAME */
+	int emit_addr;		/* 0 -> omit NFSD_A_SOCK_ADDR */
+	const void *addr;
+	int addr_len;		/* bytes to emit for NFSD_A_SOCK_ADDR */
+};
+
+static int put_raw_listener(char *buf, int off, const struct raw_listener *r)
+{
+	struct nlattr *nest = (void *)(buf + off);
+	int inner = off + NLA_HDRLEN;
+
+	if (r->emit_addr)
+		inner = put_attr(buf, inner, NFSD_A_SOCK_ADDR, r->addr, r->addr_len);
+	if (r->xprt)
+		inner = put_attr(buf, inner, NFSD_A_SOCK_TRANSPORT_NAME,
+				 r->xprt, strlen(r->xprt) + 1);
+	nest->nla_type = NFSD_A_SERVER_SOCK_ADDR | NLA_F_NESTED;
+	nest->nla_len = inner - off;
+	return off + NLA_ALIGN4(nest->nla_len);
+}
+
+/* Well-formed loopback listener for @family (AF_INET or AF_INET6). */
+static int put_listener_af(char *buf, int off, const char *xprt, int family,
+			   uint16_t port)
+{
+	struct sockaddr_storage ss = {0};
+	struct raw_listener r = { .xprt = xprt, .emit_addr = 1, .addr = &ss };
+
+	if (family == AF_INET6) {
+		struct sockaddr_in6 *s6 = (void *)&ss;
+
+		s6->sin6_family = AF_INET6;
+		s6->sin6_port = htons(port);
+		s6->sin6_addr = in6addr_loopback;
+		r.addr_len = sizeof(*s6);
+	} else {
+		struct sockaddr_in *s4 = (void *)&ss;
+
+		s4->sin_family = AF_INET;
+		s4->sin_port = htons(port);
+		s4->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+		r.addr_len = sizeof(*s4);
+	}
+	return put_raw_listener(buf, off, &r);
+}
+
+static int put_listener(char *buf, int off, const char *xprt, uint16_t port)
+{
+	return put_listener_af(buf, off, xprt, AF_INET, port);
+}
+
+/* ------------------- LISTENER_GET parsing ------------------- */
+
+struct listener_ent {
+	char xprt[16];
+	int family;
+	uint16_t port;
+	struct in_addr a4;
+	struct in6_addr a6;
+};
+
+static int parse_listener_get(const char *rbuf, int len,
+			      struct listener_ent *out, int max)
+{
+	const struct nlmsghdr *nlh = (const void *)rbuf;
+	const struct nlattr *na;
+	int left, count = 0;
+
+	(void)len;
+	na = (const void *)(rbuf + NLMSG_HDRLEN + GENL_HDRLEN);
+	left = nlh->nlmsg_len - NLMSG_HDRLEN - GENL_HDRLEN;
+
+	while (left >= (int)NLA_HDRLEN) {
+		int alen = na->nla_len;
+
+		if ((na->nla_type & NLA_TYPE_MASK) == NFSD_A_SERVER_SOCK_ADDR &&
+		    count < max) {
+			const struct nlattr *in = (const void *)((char *)na + NLA_HDRLEN);
+			int ileft = alen - NLA_HDRLEN;
+			struct listener_ent *e = &out[count];
+
+			memset(e, 0, sizeof(*e));
+			while (ileft >= (int)NLA_HDRLEN) {
+				const void *d = (const char *)in + NLA_HDRLEN;
+				int t = in->nla_type & NLA_TYPE_MASK;
+
+				if (t == NFSD_A_SOCK_TRANSPORT_NAME) {
+					strncpy(e->xprt, d, sizeof(e->xprt) - 1);
+				} else if (t == NFSD_A_SOCK_ADDR) {
+					const struct sockaddr_storage *ss = d;
+
+					e->family = ss->ss_family;
+					if (ss->ss_family == AF_INET) {
+						const struct sockaddr_in *s = d;
+
+						e->a4 = s->sin_addr;
+						e->port = ntohs(s->sin_port);
+					} else if (ss->ss_family == AF_INET6) {
+						const struct sockaddr_in6 *s = d;
+
+						e->a6 = s->sin6_addr;
+						e->port = ntohs(s->sin6_port);
+					}
+				}
+				ileft -= NLA_ALIGN4(in->nla_len);
+				in = (const void *)((char *)in + NLA_ALIGN4(in->nla_len));
+			}
+			count++;
+		}
+		left -= NLA_ALIGN4(alen);
+		na = (const void *)((char *)na + NLA_ALIGN4(alen));
+	}
+	return count;
+}
+
+/* ------------------- convenience wrappers ------------------- */
+
+static int listener_set(const char *attrs, int len)
+{
+	return genl_request(NFSD_CMD_LISTENER_SET, attrs, len);
+}
+
+/* Fetch the current listeners; returns count (>=0) or -errno. */
+static int listener_get(struct listener_ent *out, int max)
+{
+	char rbuf[8192];
+	int n = genl_request_reply(NFSD_CMD_LISTENER_GET, rbuf, sizeof(rbuf));
+
+	if (n < 0)
+		return n;
+	return parse_listener_get(rbuf, n, out, max);
+}
+
+/* --------------------------- fixture --------------------------- */
+
+FIXTURE(nfsd_listener) {
+	int placeholder;
+};
+
+FIXTURE_SETUP(nfsd_listener)
+{
+	struct ifreq ifr = {0};
+	struct stat st;
+	int s;
+
+	if (geteuid() != 0)
+		SKIP(return, "must be run as root");
+	if (unshare(CLONE_NEWNET | CLONE_NEWNS) < 0)
+		SKIP(return, "unshare(NEWNET|NEWNS): %s", strerror(errno));
+	if (mount("", "/", NULL, MS_REC | MS_PRIVATE, NULL) < 0)
+		SKIP(return, "mount(/ private): %s", strerror(errno));
+
+	/*
+	 * Keep the kernel's rpcbind client inside this namespace. The
+	 * abstract socket it tries first is per-netns, but the
+	 * "/var/run/rpcbind.sock" fallback is not, so hide the path.
+	 */
+	if (mount("tmpfs", "/run", "tmpfs", 0, NULL) < 0)
+		SKIP(return, "mount(tmpfs on /run): %s", strerror(errno));
+	if (lstat("/var/run", &st) == 0 && S_ISDIR(st.st_mode) &&
+	    mount("tmpfs", "/var/run", "tmpfs", 0, NULL) < 0)
+		SKIP(return, "mount(tmpfs on /var/run): %s", strerror(errno));
+
+	/* Bring loopback up so listener binds (127.0.0.1 / ::1) work. */
+	s = socket(AF_INET, SOCK_DGRAM, 0);
+	ASSERT_GE(s, 0);
+	strcpy(ifr.ifr_name, "lo");
+	ASSERT_EQ(0, ioctl(s, SIOCGIFFLAGS, &ifr));
+	ifr.ifr_flags |= IFF_UP | IFF_RUNNING;
+	ASSERT_EQ(0, ioctl(s, SIOCSIFFLAGS, &ifr));
+	close(s);
+
+	nfsd_family = genl_resolve_nfsd();
+	if (nfsd_family < 0)
+		SKIP(return, "nfsd genl family not found (modprobe nfsd?)");
+}
+
+FIXTURE_TEARDOWN(nfsd_listener)
+{
+}
+
+/* ===================== validation / negative ===================== */
+
+TEST_F(nfsd_listener, val_too_many)
+{
+	static char attrs[1 << 20];
+	int i, off = 0;
+
+	for (i = 0; i < 1025; i++)		/* > NFSD_NL_LISTENER_MAX (1024) */
+		off = put_listener(attrs, off, "udp", TEST_PORT);
+	EXPECT_EQ(-E2BIG, listener_set(attrs, off));
+}
+
+TEST_F(nfsd_listener, val_missing_addr)
+{
+	char attrs[64];
+	struct raw_listener r = { .xprt = "tcp", .emit_addr = 0 };
+	int off = put_raw_listener(attrs, 0, &r);
+
+	EXPECT_EQ(-EINVAL, listener_set(attrs, off));
+}
+
+TEST_F(nfsd_listener, val_missing_transport)
+{
+	struct sockaddr_in s4 = { .sin_family = AF_INET, .sin_port = htons(TEST_PORT) };
+	struct raw_listener r = { .xprt = NULL, .emit_addr = 1,
+				  .addr = &s4, .addr_len = sizeof(s4) };
+	char attrs[64];
+	int off = put_raw_listener(attrs, 0, &r);
+
+	EXPECT_EQ(-EINVAL, listener_set(attrs, off));
+}
+
+/*
+ * A name matching no transport class must be refused before nfsd_mutex is
+ * taken, so it never reaches svc_xprt_create_from_sa() and its
+ * request_module("svc%s", name) upcall.
+ */
+TEST_F(nfsd_listener, val_bad_transport)
+{
+	char attrs[64];
+	int off = put_listener(attrs, 0, "bogus_xprt", TEST_PORT);
+
+	EXPECT_EQ(-EPROTONOSUPPORT, listener_set(attrs, off));
+}
+
+TEST_F(nfsd_listener, val_addr_too_short)
+{
+	unsigned char tiny = 0;
+	struct raw_listener r = { .xprt = "tcp", .emit_addr = 1,
+				  .addr = &tiny, .addr_len = 1 };
+	char attrs[64];
+	int off = put_raw_listener(attrs, 0, &r);
+
+	EXPECT_EQ(-EINVAL, listener_set(attrs, off));
+}
+
+TEST_F(nfsd_listener, val_inet_short)
+{
+	struct sockaddr_in s4 = { .sin_family = AF_INET, .sin_port = htons(TEST_PORT) };
+	struct raw_listener r = { .xprt = "tcp", .emit_addr = 1, .addr = &s4,
+				  .addr_len = sizeof(sa_family_t) + 2 };
+	char attrs[64];
+	int off = put_raw_listener(attrs, 0, &r);
+
+	EXPECT_EQ(-EINVAL, listener_set(attrs, off));
+}
+
+TEST_F(nfsd_listener, val_inet6_short)
+{
+	struct sockaddr_in6 s6 = { .sin6_family = AF_INET6, .sin6_port = htons(TEST_PORT) };
+	struct raw_listener r = { .xprt = "tcp", .emit_addr = 1, .addr = &s6,
+				  .addr_len = sizeof(struct sockaddr_in) };
+	char attrs[64];
+	int off = put_raw_listener(attrs, 0, &r);
+
+	EXPECT_EQ(-EINVAL, listener_set(attrs, off));
+}
+
+TEST_F(nfsd_listener, val_bad_family)
+{
+	struct sockaddr_storage ss = { .ss_family = AF_UNIX };
+	struct raw_listener r = { .xprt = "tcp", .emit_addr = 1, .addr = &ss,
+				  .addr_len = sizeof(struct sockaddr_in) };
+	char attrs[64];
+	int off = put_raw_listener(attrs, 0, &r);
+
+	EXPECT_EQ(-EAFNOSUPPORT, listener_set(attrs, off));
+}
+
+TEST_F(nfsd_listener, val_second_entry_bad)
+{
+	struct sockaddr_storage ss = { .ss_family = AF_UNIX };
+	struct raw_listener bad = { .xprt = "tcp", .emit_addr = 1, .addr = &ss,
+				    .addr_len = sizeof(struct sockaddr_in) };
+	char attrs[128];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	off = put_raw_listener(attrs, off, &bad);
+	/* The whole request is rejected during validation; nothing applied. */
+	EXPECT_EQ(-EAFNOSUPPORT, listener_set(attrs, off));
+}
+
+/* LISTENER_GET with no serv in this netns returns an empty list. */
+TEST_F(nfsd_listener, func_get_empty)
+{
+	struct listener_ent got[MAX_LISTENERS];
+
+	EXPECT_EQ(0, listener_get(got, MAX_LISTENERS));
+}
+
+TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/nfsd/settings b/tools/testing/selftests/nfsd/settings
new file mode 100644
index 000000000000..6091b45d226b
--- /dev/null
+++ b/tools/testing/selftests/nfsd/settings
@@ -0,0 +1 @@
+timeout=120

-- 
2.55.0

