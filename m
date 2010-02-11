Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:33177 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756599Ab0BKWE7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 17:04:59 -0500
Subject: [PATCH 0/2] commit_metadata export operation v4
To: bfields@fieldses.org
From: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Date: Thu, 11 Feb 2010 16:04:55 -0600
Message-ID: <20100211220454.26466.37578.stgit@case>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Bruce,

Here is the latest version of the knfsd sync changes.  I have addressed the
suggestions provided by Christoph, Trond, and Dave.  This time rebased atop
for-2.6.34 (I hope).  Sorry for the extra noise.

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
