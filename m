Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34396 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757762Ab2AFJmr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 04:42:47 -0500
Received: by bkcjm19 with SMTP id jm19so273098bkc.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jan 2012 01:42:46 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATH v5 1/8] nfsd4: initialize special stateid's at compile time
Date: Fri,  6 Jan 2012 10:45:09 +0100
Message-Id: <1325843116-20570-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>

Stateid's with "other" ("opaque") field all zeros or all ones are
reserved.  We define all_ones separately on the off chance there will be
more such some day, though currently all the other special stateid's
have zero other field.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Conflicts:

	fs/nfsd/nfs4state.c

Conflicts:

	fs/nfsd/nfs4state.c
Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4state.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a62dbc9..40d3bdf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -51,12 +51,24 @@
 time_t nfsd4_lease = 90;     /* default lease time */
 time_t nfsd4_grace = 90;
 static time_t boot_time;
-static stateid_t zerostateid;             /* bits all 0 */
-static stateid_t onestateid;              /* bits all 1 */
+
+#define all_ones {{~0,~0},~0}
+static const stateid_t one_stateid = {
+	.si_generation = ~0,
+	.si_opaque = all_ones,
+};
+static const stateid_t zero_stateid = {
+	/* all fields zero */
+};
+static const stateid_t currentstateid = {
+	.si_generation = 1,
+};
+ 
 static u64 current_sessionid = 1;
 
-#define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
-#define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
+#define ZERO_STATEID(stateid) (!memcmp((stateid), &zero_stateid, sizeof(stateid_t)))
+#define ONE_STATEID(stateid)  (!memcmp((stateid), &one_stateid, sizeof(stateid_t)))
+#define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
@@ -4569,7 +4581,6 @@ nfs4_state_init(void)
 	for (i = 0; i < LOCK_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
 	}
-	memset(&onestateid, ~0, sizeof(stateid_t));
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
-- 
1.7.7.5

