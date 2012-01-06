Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47856 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933112Ab2AFJmz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 04:42:55 -0500
Received: by mail-ey0-f174.google.com with SMTP id d14so860470eaa.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jan 2012 01:42:54 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v5 8/8] nfsv41: handle current stateid on LAYOUTGET
Date: Fri,  6 Jan 2012 10:45:16 +0100
Message-Id: <1325843116-20570-9-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |    3 ++-
 fs/nfsd/nfs4proc.c        |    2 ++
 fs/nfsd/nfs4state.c       |   12 ++++++++++++
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index 6e54d19..9fc23c9 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -10,6 +10,7 @@
 extern void nfsd4_set_openstateid(struct nfsd4_compound_state *, struct nfsd4_open *);
 extern void nfsd4_set_lockstateid(struct nfsd4_compound_state *, struct nfsd4_lock *);
 extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
+extern void nfsd4_set_layoutgetstateid(struct nfsd4_compound_state *, struct nfsd4_pnfs_layoutget *);
 
 /*
  * functions to consume current state id
@@ -18,5 +19,5 @@ extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_c
 extern void nfsd4_get_lockustateid(struct nfsd4_compound_state *, struct nfsd4_locku *);
 extern void nfsd4_get_readstateid(struct nfsd4_compound_state *, struct nfsd4_read *);
 extern void nfsd4_get_writestateid(struct nfsd4_compound_state *, struct nfsd4_write *);
-
+extern void nfsd4_get_layoutgetstateid(struct nfsd4_compound_state *, struct nfsd4_pnfs_layoutget *);
 #endif   /* _NFSD4_CURRENT_STATE_H */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8ee49d8..f227f71 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2034,6 +2034,8 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_LAYOUTGET] = {
 		.op_func = (nfsd4op_func)nfsd4_layoutget,
 		.op_name = "OP_LAYOUTGET",
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_layoutgetstateid,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_layoutgetstateid,
 	},
 	[OP_LAYOUTCOMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_layoutcommit,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cf9bc80..000cae7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4743,6 +4743,12 @@ nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate, struct nfsd4_lock *lo
 	put_stateid(cstate, &lock->lk_resp_stateid);
 }
 
+void
+nfsd4_set_layoutgetstateid(struct nfsd4_compound_state *cstate, struct nfsd4_pnfs_layoutget *lgp)
+{
+	put_stateid(cstate, &lgp->lg_sid);
+}
+
 /*
  * functions to consume current state id
  */
@@ -4769,3 +4775,9 @@ nfsd4_get_writestateid(struct nfsd4_compound_state *cstate, struct nfsd4_write *
 {
 	get_stateid(cstate, &write->wr_stateid);
 }
+
+void
+nfsd4_get_layoutgetstateid(struct nfsd4_compound_state *cstate, struct nfsd4_pnfs_layoutget *lgp)
+{
+	get_stateid(cstate, &lgp->lg_sid);
+}
-- 
1.7.7.5

