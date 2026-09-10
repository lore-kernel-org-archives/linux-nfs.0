Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71135582BA5;
	Thu, 10 Sep 2026 18:00:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789063261; cv=none; b=kqlojJ6uRAg3QeDQ9zYGRvNzcbVNC+MpxER6mf9FMYGjE2PdAGDhCpkhe/uivWFoX8f5egkRuBbmvinHHBkMkz3mOiUAkmnCW/1Q0hl8V15xnLcgEZ2kh+i9Ht7+Y/neHCDJb9JRdmncB8OVH0KPguuc/xQn5OC+6OmjE2uNMJM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789063261; c=relaxed/simple;
	bh=/ahQTbHtkmXc0vVtpv5rFUws88TJMKDVz4HzNdfcDC8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=VXnxubsuqlkJdMcj1jIYQ8emOuZsPsXcB0nFArrzjUGDpqHUaZdkOtAes0wbwpXyQ/UGHaubVTR3ZQKbdIeTnpGvHt3GdTKTYzm2a7SPCM1yN37xF7Zso7BG+3HpGBY9PTPFIoYfKB3ZL3NQiGB7kFCwNRTA1HCpSrC0FFy+cYg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IIAj48mH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IIAj48mH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98FE31F00893;
	Thu, 10 Sep 2026 18:00:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789063259;
	bh=JwFBOCwRWWpE4JTW9YlYjZhziYvJsFQmmybzwVleQPY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IIAj48mHz0vitv6ZMpc48JmRwjLWtfMepdzJo/ZELxYnkVW/QtI0YYAnu8aoKfPzz
	 SZNCgBioM3ZvgRbIJjv4F+Ih1v/zw+bOS2AT0j9BYrj6N+V2TIjVWYpXg7M6T5CUnN
	 iP57hrnmOvpoaSj/dHmMM5dkI5ArQxESFQ6jpE4smRzwjdOrjrpKk2dsM1Ieu/r+qB
	 6F4gATniEfpNEM31bmEhZl0BBXGiblqUUa1ZjJC99SIiSm2W/FfrX31DVb0aV0ZlTZ
	 JaQ8oVYNmkey1DtYGfTnb1as0KsZ4rinCcaCXU9S125QhgItSShLFO0jyFD5CJhhzD
	 AyAJg3rFOt0Fg==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:00:38 -0400
Subject: [PATCH 5/5] selftests/nfsd: exercise the userspace-rpcbind
 listener_set flag
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsd-norpcb-v1-5-b4d5182d634c@kernel.org>
References: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
In-Reply-To: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=12049; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/ahQTbHtkmXc0vVtpv5rFUws88TJMKDVz4HzNdfcDC8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovBR8oltwDYgNnAyYAdEcoA2jQDsWRQTDDSEz
 n8gOwv50RmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqLwUQAKCRAADmhBGVaC
 FV/lD/wOlZ8uMGKjBkIdU2xsFRUIw8+G6kgRhy+I024fNcBL0wDcYPQIBV7B9NoJOxGB0SHc7uX
 Q4cR1d7rx76pybTA4QK19T4z16UG8exqA5D8Ky7e6daII/B5oJJ5zxoeQ5d5kBtHVo5A+cK1XVS
 p5EORhjumYI53I+RrfVC82Oja5EKDuK2tNhAnALt1zKD1KRsk6RPUfU9+UFWO6ZIZNCKfYuPcH7
 gNYRjGyfZReA3wiTo3lTs32PE8SqlYD6qTRFJEgoh2HCmAUjMah8jrkXHi42fCcrBnY5z6ta1q7
 z1DfB+nrZcRLCqR0MORQuYPRDMVzSKtECw+t11gMT+cKmUTClxilHzm89yiNeM/mUt0fh7ee2/K
 tarVfWYf3SKvKANwlYNhsFK4/YBT+Sz2thghsG+jo0b8CLfOK6O+Q40U1yx5xfubazJNSusAbrt
 Ruko/cyWCq9x5QyjE78gCUyTIewPAvef/9Ocy8mfxgm3dyo+wE0Mv3Zi3IC1HGO1oFnUiAtZaM6
 9RX8nE7zyDU6Bm8n4dlY/1t+daYEA70bQvWF/MjzsDC4qswXy40YQm3rQrYH4rEqdK3KCfwouY+
 dWOb5NCkpdDHkLaKY/fx6JF3/+qp6LS524iv+YQqxGws+UZ8kWvYPKQF7hMY7jwoDe+SiJIPjrr
 Kxbe1MDAsDx/IEA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Cover the flag that moves rpcbind registration to the caller.

rpcb_userspace_no_traffic is the one that matters. The errno says nothing
about whether the kernel talked to rpcbind, but the stub counters do: a
request that carries the flag must leave both at zero, which is what shows
that svc_bind() and svc_register() were both skipped.

