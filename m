From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 04/47] nfsd: add a struct nfsd4_slot pointer to struct nfsd4_compound_state
Date: Fri, 27 Mar 2009 06:05:40 +0300
Message-ID: <1238123140-7040-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21984 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753953AbZC0DFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:05:46 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
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

