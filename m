Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 880B6399036;
	Fri, 28 Aug 2026 16:38:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935089; cv=none; b=ivXkj3e2kKwRCt8rErqi/6WH9Zv8rPm1uNgFuqfCRkjs4d2Os5p9INaW49vIqyzPTVe8GAw7LJM/BbzpA59PUZ8dbFWWTktsWhKAPRtnnZc/DQFeh/nx5xrHk/BrVnBDDdmoKg2kbrlrHmdaup9vWXaTKAV6vDK+N79vbsI2N/4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935089; c=relaxed/simple;
	bh=MIR3rubKscsZidNahSMzjgOnE9yq2FwNrVqOoqV3JX4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Gq1TAUvmDrmmwAVvBqEBVPuOlcZnqJk+DF6MZ/pr4GOfBA73f4HyP2cWqh+9/DLfFC2AT1+R9eajmpSpsL18JIdxPwim0XnzmiGYv6J5TYNQbcP2+gda7ktHV5qOiYhx5JDSL6/KYBmpeqg9NoyKuKtM9LExHD4XF+/nknHYnUU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jliM5px3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jliM5px3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F9B21F00A3F;
	Fri, 28 Aug 2026 16:38:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935087;
	bh=wRFZHmFVeVOFufoeeCToiP5M0y58uqHGKptV/fgLHx8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jliM5px3NtjYvmkTjzqPuQvEgVWzRB0vfYhDWxkfwuK/Uu2GZw4F6L9upcp4tAbGY
	 w7PzIv8ZQY5+OjW/i17Gv7PBB86SWLEqBFA8wwlx57hCz0qzmmZSRCXJMVSNDN0inX
	 T+HTrJ0wRVHsDQDWiVfrTWG7oKCVJZ52BQrI346rGL9GLFdN9Lfd7jTi5ciMube6xq
	 M3pwQaWHxoznpJiFo11vbKeRd5+sba3JTlpc3dcf+x2uILsi2CZCEwpthFWXlNobEQ
	 TyrL5nqCO3iW4MuPuyflXH/3JH2VxXu02ZfW6autP7PndoOvxbPDY2xdVTpaQANL23
	 lHhUXUYaJhFVg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:43 -0400
Subject: [PATCH v3 13/14] selftests/nfsd: check that listener_set asks
 rpcbind once
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-13-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=11536; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=MIR3rubKscsZidNahSMzjgOnE9yq2FwNrVqOoqV3JX4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblXdAsAb+KSFhAmiMnueC+KEKde+sgYFsXO1
 RZj+YjW4EeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VwAKCRAADmhBGVaC
 FeoFD/4yOzCIj+LKHcaSxFjS4Fa5fPhonY2BhHBMvv4zK0CLOIrbxgx9+zwJ5kMptzNqHPRUSrs
 LRVgRoUWdIVsawWSaN/QwcRdcf5++eaNmhF3CdMR25z1kxF2pGPEq7HsiVCwZ1Fg1G1f5ssuZ+7
 YXOl/2WOuSVmSGOxvEeQaZFnWvXpFmeJraln5xK97ULuBhwgTRjAYPdsSnUEza07x4l74NHBnnG
 gaS6Oa2RMOq2NULNphB78YxEuRLs2XTXjVgtCFZnwGIVbXuPpfpoFomEksioHY7Y3EZvjpyn2Ur
 v7xgYJt0Ipu++6wrVHRpWUsKJy3Ggty6NYks5S9JFytm3pMPKLELpes8k+4j5dQ6ZqLgs3jmLvl
 C+P/U0w+DBU4zCh81cWoFN0CvzJar1wFJiqaRupJ0ZTsGCP3uh2rSlvQpfh92N6YhWJU3wkbbYb
 4I1FbS8d8qM00RJLmniKtU/+UeohhMWZPPGFhaw5eXDbFM9KmLdMf66TKGBNWLWa3tLCErdFDcq
 2TQ2PeJWXSWTXHa4U3HbfRm/YpbDAI7AnviMxaHTRiOlXx3cSDGcbX03r1PBmYAof6OLKR7y5d8
 QAX+iLZthernQYLhxsrNYicXAZ9uCqlJTWDlCHpIcMA93fd3wpqrgAc+sDrZh58S+HtPE7Uw1Yd
 laEUBpIo6wxhcdQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Cover the change that stops a listener_set request from registering after
