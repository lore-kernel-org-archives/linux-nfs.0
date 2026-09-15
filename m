Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA5AC37DEA3;
	Tue, 15 Sep 2026 14:20:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789482057; cv=none; b=Qws6CLNWaBniZQHMlvHl7C3541ZGbX66mph1qWRQ5yMTdPo8iZhb1OeG/vEMy0g9OYaqcUOQs2JP96qraQbGibfkfsKv+ps82MMZft0X7STjTcLpEeL1jzImQlX8Aj4fBNPB+IB44II6kOWgqo4zJ69IYHDM9pLOutpiajx1LMQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789482057; c=relaxed/simple;
	bh=ZyiDviOVpdRZPtpm75By1lGZnAH/3lt8m+EGbiqqfNo=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=hUXTm08dXcJwV/zT0vBvXY8x4xT9YHKo/8EKwtqijUmBbx7KpkumP7VfaSwRAsasthOnPeyb2TVmkIvoJ7gZrrgwTg3+UzSoRAyVN1xcwcYjMQLzoWAiygghdFVkil2DlU8T7DHt934o9Z9YQ71O/eesaoQBeeF0shSOPe4Eygw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZAEcDfqi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZAEcDfqi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B026F1F000FF;
	Tue, 15 Sep 2026 14:20:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789482055;
	bh=5scsJyWQ1Wcuk6ksUXxv00GLg9ZuJ5MQ76IqklHez2I=;
	h=From:Subject:Date:To:Cc;
	b=ZAEcDfqi4o1os9p4NdqyrGu5FIVViGTDCyVD0FH3buFTMR/0i9BGOrfiGDxuTOkdt
	 usXc9KIT71fG+AethPCsxp+ZuC7m2yQGnHI049pYBMqqaBL1CsUsaeiDH+nkhwWXWr
	 jWYsuBd66AnDbI4xZ9vhf6JMGLA4k0uJfY/kGc8UqGqIXFUa+vUnPkuJ5nDD4SPClg
	 nD7FrrEa0CTtMpmXb4dZOGnthVSx6t29PiwhSU3v97h3rdeHFlZJ+IR0rKjzPBJQs5
	 SDyZRO9p4QjB7D/v669D7on9H8LQv57tDIIr5EBh1jNzLbryS70kSnp8DLfw9yBhDl
	 IPuLK2bvQkDFQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v3 0/4] Reduce lock contention in the NFS client
Date: Tue, 15 Sep 2026 10:20:40 -0400
Message-Id: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQrCMBREr1L+2mCSahCvIi6SOG2/0KT8VBFK7
 26iyzfMexsVCKPQtdtI8ObCOVXoDx3FyacRih+VyWrr9KU3aoEMWWafIhRO7gxnTTRRUzUWwcC
 fX+12/3N5hSfi2hLtEXyBClLtqU1ZeOR0nH1ZIbTvX0Anp2OPAAAA
