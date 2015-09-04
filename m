Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:44044 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbbIDTIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 15:08:09 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v1 0/5] NFS: Add READ_PLUS support
Date: Fri, 4 Sep 2015 15:07:44 -0400
Message-ID: <1441393669-30280-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an updated posting of my NFS v4.2 READ_PLUS patches from several
months ago, and it should apply against current development trees.

I tested this code  using dd to read a file between two KVMs, and I compared
the reported transfer rates against various NFS versions and the local XFS
filesystem.  I tested using four 5 GB files, the first two simply entirely
data or entirely hole.  The others alternate between data and hole pages, at
either 4 KB (one page) or 8 KB (two page) intervals.

I found that dd uses a default block size of 512 bytes, which could cause
reads over NFS to take forever.  I bumped this up to 128K during my testing
by passing the argument "bs=128K" to dd.  My results are below:

       |    XFS     |   NFS v3   |  NFS v4.0  |  NFS v4.1  |  NFS v4.2
-------|------------|------------|------------|------------|------------
  Data |  2.7 GB/s  |  845 MB/s  |  864 MB/s  |  847 MB/s  |  807 MB/s
  Hole |  4.1 GB/s  |  980 MB/s  |  1.1 GB/s  |  989 MB/s  |  2.3 GB/s
1 Page |  1.6 GB/s  |  681 MB/s  |  683 MB/s  |  688 MB/s  |  672 MB/s
2 Page |  2.5 GB/s  |  760 MB/s  |  760 MB/s  |  755 MB/s  |  836 MB/s

The pure data case is slightly slower on NFS v4.2, most likely due to
additional server-side lseeks while reading.  The alternating 1 page
regions test didn't see as large a slowdown, most likely because of to
the additional savings by not transferring zeroes over the wire.  Any
slowdown caused by additional seeks is more than made up for by the time
we reach 2 page intervals.

These patches and the corresponding server changes are available in the
[read_plus] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (5):
  SUNRPC: Split out a function for setting current page
  SUNRPC: Add the ability to expand holes in data pages
  NFS: Add basic READ_PLUS support
  SUNRPC: Add the ability to shift data to a specific offset
  NFS: Add support for decoding multiple segments

 fs/nfs/nfs42xdr.c          | 162 ++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c          |  32 +++++-
 fs/nfs/nfs4xdr.c           |   1 +
 include/linux/nfs4.h       |   1 +
 include/linux/nfs_fs_sb.h  |   1 +
 include/linux/nfs_xdr.h    |   2 +-
 include/linux/sunrpc/xdr.h |   2 +
 net/sunrpc/xdr.c           | 243 ++++++++++++++++++++++++++++++++++++++++++++-
 8 files changed, 438 insertions(+), 6 deletions(-)

-- 
2.5.1

