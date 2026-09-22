Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B9D3547FB0C;
	Tue, 22 Sep 2026 11:34:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076868; cv=none; b=TEYGljP/EspiOeQe0tqM9Xyg0/d0LLEMg32tboZx0bgBnsk/gFN/2RsSxcKb0xyNT+QG+Jghcgy39JAuXecgVhNe3AdKERaAzGwUfcr+KqLqtN+EB4UThiOEQIsWPVO8bAJ2QS+FKC/Yn18IzTiBc/ppGSH4EAEc/fShpdCRUhU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076868; c=relaxed/simple;
	bh=E8vGIRGIZ5Ej8iVy508sE++9uoe+ty5nWr2vlsyp4Xw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=sl4jYqPagfZm5tPgTDBig1tqQkYW8mpbq4IMDvQ0VzDGumQFVSzgWz6H44d26rsqoMcI5rgm80FwlTYmiIp6NG8WX2SOSScBaZiQEkAoALlA0cGnyNNS4hzpBaaDMmyBLryfVdn/6Sv2tlvha/Sxn9Rk196yx3nH1/ieW2yuDXk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AvL+l3Qj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AvL+l3Qj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A164E1F00898;
	Tue, 22 Sep 2026 11:34:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076865;
	bh=2aVXY9iiOPtDAAWpb3Jyxfl+AE25CNbFUHutOqPD/6c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=AvL+l3QjUdv78sXs0ZzDvxviyFWjSHMjAn3uo1XIrC67WklTZzLYsM8RBxVm2OoLd
	 A7fX8hSVWER4Zy5z99fOwW8Z6vKm3olj2/mH9ez3sDU0slaYG3gATiKO1fQm42T8wk
	 Ok241egWSbp2MWA3kuXFqR500z++dEQ9Fi8jgL/iuKhUch3X9ndS99o43YzWeoahwQ
	 a/iVqSIU/8XNbe610gmWnAYLgMHBW6MdwjfKDHDKL6DRnEY6tts6vL/75Qq0w3xhsW
	 +ZoCjNbFiu71pUZR2p63p+/0PuLWjh2wkV7X7kppmn5tkbR9yCw3cTzfVC+nmdsndI
	 oQJCs6V5wKGxA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 22 Sep 2026 07:34:07 -0400
Subject: [PATCH v2 6/8] selftests/nfsd: factor the netlink plumbing into a
 shared header
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260922-nfsd-per-net-mutex-v2-6-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=20983; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=E8vGIRGIZ5Ej8iVy508sE++9uoe+ty5nWr2vlsyp4Xw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsme5PAihfAmBedzHK5Z62IPF0XRZhGv/Fx+Sy
 OHhWc1CYi+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnuQAKCRAADmhBGVaC
 FaAkEACJwD5jhrxCvI38sNz2b8TuDlTaBafPgc4fVTgnksSXrdDRvNVKqvC7Y1EnNwf4QXNgC6+
 Xb9EimX2ZM3IhkcEWZ8bbjCcKyKZecGqovEtf+sE/E10H8gqUDymHtmWenSOwcqG+dgr0VV7gGi
 RlX3egerXdgM9gSPUIfSo3HyS3Z9xhnyZIn3PsxEHfm+JHZYO8tXmEmMRUuWWx6c9JGAuKjJOmK
 +i1vXSkGYgHCwn7kaFk49otkvKS5zSSh8C7/dApWFCuasD6pO0tjOYnC2bAPEps64w31UuIhNxv
 1cotobzCqEH31Amjec/lv8cmXNmR3Xk9c0j3q8z/VT8feYt/pJWQ/j5c9HEPg45jYW9qzxtHiMT
 Ss2n7aRCIlC46AP6XWE1P3VQCnGCJpAJeQ+pqXawtd0hK5K3Z4Pdk7/0RTTCVZXD6clXNP87Llr
 Q9Nv73+oYOGvuQUX1RUeA3D9YHTbnU1+te/4yqimtZBgLK+irMiDp9DGJNSJ8+pLIFY6uuRZVNw
 SkHiNqPAGBSXk/varH42tDpIQYOEEPEcPqUNfNM/USZomm6bZmItrM1S0MO8M7wATsL7IqlOZNK
 oX+l39Idv/Lka3+He6oJ1e1Z2dN5+e1bFd7LUhvNgRTOzIJyei4HOy4mgKrH19S9kP77PjBAAFZ
 jqXtgVYBYMZRdEA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_netlink_listener.c carries a small generic-netlink client -- socket
