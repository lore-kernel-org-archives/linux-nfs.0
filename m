Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab2BOWui (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:50:38 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 nfs-for-next 0/1] NFSv4.1 Session statistics
Date: Wed, 15 Feb 2012 17:50:04 -0500
Message-Id: <1329346205-2316-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Data server sessions as well as MDS and of course normal NFSv4.1 mount session
stats are recorded.

This is an RFC - I've used these stats to verify that DS session slot table
waitq's have been drained when migrating from a dead DS to the MDS. The stats
are also useful in seeing how many session slots are actually used for various
work loads.

Comments please.

Andy Adamson (1):
  NFSv4.1 add a session statistics file to /proc/fs/nfsfs

 fs/nfs/client.c           |   93 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |    5 ++
 include/linux/nfs_fs_sb.h |    3 +
 3 files changed, 101 insertions(+), 0 deletions(-)

-- 
1.7.6.4

