From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 19/35] pnfsd: accept all ds stateids
Date: Mon,  7 Dec 2009 11:33:59 +0200
Message-ID: <1260178439-15331-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19282 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934878AbZLGJdD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:33:03 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Until a stateid protocol is implemented, remove all checking on
file layout data server stateids

Signed-off-by: Andy Adamson <andros@netapp.com>
[remove #ifdef around pnfs_fh_is_ds]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1731b35..0cd563e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2858,6 +2858,9 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	if (grace_disallows_io(ino))
 		return nfserr_grace;
 
+	if (pnfs_fh_is_ds(&current_fh->fh_handle))
+		return 0;
+
 	if (nfsd4_has_session(cstate))
 		flags |= HAS_SESSION;
 
-- 
1.6.5.1

