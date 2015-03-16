Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:44129 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932738AbbCPVRy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 17:17:54 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v3 0/5] NFS: Add READ_PLUS support
Date: Mon, 16 Mar 2015 17:17:41 -0400
Message-ID: <1426540666-31896-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client support for the NFS v4.2 operation READ_PLUS.  This
operation is triggered by doing any kind of read on a NFS v4.2 mounted
filesystem.  `

I tested these patches using xfstests and compared the runtime between NFS
v4.1, NFS v4.2 without READ_PLUS, and NFS v4.2 with READ_PLUS.  Here are
the results:


   Test     |   v4.1    | no READ_PLUS |  READ_PLUS
---------------------------------------------------
generic/013 | 135s      |    143s      |    123s
generic/075 |   4s      |     11s      |      4s
generic/091 |   9s      |     16s      |     15s
generic/112 |   4s      |      7s      |      6s
generic/127 |  62s      |    117s      |    114s
generic/213 | [not run] |      1s      |      1s
generic/214 | [not run] |      0s      |      0s
generic/228 | [not run] |      1s      |      2s
generic/236 |   1s      |      1s      |      1s
generic/263 |   4s      |      6s      |      8s
generic/285 |   0s      |      1s      |      3s
generic/315 | [not run] |      2s      |      1s
---------------------------------------------------
Total       |  3:47.47  |    5:11.85   |  4:43.77


Using the READ_PLUS operation does have an impact on reading sparse
files over the network.  There is still a big difference between v4.1
and v4.2 runtimes, but this looks to be a result of fallocate() tests
that only run over v4.2.


Changes since v2:
- Merge together patches adding DATA and HOLE segment support.
- Simplify hole zeroing code by using the zero_user_segment() function.

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
 fs/nfs/nfs4proc.c          |  30 +++++-
 fs/nfs/nfs4xdr.c           |   1 +
 include/linux/nfs4.h       |   1 +
 include/linux/nfs_fs_sb.h  |   1 +
 include/linux/nfs_xdr.h    |   2 +-
 include/linux/sunrpc/xdr.h |   2 +
 net/sunrpc/xdr.c           | 240 ++++++++++++++++++++++++++++++++++++++++++++-
 8 files changed, 434 insertions(+), 5 deletions(-)

-- 
2.3.3

