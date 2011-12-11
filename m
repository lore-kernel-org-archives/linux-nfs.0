Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40918 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab1LKQj7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 11:39:59 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so1219348eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2011 08:39:58 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v3 4/5] nfsd41: consume current stateid on read and write
Date: Sun, 11 Dec 2011 17:41:47 +0100
Message-Id: <1323621708-25138-5-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |    2 ++
 fs/nfsd/nfs4proc.c        |    6 ++++--
 fs/nfsd/nfs4state.c       |   12 ++++++++++++
 3 files changed, 18 insertions(+), 2 deletions(-)

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
index 70534a0..f2f7dfa 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1555,9 +1555,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_READ] = {
 		.op_func = (nfsd4op_func)nfsd4_read,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID,
 		.op_name = "OP_READ",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
@@ -1633,9 +1634,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_WRITE] = {
 		.op_func = (nfsd4op_func)nfsd4_write,
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME | CONSUMES_CURRENT_STATEID,
 		.op_name = "OP_WRITE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 25ac9e8..d7b8f25 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4601,3 +4601,15 @@ nfsd4_get_lockustateid(struct nfsd4_compound_state *cstate, struct nfsd4_locku *
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
1.7.7.4

