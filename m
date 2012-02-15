Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39849 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab2BOTlg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 14:41:36 -0500
Received: by iacb35 with SMTP id b35so1851170iac.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 11:41:36 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/13] For 3.4
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 14:41:33 -0500
Message-ID: <20120215193059.2925.10928.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I'm sure a hunk here or there is no longer necessary.  This is the set
of minor clean ups that have been hanging around in my tree for about
a year, as part of a patch series to support NFSv4.0 migration.

Please consider for inclusion in 3.4.

---

Chuck Lever (13):
      NFS: Request fh_expire_type attribute in "server caps" operation
      NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
      NFS: Simplify arguments of encode_renew()
      NFS: Save root file handle in nfs_server
      NFS: Add a client-side function to display NFS file handles
      SUNRPC: Add API to acquire source address
      NFS: Reduce debugging noise from encode_compound_hdr
      NFS: Add debugging messages to NFSv4's CLOSE procedure
      NFS: Clean up debugging in decode_pathname()
      nfs: Clean up debugging in nfs_follow_mountpoint()
      SUNRPC: Use KERN_DEFAULT for debugging printk's
      NFS: Fix comparison signage warnings with slot ID computations
      NFS: Make nfs_cache_array.size a signed integer


 fs/nfs/client.c              |    1 
 fs/nfs/dir.c                 |    2 -
 fs/nfs/getroot.c             |    5 +
 fs/nfs/inode.c               |   45 +++++++++++++
 fs/nfs/namespace.c           |    5 +
 fs/nfs/nfs4proc.c            |   24 ++++---
 fs/nfs/nfs4xdr.c             |   54 ++++++++++++---
 include/linux/nfs_fs.h       |   14 ++++
 include/linux/nfs_fs_sb.h    |    4 +
 include/linux/nfs_xdr.h      |    8 +-
 include/linux/sunrpc/clnt.h  |    1 
 include/linux/sunrpc/debug.h |    6 +-
 net/sunrpc/clnt.c            |  149 ++++++++++++++++++++++++++++++++++++++++++
 13 files changed, 290 insertions(+), 28 deletions(-)

-- 
Chuck Lever
