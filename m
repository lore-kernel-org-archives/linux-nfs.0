Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8185D364052
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401658; cv=none; b=rDB+C/pLLIyErlRgdyUVznmTJBUf8UtZ3xIolT0sbvYN5CaX5/by2a0CpWO2MEx4bMHWxilMC3k1wKBYsPpce8HZimcOdKBFj/RFdCt4X7rH9xzmAY52AX7s2vttsJbAkWtCE0wawHLSBFJ3s50BMY0yV+GGVyLwHojA0las5NE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401658; c=relaxed/simple;
	bh=HV66NjgRXOc7O9I5nRpV/yHNCkTCRoFhNrXOszWao+k=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LlQuU+no4u6UpxNDz482tgUHIsRHg+rBnqsbVYNLZSnygVfEdEg4G0jRQ1x4n1UbQkMT2C8AbAAX8MSxWVmkpyolVBUn26K61qvV6C8ocfeJ0MXYjILpFKcRtgJknTuzeepchUfW10wGsWsEM2aVYvNk/0qTQzCfBIMyDQB5MI0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MGMS/rDe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MGMS/rDe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A81661F000FF;
	Mon, 14 Sep 2026 16:00:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401656;
	bh=AjBpv8kBbaxwtLzgn4KmMBb+370QOw6l1VWYQ21ZvEY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MGMS/rDeDAXG3xBN4hhhsHdEiI1X2m6cDwq4X+LqCyR9mBRZnb6c3Zl9l2YjLx1b7
	 0+EhYgBQmNVpJu2Eey+bienDDohCNWhgURNszYlluW5Fmbp81wBA/zqLzo6gcWOM1W
	 LshS8ynhycqEQbquIXQBQBFamBBeOESdXhdkSgWdtDMmeVqQiDaHL0Z+oHiOj0P1JE
	 HCs0gDWs7tzCaLNKJdt54m/C7nQNB1cHBdmeVlyvDe/y4jhkOn1eNqrV708Pmh9DW3
	 xjFXoiJSCbqHS3vSW9UrokmD6iP4dw5dWRUAC8oW0ZwAjr4m7D+qMWIXfDBopozXtw
	 e4CT2Nd1AcRXw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:33 -0400
Subject: [PATCH RFC nfs-utils v2 05/10] nfsdctl: register nfsd listeners
 with rpcbind
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-5-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=10183; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=HV66NjgRXOc7O9I5nRpV/yHNCkTCRoFhNrXOszWao+k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBoxlU/rIT53gqYVK5VvvFsXZP8z/uPpi9UrN
 91UlMD9oKqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMQAKCRAADmhBGVaC
 FclfEACpJKdIra/2Irw5aSeRfu6Qo98s/zH+GRtwi0IMprU12S8YK5F4aXNO+gwk+V7j7YV4lfZ
 LenPApeDlgkLVgbk7gXNH+zVCoboDzyeEnYCOe0ziOm4uotW+KMOBe+bLQ3mWpHAs71KVJ6TQB4
 Jw/vTCKbWoDyeFBCErhUYF7aJ4HMQNWHTpRa2LRLhQ4aNuOfRK9hIawyDHVMMnjkxN9uh1m0sy7
 ptmy6b/cVgltN/GxCeq6/RdGvrnbk2l5U1Wl+rKCTky0AgSWvh3II7NCfkAxccIAlgbekTLISsd
 F07qw3wapYT1a9yDHYlinLm3vbi1kwiOrULToMQhr9HSHcu+ORX8WEnHK3j9IeUpSAlDQzgpzZ4
 P2ocSDfmnbCfNgI1xHfcrqlhd0KAm1HYIuYuE2nIS8YHEV87vQZV+zgiQnhzzN/H7FjeO8sJ9FJ
 CSMyZgkTMXceW6FnqILraKmXB7kzvMZa+A0mI1M9tN0/hyexWrYjIHstF75rzieWG539wiAZ92/
 YFK1iZS1kVajT2B938oEKFSOznVZd8Lek8CTRfD4qAqQ4cTurEffzvKKBCm/TMQFM912gfYmzsw
 vWC1PL8jikpZ/sNGlURDE5ZfrAZ7Je3V9S5QBh6B3DU08EIlSOpJsr+0I62FTMBVZ8jGXZ0iBtN
 lDjOTDfV9DNbTyw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The kernel registered NFS and NFSACL under nfsd_mutex. Every call was
