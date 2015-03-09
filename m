Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:40113 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbCIUFG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2015 16:05:06 -0400
Received: by qgdq107 with SMTP id q107so31425679qgd.7
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2015 13:05:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] Don't cache pNFS deviceids in violation of RFC5661 rules
Date: Mon,  9 Mar 2015 16:04:59 -0400
Message-Id: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 says that we can only cache a pNFS deviceid if at least one of 2
conditions is satisfied:

1) There are outstanding layouts that reference that stateid
2) The server set the NOTIFY_DEVICEID4_CHANGE and NOTIFY_DEVICEID4_DELETE
   in its reply to the GETDEVICEINFO call.

Trond Myklebust (4):
  NFSv4.1: Convert pNFS deviceid to use kfree_rcu()
  NFSv4.1: Cleanup - don't opencode nfs4_put_deviceid_node()
  NFSv4.1: Allow getdeviceinfo to return notification info back to
    caller
  NFSv4.1: Don't cache deviceids that have no notifications

 fs/nfs/blocklayout/dev.c                  |  2 +-
 fs/nfs/filelayout/filelayoutdev.c         |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  2 +-
 fs/nfs/nfs4proc.c                         |  7 +++++++
 fs/nfs/nfs4xdr.c                          | 14 +++++---------
 fs/nfs/objlayout/objio_osd.c              |  2 +-
 fs/nfs/pnfs.h                             |  3 +++
 fs/nfs/pnfs_dev.c                         | 21 +++++++++++++--------
 include/linux/nfs_xdr.h                   |  2 ++
 9 files changed, 34 insertions(+), 21 deletions(-)

-- 
2.1.0

