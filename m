Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935567AbcHJT61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Aug 2016 15:58:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, tigran.mkrtchyan@desy.de
Subject: [PATCH v4 0/2] pnfs: allow client to handle multiple layout types per filesystem
Date: Wed, 10 Aug 2016 15:58:23 -0400
Message-Id: <1470859105-32383-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4:
- pass around fsinfo instead of separate array and length args

v3:
- use sort() from lib/sort.c to sort the list

v2:
- rework Tigran's patch to preserve existing selection behaviour
- simplify layout driver selection by sorting the list

This is v4 of the patchset. The main change is the change to pass
around the fsinfo instead of separate array pointer and length args.

Only lightly tested by mounting a server that sends both flexfiles and
block layouts. The client successfully selected the block layout in most
cases, but if I blacklist blocklayoutdriver then it selects flexfiles
instead.

Jeff Layton (2):
  pnfs: track multiple layout types in fsinfo structure
  pnfs: add a new mechanism to select a layout driver according to an
    ordered list

 fs/nfs/client.c         |  3 ++-
 fs/nfs/nfs4proc.c       |  2 +-
 fs/nfs/nfs4xdr.c        | 40 +++++++++++++++--------------
 fs/nfs/pnfs.c           | 68 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/pnfs.h           |  5 ++--
 include/linux/nfs_xdr.h |  8 +++++-
 6 files changed, 90 insertions(+), 36 deletions(-)

-- 
2.7.4

