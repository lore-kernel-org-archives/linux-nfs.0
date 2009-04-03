From: andros@netapp.com
Subject: [PATCH 01/22] SQUASHME: nfsd41: add nfsd4_session pointer to nfsd4_compound_state
Date: Thu,  2 Apr 2009 20:19:42 -0400
Message-ID: <1238718003-8764-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754743AbZDCAUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review by Bruce

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/xdr4.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 7ed9955..a895bba 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -49,6 +49,7 @@ struct nfsd4_compound_state {
 	struct svc_fh		save_fh;
 	struct nfs4_stateowner	*replay_owner;
 	/* For sessions DRC */
+	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
 	__be32			*statp;
 	size_t			iovlen;
-- 
1.5.4.3

