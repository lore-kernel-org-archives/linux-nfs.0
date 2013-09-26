Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:64693 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab3IZSkF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:05 -0400
Received: by mail-qa0-f52.google.com with SMTP id k4so1091998qaq.4
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:05 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 03/49] pnfsd: return pnfs flags on exchange_id
Date: Thu, 26 Sep 2013 14:40:02 -0400
Message-Id: <1380220802-12810-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Set the cl_exchange_flags to be non_pnfs if we do not set
either pnfs or ds (in the plain old nfs41 case).

Note that we always set both MDS and DS exchangeid capability flags
when CONFIG_PNFSD is enabled.
The client needs to remember what the session is used for
if it cares to distiguish between DSs and MDSs.

EXCHGID4_FLAG_USE_NON_PNFS should be set when the server does not support
operations (e.g. LAYOUTGET) or attributes that pertain to pNFS.

[extraced from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Fixup nfsd4_set_ex_flags.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: set EXCHGID4_FLAG_USE_NON_PNFS when !CONFIG_PNFSD]
[pnfsd: fix compiler warning in nfsd4_set_ex_flags when CONFIG_PNFSD is not defined]
[pnfsd: always set both MDS and DS exchangeid capability flags]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 57a0340..21c15fc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1614,8 +1614,12 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
 static void
 nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
 {
-	/* pNFS is not supported */
+#if defined(CONFIG_PNFSD)
+	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_PNFS_MDS |
+				  EXCHGID4_FLAG_USE_PNFS_DS;
+#else  /* CONFIG_PNFSD */
 	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
+#endif /* CONFIG_PNFSD */
 
 	/* Referrals are supported, Migration is not. */
 	new->cl_exchange_flags |= EXCHGID4_FLAG_SUPP_MOVED_REFER;
-- 
1.8.3.1

