From: andros@netapp.com
Subject: [PATCH 13/14] nfsd41: add test for failed sequence operation
Date: Wed, 24 Jun 2009 15:37:57 -0400
Message-ID: <1245872278-18743-14-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
 <1245872278-18743-8-git-send-email-andros@netapp.com>
 <1245872278-18743-9-git-send-email-andros@netapp.com>
 <1245872278-18743-10-git-send-email-andros@netapp.com>
 <1245872278-18743-11-git-send-email-andros@netapp.com>
 <1245872278-18743-12-git-send-email-andros@netapp.com>
 <1245872278-18743-13-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40120 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761165AbZFXTiH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:07 -0400
In-Reply-To: <1245872278-18743-13-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Failed sequence operations are not cached.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/xdr4.h |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index ae325ad..aae3a01 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -464,6 +464,13 @@ struct nfsd4_compoundres {
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
@@ -473,7 +480,8 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
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