The rest cover the reply and the ownership rule:

- rpcb_userspace_reply. The ack flag, a non-empty program list, and the
  listener that came up. nfslocalio is hidden, so it must be absent.
- rpcb_userspace_no_v4_udp. NFSv4 carries no-udp and NFSv3 does not.
- rpcb_userspace_nfsacl_follows_nfs. CONFIG_NFSD_V3_ACL is invisible to the
  test, so assert only that nfsacl v3 implies nfs v3.
- rpcb_userspace_busy and rpcb_userspace_busy_reverse. Ownership cannot
  change under a live serv, in either direction.
- rpcb_userspace_teardown. Create and destroy a flagged serv three times,
  then confirm that a kernel-owned serv still reaches rpcbind. An
  unbalanced rpcb_put_local() would break the last step.
- rpcb_userspace_many_listeners. Forty listeners, which is more than
  GENLMSG_DEFAULT_SIZE would have held. A reply sized from that constant
  instead of from its contents returns -EMSGSIZE with every listener
  already up.

genl_request_reply() grew an attribute argument, because listener_set now
answers with a reply message rather than a bare ack.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 284 ++++++++++++++++++++-
 1 file changed, 281 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index 106360f87b99..56ac2c11c07f 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -46,6 +46,9 @@
 
 #include "../kselftest_harness.h"
 
+#define NFS_PROGRAM			100003
+#define NFS_ACL_PROGRAM			100227
+
 #define NLA_ALIGN4(len)			(((len) + 3) & ~3)
 #define TEST_PORT			20049
 #define MAX_LISTENERS			8
@@ -173,15 +176,24 @@ static int genl_request(uint8_t cmd, const char *attrs, int attrs_len)
 	return ret;
 }
 
-/* Send a command and return the full reply message; -errno on failure. */
-static int genl_request_reply(uint8_t cmd, char *rbuf, size_t rlen)
+/*
+ * Send a command with attributes and return the full reply message; -errno
+ * on failure. NLM_F_ACK is left off: the kernel reports an error either way,
+ * so the first message back is the reply whenever there is one.
+ */
+static int genl_request_reply_attrs(uint8_t cmd, const char *attrs,
+				    int attrs_len, char *rbuf, size_t rlen)
 {
-	char buf[256];
+	char buf[1 << 20];
 	struct nlmsghdr *nlh = (void *)buf;
 	int fd = genl_open();
 	int off, n, ret;
 
 	off = genl_hdr(buf, nfsd_family, NLM_F_REQUEST, cmd);
+	if (attrs_len) {
+		memcpy(buf + off, attrs, attrs_len);
+		off += attrs_len;
+	}
 	nlh->nlmsg_len = off;
 
 	if (send(fd, buf, off, 0) < 0)
@@ -198,6 +210,11 @@ static int genl_request_reply(uint8_t cmd, char *rbuf, size_t rlen)
 	return ret;
 }
 
+static int genl_request_reply(uint8_t cmd, char *rbuf, size_t rlen)
+{
+	return genl_request_reply_attrs(cmd, NULL, 0, rbuf, rlen);
+}
+
 /* Resolve the "nfsd" genl family id; -1 if not registered. */
 static int genl_resolve_nfsd(void)
 {
@@ -383,6 +400,111 @@ static int version_set_only(uint32_t major, uint32_t minor)
 	return genl_request(NFSD_CMD_VERSION_SET, attrs, NLA_ALIGN4(inner));
 }
 
