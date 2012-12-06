Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:22937 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab2LFLWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:22:35 -0500
Subject: [PATCH 0/8] nfsd: make service created per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:22:57 +0300
Message-ID: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set prepares service control to be able to start separated
independent NFSd services in different network namespace environments.
Key changes are:
1) Create independent instances of NFSd service (and thus threads pool) for
each network namespace.
2) Control generic resources allocation and destruction by usage counter.
3) Cleanup and simplify Nfsd service start and shutdown.
4) Move some more NFSd state parts (like boot_time and "nfsd is up" flag to
per-net data).

The following series implements...

---

Stanislav Kinsbursky (8):
      nfsd: move per-net startup code to separated function
      nfsd: per-net NFSd up flag introduced
      nfsd: make NFSd service boot time per-net
      nfsd: make NFSd service structure allocated per net
      nfsd: introduce helpers for generic resources init and shutdown
      nfsd: simplify NFSv4 state init and shutdown
      nfsd: replace boolean nfsd_up flag by users counter
      nfsd: simplify service shutdown


 fs/nfsd/netns.h     |    9 ++
 fs/nfsd/nfs3xdr.c   |   14 +++-
 fs/nfsd/nfs4proc.c  |   11 ++-
 fs/nfsd/nfs4state.c |   14 ++--
 fs/nfsd/nfsctl.c    |   63 ++++++++++-------
 fs/nfsd/nfsd.h      |   23 +-----
 fs/nfsd/nfssvc.c    |  185 +++++++++++++++++++++++++++++++++------------------
 7 files changed, 195 insertions(+), 124 deletions(-)

