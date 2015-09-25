Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36063 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbbIYKZ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 06:25:59 -0400
Received: by pablk4 with SMTP id lk4so5734535pab.3
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 03:25:58 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 0/6] nfs: add NFSv42 CLONE support
Date: Sat, 26 Sep 2015 02:24:33 +0800
Message-Id: <1443205479-13563-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

This is the same patchset that was sent in July. It added NFSv42 CLONE
support to nfs. Follow btrfs lead to use same ioctl for the CLONE
functionality, as sugggested by Christoph.

nfsd CLONE support will be post separately, to make the client side change easy
to merge, since nfsd change would conflict heavily with Anna's COPY work.

Cheers,
Tao

Peng Tao (6):
  nfs42: add CLONE xdr functions
  nfs42: add CLONE proc functions
  nfs42: add NFS_IOC_CLONE ioctl
  nfs: get clone_blksize when probing fsinfo
  nfs42: respect clone_blksize
  nfs42: add NFS_IOC_CLONE_RANGE ioctl

 fs/nfs/client.c           |   1 +
 fs/nfs/nfs42.h            |   1 +
 fs/nfs/nfs42proc.c        |  71 ++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         |  97 ++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4file.c         | 127 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |   4 +-
 fs/nfs/nfs4xdr.c          |  26 ++++++++++
 include/linux/nfs4.h      |   3 ++
 include/linux/nfs_fs_sb.h |   2 +
 include/linux/nfs_xdr.h   |  20 ++++++++
 include/uapi/linux/nfs.h  |  11 ++++
 11 files changed, 361 insertions(+), 2 deletions(-)

-- 
1.8.3.1

