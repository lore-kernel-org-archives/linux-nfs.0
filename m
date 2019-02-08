Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1A79C282CB
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CA20F2177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:11:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727580AbfBHUKt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: from fieldses.org ([173.255.197.46]:57022 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726211AbfBHUKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:10:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id BE6B31CE7; Fri,  8 Feb 2019 15:10:48 -0500 (EST)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/7] Eliminate delegation self-conflicts
Date:   Fri,  8 Feb 2019 15:10:40 -0500
Message-Id: <1549656647-25115-1-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

These patches allow NFSv4 clients holding delegations to keep them when
the operation that would break a delegation comes from the same client.

To do that, we somehow need to pass the identity of the
delegation-breaker down through the VFS.

This series uses the tgid, a solution suggested by Trond.  To do that we
need nfsd tasks to share the same tgid.  I do that by extending the
kthread code slightly to allow knfsd to run the kthreadd main loop in a
task of its own, and spawn its server threads off of that task.

Part of Trond's thinking was that this would work for userspace too.
Delegations are currently only available to knfsd, but Ganesha and Samba
may eventually be interested in a userspace interface (probably a minor
variation on the fcntl F_{GET,SET}LEASE interface).  A threaded
userspace server would first resolve conflicts between its own clients,
and then call into the kernel to break any leases acquired by other
processes.  That may require some careful locking of the server's own
data structures, but it should work.

Previously I considered instead adding a new field somewhere in the
struct task.  That might require a new system call to expose to user
space.  Or we might be able to put this in a keyring, if David Howells
thought that would work.

Before that I tried passing the identity of the breaker explicitly, but
that looks like it would require passing the new argument around to huge
swaths of the VFS.

I'm testing this with some a locally modified pynfs; I'll fix that up
and push it out at some point, but pynfs has a number of bugs in this
area.

I wasn't sure who to ask about the kthread.c changes, so I'm cc'ing a
random assortment of developers in recent changelogs, hope that's OK.

--b.

J. Bruce Fields (7):
  kthreads: minor kthreadd refactoring
  kthreads: Simplify tsk_fork_get_node
  kthreads: allow multiple kthreadd's
  kthreads: allow cloning threads with different flags
  rpc: separate out body of svc_start_kthreads
  rpc: move rpc server threads into their own thread group
  nfsd: ignore delegation self-conflicts

 fs/locks.c                 |  39 +++++++++++
 fs/nfsd/nfs4state.c        |  61 ++++++++++++++++
 fs/nfsd/state.h            |   2 +
 fs/nfsd/vfs.c              |  32 +++++++--
 include/linux/fs.h         |   2 +
 include/linux/kthread.h    |  21 +++++-
 include/linux/sunrpc/svc.h |   1 +
 init/init_task.c           |   3 +
 init/main.c                |   4 +-
 kernel/fork.c              |   4 ++
 kernel/kthread.c           | 140 +++++++++++++++++++++++++++----------
 net/sunrpc/svc.c           |  83 ++++++++++++++--------
 12 files changed, 317 insertions(+), 75 deletions(-)

-- 
2.20.1

