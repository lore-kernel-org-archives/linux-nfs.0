Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49290 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605Ab2BERFC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 12:05:02 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so1892522eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2012 09:05:02 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v8 09/10] nfsd41: consume current stateid on DELEGRETURN and OPENDOWNGRADE
Date: Sun,  5 Feb 2012 18:07:58 +0100
Message-Id: <1328461679-4108-10-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |    3 +++
 fs/nfsd/nfs4proc.c        |    3 +++
 fs/nfsd/nfs4state.c       |   18 ++++++++++++++++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index e1ae950..d8c9992 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -7,6 +7,7 @@
 /*
  * functions to set current state id
  */
+extern void nfsd4_set_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *);
 extern void nfsd4_set_openstateid(struct nfsd4_compound_state *, struct nfsd4_open *);
 extern void nfsd4_set_lockstateid(struct nfsd4_compound_state *, struct nfsd4_lock *);
 extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
@@ -14,6 +15,8 @@ extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_c
 /*
  * functions to consume current state id
  */
+extern void nfsd4_get_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *);
+extern void nfsd4_get_delegreturnstateid(struct nfsd4_compound_state *, struct nfsd4_delegreturn *);
 extern void nfsd4_get_freestateid(struct nfsd4_compound_state *, struct nfsd4_free_stateid *);
 extern void nfsd4_get_setattrstateid(struct nfsd4_compound_state *, struct nfsd4_setattr *);
 extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 124934a..dffc9bd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1454,6 +1454,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DELEGRETURN",
 		.op_rsize_bop = nfsd4_only_status_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_delegreturnstateid,
 	},
 	[OP_GETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_getattr,
@@ -1521,6 +1522,8 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_DOWNGRADE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_opendowngradestateid,
+		.op_set_currentstateid = (stateid_setter)nfsd4_set_opendowngradestateid,
 	},
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8214c0f..9c5a239 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4714,6 +4714,12 @@ put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
  * functions to set current state id
  */
 void
+nfsd4_set_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *odp)
+{
+	put_stateid(cstate, &odp->od_stateid);
+}
+
+void
 nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
 {
 	put_stateid(cstate, &open->op_stateid);
@@ -4736,6 +4742,18 @@ nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate, struct nfsd4_lock *lo
  */
 
 void
+nfsd4_get_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *odp)
+{
+	get_stateid(cstate, &odp->od_stateid);
+}
+
+void
+nfsd4_get_delegreturnstateid(struct nfsd4_compound_state *cstate, struct nfsd4_delegreturn *drp)
+{
+	get_stateid(cstate, &drp->dr_stateid);
+}
+
+void
 nfsd4_get_freestateid(struct nfsd4_compound_state *cstate, struct nfsd4_free_stateid *fsp)
 {
 	get_stateid(cstate, &fsp->fr_stateid);
-- 
1.7.7.6