synchronous. A local rpcbind that never replied therefore blocked every
other NFSD netlink command, and tripped the hung-task watchdog.

A kernel that offers NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND makes no
rpcbind call of its own. It answers a listener_set that carries the flag
with the programs to register and the listeners that started. This
program now does three steps instead:

  1: send the flag
  2: read the reply
  3: register the listeners, where nothing holds a lock

Read the maximum attribute of LISTENER_SET to detect support. This adds
no configuration. An older kernel does not offer the attribute, so that
kernel keeps the registration. A build without TI-RPC has no rpcb_set(),
so it reports no support either and leaves the kernel in charge.

nfsdctl clears every nfsd entry before it registers. rpcbind matches an
unset on [program, version, netid] and takes no address, so an unset
cannot drop one of two TCP ports. The sweep also replaces the
svc_unregister() that svc_rpcb_setup() ran at serv creation. An
sv_no_rpcbind serv no longer reaches that call.

That sweep makes step 2 load-bearing, so register only once the reply
has been parsed. A reply that carries no rpcbind attributes would
otherwise clear every NFS and NFSACL entry and put nothing back, leaving
a running server that advertises nothing.

Abort if the flag does not fit in the message. Sending without it leaves
the kernel owning rpcbind while this program rewrites the same entries.

The reply names only the listeners that started. A request that failed
part way therefore registers what exists, not what the caller asked for.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.8    |  16 ++++++
 utils/nfsdctl/nfsdctl.adoc |  17 ++++++
 utils/nfsdctl/nfsdctl.c    | 125 ++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 156 insertions(+), 2 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.8 b/utils/nfsdctl/nfsdctl.8
index 1f526e77bebf..d90f1eb96a41 100644
--- a/utils/nfsdctl/nfsdctl.8
+++ b/utils/nfsdctl/nfsdctl.8
@@ -337,6 +337,22 @@ interface to achieve the same goals.
 Most of the commands that query the NFS server can be run as an unprivileged
 user, but configuring the server typically requires an account with elevated
 privileges.
+.SS "rpcbind registration"
+.sp
+On a kernel that supports it, nfsdctl registers the NFS and NFSACL programs
+with the local rpcbind itself. The kernel made those calls while it held an
+internal mutex, where a slow rpcbind blocked every other NFSD netlink
+command. nfsdctl detects support and needs no configuration.
+.sp
+nfsdctl registers the listeners after it sets them, and it clears the
+entries when the last thread stops. A failed registration is not fatal. The
+server starts, but a client that looks the server up in rpcbind cannot find
+it. NFSv4 does not need rpcbind, and a v2 or v3 client that already knows
+the port does not need it either.
+.sp
+RDMA listeners are not registered, which matches what the kernel did.
+.sp
+lockd still registers NLM itself on every kernel.
 .SH "SEE ALSO"
 .sp
 nfs.conf(5), rpc.nfsd(8), rpc.mountd(8), exports(5), exportfs(8), rpc.rquotad(8), nfsstat(8), netconfig(5)
diff --git a/utils/nfsdctl/nfsdctl.adoc b/utils/nfsdctl/nfsdctl.adoc
index e85348e29ed8..bd21234b0d9d 100644
--- a/utils/nfsdctl/nfsdctl.adoc
+++ b/utils/nfsdctl/nfsdctl.adoc
@@ -176,6 +176,23 @@ Most of the commands that query the NFS server can be run as an unprivileged
 user, but configuring the server typically requires an account with elevated
 privileges.
 
