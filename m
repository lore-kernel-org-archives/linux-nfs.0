Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34693 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbbJXP2q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:28:46 -0400
Received: by padhk11 with SMTP id hk11so144702920pad.1
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:28:45 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org,
        Steve French <steve.french@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 0/9] vfs: move btrfs clone ioctls to common code
Date: Sun, 25 Oct 2015 07:17:07 +0800
Message-Id: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

This patchset moves BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE to common vfs
layer and adds NFS42 CLONE support to knfsd.

It is based on top of Trond's linux-next branch (a85240d254) and Anna's latest
sys_copy_file_range work (v7).

With this, btrfs/cifs/nfs all handle CLONE/CLONE_RANGE ioctls through the
.copy_file_range method instead of each implementing them in the private
ioctl handlers.

Cheers,
Tao

Anna Schumaker (2):
  nfsd: Pass filehandle to nfs4_preprocess_stateid_op()
  NFSD: Implement the CLONE call

Peng Tao (7):
  vfs: add COPY_FILE_CLONE_ONLY flag
  cifs: add .copy_file_range file operation
  nfs42: add .copy_file_range file operation
  vfs: pull btrfs clone API to vfs layer
  btrfs: remove btrfs_ioctl_clone(_range)
  cifs: remove private handler of BTRFS_IOC_CLONE
  nfs42: remove private clone ioctl handler

 fs/btrfs/ioctl.c        |  49 ------------------
 fs/cifs/cifsfs.c        |  22 ++++++++
 fs/cifs/cifsfs.h        |   4 +-
 fs/cifs/ioctl.c         | 103 ++++++++++++++++++++-----------------
 fs/ioctl.c              |  40 +++++++++++++++
 fs/nfs/nfs4file.c       | 133 +++++++++---------------------------------------
 fs/nfsd/nfs4proc.c      |  96 +++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c     |   6 +--
 fs/nfsd/nfs4xdr.c       |  21 ++++++++
 fs/nfsd/state.h         |   5 +-
 fs/nfsd/vfs.c           |  12 +++++
 fs/nfsd/vfs.h           |   1 +
 fs/nfsd/xdr4.h          |  10 ++++
 fs/read_write.c         |   9 ++--
 include/linux/fs.h      |   3 ++
 include/linux/nfs4.h    |   4 +-
 include/uapi/linux/fs.h |   9 ++++
 17 files changed, 303 insertions(+), 224 deletions(-)

-- 
1.8.3.1

