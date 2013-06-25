Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f179.google.com ([209.85.160.179]:57790 "EHLO
	mail-gh0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab3FYQXU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 12:23:20 -0400
Received: by mail-gh0-f179.google.com with SMTP id f16so4105377ghb.38
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 09:23:20 -0700 (PDT)
Subject: [PATCH 0/5] For 3.11
To: trond.myklebust@netapp.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Jun 2013 12:23:17 -0400
Message-ID: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond-

Please consider these for 3.11.  Thanks.

---

Chuck Lever (5):
      NFS: Set NFS_CS_MIGRATION for NFSv4 mounts
      NFS: Use root's credential for lease management when keytab is missing
      NFS: Never use user credentials for lease renewal
      NFS: Export _nfs_display_fhandle()
      NFS: Save FSID's root FH in nfs_server


 fs/nfs/client.c           |   10 ++++++++--
 fs/nfs/inode.c            |    2 ++
 fs/nfs/internal.h         |   12 ++++++++++++
 fs/nfs/nfs4client.c       |    9 ++++++++-
 fs/nfs/nfs4proc.c         |    4 ++--
 fs/nfs/nfs4state.c        |   20 +++++++++++++++++++-
 include/linux/nfs_fs_sb.h |    1 +
 7 files changed, 52 insertions(+), 6 deletions(-)

-- 
Chuck Lever