setup, attribute packing, extack parsing, family resolution -- plus the
LISTENER_SET/THREADS_SET/VERSION_SET wrappers. Other nfsd tests want the
same thing.

Move it to nfsd_netlink.h as static inline helpers, so each test binary
gets its own copy and there is nothing to link. Code is unchanged; only
the three continuation lines that the static inline prefix pushed out of
alignment were reflowed.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 tools/testing/selftests/nfsd/nfsd_netlink.h        | 319 +++++++++++++++++++++
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 295 +------------------
 2 files changed, 322 insertions(+), 292 deletions(-)

diff --git a/tools/testing/selftests/nfsd/nfsd_netlink.h b/tools/testing/selftests/nfsd/nfsd_netlink.h
new file mode 100644
index 000000000000..c66a980bfc01
--- /dev/null
+++ b/tools/testing/selftests/nfsd/nfsd_netlink.h
@@ -0,0 +1,319 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Shared generic-netlink plumbing for the NFSD selftests.
+ *
+ * Header-only: every helper is static inline, so each test binary gets its
+ * own copy and there is nothing extra to link. nfsd_family must be set by
+ * calling genl_resolve_nfsd() before any of the request helpers are used.
+ */
+#ifndef __SELFTESTS_NFSD_NETLINK_H__
+#define __SELFTESTS_NFSD_NETLINK_H__
+
+#include <errno.h>
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/socket.h>
+#include <sys/time.h>
+#include <netinet/in.h>
+#include <linux/netlink.h>
+#include <linux/genetlink.h>
+#include <linux/nfsd_netlink.h>
+
+#define NLA_ALIGN4(len)			(((len) + 3) & ~3)
+#define RECV_TIMEO_SEC			30
+
+static int nfsd_family = -1;		/* set per-test in FIXTURE_SETUP */
+
+/* Extack message from the last genl_request(); empty if there was none. */
+static char last_extack[128];
+
+static inline void die(const char *msg)
+{
+	perror(msg);
+	exit(1);
+}
+
+/* ------------------- minimal generic-netlink plumbing ------------------- */
+
+static inline int genl_open(void)
+{
+	struct sockaddr_nl sa = { .nl_family = AF_NETLINK };
+	struct timeval tv = { .tv_sec = RECV_TIMEO_SEC };
+	int fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
+	int on = 1;
+
+	if (fd < 0)
+		die("socket(NETLINK_GENERIC)");
+	if (bind(fd, (void *)&sa, sizeof(sa)) < 0)
+		die("bind(netlink)");
+	setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
+	/*
+	 * Ask for extack, and cap the ack so the request is not echoed back:
+	 * the TLVs then always follow the fixed part of the error message.
+	 */
+	setsockopt(fd, SOL_NETLINK, NETLINK_EXT_ACK, &on, sizeof(on));
+	setsockopt(fd, SOL_NETLINK, NETLINK_CAP_ACK, &on, sizeof(on));
+	return fd;
+}
+
+/* Stash the extack message of an ack, if it carries one. */
+static inline void parse_extack(const char *rbuf)
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
+/* Append an attribute at @off; return the new (aligned) offset. */
+static inline int put_attr(char *buf, int off, uint16_t type,
+			   const void *data, int len)
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
+static inline int genl_hdr(char *buf, uint16_t type, uint16_t flags, uint8_t cmd)
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
+static inline int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
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
+	last_extack[0] = '\0';
+	n = recv(fd, rbuf, sizeof(rbuf), 0);
+	if (n < 0) {
+		ret = (errno == EAGAIN || errno == EWOULDBLOCK) ? -ETIMEDOUT : -errno;
+	} else if (((struct nlmsghdr *)rbuf)->nlmsg_type == NLMSG_ERROR) {
+		ret = ((struct nlmsgerr *)NLMSG_DATA(rbuf))->error;
+		parse_extack(rbuf);
+	} else {
+		ret = 0;
+	}
+	close(fd);
+	return ret;
+}
+
+/*
+ * Send a command with attributes and return the full reply message; -errno
+ * on failure. NLM_F_ACK is left off: the kernel reports an error either way,
+ * so the first message back is the reply whenever there is one.
+ */
+static inline int genl_request_reply_attrs(uint8_t cmd, const char *attrs,
+					   int attrs_len, char *rbuf,
+					   size_t rlen)
+{
+	char buf[1 << 20];
+	struct nlmsghdr *nlh = (void *)buf;
+	int fd = genl_open();
+	int off, n, ret;
+
+	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST, cmd);
+	if (attrs_len) {
+		memcpy(buf + off, attrs, attrs_len);
+		off += attrs_len;
+	}
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
+static inline int genl_request_reply(uint8_t cmd, char *rbuf, size_t rlen)
+{
+	return genl_request_reply_attrs(cmd, NULL, 0, rbuf, rlen);
+}
+
+/* Resolve the "nfsd" genl family id; -1 if not registered. */
+static inline int genl_resolve_nfsd(void)
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
+static inline int put_raw_listener(char *buf, int off, const struct raw_listener *r)
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
+static inline int put_listener_af(char *buf, int off, const char *xprt,
+				  int family, uint16_t port)
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
+static inline int put_listener(char *buf, int off, const char *xprt, uint16_t port)
+{
+	return put_listener_af(buf, off, xprt, AF_INET, port);
+}
+
+static inline int listener_set(const char *attrs, int len)
+{
+	return genl_request(NFSD_CMD_LISTENER_SET, attrs, len);
+}
+
+/*
+ * Enable exactly one NFS version in this netns. NFSD_CMD_VERSION_SET clears
+ * every version first, so one nest is enough to leave the server v4-only.
+ * It refuses once a serv exists, so call it before any listener.
+ */
+static inline int version_set_only(uint32_t major, uint32_t minor)
+{
+	char attrs[64];
+	struct nlattr *nest = (void *)attrs;
+	int inner = NLA_HDRLEN;
+
+	inner = put_attr(attrs, inner, NFSD_A_VERSION_MAJOR,
+			 &major, sizeof(major));
+	inner = put_attr(attrs, inner, NFSD_A_VERSION_MINOR,
+			 &minor, sizeof(minor));
+	inner = put_attr(attrs, inner, NFSD_A_VERSION_ENABLED, NULL, 0);
+	nest->nla_type = NFSD_A_SERVER_PROTO_VERSION | NLA_F_NESTED;
+	nest->nla_len = inner;
+
+	return genl_request(NFSD_CMD_VERSION_SET, attrs, NLA_ALIGN4(inner));
+}
+
+/* Start (@n > 0) or stop (@n == 0) nfsd threads in this netns. */
+static inline int threads_set(int n)
+{
+	char attrs[64];
+	uint32_t v = n;
+	int off = put_attr(attrs, 0, NFSD_A_SERVER_THREADS, &v, sizeof(v));
+
+	return genl_request(NFSD_CMD_THREADS_SET, attrs, off);
+}
+
+#endif /* __SELFTESTS_NFSD_NETLINK_H__ */
diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index 1294057b6f62..f6f8aa1e1cfe 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -46,267 +46,13 @@
 #include <linux/nfsd_netlink.h>
 
 #include "../kselftest_harness.h"
