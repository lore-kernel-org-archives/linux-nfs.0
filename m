Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47856 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933012Ab2AFJmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 04:42:51 -0500
Received: by eaad14 with SMTP id d14so860470eaa.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jan 2012 01:42:50 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v5 4/8] nfsd41: consume current stateid on read and write
Date: Fri,  6 Jan 2012 10:45:12 +0100
Message-Id: <1325843116-20570-5-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |    2 ++
 fs/nfsd/nfs4proc.c        |    2 ++
 fs/nfsd/nfs4state.c       |   12 ++++++++++++
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index 21550b6..6e54d19 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -16,5 +16,7 @@ extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_c
  */
 extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
 extern void nfsd4_get_lockustateid(struct nfsd4_compound_state *, struct nfsd4_locku *);
+extern void nfsd4_get_readstateid(struct nfsd4_compound_state *, struct nfsd4_read *);
+extern void nfsd4_get_writestateid(struct nfsd4_compound_state *, struct nfsd4_write *);
 
 #endif   /* _NFSD4_CURRENT_STATE_H */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3e7b97f..20c8d24 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1864,6 +1864,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_READ",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
@@ -1942,6 +1943,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_WRITE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5add33f8..cf9bc80 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4757,3 +4757,15 @@ nfsd4_get_lockustateid(struct nfsd4_compound_state *cstate, struct nfsd4_locku *
 {
 	get_stateid(cstate, &locku->lu_stateid);
 }
+
+void
+nfsd4_get_readstateid(struct nfsd4_compound_state *cstate, struct nfsd4_read *read)
+{
+	get_stateid(cstate, &read->rd_stateid);
+}
+
+void
+nfsd4_get_writestateid(struct nfsd4_compound_state *cstate, struct nfsd4_write *write)
+{
+	get_stateid(cstate, &write->wr_stateid);
+}
-- 
1.7.7.5

