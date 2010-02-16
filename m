Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:42504 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933078Ab0BPVER (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Feb 2010 16:04:17 -0500
Subject: [PATCH 0/2] commit_metadata export operation v5
To: bfields@fieldses.org
From: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Date: Tue, 16 Feb 2010 15:04:08 -0600
Message-ID: <20100216210026.5694.14423.stgit@case>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Bruce,

Here is the latest version of the knfsd sync changes that I've been spamming
you with.  I have addressed the latest suggestions provided by Christoph,
Trond, Dave, and Alex.  This version of the commit_metadata export operation
takes only one inode as suggested by Christoph and it turns out to be much
cleaner this way.  Now we've gone back to committing all of the time in
nfsd_create_setattr and don't bother with the added argument.  A couple extra
comments to explain the commit ordering.

Thanks,
Ben

---

Ben Myers (2):
      commit_metadata export operation replacing nfsd_sync_dir
      xfs_export_operations.commit_metadata


 fs/nfsd/nfs4recover.c         |    4 --
 fs/nfsd/vfs.c                 |  109 ++++++++++++++++++++---------------------
 fs/xfs/linux-2.6/xfs_export.c |   24 +++++++++
 include/linux/exportfs.h      |    5 ++
 4 files changed, 83 insertions(+), 59 deletions(-)

-- 