+=== rpcbind registration
+
+On a kernel that supports it, nfsdctl registers the NFS and NFSACL programs
+with the local rpcbind itself. The kernel made those calls while it held an
+internal mutex, where a slow rpcbind blocked every other NFSD netlink
+command. nfsdctl detects support and needs no configuration.
+
+nfsdctl registers the listeners after it sets them, and it clears the
+entries when the last thread stops. A failed registration is not fatal. The
+server starts, but a client that looks the server up in rpcbind cannot find
+it. NFSv4 does not need rpcbind, and a v2 or v3 client that already knows
+the port does not need it either.
+
+RDMA listeners are not registered, which matches what the kernel did.
+
+lockd still registers NLM itself on every kernel.
+
 == SEE ALSO
 
 nfs.conf(5), rpc.nfsd(8), rpc.mountd(8), exports(5), exportfs(8), rpc.rquotad(8), nfsstat(8), netconfig(5)
diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 860ea9c09ad2..699947e4507f 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -59,6 +59,9 @@ static int nfsd_nl_family;
 /* The highest attribute index supported by NFSD_CMD_THREADS_SET on this kernel */
 int nfsd_threads_max_nlattr;
 
+/* The same for NFSD_CMD_LISTENER_SET */
+int nfsd_listener_max_nlattr;
+
 struct nfs_version {
 	uint8_t	major;
 	uint8_t	minor;
@@ -78,6 +81,15 @@ struct nfs_version nfsd_versions[MAX_NFS_VERSIONS];
 int nfsd_socket_count;
 struct server_socket nfsd_sockets[MAX_NFSD_SOCKETS];
 
+/* Programs the kernel reported in the last LISTENER_SET reply. */
+#define MAX_RPCB_PROGS			16
+
+static int nfsd_rpcb_prog_count;
+static struct nfsd_rpcb_prog nfsd_rpcb_progs[MAX_RPCB_PROGS];
+
+/* Did a LISTENER_SET reply actually reach parse_listener_set()? */
+static bool nfsd_rpcb_reply_seen;
+
 const char *taskname;
 
 static const struct option help_only_options[] = {
@@ -304,6 +316,57 @@ static void parse_listener_get(struct genlmsghdr *gnlh)
 	nfsd_socket_count = idx;
 }
 
+/*
+ * A LISTENER_SET that asked to own rpcbind answers with the programs to
+ * register and the listeners that came up.
+ */
+static void parse_listener_set(struct genlmsghdr *gnlh)
+{
+	struct nlattr *attr;
+	int rem, idx = 0;
+
+	memset(nfsd_sockets, '\0', sizeof(*nfsd_sockets) * MAX_NFSD_SOCKETS);
+	nfsd_rpcb_prog_count = 0;
+
+	nla_for_each_attr(attr, genlmsg_attrdata(gnlh, 0),
+			  genlmsg_attrlen(gnlh, 0), rem) {
+		struct nfsd_rpcb_prog *p;
+		struct nlattr *a;
+		int i;
+
+		switch (nla_type(attr)) {
+		case NFSD_A_SERVER_SOCK_ADDR:
+			if (idx >= MAX_NFSD_SOCKETS)
+				break;
+			parse_sock_nest(attr, &nfsd_sockets[idx]);
+			++idx;
+			break;
+		case NFSD_A_SERVER_SOCK_RPCBIND:
+			if (nfsd_rpcb_prog_count >= MAX_RPCB_PROGS)
+				break;
+			p = &nfsd_rpcb_progs[nfsd_rpcb_prog_count];
+			memset(p, '\0', sizeof(*p));
+			nla_for_each_nested(a, attr, i) {
+				switch (nla_type(a)) {
+				case NFSD_A_RPCBIND_PROGRAM:
+					p->program = nla_get_u32(a);
+					break;
+				case NFSD_A_RPCBIND_VERSION:
+					p->version = nla_get_u32(a);
+					break;
+				case NFSD_A_RPCBIND_FLAGS:
+					p->flags = nla_get_u32(a);
+					break;
+				}
+			}
+			++nfsd_rpcb_prog_count;
+			break;
+		}
+	}
+	nfsd_socket_count = idx;
+	nfsd_rpcb_reply_seen = true;
+}
+
 static void parse_threads_get(struct genlmsghdr *gnlh)
 {
 	struct nlattr *attr;
@@ -405,6 +468,9 @@ static int recv_handler(struct nl_msg *msg, void *arg)
 	case NFSD_CMD_LISTENER_GET:
 		parse_listener_get(gnlh);
 		break;
+	case NFSD_CMD_LISTENER_SET:
+		parse_listener_set(gnlh);
+		break;
 	case NFSD_CMD_POOL_MODE_GET:
 		parse_pool_mode_get(gnlh);
 		break;
@@ -576,8 +642,29 @@ out:
 
 static int query_nfsd_nl_policy(struct nl_sock *sock)
 {
-	return query_nfsd_nl_cmd_policy(sock, NFSD_CMD_THREADS_SET,
-					&nfsd_threads_max_nlattr);
+	int ret;
+
+	ret = query_nfsd_nl_cmd_policy(sock, NFSD_CMD_THREADS_SET,
+				       &nfsd_threads_max_nlattr);
+	if (ret)
+		return ret;
+
+	/*
+	 * A kernel that offers NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND expects
+	 * this program to register the listeners itself.
+	 */
+	return query_nfsd_nl_cmd_policy(sock, NFSD_CMD_LISTENER_SET,
+					&nfsd_listener_max_nlattr);
+}
+
+static bool userspace_rpcbind_supported(void)
+{
+#ifdef HAVE_LIBTIRPC
+	return nfsd_listener_max_nlattr >= NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND;
+#else
+	/* No rpcb_set() here, so leave the registration to the kernel. */
+	return false;
+#endif
 }
 
 static void status_usage(void)
@@ -1340,12 +1427,15 @@ out_inval:
 
 static int set_listeners(struct nl_sock *sock)
 {
+	bool userspace_rpcbind = userspace_rpcbind_supported();
 	struct genlmsghdr *ghdr;
 	struct nlmsghdr *nlh;
 	struct nl_msg *msg;
 	struct nl_cb *cb;
 	int i, ret;
 
+	nfsd_rpcb_reply_seen = false;
+
 	if (!nfsd_nl_family_setup(sock))
 		return 1;
 
@@ -1382,6 +1472,21 @@ static int set_listeners(struct nl_sock *sock)
 		nla_nest_end(msg, a);
 	}
 
+	/*
+	 * Take rpcbind registration off the kernel. It made those calls
+	 * under nfsd_mutex, where a slow rpcbind stalled every other NFSD
+	 * netlink operation.
+	 *
+	 * Losing this flag would leave the kernel owning rpcbind while this
+	 * program went on to rewrite the entries, so do not send without it.
+	 */
+	if (userspace_rpcbind &&
+	    nla_put_flag(msg, NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND)) {
+		xlog(L_ERROR, "Unable to request rpcbind ownership");
+		ret = 1;
+		goto out;
+	}
+
 	ghdr = nlmsg_data(nlh);
 	ghdr->cmd = NFSD_CMD_LISTENER_SET;
 
@@ -1410,6 +1515,22 @@ static int set_listeners(struct nl_sock *sock)
 		xlog(L_ERROR, "Error: %s", strerror(-ret));
 		ret = 1;
 	}
+
+	/*
+	 * recv_handler() filled nfsd_sockets and nfsd_rpcb_progs from the
+	 * reply, which names only the listeners that came up. Without that
+	 * reply there is nothing to register, and registering anyway would
+	 * clear the entries the kernel installed and put nothing back.
+	 */
+	if (!ret && userspace_rpcbind) {
+		if (nfsd_rpcb_reply_seen)
+			nfsd_rpcb_register(nfsd_sockets, nfsd_socket_count,
+					   nfsd_rpcb_progs,
+					   nfsd_rpcb_prog_count);
+		else
+			xlog(L_WARNING,
+			     "no rpcbind info in the listener_set reply. Leaving the rpcbind registrations alone.");
+	}
 out_cb:
 	nl_cb_put(cb);
 out:

-- 
2.55.0

