Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA5E03A7F54;
	Tue,  1 Sep 2026 13:40:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270028; cv=none; b=L19fIzM+I7QzApTA1ULZUOmgHDVOxoqzlaCU63N7Spif7d+zz3VhAcjwWF2+0EgIS1yobsrueDUQKOVavzvqXt3mzoxDKvCEYtzuPXOX8HGZELzPiVaFF9HeCejAtAw1ZWJiIlpyIRyo2RW4E9DOIIob3v7dg8NbW75N81akq1c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270028; c=relaxed/simple;
	bh=ZdQ2DwHT6+BFMpslmGQ2xxKdyv96/k/ivRDtgIuGRWU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rNbAyDHgeh4t7vLyv0Lmw+t2llTs+ZPJeqm4d69DEWpUZyuUmnFdJAuc/WwIWVDZ+BDfPEPs10KIL8E+fg2nAFSe1ONYOMbVf4W7B5xz5kLGbLwwq0Jh7VmB/GfiV1ExO52DFSR2oFnybeT5GiCT6DFU8fs1QSsZjth4Bg5NjXU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OHdxrpRV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OHdxrpRV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 273CF1F00A3E;
	Tue,  1 Sep 2026 13:40:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270026;
	bh=sPiGeA0yUw9jwfTLJw/xxScsnI1bmbUKsOj3tK2uhro=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OHdxrpRV3RIUDL54ZwQpKSCnaSy7VLUucP7yfVOlaASSQnsmsQrJIutGPI6UVVJaf
	 GAju2CPjyoA3ynHSCw31QJfqRdfxnibUvrJx8+x7wSEpvJMwSuPYe5qLnoVJQ/FYEA
	 W6BhHNcUS/En6EChHBulduaN7f2wgbtK76IUkoALw8IbzXGKOzxo2co/LqRIKecjUc
	 5ZyTCxquZ7pDnu+fmRsKo7ZRX1XXtxIX5Qu72A26mdi/fv9RcHhCUPnM6AIvndJUZZ
	 RXCyjjo6fwJRRcMCSz4EfIA9PinN+MVIUXHlQL/j4PfVWbzxvFM47QL5bG7IQ5bKEN
	 L9BH18Ms/+8Gw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:52 -0400
Subject: [PATCH v5 14/15] selftests/nfsd: check that listener_set asks
 rpcbind once
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-14-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=10730; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ZdQ2DwHT6+BFMpslmGQ2xxKdyv96/k/ivRDtgIuGRWU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWx8jkKWLN8poS5xFkUxh9XnmfxekD5oyUAR
 HF4XMct/VSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVsQAKCRAADmhBGVaC
 FbRrEACaMdCVn1dHhfKwOn98PKc/P99/mEN/igzT3YuYioeb53aOpd7zs15kzSN5TO3PMq5MY0P
 8w1IcZ6SayUNXvER+ynf4fIfoqbH/524E8cE4GtLqgqpi1O8zVY04/jl0uknVSp/2qB7SlwQxvv
 +RCclRNcuuu3Sc4wWgkukZcTfXoDoeyXPDMEam9xJvVg3Fs70A/qo6Uepwgc1ti59/Kf0+ABhh/
 aA51ScF6OI788ssG3BqmgUEj0l3sUqvH2pqAilQHuVecED7WzWXnGmsEP70Am5e3C7dALOHyPi2
 fXRWCUG0o/E2hbr54np1Ui2EtHJ+isGlDvGMygM+lAhBWpAE0WYq7yfFIPdOdeuSHHuOVmRKzaU
 Soxj7QNJ1vXAjzxj0oqG5MedpFWipXLLyZ2rfap32ngEPzgW76Bi8LgYFP6emUqeMLuXazZSuvf
 MQubiMqF4dbG183VhRIXGXLwfncGVzFIUMyVPmzuDjCRpFT1W5tpu1RBExxT6FAgJKf/+l2Ijcn
 zLGkGdtMjQTBfd5VorwwidSYlLyyGjW9TtpK6cg4zRUdm7aPqmSmFnHOSvHtFKfBJG4wUWDlyfF
 qCStx7U/IG8FN6tQaqWgjlp9rD7czwis6mJAKHEfiaIwj7pIQJKbixJxh4rts+iP9TQbf45LnZ+
 Vfq9R6Ds+KYtf1Q==
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
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 183 ++++++++++++++++++++-
 1 file changed, 181 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
index 736691ce9a20..d0f4258f905d 100644
--- a/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
+++ b/tools/testing/selftests/nfsd/nfsd_netlink_listener.c
@@ -361,6 +361,28 @@ static int listener_set(const char *attrs, int len)
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
@@ -431,6 +453,14 @@ static int threads_set(int n)
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
@@ -448,7 +478,7 @@ static int threads_set(int n)
 #define RPCB_ABSTRACT_NAME	"/run/rpcbind.sock"
 #define RPCB_STUB_MAXCONN	4
 
-enum { RPCB_STUB_ACCEPT, RPCB_STUB_REFUSE };
+enum { RPCB_STUB_ACCEPT, RPCB_STUB_REFUSE, RPCB_STUB_SILENT };
 
 struct rpcb_stub_stats {
 	unsigned int conns;		/* connections accepted */
@@ -563,7 +593,9 @@ static int rpcb_stub_call(int fd)
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
@@ -577,6 +609,15 @@ static int rpcb_stub_call(int fd)
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
@@ -1064,6 +1105,144 @@ TEST_F(nfsd_listener, sem_create_failure_extack)
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

