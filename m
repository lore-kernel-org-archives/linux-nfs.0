Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757765Ab3BVRJo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 12:09:44 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2]  NFS v4.2 support to both the server and client (take 4)
Date: Fri, 22 Feb 2013 12:09:39 -0500
Message-Id: <1361552981-29385-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes:
  * fixed typo in Kconfig 
  * Reworked verbiage in Kconfig file
  * Merged cases in nfs_callback_up_net()
  * Created a new nfs4_minor_version_ops structure for minor version 2
  * Correctly initialized minor number in nfsd_exchange_id()
  * Correct a comment in the nfs4_cb_conn structure.

These patches add v4.2 support to both the server and client. 
The v4.1 code is reused to support this new version. Main reason
for this new version is to enable features like Label NFS.

Note, these patches apply on top of the lNFS: 3.8-rc3 release
patches. Although the only conflict, if applied without those 
patches, would be in the Kconfig files 

Steve Dickson (2):
  NFSv4.2: Added NFS v4.2 support to the NFS client
  NFSDv4.2: Added NFS v4.2 support to the NFS server

 fs/nfs/Kconfig       | 33 +++++++++++++++++++--------------
 fs/nfs/callback.c    |  1 +
 fs/nfs/nfs4client.c  |  5 +++++
 fs/nfs/nfs4proc.c    | 15 +++++++++++++++
 fs/nfs/super.c       |  7 ++++++-
 fs/nfsd/nfs4state.c  |  2 +-
 fs/nfsd/nfs4xdr.c    |  1 +
 fs/nfsd/nfsd.h       |  2 +-
 fs/nfsd/state.h      |  2 +-
 include/linux/nfs4.h |  4 ++++
 10 files changed, 54 insertions(+), 18 deletions(-)

-- 
1.8.1.2

