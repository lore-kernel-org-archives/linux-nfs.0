From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 03/47] nfsd: add a struct nfsd4_slot pointer to struct nfsd4_compound_state
Date: Sat, 28 Mar 2009 11:30:57 +0300
Message-ID: <1238229057-7887-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:19272 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753312AbZC1IbD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:31:03 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

To be used for sessions DRC replay.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/xdr4.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index fd15ddc..e309d55 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -48,6 +48,8 @@ struct nfsd4_compound_state {
 	struct svc_fh		current_fh;
 	struct svc_fh		save_fh;
 	struct nfs4_stateowner	*replay_owner;
+	/* For sessions DRC */
+	struct nfsd4_slot	*slot;
 };
 
 struct nfsd4_change_info {
-- 
1.6.2.1

