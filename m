Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:54917 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098AbbLCUzm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Dec 2015 15:55:42 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v1 0/4] NFSv4.2: Add support for the COPY operation
Date: Thu, 3 Dec 2015 15:55:33 -0500
Message-ID: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client and server support for the NFS v4.2 COPY operation,
and depend on the new copy_file_range() system call currently scheduled for
Linux 4.5. I gathered performance information by comparing the runtime and RPC
count of my test program, included as an RFC patch, against /usr/bin/cp for
various file sizes.

/usr/bin/cp:
                      size:    513MB   1024MB   1536MB   2048MB
------------- ------------- -------- -------- -------- --------
nfs v4 client        total:     8203    16396    24588    32780
------------- ------------- -------- -------- -------- --------
nfs v4 client         read:     4096     8192    12288    16384
nfs v4 client        write:     4096     8192    12288    16384
nfs v4 client       commit:        1        1        1        1
nfs v4 client         open:        1        1        1        1
nfs v4 client    open_noat:        2        2        2        2
nfs v4 client        close:        1        1        1        1
nfs v4 client      setattr:        2        2        2        2
nfs v4 client       access:        2        3        3        3
nfs v4 client      getattr:        2        2        2        2

/usr/bin/cp /nfs/test-512  /nfs/test-copy  0.00s user 0.32s system 14% cpu 2.209 total
/usr/bin/cp /nfs/test-1024 /nfs/test-copy  0.00s user 0.66s system 18% cpu 3.651 total
/usr/bin/cp /nfs/test-1536 /nfs/test-copy  0.02s user 0.97s system 18% cpu 5.477 total
/usr/bin/cp /nfs/test-2048 /nfs/test-copy  0.00s user 1.38s system 15% cpu 9.085 total


Copy system call:
                      size:    512MB   1024MB   1536MB   2048MB
------------- ------------- -------- -------- -------- --------
nfs v4 client        total:        6        6        6        6
------------- ------------- -------- -------- -------- --------
nfs v4 client         open:        2        2        2        2
nfs v4 client        close:        2        2        2        2
nfs v4 client       access:        1        1        1        1
nfs v4 client         copy:        1        1        1        1


./nfscopy /nfs/test-512  /nfs/test-copy  0.00s user 0.00s system 0% cpu 1.148 total
./nfscopy /nfs/test-1024 /nfs/test-copy  0.00s user 0.00s system 0% cpu 2.293 total
./nfscopy /nfs/test-1536 /nfs/test-copy  0.00s user 0.00s system 0% cpu 3.037 total
./nfscopy /nfs/test-2048 /nfs/test-copy  0.00s user 0.00s system 0% cpu 4.045 total


Questions, comments, and other testing ideas would be greatly appreciated!

Thanks,
Anna


Anna Schumaker (4):
  NFSD: Pass filehandle to nfs4_preprocess_stateid_op()
  NFSD: Implement the COPY call
  NFS: Add COPY nfs operation
  vfs_copy_range() test program

 fs/nfs/nfs42.h            |   1 +
 fs/nfs/nfs42proc.c        |  58 ++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 136 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |   8 +++
 fs/nfs/nfs4proc.c         |   1 +
 fs/nfs/nfs4xdr.c          |   1 +
 fs/nfs/objlayout/Makefile |   0
 fs/nfsd/nfs4proc.c        |  91 ++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c       |   5 +-
 fs/nfsd/nfs4xdr.c         |  62 ++++++++++++++++++++-
 fs/nfsd/state.h           |   4 +-
 fs/nfsd/vfs.c             |  17 ++++++
 fs/nfsd/vfs.h             |   1 +
 fs/nfsd/xdr4.h            |  23 ++++++++
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  27 +++++++++
 nfscopy.c                 |  59 ++++++++++++++++++++
 18 files changed, 482 insertions(+), 14 deletions(-)
 create mode 100644 fs/nfs/objlayout/Makefile
 create mode 100644 nfscopy.c

-- 
2.6.3

