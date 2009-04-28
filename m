From: andros@netapp.com
Subject: [PATCH 08/31] nfsd41: sanity check client drc maxreqs
Date: Tue, 28 Apr 2009 12:59:42 -0400
Message-ID: <1240938005-23778-8-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35416 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932503AbZD1RBd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:01:33 -0400
In-Reply-To: <1240938005-23778-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Ensure the client requested maximum requests are between 1 and
NFSD_MAX_SLOTS_PER_SESSION

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e216169..59b601b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -427,6 +427,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
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
1.5.4.3

