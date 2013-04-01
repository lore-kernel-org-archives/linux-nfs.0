Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:27084 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757232Ab3DANGw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 09:06:52 -0400
Message-ID: <5159868A.8080105@cn.fujitsu.com>
Date: Mon, 01 Apr 2013 21:07:22 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: PATCH]nfsd: don't run get_file if nfs4_preprocess_stateid_op return
 error
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

we should return error status directly when 
nfs4_preprocess_stateid_op return error. 

Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
---
 fs/nfsd/nfs4proc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ae73175..8288b08 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -931,14 +931,14 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
 					cstate, stateid, WR_STATE, &filp);
-	if (filp)
-		get_file(filp);
-	nfs4_unlock_state();
-
 	if (status) {
+		nfs4_unlock_state();
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
 	}
+	if (filp)
+		get_file(filp);
+	nfs4_unlock_state();
 
 	cnt = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
-- 
1.7.1


