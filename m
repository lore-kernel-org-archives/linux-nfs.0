Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564Ab2DDUXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Apr 2012 16:23:18 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFSv4.1 resend LAYOUTGET on data server invalid layout errors
Date: Wed,  4 Apr 2012 16:22:36 -0400
Message-Id: <1333570957-2008-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

>From patch comments:

The "invalid layout" class of errors is handled by destroying the layout and
getting a new layout from the server.  Currently, the layout must be
destroyed before a new layout can be obtained.

This means that all references (e.g.lsegs) to the "to be destroyed" layout
header must be dropped before it can be destroyed. This in turn means waiting
for all in flight RPC's using the old layout as well as draining the data
server session slot table wait queue.

Set the NFS_LAYOUT_INVALID flag to redirect I/O to the MDS while waiting for
the old layout to be destroyed.

Testing:

Tested against a modified pynfs filelayout server with one DS. I mount the DS,
set an NFS4ERR_BADHANDLE error in config/ops/write file which triggers the
error on the "first" write. Umount the DS. Mount the MDS and run
"dd if=/dev/zero of=/mnt/dd.out bs=4096 count=200". This results in a maxreqs
worth of writes to the DS (8 for pynfs) before the NFS4ERR_BADHANDLE gets
sent whereon writes are redirected to the MDS. Once the DS on the wire RPC's
have all returned, and all the DS slot_tbl_waitq tasks are redirected to the
MDS, the layout is destroyed, a new layout is obtained, and the writes return
to pNFS before the 'dd' command finishes.

Andy Adamson (1):
  NFSv4.1 resend LAYOUTGET on data server invalid layout errors

 fs/nfs/nfs4filelayout.c |   27 +++++++++++++++++++++++----
 fs/nfs/nfs4filelayout.h |   13 +++++++++++++
 fs/nfs/pnfs.c           |    1 +
 fs/nfs/pnfs.h           |    1 +
 4 files changed, 38 insertions(+), 4 deletions(-)

-- 
1.7.6.4