+#include "nfsd_netlink.h"
 
-#define NFS_PROGRAM			100003
-#define NFS_ACL_PROGRAM			100227
-
-#define NLA_ALIGN4(len)			(((len) + 3) & ~3)
 #define TEST_PORT			20049
 #define MAX_LISTENERS			8
-#define RECV_TIMEO_SEC			30
-
-static int nfsd_family = -1;		/* set per-test in FIXTURE_SETUP */
-
-/* Extack message from the last genl_request(); empty if there was none. */
-static char last_extack[128];
-
-static void die(const char *msg)
-{
-	perror(msg);
-	exit(1);
-}
-
-/* ------------------- minimal generic-netlink plumbing ------------------- */
-
-static int genl_open(void)
-{
-	struct sockaddr_nl sa = { .nl_family = AF_NETLINK };
-	struct timeval tv = { .tv_sec = RECV_TIMEO_SEC };
-	int fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
-	int on = 1;
-
-	if (fd < 0)
-		die("socket(NETLINK_GENERIC)");
-	if (bind(fd, (void *)&sa, sizeof(sa)) < 0)
-		die("bind(netlink)");
-	setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
-	/*
-	 * Ask for extack, and cap the ack so the request is not echoed back:
-	 * the TLVs then always follow the fixed part of the error message.
-	 */
-	setsockopt(fd, SOL_NETLINK, NETLINK_EXT_ACK, &on, sizeof(on));
-	setsockopt(fd, SOL_NETLINK, NETLINK_CAP_ACK, &on, sizeof(on));
-	return fd;
-}
-
-/* Stash the extack message of an ack, if it carries one. */
-static void parse_extack(const char *rbuf)
-{
-	const struct nlmsghdr *nlh = (const void *)rbuf;
-	const struct nlattr *na;
-	int off, left;
-
-	last_extack[0] = '\0';
-	if (nlh->nlmsg_type != NLMSG_ERROR ||
-	    !(nlh->nlmsg_flags & NLM_F_ACK_TLVS))
-		return;
-
-	off = NLMSG_HDRLEN + NLMSG_ALIGN(sizeof(struct nlmsgerr));
-	left = nlh->nlmsg_len - off;
-	na = (const void *)(rbuf + off);
-
-	while (left >= (int)NLA_HDRLEN) {
-		if ((na->nla_type & NLA_TYPE_MASK) == NLMSGERR_ATTR_MSG) {
-			strncpy(last_extack, (const char *)na + NLA_HDRLEN,
-				sizeof(last_extack) - 1);
-			last_extack[sizeof(last_extack) - 1] = '\0';
-			return;
-		}
-		left -= NLA_ALIGN4(na->nla_len);
-		na = (const void *)((const char *)na + NLA_ALIGN4(na->nla_len));
-	}
-}
-
-/* Append an attribute at @off; return the new (aligned) offset. */
-static int put_attr(char *buf, int off, uint16_t type,
-		    const void *data, int len)
-{
-	struct nlattr *na = (void *)(buf + off);
-
-	na->nla_type = type;
-	na->nla_len = NLA_HDRLEN + len;
-	if (len)
-		memcpy(buf + off + NLA_HDRLEN, data, len);
-	return off + NLA_ALIGN4(NLA_HDRLEN + len);
-}
-
-/* Build a genl message header into @buf; return the offset past it. */
-static int genl_hdr(char *buf, uint16_t type, uint16_t flags, uint8_t cmd)
-{
-	struct nlmsghdr *nlh = (void *)buf;
-	struct genlmsghdr *gnl = (void *)(buf + NLMSG_HDRLEN);
-
-	memset(buf, 0, NLMSG_HDRLEN + GENL_HDRLEN);
-	nlh->nlmsg_type = type;
-	nlh->nlmsg_flags = flags;
-	nlh->nlmsg_seq = 1;
-	gnl->cmd = cmd;
-	gnl->version = 1;
-	return NLMSG_HDRLEN + GENL_HDRLEN;
-}
-
-/* Send an nfsd command with an ACK; return the ACK errno (<= 0). */
-static int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
-{
-	char buf[1 << 20], rbuf[4096];
-	struct nlmsghdr *nlh = (void *)buf;
-	int fd = genl_open();
-	int off, n, ret;
-
-	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST | NLM_F_ACK, cmd);
-	if (attrs_len) {
-		memcpy(buf + off, attrs, attrs_len);
-		off += attrs_len;
-	}
-	nlh->nlmsg_len = off;
-
-	if (send(fd, buf, off, 0) < 0)
-		die("send(genl)");
-
-	last_extack[0] = '\0';
-	n = recv(fd, rbuf, sizeof(rbuf), 0);
-	if (n < 0) {
-		ret = (errno == EAGAIN || errno == EWOULDBLOCK) ? -ETIMEDOUT : -errno;
-	} else if (((struct nlmsghdr *)rbuf)->nlmsg_type == NLMSG_ERROR) {
-		ret = ((struct nlmsgerr *)NLMSG_DATA(rbuf))->error;
-		parse_extack(rbuf);
-	} else {
-		ret = 0;
-	}
-	close(fd);
-	return ret;
-}
-
-/*
- * Send a command with attributes and return the full reply message; -errno
- * on failure. NLM_F_ACK is left off: the kernel reports an error either way,
- * so the first message back is the reply whenever there is one.
- */
-static int genl_request_reply_attrs(uint8_t cmd, const char *attrs,
-				    int attrs_len, char *rbuf, size_t rlen)
-{
-	char buf[1 << 20];
-	struct nlmsghdr *nlh = (void *)buf;
-	int fd = genl_open();
-	int off, n, ret;
-
-	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST, cmd);
-	if (attrs_len) {
-		memcpy(buf + off, attrs, attrs_len);
-		off += attrs_len;
-	}
-	nlh->nlmsg_len = off;
 
