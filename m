Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:17257 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760270AbbIDTHZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 15:07:25 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/3] NFSD: Add READ_PLUS support
Date: Fri, 4 Sep 2015 15:07:18 -0400
Message-ID: <1441393641-30152-1-git-send-email-Anna.Schumaker@Netapp.com>
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

These patches and the corresponding client changes are available in the
[read_plus] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thoughts?

Anna



Anna Schumaker (3):
  NFSD: nfsd4_encode_read{v}() should encode eof and maxcount
  NFSD: Add basic READ_PLUS support
  NFSD: Add support for encoding multiple segments

 fs/nfsd/nfs4proc.c |  16 +++++
 fs/nfsd/nfs4xdr.c  | 183 ++++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 161 insertions(+), 38 deletions(-)

-- 
2.5.1

