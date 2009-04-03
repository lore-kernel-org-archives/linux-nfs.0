From: andros@netapp.com
Subject: [PATCH 12/22] SQUASHME: nfsd41 rename nfsd4_set_cache_entry
Date: Thu,  2 Apr 2009 20:19:53 -0400
Message-ID: <1238718003-8764-12-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
 <1238718003-8764-9-git-send-email-andros@netapp.com>
 <1238718003-8764-10-git-send-email-andros@netapp.com>
 <1238718003-8764-11-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756361AbZDCAUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:33 -0400
In-Reply-To: <1238718003-8764-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
squash into nfsd41: DRC save, restor, and clear functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c       |    2 +-
 include/linux/nfsd/xdr4.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f1beb1c..b4eb49a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1056,7 +1056,7 @@ nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
  * of the NFSv4.1 data, just past the rpc header.
  */
 void
-nfsd4_set_cache_entry(struct nfsd4_compoundres *resp)
+nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index a895bba..845f05e 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -529,7 +529,7 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
 #if defined(CONFIG_NFSD_V4_1)
-extern void nfsd4_set_cache_entry(struct nfsd4_compoundres *resp);
+extern void nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		struct nfsd4_sequence *seq);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
-- 
1.5.4.3

