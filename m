Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50231 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498AbaIRGEV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 02:04:21 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 18 Sep 2014 16:03:17 +1000
Subject: [PATCH 0/4] Remove possible deadlocks in nfs_release_page() - V2
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140918055907.23854.32118.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These two patches are updated versions of the last two patches of this
series.  They include the use of congestion to avoid excessive
waiting.

(I'm not resenting 1/4 and 2/4, they are unchanged).

Without the congestion check, I've seen wait times in
try_to_free_pages as long as 208 seconds.
With no waiting at all in nfs_release_page() I've seen wait times as long
as 1.4 seconds.
With the 1 second wait, I've seen 2 seconds.
These numbers will vary based on numerous factors, but it does seem
to suggest that 1 second is a good ball-park number.

NeilBrown

---

NeilBrown (2):
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.
      NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()


 fs/nfs/file.c                   |   28 ++++++++++++++++++----------
 fs/nfs/write.c                  |    7 +++++++
 net/sunrpc/sched.c              |    2 --
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtsock.c           |   10 ----------
 5 files changed, 25 insertions(+), 24 deletions(-)

-- 
Signature

