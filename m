Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61929 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943Ab2EXROr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 13:14:47 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/4] NFSv4.1 add nfs_inode book keeping for mdsthreshold
Date: Thu, 24 May 2012 13:13:23 -0400
Message-Id: <1337879604-24940-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Only resending NFSv4.1 add nfs_inode book keeping for mdsthreshold. 
Responded to Trond's comments.
I have not tested the directio nor the memmap io cases. The regular file
i/o works as intended.

Andy Adamson (4):
  NFSv4.1 mdsthreshold attribute xdr
  NFSv4.1 cache mdsthreshold values on OPEN
  NFSv4.1 add nfs_inode book keeping for mdsthreshold
  NFSv4.1 test the mdsthreshold hint parameters

 fs/nfs/direct.c         |    2 +
 fs/nfs/file.c           |    1 +
 fs/nfs/inode.c          |    4 ++
 fs/nfs/nfs4proc.c       |   38 ++++++++++++--
 fs/nfs/nfs4xdr.c        |  125 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.c           |   94 +++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h           |   21 ++++++++
 fs/nfs/read.c           |    2 +
 include/linux/nfs4.h    |    7 +++
 include/linux/nfs_fs.h  |    4 ++
 include/linux/nfs_xdr.h |   10 ++++
 11 files changed, 301 insertions(+), 7 deletions(-)

-- 
1.7.7.6

