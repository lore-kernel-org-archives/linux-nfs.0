Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49336 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700Ab0IJUDN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:03:13 -0400
Received: by gyd8 with SMTP id 8so1363332gyd.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:03:12 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Replace NFSROOT mount option parsing
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:03:09 -0400
Message-ID: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond-

For 2.6.37, it would be nice to eliminate the redundant mount option
parsing logic in fs/nfs/nfsroot.c.  Merged up to 2.6.36-rc, and
compile-tested.

We had discussed, as a first step, merging these into linux-next.
I unit-tested these on late 2.6.34-rc kernels, so there might be an
additional detail or two to clean up.

---

Chuck Lever (6):
      SUNRPC: Remove rpcb_getport_sync()
      NFS: Allow NFSROOT debugging messages to be enabled dynamically
      NFS: Clean up nfsroot.c
      NFS: Use super.c for NFSROOT mount option parsing
      NFS: Clean up NFSROOT command line parsing
      NFS: Remove \t from mount debugging message


 Documentation/filesystems/nfs/nfsroot.txt |   22 +
 Documentation/kernel-parameters.txt       |    5 
 fs/nfs/mount_clnt.c                       |    2 
 fs/nfs/nfsroot.c                          |  566 +++++++++--------------------
 include/linux/nfs_fs.h                    |   10 -
 include/linux/sunrpc/clnt.h               |    1 
 init/do_mounts.c                          |   12 -
 net/sunrpc/rpcb_clnt.c                    |   51 ---
 8 files changed, 208 insertions(+), 461 deletions(-)

-- 
Chuck Lever
