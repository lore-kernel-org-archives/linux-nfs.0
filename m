Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132Ab2FLOj3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jun 2012 10:39:29 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFSv4.1 Fix umount when filelayout DS is also the MDS
Date: Tue, 12 Jun 2012 10:39:25 -0400
Message-Id: <1339511966-2448-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

At the Bakeathon, Jorge noted that when the MDS and DS use the same struct
nfs_client, umount would fail to free the nfs_client struct and the
keep-alive SEQUENCE compound would continue ad infinitum.

This was due to the fact that the DS reference to the MDS nfs_client would
prevent the umount from dropping the cl_count to zero. Moreover, the
DS refererence is only dropped by the deviceid dereference only called
by nfs4_deviceid_purge_client from nfs_free_client when the nfs_client
cl_count was zero.

See the patch comments for the solution description.

I've tested this solution against a 2-node C-mode filer where one node is an
MDS/DS and the other node a standalone MDS but uses the first node as a DS.

I tested all combinations, including mounting the MDS/DS node, and using pNFS
for I/O. Then mounting the solo MDS node, and using pNFS for I/O (which uses
the MDS/DS node as a DS), then umounting one of the mount points, doing pNFS
I/O and then umount the other.

In all cases, umount destroyed the appropriate nfs_client, and associated
session.

Andy Adamson (1):
  NFSv4.1 Fix umount when filelayout DS is also the MDS

 fs/nfs/client.c            |   71 ++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h          |    1 +
 fs/nfs/nfs4filelayoutdev.c |   29 +++++++++++++++--
 include/linux/nfs_fs_sb.h  |    1 +
 4 files changed, 95 insertions(+), 7 deletions(-)

-- 
1.7.6.4

