Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56702 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab1I1Lwr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Sep 2011 07:52:47 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com, smfrench@gmail.com, pavel@ucw.cz, rjw@sisk.pl
Cc: linux-pm@lists.linux-foundation.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, john@Calva.COM,
        linux-kernel@vger.kernel.org
Subject: [PATCH 0/4] allow freezing of tasks with netfs calls in flight
Date: Wed, 28 Sep 2011 07:52:37 -0400
Message-Id: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We've had a number of reports recently of people with NFS and CIFS
mounts that were unable to suspend or hibernate their machines. Here
are a couple of Fedora bugs that illustrate the problem:

    https://bugzilla.redhat.com/show_bug.cgi?id=712088
    https://bugzilla.redhat.com/show_bug.cgi?id=717735

When it occurs the problem is pretty clear. We have a task that's
sleeping in the kernel in TASK_KILLABLE sleep, generally waiting
for a reply to come in. Often though, userspace has already taken
down the interface so that reply will never come. The process then
fails to freeze and the suspend fails.

This patch fixes this by allowing the TASK_KILLABLE sleeps in NFS and
CIFS to be awoken by the freezer and then to try to freeze. If a freeze
event does occur, then the code will treat it as if a schedule() has
already occured.

I've had a number of people test versions of this set and the results
have been positive. Part of the problem though is that there are
sometimes still unrelated problems with suspend/resume that seem to
cloud the results. As best we can tell though, this patchset does work
as advertised.

Jeff Layton (4):
  freezer: make fake_signal_wake_up wake TASK_KILLABLE tasks too
  cifs, freezer: add wait_event_freezekillable and have cifs use it
  sunrpc: make rpc_wait_bit_killable handle freeze events
  nfs: make TASK_KILLABLE sleeps attempt to freeze

 fs/cifs/transport.c     |    3 ++-
 fs/nfs/inode.c          |    4 +++-
 fs/nfs/nfs3proc.c       |    3 ++-
 fs/nfs/nfs4proc.c       |   12 ++++++++----
 fs/nfs/proc.c           |    3 ++-
 include/linux/freezer.h |   19 +++++++++++++++++--
 kernel/freezer.c        |    2 +-
 net/sunrpc/sched.c      |    4 +++-
 8 files changed, 38 insertions(+), 12 deletions(-)

-- 
1.7.6.2

