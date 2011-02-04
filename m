Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268Ab1BDVew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:52 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 33/40] pnfs-submit wave3 remove CONFIG_NFS_V4 and V4_1 from nfs_read_data
Date: Fri,  4 Feb 2011 16:33:55 -0500
Message-Id: <1296855242-2592-34-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-33-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
 <1296855242-2592-30-git-send-email-andros@netapp.com>
 <1296855242-2592-31-git-send-email-andros@netapp.com>
 <1296855242-2592-32-git-send-email-andros@netapp.com>
 <1296855242-2592-33-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs_xdr.h |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3b2e488..1222aa9 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1016,15 +1016,11 @@ struct nfs_read_data {
 	unsigned int		npages;	/* Max length of pagevec */
 	struct nfs_readargs args;
 	struct nfs_readres  res;
-	struct pnfs_layout_segment *lseg;
-	struct nfs_client	*ds_clp;   /* pNFS data server */
-#ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
-#endif
-#if defined(CONFIG_NFS_V4_1)
-	const struct rpc_call_ops *call_ops;
-	__u64			orig_offset; /* For filelayout dense stripe */
-#endif /* CONFIG_NFS_V4_1 */
+	struct pnfs_layout_segment *lseg;
+	struct nfs_client	*ds_clp;	/* pNFS data server */
+	const struct rpc_call_ops *call_ops;	/* For pNFS recovery to MDS */
+	__u64			orig_offset;	/* Filelayout dense stripe */
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.6.6

