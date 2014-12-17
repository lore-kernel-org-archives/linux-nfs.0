Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48804 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbaLQWf3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 17:35:29 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] NFS: Add READ_PLUS support
Date: Wed, 17 Dec 2014 17:35:23 -0500
Message-ID: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client support for the NFS v4.2 operation READ_PLUS.  This
operation is triggered by doing any kind of read on a NFS v4.2 mounted
filesystem.  `

The spec allows for the server to return multiple data and hole segments when
reading a file.  Supporting this would requre a tedious amount of shifiting
to make sure data is aligned properly, so I'm skipping this feature until I
figure out a clean way of coding it.

These patches and the corresponding server changes are available in the
[read_plus] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (3):
  NFS: Add basic support for READ_PLUS
  SUNRPC: Add the ability to zero out data pages
  NFS: Add support for reading NFS4_CONTENT_HOLE segments

 fs/nfs/nfs42xdr.c          | 159 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c          |  30 ++++++++-
 fs/nfs/nfs4xdr.c           |   1 +
 include/linux/nfs4.h       |   1 +
 include/linux/nfs_fs_sb.h  |   1 +
 include/linux/nfs_xdr.h    |   2 +-
 include/linux/sunrpc/xdr.h |   1 +
 net/sunrpc/xdr.c           |  45 +++++++++++++
 8 files changed, 237 insertions(+), 3 deletions(-)

-- 
2.1.3

