Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43811 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932414Ab0DPUbY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:24 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMkt026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:22 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/24] Reduce the stack foot print of the NFS client
Date: Fri, 16 Apr 2010 16:30:58 -0400
Message-Id: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patch series aims to significantly reduce the stack foot
print of the NFS client by dynamically allocating the struct nfs_fattr
and struct nfs_fh.

Cheers
  Trond

Trond Myklebust (24):
  NFS: Add helper functions for allocating filehandles and fattr
    structs
  NFSv4: Eliminate nfs4_path_walk()
  NFS: Reduce the stack footprint of nfs_follow_mountpoint()
  NFS: Reduce the stack footprint of nfs_create_server
  NFSv4: Reduce the stack footprint of try_location()
  NFS: Reduce the stack footprint of nfs_lookup
  NFS: Reduce the stack footprint of nfs_follow_remote_path()
  NFSv4: Reduce stack footprint of nfs4_get_root()
  NFSv4: Reduce the stack footprint of nfs4_remote_referral_get_sb
  NFSv4: Reduce stack footprint of nfs4_proc_access() and
    nfs3_proc_access()
  NFS: Reduce stack footprint of nfs_revalidate_inode()
  NFS: Reduce stack footprint of nfs3_proc_rename() and
    nfs4_proc_rename()
  NFS: Reduce stack footprint of nfs_readdir()
  NFS: Reduce the stack footprint of nfs_link()
  NFS: Reduce stack footprint of nfs3_proc_readlink()
  NFS: Reduce stack footprint of nfs_proc_remove()
  NFS: Reduce the stack footprint of nfs_rmdir
  NFS: Reduce the stack footprint of nfs_proc_create
  NFS: Reduce the stack footprint of nfs_proc_symlink()
  NFS: Reduce stack footprint of nfs4_proc_create()
  NFS: Reduce stack footprint of nfs_setattr()
  NFS: Reduce stack footprint of nfs_statfs()
  NFS: Reduce stack footprint of nfs3_proc_getacl() and
    nfs3_proc_setacl()
  NFS: Prevent the mount code from looping forever on broken exports

 fs/nfs/client.c         |   54 ++++++++++---
 fs/nfs/dir.c            |   62 +++++++++++----
 fs/nfs/getroot.c        |  191 +++++++++++++++++------------------------------
 fs/nfs/inode.c          |   46 ++++++++++--
 fs/nfs/internal.h       |    4 +-
 fs/nfs/namespace.c      |   20 ++++--
 fs/nfs/nfs3acl.c        |   23 ++++--
 fs/nfs/nfs3proc.c       |  128 +++++++++++++++++++------------
 fs/nfs/nfs3xdr.c        |    2 +-
 fs/nfs/nfs4namespace.c  |   10 ++-
 fs/nfs/nfs4proc.c       |   81 ++++++++++++--------
 fs/nfs/nfs4xdr.c        |    2 +-
 fs/nfs/proc.c           |  144 ++++++++++++++++++++---------------
 fs/nfs/super.c          |  121 ++++++++++++++++++++++++++----
 fs/nfs/unlink.c         |    4 +-
 include/linux/nfs_fs.h  |   14 ++++
 include/linux/nfs_xdr.h |    2 +-
 17 files changed, 566 insertions(+), 342 deletions(-)