X-Change-ID: 20260831-performance-e465e621c1c0
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Tim Menninger <tmenninger@purestorage.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2516; i=cel@kernel.org;
 h=from:subject:message-id; bh=ZyiDviOVpdRZPtpm75By1lGZnAH/3lt8m+EGbiqqfNo=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGqpVD+i8XcC+a/Un9Zhto8rXPjZ/JUw8j/wvLRQm9lJaCl2Z
 4kCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqqVQ/AAoJEDNqszNvZn+XNYMP/0X/
 2sVwhYceUbT5gW3swAPM/enaumoUXOEg4mxgnyo2KvAy8zxHhh2QsDCnN1BXRqDEkN5+baGnBPe
 UTmzNHPy2eA24O2GwjUVaKdF/HuiMIUCkxxwcCZL33wCec8JN1riZBaPWxjEYcThQ7cu9dtEuT9
 0m7HTbq1xltifaa0JlcyO0ALFxSQ+7ILGVPXkMEhoZhP7KvCi4UN42oIoylI48Ebgo7mn010151
 E+mc77+0EqYlaqAAgQ34iWVSXLPYBOWtyKbHtp21Wr4JyErjTNxAqNhESWf89ctLNaLg4I36nVW
 fTVR6qc4krztuyMvDzh2ZlpMGSDSXP57xjRefTIAp9m1BRYd4FtdiocAJXDqhNAC+i9DqCai74v
 nTewQMn2KQgSjD0un3GXoe6IP8nqNlRahJ/hulxZo7N0EjRZsBrj8rjovcqNtQDJp6VFvQt/wxw
 iicVQY641ALD2937B+K5kniMhQ1o505PP0AsgOYm/kWlB7jy4jSscx+p7Gc9zcWH+jvAmib4gp7
 RKqvRRb+UEYK0P+Hf16qsuwd9j7o9mMG9Sb//dApZxVlTHLmn0F8UNzy5Ngh3ZdCjPWRtVuAgKw
 ce5WuXAUf0ilCfc6XkcZ+2WPHecQapXVlGEy1ff0en9DORy3RV+w+rlIbVUYvTg9wYEDqCmyQEP
 AD8OY
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Under a 4KB NFSv3 workload on 100GbE RDMA, roughly 150 RPC worker
threads drive the client, and lock contention dominates its CPU
profile: up to 53% of non-idle cycles are spent in
native_queued_spin_lock_slowpath.

Three locks account for that: reserve_lock on every XID
allocation, queue_lock on every submit and completion, and the
unbound worker pool lock on every enqueue and dequeue for rpciod,
nfsiod, and xprtiod.

This series addresses the first two. v2 also moved the three
workqueues to the WQ_AFFN_SMT scope. Tim Menninger reported an
intermittent throughput regression on a 96-CPU two-socket
NFS/RDMA client and bisected it to the rpciod scope change [1].
The cause is still being worked out in that thread, so the scope
patches are withdrawn until it is understood. Until then, WQ_SYSFS
on all three workqueues lets an administrator set the scope from
user space.

[1] https://lore.kernel.org/linux-nfs/20260902204048.4100864-1-tmenninger@everpuredata.com/

---
Changes in v3:
- Drop the WQ_AFFN_SMT scope patches (Tim Menninger's regression report)
- Rebase on v7.3-rc2
- Link to v2: https://patch.msgid.link/20260902-performance-v2-0-b71c0c082f9d@kernel.org

Changes in v2:
- Fix send bvec use-after-free in xprt_request_dequeue_xprt() (sashiko)
- Replace the three workqueue exports with workqueue_set_affn_scope()
- Split the WQ_SYSFS patch into SUNRPC and NFS patches
- Drop v1 patch 2: async completions in the submitter can deadlock
- Correct the pool cost and SMT group wording in the scope patches
- Link to v1: https://patch.msgid.link/20260831-performance-v1-0-8d9fd9b67f96@kernel.org

---
Chuck Lever (4):
      SUNRPC: Use atomic_t for XID allocation
      SUNRPC: Split recv_lock out of xprt->queue_lock
      SUNRPC: Set WQ_SYSFS on rpciod and xprtiod
      NFS: Set WQ_SYSFS on nfsiod

 fs/nfs/inode.c                             |  3 +-
 include/linux/sunrpc/xprt.h                |  8 ++-
 net/sunrpc/sched.c                         |  5 +-
 net/sunrpc/svcsock.c                       |  6 +--
 net/sunrpc/xprt.c                          | 85 ++++++++++++++++++------------
 net/sunrpc/xprtrdma/rpc_rdma.c             | 14 ++---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  8 +--
 net/sunrpc/xprtsock.c                      | 18 +++----
 8 files changed, 85 insertions(+), 62 deletions(-)
---
base-commit: df2908090cda368b01ff43709f51890076c56157
change-id: 20260831-performance-e465e621c1c0

Best regards,
--  
Chuck Lever