+/* ------------------- userspace-rpcbind ------------------- */
+
+struct rpcb_ent {
+	uint32_t program;
+	uint32_t version;
+	uint32_t flags;
+};
+
+/* More listeners than GENLMSG_DEFAULT_SIZE would have held. */
+#define RPCB_MANY_LISTENERS		40
+
+struct rpcb_reply {
+	int acked;			/* saw NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND */
+	int nprog;
+	struct rpcb_ent prog[16];
+	int naddr;			/* every addr nest, not just the stored ones */
+	int nlistener;
+	struct listener_ent listener[MAX_LISTENERS];
+};
+
+/* Append the userspace-rpcbind request flag. */
+static int put_userspace_rpcbind(char *buf, int off)
+{
+	return put_attr(buf, off, NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND, NULL, 0);
+}
+
+static void parse_rpcb_nest(const struct nlattr *na, struct rpcb_ent *e)
+{
+	const struct nlattr *in = (const void *)((const char *)na + NLA_HDRLEN);
+	int ileft = na->nla_len - NLA_HDRLEN;
+
+	memset(e, 0, sizeof(*e));
+	while (ileft >= (int)NLA_HDRLEN) {
+		const void *d = (const char *)in + NLA_HDRLEN;
+
+		switch (in->nla_type & NLA_TYPE_MASK) {
+		case NFSD_A_RPCBIND_PROGRAM:
+			e->program = *(const uint32_t *)d;
+			break;
+		case NFSD_A_RPCBIND_VERSION:
+			e->version = *(const uint32_t *)d;
+			break;
+		case NFSD_A_RPCBIND_FLAGS:
+			e->flags = *(const uint32_t *)d;
+			break;
+		}
+		ileft -= NLA_ALIGN4(in->nla_len);
+		in = (const void *)((const char *)in + NLA_ALIGN4(in->nla_len));
+	}
+}
+
+/*
+ * Send a listener_set that asks to own rpcbind, and parse the reply.
+ * Returns 0 on success or -errno.
+ */
+static int listener_set_rpcb(char *attrs, int off, struct rpcb_reply *out)
+{
+	char rbuf[64 * 1024];
+	const struct nlmsghdr *nlh = (const void *)rbuf;
+	const struct nlattr *na;
+	int left, n;
+
+	off = put_userspace_rpcbind(attrs, off);
+	memset(out, 0, sizeof(*out));
+
+	n = genl_request_reply_attrs(NFSD_CMD_LISTENER_SET, attrs, off,
+				     rbuf, sizeof(rbuf));
+	if (n < 0)
+		return n;
+
+	out->nlistener = parse_listener_get(rbuf, n, out->listener,
+					    MAX_LISTENERS);
+
+	na = (const void *)(rbuf + NLMSG_HDRLEN + GENL_HDRLEN);
+	left = nlh->nlmsg_len - NLMSG_HDRLEN - GENL_HDRLEN;
+	while (left >= (int)NLA_HDRLEN) {
+		switch (na->nla_type & NLA_TYPE_MASK) {
+		case NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND:
+			out->acked = 1;
+			break;
+		case NFSD_A_SERVER_SOCK_ADDR:
+			out->naddr++;
+			break;
+		case NFSD_A_SERVER_SOCK_RPCBIND:
+			if (out->nprog < (int)ARRAY_SIZE(out->prog))
+				parse_rpcb_nest(na, &out->prog[out->nprog++]);
+			break;
+		}
+		left -= NLA_ALIGN4(na->nla_len);
+		na = (const void *)((const char *)na + NLA_ALIGN4(na->nla_len));
+	}
+	return 0;
+}
+
+static struct rpcb_ent *find_rpcb(struct rpcb_reply *r, uint32_t prog,
+				  uint32_t vers)
+{
+	int i;
+
+	for (i = 0; i < r->nprog; i++)
+		if (r->prog[i].program == prog && r->prog[i].version == vers)
+			return &r->prog[i];
+	return NULL;
+}
+
 /* Fetch the current listeners; returns count (>=0) or -errno. */
 static int listener_get(struct listener_ent *out, int max)
 {
@@ -1282,6 +1404,162 @@ TEST_F(nfsd_listener, rpcb_unreg_stop_after_failure)
 	EXPECT_LE(three, one);
 }
 
