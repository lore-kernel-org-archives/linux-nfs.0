Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47448 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750808AbdGMGa2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 02:30:28 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>
Date: Thu, 13 Jul 2017 16:30:05 +1000
Subject: [PATCH 0/4] Fix assorted problems with mount.nfs
Cc: linux-nfs@vger.kernel.org
Message-ID: <149992731965.9181.6611555845253022123.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These 4 patches fix various issues involves old versions of glibc, old
kernels, and parsing of old options.

Thanks,
NeilBrown

---

NeilBrown (4):
      mount: support compiling with old glibc
      mount: use version string that is supported by old kernels.
      mount: move handling of "-t nfs4" into nfs_nfs_version()
      mount: Fix problems with parsing minorversion=


 utils/mount/configfile.c |    2 +-
 utils/mount/network.c    |   41 ++++++++++++++++++++++++++---------------
 utils/mount/network.h    |    2 +-
 utils/mount/nfsumount.c  |    2 +-
 utils/mount/stropts.c    |   28 +++++++++++++++++++---------
 5 files changed, 48 insertions(+), 27 deletions(-)

--
Signature

