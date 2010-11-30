Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31408 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab0K3NeM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 08:34:12 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] Allow the admin to turn off NFSv4 uid/gid mapping
Date: Tue, 30 Nov 2010 08:33:59 -0500
Message-Id: <1291124043-5074-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches allow the admin to turn off NFSv4 uid/gid mapping
if mounting using AUTH_SYS security.

Minor changes w.r.t. first revision:
 - Added documentation in kernel-parameters.txt
 - Print a warning if an NFSERR_BADOWNER causes us to turn idmapping on again

Trond Myklebust (4):
  NFSv4: If the server sends us a numeric uid/gid then accept it
  NFSv4: Send unmapped uid/gids to the server if the idmapper fails
  NFSv4: cleanup idmapper functions to take an nfs_server argument
  NFSv4: Send unmapped uid/gids to the server when using auth_sys

 Documentation/kernel-parameters.txt |    8 +++
 fs/nfs/client.c                     |   16 ++++++
 fs/nfs/idmap.c                      |   87 +++++++++++++++++++++++++++-------
 fs/nfs/nfs4proc.c                   |   13 +++++-
 fs/nfs/nfs4xdr.c                    |   18 +++----
 include/linux/nfs_fs_sb.h           |    1 +
 include/linux/nfs_idmap.h           |    8 ++--
 7 files changed, 118 insertions(+), 33 deletions(-)

-- 
1.7.3.2

