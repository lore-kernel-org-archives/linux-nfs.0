Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:33328 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753344Ab0A1V0Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 16:26:25 -0500
Subject: [PATCH 0/3] nfs-utils: multithreaded mountd fixes
To: SteveD@redhat.com
From: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 28 Jan 2010 15:26:24 -0600
Message-ID: <20100128211454.29681.24752.stgit@case.americas.sgi.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Steve,

The following fixes a problem with mountd where you get backed up behind the
rmtab lock.  It may have happened that an xflock timed out and stat failed so
the filedescriptor was leaked in mountlist_list and the lock never released.
Skipping the fdatasync has also helped performance-wise.

Tested very lightly on TOT and more heavily on 1.0.7 where this bug was
discovered.

Thanks,
Ben

---

Ben Myers (3):
      nfs-utils: remove xflock timeout
      nfs-utils: dont leak fd in mountlist_list
      nfs-utils: don't fdatasync the rmtab


 support/nfs/cacheio.c |    5 ++---
 support/nfs/rmtab.c   |   23 ++++++++++++++++++-----
 support/nfs/xio.c     |   18 +-----------------
 utils/mountd/rmtab.c  |    5 ++++-
 4 files changed, 25 insertions(+), 26 deletions(-)

-- 
