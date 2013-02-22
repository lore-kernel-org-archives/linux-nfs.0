Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376Ab3BVOfA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 09:35:00 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] NFS v4.2 support to both the server and client (take 3)
Date: Fri, 22 Feb 2013 09:34:55 -0500
Message-Id: <1361543697-9642-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes:
  * fixed typo in Kconfig 

These patches add v4.2 support to both the server and client. 
The v4.1 code is reused to support this new version. Main reason
for this new version is to enable features like Label NFS.

Note, these patches apply on top of the lNFS: 3.8-rc3 release
patches. Although the only conflict, if applied without those 
patches, would be in the Kconfig files 

Steve Dickson (2):
  NFSv4.2: Added NFS v4.2 support to the NFS client
  NFSDv4.2: Added NFS v4.2 support to the NFS server

 fs/nfs/Kconfig       | 12 +++++++++++-
 fs/nfs/callback.c    |  3 +++
 fs/nfs/nfs4client.c  |  5 +++++
 fs/nfs/nfs4proc.c    |  3 +++
 fs/nfs/super.c       |  7 ++++++-
 fs/nfsd/nfs4xdr.c    |  1 +
 fs/nfsd/nfsd.h       |  2 +-
 include/linux/nfs4.h |  4 ++++
 8 files changed, 34 insertions(+), 3 deletions(-)

-- 
1.8.1.2

