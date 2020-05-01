Return-Path: <SRS0=2uGU=6P=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9969FC4724C
	for <linux-nfs@archiver.kernel.org>; Fri,  1 May 2020 16:01:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 73E89208DB
	for <linux-nfs@archiver.kernel.org>; Fri,  1 May 2020 16:01:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729881AbgEAQBy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 May 2020 12:01:54 -0400
Received: from fieldses.org ([173.255.197.46]:40318 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728495AbgEAQBy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 May 2020 12:01:54 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id D38A43158; Fri,  1 May 2020 12:01:53 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/4] allow multiple kthreadd's
Date:   Fri,  1 May 2020 12:01:48 -0400
Message-Id: <1588348912-24781-1-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

These patches allow a caller to create its own kthreadd.

The motivation is file delegations: currently any write operation from a
client breaks all delegations, even delegations held by the same client.

To fix that, we need to know which client is performing a given
operation.

So, we let nfsd put all the nfsd threads into the same thread group (by
spawning them from its own private kthreadd), then patch the delegation
code to treat delegation breaks from the same thread group as not
conflicting, and then leave it to nfsd to sort out conflicts among its
own clients.  Those patches are in:

	git://linux-nfs.org/~bfields/linux.git deleg-fix-self-conflicts

This was an idea from Trond.  Part of his motivation was that it could
work for userspace servers (like Ganesha and Samba) as well.  (We don't
currently let them request delegations, but probably will some day--it
shouldn't be difficult.)

Previously I considered instead adding a new field somewhere in the
struct task.  That might require a new system call to expose to user
space.  Or we might be able to put this in a keyring, if David Howells
thought that would work.

Before that I tried passing the identity of the breaker explicitly, but
that looks like it would require passing the new argument around to huge
swaths of the VFS.

Anyway, does this multiple kthreadd approach look reasonable?

(If so, who should handle the patches?)

--b.

J. Bruce Fields (4):
  kthreads: minor kthreadd refactoring
  kthreads: Simplify tsk_fork_get_node
  kthreads: allow multiple kthreadd's
  kthreads: allow cloning threads with different flags

 include/linux/kthread.h |  21 +++++-
 init/init_task.c        |   3 +
 init/main.c             |   4 +-
 kernel/fork.c           |   4 ++
 kernel/kthread.c        | 140 +++++++++++++++++++++++++++++-----------
 5 files changed, 132 insertions(+), 40 deletions(-)

-- 
2.26.2

