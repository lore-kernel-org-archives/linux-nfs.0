Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757878Ab1BKSAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:45 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 13/17] SQUASHME update nfs4_ds_connect comment
Date: Thu, 10 Feb 2011 20:52:46 -0500
Message-Id: <1297389170-26702-14-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-13-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
 <1297389170-26702-7-git-send-email-andros@netapp.com>
 <1297389170-26702-8-git-send-email-andros@netapp.com>
 <1297389170-26702-9-git-send-email-andros@netapp.com>
 <1297389170-26702-10-git-send-email-andros@netapp.com>
 <1297389170-26702-11-git-send-email-andros@netapp.com>
 <1297389170-26702-12-git-send-email-andros@netapp.com>
 <1297389170-26702-13-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into: pnfs-submit wave3 data server connection

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 6a7de00..b8c3681 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -105,7 +105,7 @@ _data_server_lookup_locked(u32 ip_addr, u32 port)
 }
 
 /*
- * Create an rpc to the nfs4_pnfs_ds data server
+ * Create an rpc connection to the nfs4_pnfs_ds data server
  * Currently only support IPv4
  */
 static int
-- 
1.6.6

