Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E970466B02
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391676; cv=none; b=sNq4MlDqCzB1qQ4PD2gcFZT/et9clZkR0UF4os/+dpPhoxxN1vozajKet+E/PY33H8jwj+1oFn4lE8ny+cnZgykHch82cBcWmqEdHUfkbIrYC7M1fHfzin7vN75/A3XBjfJ+MkH3G0s2ZVkEk6gZKzHovKOnefxUYVjoU2Nh4gI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391676; c=relaxed/simple;
	bh=nZUNglivp76qdtsMkTailh1en+RgLz9cQcFKwIR0RI4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=E1R5BTBxYh+1ztLuBKr+rhdf/jddgYeMZWOHyVLgF+lDH3WGYf6yZYuYpthkRAbNvnLxlfEM+uAtPTe0aZcWLdzsT0ck7/QHW6ql8fJDLG6vVlUQAKDhZ3N+0NUC40CfrPEyjzVEb+g7LvsKvvwMVOF8f+G3ytZB0rSj6p6jTcA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k0UDEojc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k0UDEojc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7CABC1F0089C;
	Mon, 14 Sep 2026 13:14:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391673;
	bh=QEGAu7CWNyfucaC3DRWlxqErAJpS6kM4B+o9zlmZLm8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=k0UDEojcOOJhxo3QUZ7Z8f75lJlvo6YSxPjqj9KeAUjkf/I8OKDubZWypPdzYuBhq
	 cPYvP1gjsiURf1xmNcdmO16g/Vl1cozodZXHu1r/aZxNRxUPtbx9t/NVmAliqEE4iJ
	 9fkegGiuFoBpiXpFrX4j60fQeABEz5B5BYsDSupjNbLzGwPxKfvoEiRPLPDlHsUY7z
	 mSdjUoaZXdX0dtvkYFMGlbgygUFwqOAwrKVR5PfyLSuxC7j/9SzUOHgae37yBbaxWp
	 IFyn6lf+TN5A3LpMxpU+aOWvRaGICDKrpSztihhXDo3sOT7zP4MMI9s7+MBtgZnQ54
	 cc4lWTdL5xBVw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:16 -0400
Subject: [PATCH nfs-utils v3 07/11] mountd: give each worker its own
 netlink command socket
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nl-crossmnt-v3-7-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2989; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=nZUNglivp76qdtsMkTailh1en+RgLz9cQcFKwIR0RI4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/MzzAAxFrlGsk5kgN843urtUgd2fNDdAQmOw
 D9kVkag+TeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzMwAKCRAADmhBGVaC
 FSNmD/9d/eI5xVzXdP91ikicjHjUyu6orqM0xGiL1nGL8t6gozj6+0XaDgPPxXRjJtUh7SsNe76
 SDtw8L8NdSrczy86i6Jq6iL8hJjT0qDS5SR75NN0KGb8yill5bn71oTh1z+6/9bJz/cdCulQdvf
 PakXFos8VdyY3+ygI+49GsdHapSRFc7WvYCzkyZx+kuSWcObGaQ4zsTxnBZQki+Sz4DqmuVGFR+
 ijOBRXh6R2b1vEmns1OclYp5xJAiFyL9I+WebKofJFHwBO1EBB92WcIg3E4ceFiQNT76XTZnEer
 Qv8HuHQxm1QV39tnMxVEdI9VXYsI88pIDI1VX9HnMA3fZie+YYHvSOS0lnhdi+qPL3T7PFBocu4
 Z1B7C7Tpw3rAHDIjBlA51euCct7NAUD7eAVjP4ieUBpC1LSBU3PRm7P7tchrH6FvteKyuO53Qxd
 7+F+c3e7WqHpUSuRWnwBVXTAqv9wGceKPnXtLvp0gDrD8VyOcYmW+FkfRKZJLJuhOsB1aTdKoQF
 EtenEpeSaPtnwJfSS71iAmY6Q86m7XmUwvB5KHBGyduusy3pDE1AMvy6AhMZwb5j5Tn8nRZ/CgX
 kWQi9shVht7uOGzwng0uCpL8hZg/XJsYRA7/q6xyl0wZw8C5gmFM+tev9SddmShpO/XaiFDMCov
 34i+p2NP53yGrIg==
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
index 6a5cdd9d9670..cbe3df83b0eb 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -3994,6 +3994,29 @@ cache_wait_for_workers(char *prog)
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
@@ -4015,12 +4038,22 @@ cache_fork_workers(char *prog, int num_threads)
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

