Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 199544A093F
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143947; cv=none; b=nYRwlj8rAiVn04LTFjiXXWTotn48ao3RVdX58BzgZWHTNOetdM1zXfAJ+MW1AMAb3l7GnFbvCf9juSLcBQJ6KfC1cZRxVCaCgxhHVPJc9gHWnogLhM1e3Vi31DWC+VPP/iRVzn7OSBUMNHMyZOwkJHzXdAKed0Fu6DF05Liqb7w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143947; c=relaxed/simple;
	bh=8Y/ChX4hr7/ZO4f2b3KpDeihWFmlylYfoNhx4eArgdQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iu36eNZDxJFqqR0//WsFEk0MK44+Lr01BpY81KI4/QqL/MgwIkMLL1OyDv/YKJ3TCA971wPxYrzNlvKIL2gvooNxZJ65xv0fmA+ikjtnXvS0X4QEg+uAlCZcye1cftsqmLwDsnRds6iIkK/8PUMsS88hpG/CN3lkqD2NQvqkb8g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=K1IrOoS/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="K1IrOoS/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98D991F00899;
	Fri, 11 Sep 2026 16:25:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143946;
	bh=F7ym+o5d9eIkcfXspsRqo97apcl0owxtxLK+g/w7gbA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=K1IrOoS/c9Ez4F/be5zerTw6Xr3Eq/V6yB35uFDpXs8aqvQ6xOdG1jrztai7SKWkW
	 j8vmyNvkQB+qALMHBCGevCCKum3i1+uONIA0w8QaSCqfQ/Aki+fZLdGKsyPZkNJ7Nm
	 B1ff8/ir2fLn6RiChTzBwH3dbn/5aZjlRDie/U+Ny8ldm+0GJZsnIe26g7F3DhCdJ8
	 qxtRw/Hp2e24CHAaa01Lrqt8CqyIPYojrCVxs0K6Ym32NgrKtBrF1Zvz1L/PJe6kQ+
	 PUvaJb/ppICOhwsHq3NCdvz3YYhNglg/GV31CqRDIiOpFEORMuknZAedk/oH2QA1Wr
	 YJrrl931EUCqw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:32 -0400
Subject: [PATCH nfs-utils v2 07/10] mountd: give each worker its own
 netlink command socket
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260911-nl-crossmnt-v2-7-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2989; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=8Y/ChX4hr7/ZO4f2b3KpDeihWFmlylYfoNhx4eArgdQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuEw/d+oKdrUGoKfwY1xLbsunLr9EOLgYyYv
 uSJ/6+ju0GJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrhAAKCRAADmhBGVaC
 FSkWD/9etNhUvDh2eGY/ZgOfa96YAdxGrzSyZlXs6kU3DMZF+o3y36VLGwJZUUVTeOye2iuj5ny
 0Y2hq4xSM3HYo8r/8VaXfTmmYoWLJrHKau+6/6kprJ7Y3DEEMRyPwOxp8l7KvjPD1GrnB2lGVLL
 8QNw9j8IevTi+objomK6vmPu08VTyCkjFOFCy1L6b64f9Rm/eTOcAT/093FJBuPy1x6vaV4Hf2E
 n6Uq+4/43npRwmNupTQnWwwTmX93A5AudwfEA+aTdbicEndOekC21MRAfCGu2eN1HJ8ZimAcGQ+
 bcNmPcxypAf+E7J/WurCAWOXs+hOxDueOUj91qMZtv0ztAVwuUZdnGAKg8tcaqENwaXH9v3IHXW
 iYNFJRfb5aOctbADo5M5fZo3NOqnyTfdz7kpL8mEXeSBSXldaYZQNmc3shVuK83b7uKU0MdSMj5
 o2ZsWypYukIHdJwKb6CqmNhAwdDz4U6EcR/pdnb07qM/AHeLpi1hH76vfKgdVLfQueZiN5BipPQ
 qL5M47t2gizCiD4fj81p9jtiDAbkqO6WZf6MezbepbRZYcB3b7+CkRLlL+buHYS5deyK+qKmqsn
 6HOKLFDkHCILRgj6+8yObS9eD5F501DusLzqrxOkoGqXXwXE+OQ5/6ETPt7+HEzzy1yEmdwnxIM
 ga3iNZhZQx6SdGA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

cache_open() opens the nfsd and sunrpc command sockets before
cache_fork_workers() forks, so every worker shares one fd, and a
copy-on-write struct nl_sock carrying the same s_seq_next/s_seq_expect.
Only the notify sockets get nl_socket_disable_seq_check(); the command
sockets keep libnl's default sequence check, which each worker will
happily pass on the other's reply.

Two workers in a command/reply round trip can therefore take each other's
ack or NLMSG_ERROR.  cache_nl_set_reqs() then reports the wrong outcome
and the caller answers the wrong client and path - marking it exported,
retryable, or negatively cached.

Reopen both command sockets in the worker child.  genl_connect() binds a
fresh port id, so each worker gets its own reply stream.  The notify
sockets stay shared: they are receive-only, have the sequence check
disabled, and are nonblocking, so whichever worker gets there first takes
the notification.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 support/export/cache.c | 37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 78b050ae9d71..7b2ad3ca1611 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -3939,6 +3939,29 @@ cache_wait_for_workers(char *prog)
 	}
 }
 
+/*
+ * Replace a command socket inherited across fork().  Returns @old if a new one
+ * cannot be had; sharing it is worse than having one, but not by as much as
+ * having none.
+ */
+static struct nl_sock *nl_cmd_sock_reopen(struct nl_sock *old)
+{
+	struct nl_sock *sock;
+
+	if (!old)
+		return NULL;
+
+	sock = nl_sock_setup();
+	if (!sock) {
+		xlog(L_WARNING, "%s: cannot reopen netlink command socket,"
+		     " sharing the inherited one", __func__);
+		return old;
+	}
+
+	nl_socket_free(old);
+	return sock;
+}
+
 /* Fork num_threads worker children and wait for them */
 int
 cache_fork_workers(char *prog, int num_threads)
@@ -3960,12 +3983,22 @@ cache_fork_workers(char *prog, int num_threads)
 		if (pid == 0) {
 			/* worker child */
 
+			/*
+			 * A command socket carries a reply back to the process
+			 * that sent the request, so it cannot be shared.  Every
+			 * worker inherits the same fd and the same copied
+			 * sequence counters, and two of them mid-round-trip
+			 * will take each other's ack.
+			 */
+			nfsd_nl_cmd_sock = nl_cmd_sock_reopen(nfsd_nl_cmd_sock);
+			sunrpc_nl_cmd_sock =
+				nl_cmd_sock_reopen(sunrpc_nl_cmd_sock);
+
 			/*
 			 * cache_open() drains the netlink downcalls before we
 			 * get here, so anything it deferred is now on the retry
 			 * queues of every worker.  Let the first worker own
-			 * those, or they get answered once per worker over the
-			 * shared command socket.
+			 * those, or they get answered once per worker.
 			 */
 			if (i > 0) {
 				delayed_export_flush();

-- 
2.55.0

