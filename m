Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2898C4A3D5A;
	Mon, 31 Aug 2026 18:22:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200531; cv=none; b=ghIn5q7Km/sin0jywtVXo6axJa9a0zhLu8JWOrAoN6DoRSaM0tJvCyEvgaJ3GycYVI1lk4rY0NveifAR7KRXVCwYBgS6jZachLgqYeoJU8P/9DQeXCCFh4Z2PsjICM2oKdxOUgflNSuCadGEePe1x/OGoO+G/3/kntWy+Xh0Lxk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200531; c=relaxed/simple;
	bh=NMoveCuj/U3vFYbbxpy7pgcMhDCKjoWIC99DsA8Pox8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FiU2cRtRI6g/OdV6sUcCvswE6+H3NYz0EoaaxkwxamckNFkSvg/Qsqe0yOTeoQ36uYblu5cqlQsl9ubzC9Hsz4odV/8Pr7BveBmIvf4jH+FbNEayFyv/IPMyKE4cMpQK3nzAZGIRcG+SgpdSbX/goa4n+mJ/HRSZH220ukjmwss=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=btEKD86j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="btEKD86j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69EB71F00ACA;
	Mon, 31 Aug 2026 18:22:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200530;
	bh=Pu4GPT9xCofiWopDGkZSuP+4u3elKLBzQ0R5BEM+3Fg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=btEKD86jgNOsJL0oKrub4fuY4KwHZw9+y5aQNynDhNnAwDVKq5pB5r8rA4WQP7fWw
	 YIJ3mPXStwIUvuEMwK+5md4pvvytTBP8NinMwwy5w49tYazsxVWJMEU4sDOZtG2eSF
	 TYRMYgR67dhU2eWzPSPx1gIDU18gGKmOzyr6yyYO1LvWtJTyMMgvEahm/wtZyuHJ9Y
	 NPACmCSCd/MrZczU7NFhBUN9ahJHTEFkmqP7VYcKX2nDvLBmaU67Udot8O7cTY+3Ym
	 CoDCyJ0IYq+rARxTx3IsWXB4ozAat9pjEX9Xm1rKsD3GmfmBsC8KtquSXl9abdB+JA
	 PZKyTGj5gF5rA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:21:58 -0400
Subject: [PATCH RFC 2/8] SUNRPC: Execute initial async RPC states in
 caller's context
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-2-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2178; i=cel@kernel.org;
 h=from:subject:message-id; bh=NMoveCuj/U3vFYbbxpy7pgcMhDCKjoWIC99DsA8Pox8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZPOC0GWRQVNLqFBploRctZQAImd8K0Laag/
 SbEtcrdA1iJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 l+spD/9mVO49lQZzoGwus61XbLGxoq5OZrEgMGEM1vdSGGtjN4/zD3ihSi0utsfD49cWoQIBk7L
 6vzqdZhkPjA243jpnAbtbwjyLm2r7q3JwCtZvkJ/f4rI/tmV6cQPmFG+i+VRo+AtMytBEV5Qvc5
 Aisl6cN0bmgYYyQNXrS4jGD6Tr3reu7VgXJQ2Jy6C2zcpISUqQtZtpwBIEYahdo7NSkpYUUSNKb
 e74q9tnXIm4I9dt/L0jH94DL3BPoCFr3V/2RSinLSRLzurZKXO2668NtT7sHdFjg6xkIJdIEaE+
 P4zzmZ8MEKkin3klXi1wOGOvBy/5GqA+NEiHJMiyl8zqfIGHeTMPZ1bGMjDWV9NEZZgv/SgbWC7
 SLv7iT7L4aDUBNdbnAg4oq1Y/V6t1Cute5TtSiK3a8/Xx3IIdHv45oCxY+5zJ12uPFE9hPcSnQN
 0CcrAiiaffZ4zhg09xrInEDaYr6YwbSkCjdf3ZTD3IT2wPZwOVAeoZVWmKls8SzbkmCDGZ4NGlo
 Y0MnaCK5bfpJJcXhIiO5A4ddZh14dlz3qh72RTiV4EWdb5cRG2zak59PPZ5vvABBLZCwJKW4est
 gnxfDJDjS/idV5FoxDE9+80mX6RljdMATQkIquxVjLfrVDjjcTyzwOynuwj93UkQVNaotC8sutu
 tis7w6m/z2aFObw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Each async RPC task is dispatched to the rpciod workqueue before its
first FSM state runs, though the initial states (call_start through
call_allocate) typically complete without blocking. Under high
concurrency this adds a workqueue enqueue, dequeue, and context
switch per RPC and contributes to rpciod pool lock contention.

Have rpc_execute() call __rpc_execute() directly for async tasks as
well. The initial states then run in the caller's context, and
__rpc_execute() returns to the caller when the task first sleeps on
a wait queue. Later wake-ups still dispatch to rpciod via
rpc_make_runnable().

Commit d6a1ed08c6ac ("SUNRPC: Reduce asynchronous RPC task stack
usage") moved async dispatch onto rpciod to bound caller stack
depth. Inline execution preserves that bound because __rpc_execute()
still runs each state from the same stack frame.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/sched.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 016f16ca5779..9b2800f6bfc7 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1003,8 +1003,9 @@ static void __rpc_execute(struct rpc_task *task)
 	current_restore_flags(pflags, PF_MEMALLOC);
 }
 
-/*
- * User-visible entry point to the scheduler.
+/**
+ * rpc_execute - Consumer entry point to the RPC scheduler
+ * @task: RPC task to be scheduled
  *
  * This may be called recursively if e.g. an async NFS task updates
  * the attributes and finds that dirty pages must be flushed.
@@ -1014,15 +1015,12 @@ static void __rpc_execute(struct rpc_task *task)
  */
 void rpc_execute(struct rpc_task *task)
 {
-	bool is_async = RPC_IS_ASYNC(task);
+	unsigned int pflags = memalloc_nofs_save();
 
 	rpc_set_active(task);
-	rpc_make_runnable(rpciod_workqueue, task);
-	if (!is_async) {
-		unsigned int pflags = memalloc_nofs_save();
-		__rpc_execute(task);
-		memalloc_nofs_restore(pflags);
-	}
+	rpc_test_and_set_running(task);
+	__rpc_execute(task);
+	memalloc_nofs_restore(pflags);
 }
 
 static void rpc_async_schedule(struct work_struct *work)

-- 
2.55.0

