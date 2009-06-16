From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 09/44] nfsd41: sanity check client drc maxreqs
Date: Tue, 16 Jun 2009 04:19:38 +0300
Message-ID: <1245115178-7097-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2625
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753959AbZFPBTh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Ensure the client requested maximum requests are between 1 and
NFSD_MAX_SLOTS_PER_SESSION

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 582cd2c..90e6645 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -425,6 +425,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
 {
 	int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
 
+	if (fchan->maxreqs < 1)
+		return nfserr_inval;
+	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
+		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
+
 	spin_lock(&nfsd_serv->sv_lock);
 	if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
 		np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
-- 
1.6.3

