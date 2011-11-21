Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40644 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753573Ab1KURk2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 12:40:28 -0500
From: Jeff Layton <jlayton@redhat.com>
To: rjw@sisk.pl
Cc: linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, john@calva.com,
        tj@kernel.org, trond.myklebust@netapp.com
Subject: [PATCH 0/2] nfs/sunrpc: allow freezing of tasks with NFS calls in flight
Date: Mon, 21 Nov 2011 12:40:19 -0500
Message-Id: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is a second (third?) attempt at fixing the issues with
suspending a machine that has an active NFS mount.

The bug reported against Fedora is here:

    https://bugzilla.redhat.com/show_bug.cgi?id=717735

This patchset is a bit different from the original one. Instead of
attempting to make TASK_KILLABLE sleeps wake up when the freezer runs,
this one makes the freezer skip those processes when it runs.

This is the method that Tejun, Rafael, and Oleg have recommended for
now. Long term, it might make more sense to add a new TASK_WAKEFREEZE
flag or something and awake tasks based on that, and have them then
call try_to_freeze() when awoken. For now though this seems to work
as expected.

So far, results with this patchset have been good, but it seems like
it's a bit late for 3.2. I'd like to see this go in early for 3.3,
probably via Rafael's tree.

Jeff Layton (2):
  sunrpc: make rpc_wait_bit_killable handle freeze events
  nfs: make TASK_KILLABLE sleeps attempt to freeze

 fs/nfs/inode.c          |    3 ++-
 fs/nfs/nfs3proc.c       |    3 ++-
 fs/nfs/nfs4proc.c       |    5 +++--
 fs/nfs/proc.c           |    3 ++-
 include/linux/freezer.h |   22 ++++++++++++++++++++++
 net/sunrpc/sched.c      |    3 ++-
 6 files changed, 33 insertions(+), 6 deletions(-)

-- 
1.7.6.4

