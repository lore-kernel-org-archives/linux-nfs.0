Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50482 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751820AbaIRGKA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 02:10:00 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 18 Sep 2014 16:09:27 +1000
Subject: [PATCH 0/2] Two miscellaneous NFS patches.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140918060551.24098.72288.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are two unrelated patches that I found while tidying up :-)
One has been sitting, unloved, for over a year... (though I did
mention it in a recent email - I'm resending it for simplicity).

Both fix performance issues in unusual situations.
The first allows an 'unlink' to complete in 100ms where it will
take 15 seconds in the current kernel.
The second uses non-STABLE writes in a case where STABLE writes
are current used but not needed, resulting in reduced throughput.

Thanks,
NeilBrown


---

NeilBrown (2):
      NFSv4: use exponential retry on NFS4ERR_DELAY for async requests.
      NFS: don't use STABLE writes during writeback.


 fs/nfs/nfs4proc.c       |   65 ++++++++++++++++++++++++++++++-----------------
 fs/nfs/write.c          |    7 ++++-
 include/linux/nfs_xdr.h |    2 +
 3 files changed, 49 insertions(+), 25 deletions(-)

-- 
Signature