-	if (send(fd, buf, off, 0) < 0)
-		die("send(genl reply)");
-
-	n = recv(fd, rbuf, rlen, 0);
-	if (n < 0)
-		ret = (errno == EAGAIN || errno == EWOULDBLOCK) ? -ETIMEDOUT : -errno;
-	else if (((struct nlmsghdr *)rbuf)->nlmsg_type == NLMSG_ERROR)
-		ret = ((struct nlmsgerr *)NLMSG_DATA(rbuf))->error;
-	else
-		ret = n;
-	close(fd);
-	return ret;
-}
-
-static int genl_request_reply(uint8_t cmd, char *rbuf, size_t rlen)
-{
-	return genl_request_reply_attrs(cmd, NULL, 0, rbuf, rlen);
-}
-
-/* Resolve the "nfsd" genl family id; -1 if not registered. */
-static int genl_resolve_nfsd(void)
-{
-	char buf[1024], rbuf[4096];
-	struct nlmsghdr *nlh = (void *)buf;
-	struct nlmsghdr *rh = (void *)rbuf;
-	struct nlattr *na;
-	int fd, off, left, id = -1;
-
-	fd = genl_open();
-	off = genl_hdr(buf, GENL_ID_CTRL, NLM_F_REQUEST, CTRL_CMD_GETFAMILY);
-	off = put_attr(buf, off, CTRL_ATTR_FAMILY_NAME,
-		       NFSD_FAMILY_NAME, sizeof(NFSD_FAMILY_NAME));
-	nlh->nlmsg_len = off;
-
-	if (send(fd, buf, off, 0) < 0)
-		die("send(GETFAMILY)");
-	if (recv(fd, rbuf, sizeof(rbuf), 0) < 0)
-		die("recv(GETFAMILY)");
-	close(fd);
-
-	if (rh->nlmsg_type == NLMSG_ERROR)
-		return -1;
-
-	na = (void *)((char *)NLMSG_DATA(rh) + GENL_HDRLEN);
-	left = rh->nlmsg_len - NLMSG_HDRLEN - GENL_HDRLEN;
-	while (left >= (int)NLA_HDRLEN) {
-		if (na->nla_type == CTRL_ATTR_FAMILY_ID) {
-			id = *(uint16_t *)((char *)na + NLA_HDRLEN);
-			break;
-		}
-		left -= NLA_ALIGN4(na->nla_len);
-		na = (void *)((char *)na + NLA_ALIGN4(na->nla_len));
-	}
-	return id;
-}
-
-/* ------------------- listener request builders ------------------- */
-
-/* Fine-grained control for negative tests: any field can be omitted/malformed. */
-struct raw_listener {
-	const char *xprt;	/* NULL -> omit NFSD_A_SOCK_TRANSPORT_NAME */
-	int emit_addr;		/* 0 -> omit NFSD_A_SOCK_ADDR */
-	const void *addr;
-	int addr_len;		/* bytes to emit for NFSD_A_SOCK_ADDR */
-};
-
-static int put_raw_listener(char *buf, int off, const struct raw_listener *r)
-{
-	struct nlattr *nest = (void *)(buf + off);
-	int inner = off + NLA_HDRLEN;
-
-	if (r->emit_addr)
-		inner = put_attr(buf, inner, NFSD_A_SOCK_ADDR, r->addr, r->addr_len);
-	if (r->xprt)
-		inner = put_attr(buf, inner, NFSD_A_SOCK_TRANSPORT_NAME,
-				 r->xprt, strlen(r->xprt) + 1);
-	nest->nla_type = NFSD_A_SERVER_SOCK_ADDR | NLA_F_NESTED;
-	nest->nla_len = inner - off;
-	return off + NLA_ALIGN4(nest->nla_len);
-}
-
-/* Well-formed loopback listener for @family (AF_INET or AF_INET6). */
-static int put_listener_af(char *buf, int off, const char *xprt, int family,
-			   uint16_t port)
-{
-	struct sockaddr_storage ss = {0};
-	struct raw_listener r = { .xprt = xprt, .emit_addr = 1, .addr = &ss };
-
-	if (family == AF_INET6) {
-		struct sockaddr_in6 *s6 = (void *)&ss;
-
-		s6->sin6_family = AF_INET6;
-		s6->sin6_port = htons(port);
-		s6->sin6_addr = in6addr_loopback;
-		r.addr_len = sizeof(*s6);
-	} else {
-		struct sockaddr_in *s4 = (void *)&ss;
-
-		s4->sin_family = AF_INET;
-		s4->sin_port = htons(port);
-		s4->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-		r.addr_len = sizeof(*s4);
-	}
-	return put_raw_listener(buf, off, &r);
-}
-
-static int put_listener(char *buf, int off, const char *xprt, uint16_t port)
-{
-	return put_listener_af(buf, off, xprt, AF_INET, port);
-}
+#define NFS_PROGRAM			100003
+#define NFS_ACL_PROGRAM			100227
 
 /* ------------------- LISTENER_GET parsing ------------------- */
 
