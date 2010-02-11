From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 0/2] commit_metadata export operation v3
Date: Thu, 11 Feb 2010 13:26:12 -0600
Message-ID: <20100211192611.12949.65493.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: xfs@oss.sgi.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:54709 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756714Ab0BKT0R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 14:26:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is the latest version of the knfsd sync changes.  I have addressed the
suggestions provided by Christoph, Trond, and Dave.

Thanks,
	Ben

---

Ben Myers (2):
      commit_metadata export operation replacing nfsd_sync_dir
      xfs_export_operations.commit_metadata


 fs/nfsd/nfs3proc.c            |    2 -
 fs/nfsd/nfs4proc.c            |    2 -
 fs/nfsd/nfs4recover.c         |    4 -
 fs/nfsd/nfs4state.c           |    2 -
 fs/nfsd/nfsproc.c             |    4 +
 fs/nfsd/vfs.c                 |  116 +++++++++++++++++++----------------------
 fs/nfsd/vfs.h                 |    3 -
 fs/xfs/linux-2.6/xfs_export.c |   43 +++++++++++++++
 include/linux/exportfs.h      |    6 ++
 9 files changed, 111 insertions(+), 71 deletions(-)

-- 
