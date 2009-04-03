From: andros@netapp.com
Subject: [PATCH 20/22] SQUASHME nfsd41 nfsd4_is_solo_sequence
Date: Thu,  2 Apr 2009 20:20:01 -0400
Message-ID: <1238718003-8764-20-git-send-email-andros@netapp.com>
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
 <1238718003-8764-12-git-send-email-andros@netapp.com>
 <1238718003-8764-13-git-send-email-andros@netapp.com>
 <1238718003-8764-14-git-send-email-andros@netapp.com>
 <1238718003-8764-15-git-send-email-andros@netapp.com>
 <1238718003-8764-16-git-send-email-andros@netapp.com>
 <1238718003-8764-17-git-send-email-andros@netapp.com>
 <1238718003-8764-18-git-send-email-andros@netapp.com>
 <1238718003-8764-19-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33646 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758091AbZDCAUk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:40 -0400
In-Reply-To: <1238718003-8764-19-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
squash into nfsd41: non-page DRC for solo sequence responses

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/xdr4.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 018a821..0352863 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -487,10 +487,10 @@ struct nfsd4_compoundres {
 	struct nfsd4_compound_state	cstate;
 };
 
-static inline u32 nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
+static inline int nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
-	return args->opcnt == 1 ? 1 : 0;
+	return args->opcnt == 1;
 }
 
 static inline u32 nfsd4_not_cached(struct nfsd4_compoundres *resp)
-- 
1.5.4.3

