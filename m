Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:64889 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbaIHOrC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 10:47:02 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so2335911qac.32
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 07:46:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH v3 0/8] nfsd: support for lifting grace period early
Date: Mon,  8 Sep 2014 10:46:41 -0400
Message-Id: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
- only accept Y/y/1 in new procfile writes
- turn minorversion env var into a "reclaim complete" boolean
- serialize nfsdcltrack upcalls for a client
- reduce duplicate upcalls via NFSD4_CLIENT_STABLE flag
- don't allow reclaims after RECLAIM_COMPLETE

v2:
- move grace period handling into its own module

Here's a respin of the patches to reduce the grace period. A respun
version of the nfs-utils patches will be posted separately (needed due
to the minorversion to reclaim complete boolean change). I also threw
in some other patches that clean up the upcall handling a bit and
that prevent the client from being able to reclaim after sending a
RECLAIM_COMPLETE.

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

Jeff Layton (8):
  lockd: move lockd's grace period handling into its own module
  nfsd: remove redundant boot_time parm from grace_done client tracking
    op
  lockd: add a /proc/fs/lockd/nlm_end_grace file
  nfsd: add a v4_end_grace file to /proc/fs/nfsd
  nfsd: pass extra info in env vars to upcalls to allow for early grace
    period end
  nfsd: serialize nfsdcltrack upcalls for a particular client
  nfsd: set and test NFSD4_CLIENT_STABLE bit to reduce nfsdcltrack
    upcalls
  nfsd: reject reclaim request when client has already sent
    RECLAIM_COMPLETE

 fs/Kconfig              |   6 +-
 fs/lockd/Makefile       |   3 +-
 fs/lockd/grace.c        |  65 ---------------------
 fs/lockd/netns.h        |   1 -
 fs/lockd/procfs.c       |  92 +++++++++++++++++++++++++++++
 fs/lockd/procfs.h       |  28 +++++++++
 fs/lockd/svc.c          |  10 +++-
 fs/nfs_common/Makefile  |   3 +-
 fs/nfs_common/grace.c   | 113 ++++++++++++++++++++++++++++++++++++
 fs/nfsd/Kconfig         |   1 +
 fs/nfsd/nfs4recover.c   | 150 +++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4state.c     |  11 ++--
 fs/nfsd/nfsctl.c        |  45 +++++++++++++++
 fs/nfsd/state.h         |   6 +-
 include/linux/proc_fs.h |   2 +
 15 files changed, 440 insertions(+), 96 deletions(-)
 delete mode 100644 fs/lockd/grace.c
 create mode 100644 fs/lockd/procfs.c
 create mode 100644 fs/lockd/procfs.h
 create mode 100644 fs/nfs_common/grace.c

-- 
1.9.3

