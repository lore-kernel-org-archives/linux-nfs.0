Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40918 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab1LKQj6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 11:39:58 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so1219348eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2011 08:39:57 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v3 3/5] nfsd41: update operations's stateid iff current stateid is set
Date: Sun, 11 Dec 2011 17:41:46 +0100
Message-Id: <1323621708-25138-4-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4state.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fd10283..25ac9e8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4553,15 +4553,17 @@ nfs4_state_shutdown(void)
 static void
 get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
-	if (cstate->minorversion && CURRENT_STATEID(stateid))
+	if (cstate->has_stateid && CURRENT_STATEID(stateid))
 		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
 }
 
 static void
 put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
 {
-	if (cstate->minorversion)
+	if (cstate->minorversion) {
 		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
+		cstate->has_stateid = true;
+	}
 }
 
 /*
-- 
1.7.7.4

