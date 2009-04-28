From: andros@netapp.com
Subject: [PATCH 29/31] nfsd41: add test for failed sequence operation
Date: Tue, 28 Apr 2009 13:00:03 -0400
Message-ID: <1240938005-23778-29-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
 <1240938005-23778-10-git-send-email-andros@netapp.com>
 <1240938005-23778-11-git-send-email-andros@netapp.com>
 <1240938005-23778-12-git-send-email-andros@netapp.com>
 <1240938005-23778-13-git-send-email-andros@netapp.com>
 <1240938005-23778-14-git-send-email-andros@netapp.com>
 <1240938005-23778-15-git-send-email-andros@netapp.com>
 <1240938005-23778-16-git-send-email-andros@netapp.com>
 <1240938005-23778-17-git-send-email-andros@netapp.com>
 <1240938005-23778-18-git-send-email-andros@netapp.com>
 <1240938005-23778-19-git-send-email-andros@netapp.com>
 <1240938005-23778-20-git-send-email-andros@netapp.com>
 <1240938005-23778-21-git-send-email-andros@netapp.com>
 <1240938005-23778-22-git-send-email-andros@netapp.com>
 <1240938005-23778-23-git-send-email-andros@netapp.com>
 <1240938005-23778-24-git-send-email-andros@netapp.com>
 <1240938005-23778-25-git-send-email-andros@netapp.com>
 <1240938005-23778-26-git-send-email-andros@netapp.com>
 <1240938005-23778-27-git-send-email-andros@netapp.com>
 <1240938005-23778-28-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50815 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758484AbZD1RAj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:39 -0400
In-Reply-To: <1240938005-23778-28-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Failed sequence operations are not cached.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/xdr4.h |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index bc8fab3..7cbb5e7 100644
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
 	return !resp->cstate.slot->sl_cachethis ||
-			nfsd4_is_solo_sequence(resp);
+			nfsd4_is_solo_sequence(resp) ||
+			nfsd4_is_failed_sequence(resp);
 }
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
-- 
1.5.4.3

