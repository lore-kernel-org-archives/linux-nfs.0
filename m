Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:33326 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab3KLTGY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 14:06:24 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFS: Add support for SEEK_HOLE and SEEK_DATA
Date: Tue, 12 Nov 2013 14:06:10 -0500
Message-ID: <1384283171-8062-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch should be applied after the matching NFSD patch series
(NFSD: Implement SEEK) and only includes the SEEK patch from my earlier
WRITE_PLUS / SEEK submission.

Questions?  Comments?  Thoughts?
Anna

Anna Schumaker (1):
  NFS: Implement SEEK

 fs/nfs/inode.c          |   2 +
 fs/nfs/nfs4_fs.h        |   4 ++
 fs/nfs/nfs4file.c       |  61 +++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c       |  31 ++++++++++++++
 fs/nfs/nfs4xdr.c        | 109 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |   3 ++
 include/linux/nfs_xdr.h |  22 ++++++++++
 7 files changed, 232 insertions(+)

-- 
1.8.4.2

