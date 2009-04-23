From: andros@netapp.com
Subject: [PATCH 27/29] nfsd41: add test for failed sequence operation
Date: Thu, 23 Apr 2009 12:43:06 -0400
Message-ID: <1240504988-9572-28-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
 <1240504988-9572-11-git-send-email-andros@netapp.com>
 <1240504988-9572-12-git-send-email-andros@netapp.com>
 <1240504988-9572-13-git-send-email-andros@netapp.com>
 <1240504988-9572-14-git-send-email-andros@netapp.com>
 <1240504988-9572-15-git-send-email-andros@netapp.com>
 <1240504988-9572-16-git-send-email-andros@netapp.com>
 <1240504988-9572-17-git-send-email-andros@netapp.com>
 <1240504988-9572-18-git-send-email-andros@netapp.com>
 <1240504988-9572-19-git-send-email-andros@netapp.com>
 <1240504988-9572-20-git-send-email-andros@netapp.com>
 <1240504988-9572-21-git-send-email-andros@netapp.com>
 <1240504988-9572-22-git-send-email-andros@netapp.com>
 <1240504988-9572-23-git-send-email-andros@netapp.com>
 <1240504988-9572-24-git-send-email-andros@netapp.com>
 <1240504988-9572-25-git-send-email-andros@netapp.com>
 <1240504988-9572-26-git-send-email-andros@netapp.com>
 <1240504988-9572-27-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757405AbZDWQng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:36 -0400
In-Reply-To: <1240504988-9572-27-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Failed sequence operations are not cached.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/xdr4.h |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index e312601..8255a87 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -472,6 +472,13 @@ struct nfsd4_compoundres {
 	struct nfsd4_compound_state	cstate;
 };
 
+static inline bool nfsd4_is_failed_sequence(struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
+	return resp->opcnt == 1 && args->ops[0].opnum == OP_SEQUENCE &&
+		resp->cstate.status;
+}
+
 static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
@@ -481,7 +488,8 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
 {
 	return !resp->cstate.slot->sl_cache_entry.ce_cachethis ||
-			nfsd4_is_solo_sequence(resp);
+			nfsd4_is_solo_sequence(resp) ||
+			nfsd4_is_failed_sequence(resp);
 }
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
-- 
1.5.4.3

