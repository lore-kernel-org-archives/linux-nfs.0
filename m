Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40476 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577Ab2BMVwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 16:52:30 -0500
Received: by mail-ey0-f174.google.com with SMTP id h12so1933968eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 13:52:29 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v9 08/10] nfsd41: handle current stateid in SETATTR and FREE_STATEID
Date: Mon, 13 Feb 2012 22:55:30 +0100
Message-Id: <1329170132-7081-9-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1329170132-7081-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1329170132-7081-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/current_stateid.h |    2 ++
 fs/nfsd/nfs4proc.c        |    1 +
 fs/nfsd/nfs4state.c       |   13 +++++++++++++
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index 6e54d19..e1ae950 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -14,6 +14,8 @@ extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_c
 /*
  * functions to consume current state id
  */
+extern void nfsd4_get_freestateid(struct nfsd4_compound_state *, struct nfsd4_free_stateid *);
+extern void nfsd4_get_setattrstateid(struct nfsd4_compound_state *, struct nfsd4_setattr *);
 extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
 extern void nfsd4_get_lockustateid(struct nfsd4_compound_state *, struct nfsd4_locku *);
 extern void nfsd4_get_readstateid(struct nfsd4_compound_state *, struct nfsd4_read *);
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 620abcc..124934a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1606,6 +1606,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_SETATTR",
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setattr_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_setattrstateid,
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1c97912..8214c0f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4734,6 +4734,19 @@ nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate, struct nfsd4_lock *lo
 /*
  * functions to consume current state id
  */
+
+void
+nfsd4_get_freestateid(struct nfsd4_compound_state *cstate, struct nfsd4_free_stateid *fsp)
+{
+	get_stateid(cstate, &fsp->fr_stateid);
+}
+
+void
+nfsd4_get_setattrstateid(struct nfsd4_compound_state *cstate, struct nfsd4_setattr *setattr)
+{
+	get_stateid(cstate, &setattr->sa_stateid);
+}
+
 void
 nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
 {
-- 
1.7.7.6

