Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46950 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754660Ab1K1UBi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 15:01:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: rjw@sisk.pl
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, tj@kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
Subject: [PATCH v3 0/2] nfs/sunrpc: allow freezing of tasks with NFS calls in flight
Date: Mon, 28 Nov 2011 15:01:26 -0500
Message-Id: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is a second (third?) attempt at fixing the issues with
suspending a machine that has an active NFS mount.

The bug reported against Fedora is here:

    https://bugzilla.redhat.com/show_bug.cgi?id=717735

The main difference between v2 and this one is that this one has the new
macros attempt to freeze before going to sleep. It's possible for the
freezer_do_not_count() call to race with the freezer. The FREEZER_SKIP
flag can be set after the freezer has already attempted to freeze the
task. If so, it may just go to sleep without attempting to freeze.

This set attempts to remedy this by calling try_to_freeze() after
calling freezer_do_not_count() and before sleeping. This should prevent
the above race.

I've also fleshed out the comments a bit to nail down the semantics for
these new functions. I'm quite open to changing the names of the
functions as well, if anyone can suggest better alternatives.

Comments and more tested would be appreciated. My goal is to get this
in for 3.3, hopefully via Rafael's tree.

Jeff Layton (2):
  sunrpc: make rpc_wait_bit_killable handle freeze events
  nfs: make TASK_KILLABLE sleeps attempt to freeze

 fs/nfs/inode.c          |    3 ++-
 fs/nfs/nfs3proc.c       |    3 ++-
 fs/nfs/nfs4proc.c       |    5 +++--
 fs/nfs/proc.c           |    3 ++-
 include/linux/freezer.h |   40 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c      |    3 ++-
 6 files changed, 51 insertions(+), 6 deletions(-)

-- 
1.7.6.4

