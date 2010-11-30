Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821Ab0K3Onh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 09:43:37 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/5] Allow the admin to turn off NFSv4 uid/gid mapping
Date: Tue, 30 Nov 2010 09:43:26 -0500
Message-Id: <1291128211-7961-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches allow the admin to turn off NFSv4 uid/gid mapping
if mounting using AUTH_SYS security.

Changes w.r.t. first revision:
 - Added documentation in kernel-parameters.txt
 - Print a warning if an NFSERR_BADOWNER causes us to turn idmapping on again

Changes w.r.t. second revision:
 - Ensure we propagate the NFS4ERR_BADOWNER up to the NFSv4 middle layers
 - Fix a typo in nfs4_handle_exception

Trond Myklebust (5):
  NFSv4: If the server sends us a numeric uid/gid then accept it
  NFSv4: Send unmapped uid/gids to the server if the idmapper fails
  NFSv4: cleanup idmapper functions to take an nfs_server argument
  NFSv4: Propagate the error NFS4ERR_BADOWNER to nfs4_do_setattr
  NFSv4: Send unmapped uid/gids to the server when using auth_sys

 Documentation/kernel-parameters.txt |    8 +++
 fs/nfs/client.c                     |   16 ++++++
 fs/nfs/idmap.c                      |   87 +++++++++++++++++++++++++++-------
 fs/nfs/nfs4proc.c                   |   15 ++++++-
 fs/nfs/nfs4xdr.c                    |   19 +++----
 include/linux/nfs_fs_sb.h           |    1 +
 include/linux/nfs_idmap.h           |    8 ++--
 7 files changed, 120 insertions(+), 34 deletions(-)

-- 
1.7.3.2

