Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37557 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758716Ab1DYSnP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:43:15 -0400
Received: by iwn34 with SMTP id 34so2050043iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:43:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/15] Client-side NFSv4 migration (take 2?)
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:43:09 -0400
Message-ID: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond-

These apply on top of a 2.6.39-rc4 kernel with the RPC lock client
patches.  The full series is available at:

  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=commit;h=6e324e239238810e939d76af4d59a3b60e8d59ea

Light testing identified a number of bugs and verified that the
architecture is suitable for consideration for integration in 2.6.40.

For various reasons, I was not able to test post-migration state
recovery at this time, but I expect to have testing facilities
available for a while to continue exercising this code.  I don't
think state recovery will need much, if any, extra work.

Also, I don't have facilities yet to try NFSv4.1 migration.

---

Chuck Lever (15):
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Remove "const" from "struct nfs_server *" fields
      NFS: Add basic migration support to state manager thread
      NFS: Add functions to swap transports during migration recovery
      NFS: Add an API for cloning an nfs_client
      NFS: Add infrastructure for updating callback data
      NFS: Introduce nfs4_proc_get_mig_status()
      NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
      NFS: Save root file handle in nfs_server
      NFS: Add a client-side function to display file handles
      SUNRPC: Add API to acquire source address
      SUNRPC: Address a lockdep splat in sunrpc.ko
      NFS: Address lockdep splat during NFSv4 mount
      SUNRPC: Remove obsolete comment


 fs/nfs/client.c             |  112 +++++++++++++++++++----
 fs/nfs/getroot.c            |    5 +
 fs/nfs/inode.c              |   45 +++++++++
 fs/nfs/internal.h           |    6 +
 fs/nfs/nfs4_fs.h            |    8 ++
 fs/nfs/nfs4namespace.c      |  202 +++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c           |  203 ++++++++++++++++++++++++++++++++++++-----
 fs/nfs/nfs4state.c          |  213 ++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c            |   50 +++++++---
 include/linux/nfs_fs.h      |   14 +++
 include/linux/nfs_fs_sb.h   |    7 +
 include/linux/nfs_xdr.h     |   36 ++++---
 include/linux/sunrpc/clnt.h |    1 
 net/sunrpc/clnt.c           |  155 ++++++++++++++++++++++++++++++-
 net/sunrpc/xprt.c           |    2 
 15 files changed, 977 insertions(+), 82 deletions(-)

-- 
Chuck Lever
