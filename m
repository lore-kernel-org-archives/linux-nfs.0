Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07739417BD2;
	Fri, 25 Sep 2026 09:29:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790328567; cv=none; b=TiHFzEna7VGMYSRPZhOrjyIRWo9F3f/kJgH/jCV0XS/JfF8/aAM4KktwDbtep0Fsg+teI0wbD8m9Qk0RG/vafDmt11IE3RV8+NREMcmEZpmSF4G3CwnG8kgUhG9hmDbtPljkdKtpivYJmvMGgxMs0cv5g8kkNnl1VF7yKGDmdk0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790328567; c=relaxed/simple;
	bh=GiE/IFtkH/fTurl9Cbwum67nELKTfM58GrzMPpCu3HQ=;
	h=From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:Date; b=LQ7twO9SKkPea59vuz1/Gonn1X19ebAllctQMCkGUUl0HPGOunlVGHWl93S2KQGEtB5rgmfrqJDvoRGBD7Y7W4QLDZ0tE2LVPo+wbeBurnxFIps6DXVPfZtq0MTvAEeysO0NTqfA5v6Ze0/8NlrCwboonVseRoKEjcw/BiR7hnA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TtPSZBjo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TtPSZBjo"
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id E9DC91F000FF;
	Fri, 25 Sep 2026 09:29:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790328565;
	bh=GREGS4oZNqxqpzIpoelW3295UnRYOFsuTaHdiBzNhE0=;
	h=From:To:Cc:Subject:Date;
	b=TtPSZBjo6X61/lVvEqN1twdqk8LALUkB051G5qu5UOgJbUETakRnNUMEtlrKzAF5S
	 D6cZIxVTEMU0PhJHxAvzs98ibuADOlOoLweMocR3MLjbZ/IKoyyirnte4tlkmDnfSZ
	 MO1PiboP5FEhK8XymN6915aLz3LJlu0d5VMxj/rrqSl61E6b3H5okYQFoGVcW+4l1D
	 rmmgFG3F0Bb91NixdduP5ptXvXYcc6vJHL7Fa6q7uJwDZPDU8C2NKMIt8JeqhBPKcu
	 V9HvfcOC7+u9KS2V1tV1BCnX+whRuvLnhPm2Qls3c4KOkUFdQGpckDHunq7OC2sE0b
	 HmjUIlM7Rh47Q==
From: "syzbot" <syzbot@kernel.org>
To: syzkaller-bugs@googlegroups.com, Marco Elver <elver@google.com>, "Anna Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>, "David S. Miller" <davem@davemloft.net>, "Eric Dumazet" <edumazet@google.com>, "Jeff Layton" <jlayton@kernel.org>, "Jakub Kicinski" <kuba@kernel.org>, <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>, "Paolo Abeni" <pabeni@redhat.com>, "Trond Myklebust" <trondmy@kernel.org>, "Peter Zijlstra" <peterz@infradead.org>
Cc: Dai.Ngo@oracle.com, horms@kernel.org, linux-kernel@vger.kernel.org, neil@brown.name, okorniev@redhat.com, syzbot@lists.linux.dev, tom@talpey.com
Subject: [PATCH] SUNRPC: Use TASK_FREEZABLE_UNSAFE in __rpc_execute()
Message-ID: <21891299-3a5d-4cfe-b3c4-8d711c7e8565@mail.kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Date: Fri, 25 Sep 2026 09:29:24 +0000 (UTC)

From: Marco Elver <elver@google.com>

When a task executes a synchronous RPC call via __rpc_execute(), it waits
for the queued RPC task to wake up using out_of_line_wait_on_bit(). Callers
in subsystems such as NFS or NFSD (for example, write_ports() acquiring
nfsd_mutex during NFS server initialization and issuing an rpc_ping())
frequently hold locks across these synchronous RPC waits.

Historically, rpc_wait_bit_killable() invoked freezable_schedule_unsafe(),
which explicitly bypassed lockdep checks for held locks during freeze.
However, during the core freezer refactoring in commit f5d39b020809
("freezer,sched: Rewrite core freezer logic"), freezable_schedule_unsafe()
was removed, and callers were updated to pass freezer flags directly into
out_of_line_wait_on_bit(). While rpc_wait_for_completion_task() was
correctly updated to use TASK_KILLABLE | TASK_FREEZABLE_UNSAFE,
__rpc_execute() was mistakenly updated to use TASK_KILLABLE |
TASK_FREEZABLE without the unsafe flag.

As a result, if a system suspend occurs concurrently while a task is
waiting in __rpc_execute() with a lock held, __set_task_frozen() observes
p->lockdep_depth > 0 without __TASK_FREEZABLE_UNSAFE and triggers a lockdep
warning:

WARNING: kernel/freezer.c:139 at __set_task_frozen+0x260/0x340
Call Trace:
 <TASK>
 task_call_func+0x1aa/0x260 kernel/sched/core.c:4518
 __freeze_task kernel/freezer.c:150 [inline]
 freeze_task+0x216/0x390 kernel/freezer.c:169
 try_to_freeze_tasks+0x190/0x620 kernel/power/process.c:54
 freeze_processes+0xd0/0x1f0 kernel/power/process.c:137
 suspend_prepare kernel/power/suspend.c:387 [inline]
 enter_state kernel/power/suspend.c:609 [inline]
 pm_suspend+0x2f1/0x760 kernel/power/suspend.c:644
 state_store+0x206/0x290 kernel/power/main.c:819
 kernfs_fop_write_iter+0x3a5/0x540 fs/kernfs/file.c:345
 vfs_write+0x61e/0xbb0 fs/read_write.c:687
 ksys_write+0x156/0x270 fs/read_write.c:739
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
 </TASK>

Update __rpc_execute() to pass TASK_KILLABLE | TASK_FREEZABLE_UNSAFE to
out_of_line_wait_on_bit(). This restores the pre-regression behavior and
aligns __rpc_execute() with rpc_wait_for_completion_task(), avoiding the
false-positive lockdep warning when tasks holding locks are frozen during
synchronous RPC execution.

Fixes: f5d39b020809 ("freezer,sched: Rewrite core freezer logic")
Assisted-by: Gemini:gemini-3.8-flash Gemini:gemini-3.1-pro-preview syzbot
Reported-by: syzbot+209eccd8f507de9f7f1b@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=209eccd8f507de9f7f1b
Link: https://syzkaller.appspot.com/ai_job?id=cb10c20b-f568-4900-8b09-dc937852ee3f
Signed-off-by: Marco Elver <elver@google.com>

---
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 016f16ca5..494947d50 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -984,7 +984,7 @@ static void __rpc_execute(struct rpc_task *task)
 		trace_rpc_task_sync_sleep(task, task->tk_action);
 		status = out_of_line_wait_on_bit(&task->tk_runstate,
 				RPC_TASK_QUEUED, rpc_wait_bit_killable,
-				TASK_KILLABLE|TASK_FREEZABLE);
+				TASK_KILLABLE | TASK_FREEZABLE_UNSAFE);
 		if (status < 0) {
 			/*
 			 * When a sync task receives a signal, it exits with


base-commit: 93f51579e7df248780214094418f205253383cc5
-- 
See https://goo.gle/syzbot-ai-patches for information about AI-generated patches.
The person who has signed off on the patch is responsible for
addressing comments.
syzbot engineers can be reached at syzkaller@googlegroups.com.