rpcbind stops answering.

RPCB_STUB_SILENT is new. It reads a call and writes nothing back, so the
kernel waits out its own timeout. RPCB_STUB_REFUSE cannot serve here: a
refusal is an answer, and the count ignores it on purpose.

Every procedure but the NULL one is silenced, so an unregistration goes
unanswered as well. The NULL one has to be answered:
rpcb_create_af_local() builds its client without RPC_CLNT_CREATE_NOPING, so
rpc_create() pings at creation. Silencing that ping too would fail the
AF_LOCAL client, send rpcb_create_local() on to the loopback client of
rpcb_create_local_net(), and leave the stub seeing one call per request no
matter how many listeners it carried.

- rpcb_stop_after_failure. Ask for one listener, then for three, and
  compare what the stub saw. Three entries must not cost three times as
  much.
- rpcb_silent_set_complete. The entry that finds rpcbind silent is the one
  that pays the timeout, and with v3 enabled it is the only entry whose
  listener would be lost. Require that a three-entry request brings up all
  three, succeeds, and warns.
- rpcb_v4_only_bounded. The case that needs the count rather than a failed
  listener. version_set_only() makes the server v4-only, so vs_rpcb_optnl
  discards every error and every listener comes up. Require that the
  listeners are present, that the ack warns about them, and that three
  entries do not cost three round trips.
- rpcb_retry_next_request. The stop lasts for one request. After the stub
  starts to answer, the next request must reach rpcbind again.

The counts these tests compare include the unregistrations that the
teardown between the two measurements issues. The preceding patches bound
that direction too, so the sweeps stay at one timeout rather than one per
program and version.

version_set_only() is new. NFSD_CMD_VERSION_SET clears every version
before it reads the request, so one nest leaves the server v4-only. It
returns -EBUSY once a serv exists, so the test calls it first.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 188 ++++++++++++++++++++-
 1 file changed, 186 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index 99c320e2f7c2..511d20566ff3 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -48,12 +48,17 @@
 /* NFSD generic-netlink constants (from linux/nfsd_netlink.h). */
 #define NFSD_FAMILY_NAME		"nfsd"
 #define NFSD_CMD_THREADS_SET		2
+#define NFSD_CMD_VERSION_SET		4
 #define NFSD_CMD_LISTENER_SET		6
 #define NFSD_CMD_LISTENER_GET		7
 #define NFSD_A_SERVER_THREADS		1
 #define NFSD_A_SERVER_SOCK_ADDR		1	/* per-listener nest */
 #define NFSD_A_SOCK_ADDR		1	/* inside the nest */
 #define NFSD_A_SOCK_TRANSPORT_NAME	2	/* inside the nest */
+#define NFSD_A_SERVER_PROTO_VERSION	1	/* per-version nest */
+#define NFSD_A_VERSION_MAJOR		1	/* inside the version nest */
+#define NFSD_A_VERSION_MINOR		2	/* inside the version nest */
+#define NFSD_A_VERSION_ENABLED		3	/* inside the version nest */
 
 #define NLA_ALIGN4(len)			(((len) + 3) & ~3)
 #define TEST_PORT			20049
@@ -370,6 +375,28 @@ static int listener_set(const char *attrs, int len)
 	return genl_request(NFSD_CMD_LISTENER_SET, attrs, len);
 }
 
