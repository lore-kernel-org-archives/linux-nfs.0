Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43314 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244Ab2BMVvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 16:51:32 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so2010863eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 13:51:31 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bhalevy@tonian.com, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v9 04/10] nfsd41: consume current stateid on read and write
Date: Mon, 13 Feb 2012 22:54:38 +0100
Message-Id: <1329170084-7032-5-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1329170084-7032-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1329170084-7032-1-git-send-email-tigran.mkrtchyan@desy.de>
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
index f66a8b2..9a61bbf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1546,6 +1546,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_READ",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
@@ -1624,6 +1625,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_WRITE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5665061..1c97912 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4745,3 +4745,15 @@ nfsd4_get_lockustateid(struct nfsd4_compound_state *cstate, struct nfsd4_locku *
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
1.7.7.6

