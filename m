Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53618 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753118Ab2AQTNj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 14:13:39 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] NFS: Remove unnecessary includes from linux/nfs_fs_i.h
Date: Tue, 17 Jan 2012 14:13:26 -0500
Message-Id: <1326827613-7997-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/nfs_fs_i.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/nfs_fs_i.h b/include/linux/nfs_fs_i.h
index 8617302..a5c50d9 100644
--- a/include/linux/nfs_fs_i.h
+++ b/include/linux/nfs_fs_i.h
@@ -1,10 +1,6 @@
 #ifndef _NFS_FS_I
 #define _NFS_FS_I
 
-#include <asm/types.h>
-#include <linux/list.h>
-#include <linux/nfs.h>
-
 struct nlm_lockowner;
 
 /*
-- 
1.7.7.5