+/*
+ * Enable exactly one NFS version in this netns. NFSD_CMD_VERSION_SET clears
+ * every version first, so one nest is enough to leave the server v4-only.
+ * It refuses once a serv exists, so call it before any listener.
+ */
+static int version_set_only(uint32_t major, uint32_t minor)
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
 /* Fetch the current listeners; returns count (>=0) or -errno. */
 static int listener_get(struct listener_ent *out, int max)
 {
@@ -440,6 +467,14 @@ static int threads_set(int n)
  * rpcb_register_call() reports as -EACCES. UNSET is left alone: only
  * svc_unregister() issues it, and it discards the result.
  *
+ * In RPCB_STUB_SILENT mode a SET or an UNSET is read and nothing is written
+ * back, so the kernel waits out its own timeout. That is the only mode that
+ * makes rpcb_register_call() report a call that got no answer, which is what
+ * the per-net failure count records. The NULL procedure is still answered:
+ * rpcb_create_af_local() builds its client without RPC_CLNT_CREATE_NOPING, so
+ * rpc_create() pings, and a ping that goes unanswered drops the kernel onto
+ * the loopback rpcb_create_local_net() client, which never reaches this stub.
+ *
  * The stub also keeps counters and the mode in a page shared with the test, so
  * a test can assert that the kernel never talked to rpcbind at all, or that it
  * dropped the local rpcbind client and had to reconnect.
@@ -457,7 +492,7 @@ static int threads_set(int n)
 #define RPCB_ABSTRACT_NAME	"/run/rpcbind.sock"
 #define RPCB_STUB_MAXCONN	4
 
-enum { RPCB_STUB_ACCEPT, RPCB_STUB_REFUSE };
+enum { RPCB_STUB_ACCEPT, RPCB_STUB_REFUSE, RPCB_STUB_SILENT };
 
 struct rpcb_stub_stats {
 	unsigned int conns;		/* connections accepted */
@@ -572,7 +607,9 @@ static int rpcb_stub_call(int fd)
 	if (ntohl(call[3]) != RPCB_PROGRAM) {
 		rep[5] = htonl(1);	/* PROG_UNAVAIL */
 	} else {
-		switch (ntohl(call[5])) {
+		unsigned int proc = ntohl(call[5]);
+
+		switch (proc) {
 		case RPCB_PROC_NULL:
 			break;
 		case RPCB_PROC_SET:
@@ -586,6 +623,15 @@ static int rpcb_stub_call(int fd)
 		default:
 			rep[5] = htonl(3);	/* PROC_UNAVAIL */
 		}
+
+		/*
+		 * Answer nothing, so the caller waits out its timeout. The
+		 * NULL procedure is answered even here: the kernel pings at
+		 * client creation, and a ping with no answer takes it off
+		 * this socket entirely.
+		 */
+		if (mode == RPCB_STUB_SILENT && proc != RPCB_PROC_NULL)
+			return 0;
 	}
 
 	replen = nrep * sizeof(rep[0]);
@@ -1064,6 +1110,144 @@ TEST_F(nfsd_listener, sem_create_failure_extack)
 	close(s);
 }
 
+/* ============ one rpcbind attempt for each request ============ */
+
+/*
+ * Every listener used to register on its own, so a rpcbind that never
+ * answers cost one timeout for each entry. Ask for one listener, then for
+ * three, and compare what the stub saw. Three entries must not cost three
+ * times as much.
+ *
+ * The stub has to stay silent rather than refuse. A refusal is an answer,
+ * and rpcbind refuses one entry at a time, so the count ignores it.
+ */
+TEST_F(nfsd_listener, rpcb_stop_after_failure)
+{
+	int before, one, three, off;
+	char attrs[192];
+
+	rpcb_stub_set_mode(RPCB_STUB_SILENT);
+
+	before = rpcb_calls();
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	listener_set(attrs, off);
+	one = rpcb_calls() - before;
+	ASSERT_GT(one, 0);
+
+	ASSERT_EQ(0, listener_set(attrs, 0));
+
+	before = rpcb_calls();
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 1);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 2);
+	listener_set(attrs, off);
+	three = rpcb_calls() - before;
+
+	/* the second and third entries must not reach rpcbind at all */
+	EXPECT_LE(three, one);
+}
+
+/*
+ * The entry that finds rpcbind silent is the one that pays for the
+ * discovery, and v3 has no vs_rpcb_optnl to discard the error, so it is the
+ * only entry whose listener would be lost. Nothing distinguishes it from the
+ * rest of the request, and a retry of the same request would fail the same
+ * entry again, so the set would stay short for as long as rpcbind was quiet.
+ *
+ * Ask for three listeners against a silent stub and require the whole set,
+ * a success, and a warning that says why.
+ */
+TEST_F(nfsd_listener, rpcb_silent_set_complete)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	char attrs[192];
+	int off;
+
+	rpcb_stub_set_mode(RPCB_STUB_SILENT);
+
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 1);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 2);
+	EXPECT_EQ(0, listener_set(attrs, off));
+
+	/* the first entry is not the odd one out */
+	EXPECT_EQ(3, listener_get(got, MAX_LISTENERS));
+	/* no errno reports this, so the ack has to */
+	EXPECT_STRNE("", last_extack);
+}
+
+/*
+ * The case that needs the count rather than a failed listener. NFSv4 sets
+ * vs_rpcb_optnl, so svc_generic_rpcbind_set() discards the error, every
+ * listener comes up, and nothing reports a failure. Without the fix each
+ * entry still waits for rpcbind on its own.
+ *
+ * Make the server v4-only, answer no SET, and require three things: the
+ * listeners come up, the ack warns that they are not registered, and the
+ * stub does not see one round trip for each entry.
+ */
+TEST_F(nfsd_listener, rpcb_v4_only_bounded)
+{
+	struct listener_ent got[MAX_LISTENERS];
+	int before, one, three, off;
+	char attrs[192];
+
+	/* refuses once a serv exists, so this has to come first */
+	ASSERT_EQ(0, version_set_only(4, 1));
+	rpcb_stub_set_mode(RPCB_STUB_SILENT);
+
+	before = rpcb_calls();
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	ASSERT_EQ(0, listener_set(attrs, off));
+	one = rpcb_calls() - before;
+	ASSERT_GT(one, 0);
+
+	/* start over, so the second measurement also builds a serv */
+	ASSERT_EQ(0, listener_set(attrs, 0));
+
+	before = rpcb_calls();
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 1);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 2);
+	ASSERT_EQ(0, listener_set(attrs, off));
+	three = rpcb_calls() - before;
+
+	/* the listeners are up even though rpcbind never answered */
+	EXPECT_EQ(3, listener_get(got, MAX_LISTENERS));
+	/* and the ack says they are unregistered, since no errno can */
+	EXPECT_STRNE("", last_extack);
+	EXPECT_LE(three, one);
+}
+
+/*
+ * The stop applies to one request only. After rpcbind starts answering,
+ * the next request must register without any other step.
+ */
+TEST_F(nfsd_listener, rpcb_retry_next_request)
+{
+	int before, after, off;
+	char attrs[192];
+
+	rpcb_stub_set_mode(RPCB_STUB_SILENT);
+
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	off = put_listener(attrs, off, "tcp", TEST_PORT + 1);
+	listener_set(attrs, off);
+	ASSERT_EQ(0, listener_set(attrs, 0));
+
+	/* rpcbind recovers */
+	rpcb_stub_set_mode(RPCB_STUB_ACCEPT);
+
+	before = rpcb_calls();
+	off = put_listener(attrs, 0, "tcp", TEST_PORT);
+	EXPECT_EQ(0, listener_set(attrs, off));
+	after = rpcb_calls();
+
+	/* a fresh request starts from a fresh reading and tries again */
+	EXPECT_GT(after, before);
+	EXPECT_STREQ("", last_extack);
+}
+
 /* ===================== threads / -EBUSY semantics ===================== */
 
 TEST_F(nfsd_listener, sem_busy_on_change)

-- 
2.55.0

