Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:32829 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbaIONOS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 09:14:18 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so3808323qgd.7
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 06:14:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/9] nfsd: support for lifting grace period early
Date: Mon, 15 Sep 2014 09:14:01 -0400
Message-Id: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4:
- rename NFSDCLTRACK_RENAME_COMPLETE to NFSDCLTRACK_CLIENT_HAS_SESSION
- add patch to skip multiple create upcalls in v4.0 case
- reorder patches with less controversial ones near the front

v3:
- only accept Y/y/1 in new procfile writes
- turn minorversion env var into a "reclaim complete" boolean
- serialize nfsdcltrack upcalls for a client
- reduce duplicate upcalls via NFSD4_CLIENT_STABLE flag
- don't allow reclaims after RECLAIM_COMPLETE

v2:
- move grace period handling into its own module

This is v4 of the series. The only real change from the last one is
to rename the environment var to NFSDCLTRACK_CLIENT_HAS_SESSION, and
to add in a patch to prevent multiple upcalls in the case of a v4.0
client.

I'll also be posting a respin of the userland patches which have a
more substantial set of changes.

Original cover letter follows:

One of the huge annoyances in dealing with knfsd is the 90s grace period
that's imposed when the server reboots. This is not just an annoyance,
but means a siginificant amount of "downtime" in many production
environments.

This patchset aimed at reducing this pain. It adds a couple of /proc
knobs that tell the lockd and nfsd lock managers to lift the grace
period.

It also changes the UMH upcalls to pass a little bit of extra info in
the form of environment variables so that the upcall program can
determine whether there are still any clients that may be in the process
of reclaiming.

There are also a couple of cleanup patches in here that are not strictly
required. In particular, making a separate grace.ko module doesn't have
to be done, but I think it's a good idea.

Jeff Layton (9):
  lockd: move lockd's grace period handling into its own module
  nfsd: remove redundant boot_time parm from grace_done client tracking
    op
  nfsd: reject reclaim request when client has already sent
    RECLAIM_COMPLETE
  lockd: add a /proc/fs/lockd/nlm_end_grace file
  nfsd: add a v4_end_grace file to /proc/fs/nfsd
  nfsd: pass extra info in env vars to upcalls to allow for early grace
    period end
  nfsd: serialize nfsdcltrack upcalls for a particular client
  nfsd: set and test NFSD4_CLIENT_STABLE bit to reduce nfsdcltrack
    upcalls
  nfsd: skip subsequent UMH "create" operations after the first one for
    v4.0 clients

 fs/Kconfig              |   6 +-
 fs/lockd/Makefile       |   3 +-
 fs/lockd/grace.c        |  65 ------------------
 fs/lockd/netns.h        |   1 -
 fs/lockd/procfs.c       |  92 ++++++++++++++++++++++++++
 fs/lockd/procfs.h       |  28 ++++++++
 fs/lockd/svc.c          |  10 ++-
 fs/nfs_common/Makefile  |   3 +-
 fs/nfs_common/grace.c   | 113 +++++++++++++++++++++++++++++++
 fs/nfsd/Kconfig         |   1 +
 fs/nfsd/nfs4recover.c   | 172 +++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4state.c     |  11 ++--
 fs/nfsd/nfsctl.c        |  45 +++++++++++++
 fs/nfsd/state.h         |   6 +-
 include/linux/proc_fs.h |   2 +
 15 files changed, 461 insertions(+), 97 deletions(-)
 delete mode 100644 fs/lockd/grace.c
 create mode 100644 fs/lockd/procfs.c
 create mode 100644 fs/lockd/procfs.h
 create mode 100644 fs/nfs_common/grace.c

-- 
1.9.3

