From: andros@netapp.com
Subject: [PATCH 28/30] nfsd41: add test for failed sequence operation
Date: Mon,  8 Jun 2009 14:21:09 -0400
Message-ID: <1244485271-7461-29-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
 <1244485271-7461-11-git-send-email-andros@netapp.com>
 <1244485271-7461-12-git-send-email-andros@netapp.com>
 <1244485271-7461-13-git-send-email-andros@netapp.com>
 <1244485271-7461-14-git-send-email-andros@netapp.com>
 <1244485271-7461-15-git-send-email-andros@netapp.com>
 <1244485271-7461-16-git-send-email-andros@netapp.com>
 <1244485271-7461-17-git-send-email-andros@netapp.com>
 <1244485271-7461-18-git-send-email-andros@netapp.com>
 <1244485271-7461-19-git-send-email-andros@netapp.com>
 <1244485271-7461-20-git-send-email-andros@netapp.com>
 <1244485271-7461-21-git-send-email-andros@netapp.com>
 <1244485271-7461-22-git-send-email-andros@netapp.com>
 <1244485271-7461-23-git-send-email-andros@netapp.com>
 <1244485271-7461-24-git-send-email-andros@netapp.com>
 <1244485271-7461-25-git-send-email-andros@netapp.com>
 <1244485271-7461-26-git-send-email-andros@netapp.com>
 <1244485271-7461-27-git-send-email-andros@netapp.com>
 <1244485271-7461-28-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534AbZFHSVl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:41 -0400
In-Reply-To: <1244485271-7461-28-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Failed sequence operations are not cached.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/xdr4.h |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 026d3a5..3dbbbc3 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -460,6 +460,13 @@ struct nfsd4_compoundres {
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
@@ -469,7 +476,8 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
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

