Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35468 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbbHYPew (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:34:52 -0400
Received: by pacdd16 with SMTP id dd16so127511040pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:34:52 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH RFC 00/11] NFS/NFSD: add NFSv42 COPY operation support
Date: Tue, 25 Aug 2015 23:33:38 +0800
Message-Id: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

This patchset adds NFSv42 COPY support to nfs and nfsd. As suggested by Christoph,
it pulls btrfs BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE ioctls to generic layer and
adds a new file operation to call down to file systems. Then the CLONE ioctl
is implemented for NFS and NFSD.

I took a slightly different approach from Anna's NFS42 COPY implementation
(http://www.spinics.net/lists/linux-nfs/msg53009.html) mainly because CLONE
has different requirements than COPY. And the main differences between the two are:
1. well, CLONE is supported rather than COPY.
2. vfs_file_clone_range() does not expect file systems to do data copy, and thus
no rw_verify_area() required.
3. clone does not expect partial success.
4. clone does not fall back to data copy if underlying storage does not support it.
5. no new system call required. We reuse existing BTRFS_IOC_CLONE/BTRFS_IOC_CLONE_RANGE
and make it generic to all file systems.

Cheers,
Tao

Anna Schumaker (2):
  nfsd: Pass filehandle to nfs4_preprocess_stateid_op()
  NFSD: Implement the CLONE call

Peng Tao (9):
  vfs: pull btrfs clone API to vfs layer
  vfs/btrfs: add .clone_range file operation
  nfs42: decode_layoutstats does not need res parameter
  nfs42: remove unused declaration
  nfs42: add CLONE xdr functions
  nfs42: add CLONE proc functions
  nfs42: add .copy_range file operation
  nfs: get clone_blksize when probing fsinfo
  nfs42: respect clone_blksize

 fs/btrfs/ctree.h           |   2 +
 fs/btrfs/file.c            |   1 +
 fs/btrfs/ioctl.c           |  68 ++++--------------------------
 fs/ioctl.c                 |  30 +++++++++++++
 fs/nfs/client.c            |   1 +
 fs/nfs/nfs42.h             |   3 +-
 fs/nfs/nfs42proc.c         |  71 +++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c          | 102 +++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4file.c          |  58 ++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c          |   4 +-
 fs/nfs/nfs4xdr.c           |  26 ++++++++++++
 fs/nfsd/nfs4proc.c         |  91 ++++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c        |   5 +--
 fs/nfsd/nfs4xdr.c          |  21 ++++++++++
 fs/nfsd/state.h            |   4 +-
 fs/nfsd/vfs.c              |   7 ++++
 fs/nfsd/vfs.h              |   1 +
 fs/nfsd/xdr4.h             |  10 +++++
 fs/read_write.c            |  45 ++++++++++++++++++++
 include/linux/fs.h         |   4 ++
 include/linux/nfs4.h       |   7 +++-
 include/linux/nfs_fs_sb.h  |   2 +
 include/linux/nfs_xdr.h    |  20 +++++++++
 include/uapi/linux/btrfs.h |  10 -----
 include/uapi/linux/fs.h    |   9 ++++
 25 files changed, 510 insertions(+), 92 deletions(-)

-- 
1.8.3.1