+/* ===================== userspace rpcbind ===================== */
+
+/*
+ * The point of the flag: nfsd must make no rpcbind call at all. svc_bind()
+ * pings rpcbind at client creation and svc_register() calls it once per
+ * program and version, so a silent stub is what proves both were skipped.
+ */
+TEST_F(nfsd_listener, rpcb_userspace_no_traffic)
+{
+	struct rpcb_reply r;
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, rpcb_conns());
+	ASSERT_EQ(0, listener_set_rpcb(attrs, off, &r));
+	EXPECT_EQ(0, rpcb_conns());
+	EXPECT_EQ(0, rpcb_calls());
+}
+
+/*
+ * The reply has to tell the caller what to register. Without the program
+ * list it cannot know whether nfsacl is built in.
+ */
+TEST_F(nfsd_listener, rpcb_userspace_reply)
+{
+	struct rpcb_reply r;
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set_rpcb(attrs, off, &r));
+	EXPECT_EQ(1, r.acked);
+	EXPECT_GT(r.nprog, 0);
+	/* the listener came up and is named, so the caller knows the port */
+	ASSERT_EQ(1, r.nlistener);
+	EXPECT_NE(NULL, find_listener(r.listener, r.nlistener, "tcp",
+				      AF_INET, TEST_PORT));
+	/* nfslocalio is hidden and must never be offered for registration */
+	EXPECT_EQ(NULL, find_rpcb(&r, 400122, 1));
+}
+
+/*
+ * nfsd_nl_validate_listeners() allows far more listeners than the default
+ * genl buffer holds, so the reply has to be sized from its contents. If it
+ * is not, the listeners all come up and the caller still sees -EMSGSIZE.
+ */
+TEST_F(nfsd_listener, rpcb_userspace_many_listeners)
+{
+	char attrs[RPCB_MANY_LISTENERS * 64];
+	struct rpcb_reply r;
+	int off = 0, i;
+
+	for (i = 0; i < RPCB_MANY_LISTENERS; i++)
+		off = put_listener(attrs, off, "tcp", TEST_PORT + i);
+
+	ASSERT_EQ(0, listener_set_rpcb(attrs, off, &r));
+	EXPECT_EQ(1, r.acked);
+	EXPECT_GT(r.nprog, 0);
+	EXPECT_EQ(RPCB_MANY_LISTENERS, r.naddr);
+}
+
+/*
+ * NFSv4 sets vs_need_cong_ctrl, so the kernel never registered it on UDP.
+ * The reply cannot filter it out, because the rule depends on the listener,
+ * so it must carry the flag instead.
+ */
+TEST_F(nfsd_listener, rpcb_userspace_no_v4_udp)
+{
+	struct rpcb_ent *v4, *v3;
+	struct rpcb_reply r;
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set_rpcb(attrs, off, &r));
+
+	v4 = find_rpcb(&r, NFS_PROGRAM, 4);
+	if (v4)
+		EXPECT_EQ(NFSD_RPCBIND_FLAGS_NO_UDP,
+			  v4->flags & NFSD_RPCBIND_FLAGS_NO_UDP);
+
+	v3 = find_rpcb(&r, NFS_PROGRAM, 3);
+	if (v3)
+		EXPECT_EQ(0, v3->flags & NFSD_RPCBIND_FLAGS_NO_UDP);
+}
+
+/*
+ * nfsacl is the value userland cannot derive: CONFIG_NFSD_V3_ACL is not
+ * visible over netlink. Only assert self-consistency -- if the kernel
+ * offers nfsacl v3 then it must also offer nfs v3, since both gate on the
+ * same enabled version.
+ */
+TEST_F(nfsd_listener, rpcb_userspace_nfsacl_follows_nfs)
+{
+	struct rpcb_reply r;
+	char attrs[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set_rpcb(attrs, off, &r));
+	if (find_rpcb(&r, NFS_ACL_PROGRAM, 3))
+		EXPECT_NE(NULL, find_rpcb(&r, NFS_PROGRAM, 3));
+}
+
+/*
+ * svc_bind() decided whether to take the rpcb_users reference that teardown
+ * drops, so ownership cannot flip under a live serv.
+ */
+TEST_F(nfsd_listener, rpcb_userspace_busy)
+{
+	struct rpcb_reply r;
+	char attrs[64], plain[64];
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	int poff = put_listener(plain, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set_rpcb(attrs, off, &r));
+
+	/* same listeners, but now asking the kernel to own rpcbind */
+	EXPECT_EQ(-EBUSY, listener_set(plain, poff));
+	EXPECT_STRNE("", last_extack);
+}
+
+/* And the same the other way round. */
+TEST_F(nfsd_listener, rpcb_userspace_busy_reverse)
+{
+	struct rpcb_reply r;
+	char attrs[64], plain[64];
+	int poff = put_listener(plain, 0, "tcp", TEST_PORT);
+	int off = put_listener(attrs, 0, "tcp", TEST_PORT);
+
+	ASSERT_EQ(0, listener_set(plain, poff));
+	EXPECT_EQ(-EBUSY, listener_set_rpcb(attrs, off, &r));
+}
+
+/*
+ * rpcb_create_local() increments sn->rpcb_users and rpcb_put_local()
+ * decrements it. A serv that never took the reference must not drop it, or
+ * the next serv finds the count wrong. Cycle a few times, then confirm a
+ * kernel-owned serv can still reach rpcbind.
+ */
+TEST_F(nfsd_listener, rpcb_userspace_teardown)
+{
+	struct rpcb_reply r;
+	char attrs[64], plain[64];
+	int off, poff, i;
+
+	for (i = 0; i < 3; i++) {
+		off = put_listener(attrs, 0, "tcp", TEST_PORT);
+		ASSERT_EQ(0, listener_set_rpcb(attrs, off, &r));
+		/* empty list with no threads destroys the serv */
+		ASSERT_EQ(0, listener_set_rpcb(attrs, 0, &r));
+		ASSERT_EQ(0, rpcb_conns());
+	}
+
+	poff = put_listener(plain, 0, "tcp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(plain, poff));
+	EXPECT_GT(rpcb_conns(), 0);
+}
+
 /* ===================== threads / -EBUSY semantics ===================== */
 
 TEST_F(nfsd_listener, sem_busy_on_change)

-- 
2.55.0

