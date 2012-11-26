Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9745 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756000Ab2KZURQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:16 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 28/28] NFSv4.1: Set the maximum slot table size to 1024 slots
Date: Mon, 26 Nov 2012 15:16:45 -0500
Message-Id: <1353961005-63874-29-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-28-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-19-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-20-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-21-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-22-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-23-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-24-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-25-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-26-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-27-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-28-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This means that we end up statically allocating 128 bytes for the
bitmap on each slot table.
For a server that supports 1MB write and read I/O sizes this means
that we can completely fill the maximum 1GB TCP send/receive
windows.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4session.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index e96323f..bdd14a6 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -9,7 +9,7 @@
 
 /* maximum number of slots to use */
 #define NFS4_DEF_SLOT_TABLE_SIZE (16U)
-#define NFS4_MAX_SLOT_TABLE (256U)
+#define NFS4_MAX_SLOT_TABLE (1024U)
 #define NFS4_NO_SLOT ((u32)-1)
 
 #if IS_ENABLED(CONFIG_NFS_V4)
-- 
1.7.11.7

