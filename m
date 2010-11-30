Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464Ab0K3C5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 21:57:50 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] Allow the admin to turn off NFSv4 uid/gid mapping
Date: Mon, 29 Nov 2010 21:57:39 -0500
Message-Id: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches allow the admin to turn off NFSv4 uid/gid mapping
if mounting using AUTH_SYS security.

The new behaviour is enabled using a module parameter,
nfs4_disable_idmapping.

Note that if the server returns an NFS4ERR_BADOWNER error in reply,
then the new behaviour is automatically disabled on that particular
mount point (and the operation that returned the error is retried).

Trond Myklebust (4):
  NFSv4: If the server sends us a numeric uid/gid then accept it
  NFSv4: Send unmapped uid/gids to the server if the idmapper fails
  NFSv4: cleanup idmapper functions to take an nfs_server argument
  NFSv4: Send unmapped uid/gids to the server when using auth_sys

 fs/nfs/client.c           |   16 ++++++++
 fs/nfs/idmap.c            |   87 +++++++++++++++++++++++++++++++++++---------
 fs/nfs/nfs4proc.c         |    8 ++++-
 fs/nfs/nfs4xdr.c          |   18 ++++-----
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/nfs_idmap.h |    8 ++--
 6 files changed, 105 insertions(+), 33 deletions(-)

-- 
1.7.3.2

