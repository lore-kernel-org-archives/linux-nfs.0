Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:62609 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaHOOos (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:44:48 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so2117485qaj.7
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:44:47 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id i2sm9046955qge.27.2014.08.15.07.44.45
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:44:46 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [kernel RFC PATCH 0/4] nfsd: support for lifting grace period early
Date: Fri, 15 Aug 2014 10:44:36 -0400
Message-Id: <1408113880-5489-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

For now, this is an RFC. Does anyone have comments on the general
approach here?

Jeff Layton (4):
  lockd: add a /proc/fs/lockd/nlm_end_grace file
  nfsd: add a v4_end_grace file to /proc/fs/nfsd
  nfsd: remove redundant boot_time parm from grace_done client tracking
    op
  nfsd: pass extra info in env vars to upcalls to allow for early grace
    period end

 fs/lockd/Makefile     |   1 +
 fs/lockd/procfs.c     |  76 +++++++++++++++++++++++++++++++++++
 fs/lockd/procfs.h     |  28 +++++++++++++
 fs/lockd/svc.c        |   9 +++++
 fs/nfsd/nfs4recover.c | 107 ++++++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs4state.c   |   8 ++--
 fs/nfsd/nfsctl.c      |  35 +++++++++++++++++
 fs/nfsd/state.h       |   5 ++-
 8 files changed, 243 insertions(+), 26 deletions(-)
 create mode 100644 fs/lockd/procfs.c
 create mode 100644 fs/lockd/procfs.h

-- 
1.9.3

