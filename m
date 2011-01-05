Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43304 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954Ab1AEB55 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 20:57:57 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/5] Allow the admin to turn off NFSv4 uid/gid mapping
Date: Tue,  4 Jan 2011 20:57:46 -0500
Message-Id: <1294192671-18864-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches allow the admin to turn off NFSv4 uid/gid mapping
if mounting using AUTH_SYS security.

Minor changes w.r.t. first revision:
 - Added documentation in kernel-parameters.txt
 - Print a warning if an NFS4ERR_BADOWNER causes us to turn idmapping on again

Changes w.r.t. second revision:
 - Ensure we propagate the NFS4ERR_BADOWNER up to the NFSv4 middle layers
 - Fix a typo in nfs4_handle_exception

Changes w.r.t. third revision:
 - Work around a Linux server bug which causes pre-2.6.37 kernels to return
   NFS4ERR_BADNAME in cases where it should be returning NFS4ERR_BADOWNER.

Trond Myklebust (5):
  NFSv4: If the server sends us a numeric uid/gid then accept it
  NFSv4: Send unmapped uid/gids to the server if the idmapper fails
  NFSv4: cleanup idmapper functions to take an nfs_server argument
  NFSv4: Propagate the error NFS4ERR_BADOWNER to nfs4_do_setattr
  NFSv4: Send unmapped uid/gids to the server when using auth_sys

 Documentation/kernel-parameters.txt |    8 +++
 fs/nfs/client.c                     |   16 ++++++
 fs/nfs/idmap.c                      |   87 +++++++++++++++++++++++++++-------
 fs/nfs/nfs4proc.c                   |   18 +++++++-
 fs/nfs/nfs4xdr.c                    |   20 +++-----
 include/linux/nfs_fs_sb.h           |    1 +
 include/linux/nfs_idmap.h           |    8 ++--
 7 files changed, 123 insertions(+), 35 deletions(-)

-- 
1.7.3.4

