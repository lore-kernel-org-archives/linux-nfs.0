Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:46411 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbaHSSii (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 14:38:38 -0400
Received: by mail-qc0-f179.google.com with SMTP id m20so6607631qcx.38
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 11:38:37 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] nfsd: support for lifting grace period early
Date: Tue, 19 Aug 2014 14:38:24 -0400
Message-Id: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- move grace period handling into its own module

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

Jeff Layton (5):
  lockd: move lockd's grace period handling into its own module
  lockd: add a /proc/fs/lockd/nlm_end_grace file
  nfsd: add a v4_end_grace file to /proc/fs/nfsd
  nfsd: remove redundant boot_time parm from grace_done client tracking
    op
  nfsd: pass extra info in env vars to upcalls to allow for early grace
    period end

 fs/Kconfig                       |   6 ++-
 fs/lockd/Makefile                |   3 +-
 fs/lockd/netns.h                 |   1 -
 fs/lockd/procfs.c                |  76 +++++++++++++++++++++++++++
 fs/lockd/procfs.h                |  28 ++++++++++
 fs/lockd/svc.c                   |  10 +++-
 fs/nfs_common/Makefile           |   3 +-
 fs/{lockd => nfs_common}/grace.c |  68 +++++++++++++++++++++----
 fs/nfsd/Kconfig                  |   1 +
 fs/nfsd/nfs4recover.c            | 107 +++++++++++++++++++++++++++++++--------
 fs/nfsd/nfs4state.c              |   8 +--
 fs/nfsd/nfsctl.c                 |  35 +++++++++++++
 fs/nfsd/state.h                  |   5 +-
 include/linux/proc_fs.h          |   2 +
 14 files changed, 312 insertions(+), 41 deletions(-)
 create mode 100644 fs/lockd/procfs.c
 create mode 100644 fs/lockd/procfs.h
 rename fs/{lockd => nfs_common}/grace.c (50%)

-- 
1.9.3

