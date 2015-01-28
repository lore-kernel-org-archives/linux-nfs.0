Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:49184 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934225AbbA1Un7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:43:59 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/6] NFS: Add READ_PLUS support
Date: Wed, 28 Jan 2015 15:43:44 -0500
Message-ID: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client support for the NFS v4.2 operation READ_PLUS.  This
operation is triggered by doing any kind of read on a NFS v4.2 mounted
filesystem.  `

Changes since v1:
- Add support for decoding multiple segments.

These patches and the corresponding server changes are available in the
[read_plus] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (6):
  NFS: Add READ_PLUS support for data segments
  SUNRPC: Split out a function for setting current page
  SUNRPC: Add the ability to expand holes in data pages
  NFS: Add READ_PLUS support for hole segments
  SUNRPC: Add the ability to shift data to a specific offset
  NFS: Add support for decoding multiple segments

 fs/nfs/nfs42xdr.c          | 163 ++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c          |  30 +++++-
 fs/nfs/nfs4xdr.c           |   1 +
 include/linux/nfs4.h       |   1 +
 include/linux/nfs_fs_sb.h  |   1 +
 include/linux/nfs_xdr.h    |   2 +-
 include/linux/sunrpc/xdr.h |   2 +
 net/sunrpc/xdr.c           | 245 ++++++++++++++++++++++++++++++++++++++++++++-
 8 files changed, 440 insertions(+), 5 deletions(-)

-- 
2.2.2

