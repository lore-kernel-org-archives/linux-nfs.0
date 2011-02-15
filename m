Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792Ab1BPSjB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:39:01 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 2 01/18] NFSv4: remove CONFIG_NFS_V4 from nfs_read_data
Date: Tue, 15 Feb 2011 03:38:46 -0500
Message-Id: <1297759143-2045-2-git-send-email-andros@netapp.com>
In-Reply-To: <1297759143-2045-1-git-send-email-andros@netapp.com>
References: <1297759143-2045-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Cleanup nfs_read_data. We also won't use CONFIG_NFS_V4_1 for additional
NFSv4.1 fields in subsequent patches.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs_xdr.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b006857..51bfadb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1016,9 +1016,7 @@ struct nfs_read_data {
 	unsigned int		npages;	/* Max length of pagevec */
 	struct nfs_readargs args;
 	struct nfs_readres  res;
-#ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
-#endif
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.7.2.3