@@ -374,32 +120,6 @@ static int parse_listener_get(const char *rbuf, int len,
 
 /* ------------------- convenience wrappers ------------------- */
 
-static int listener_set(const char *attrs, int len)
-{
-	return genl_request(NFSD_CMD_LISTENER_SET, attrs, len);
-}
-
-/*
- * Enable exactly one NFS version in this netns. NFSD_CMD_VERSION_SET clears
- * every version first, so one nest is enough to leave the server v4-only.
- * It refuses once a serv exists, so call it before any listener.
- */
-static int version_set_only(uint32_t major, uint32_t minor)
-{
-	char attrs[64];
-	struct nlattr *nest = (void *)attrs;
-	int inner = NLA_HDRLEN;
-
-	inner = put_attr(attrs, inner, NFSD_A_VERSION_MAJOR,
-			 &major, sizeof(major));
-	inner = put_attr(attrs, inner, NFSD_A_VERSION_MINOR,
-			 &minor, sizeof(minor));
-	inner = put_attr(attrs, inner, NFSD_A_VERSION_ENABLED, NULL, 0);
-	nest->nla_type = NFSD_A_SERVER_PROTO_VERSION | NLA_F_NESTED;
-	nest->nla_len = inner;
-
-	return genl_request(NFSD_CMD_VERSION_SET, attrs, NLA_ALIGN4(inner));
-}
 
 /* ------------------- userspace-rpcbind ------------------- */
 
@@ -552,15 +272,6 @@ static struct listener_ent *find_listener(struct listener_ent *e, int n,
 	return NULL;
 }
 
-/* Start (@n > 0) or stop (@n == 0) nfsd threads in this netns. */
-static int threads_set(int n)
-{
-	char attrs[64];
-	uint32_t v = n;
-	int off = put_attr(attrs, 0, NFSD_A_SERVER_THREADS, &v, sizeof(v));
-
-	return genl_request(NFSD_CMD_THREADS_SET, attrs, off);
-}
 
 /* ------------------- per-netns local rpcbind stub ------------------- */
 

-- 
2.55.0

