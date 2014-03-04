Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36487 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaCDRbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 12:31:18 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/4] NFSv4 propagate nfs4_stateid_is_current errors
Date: Tue, 4 Mar 2014 12:31:06 -0500
Message-ID: <1393954269-3974-2-git-send-email-andros@netapp.com>
In-Reply-To: <1393954269-3974-1-git-send-email-andros@netapp.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Check nfs4_set_rw_stateid return and try to match the input stateid
on success.

Return error so that caller can react accordingly

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c  | 21 +++++++++++++++++----
 fs/nfs/nfs4state.c |  6 ++++++
 2 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 02f65cc..2f1997d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4046,16 +4046,29 @@ int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 }
 EXPORT_SYMBOL_GPL(nfs4_set_rw_stateid);
 
-static bool nfs4_stateid_is_current(nfs4_stateid *stateid,
+/**
+ * @stateid: stateid to test
+ * @ctx:     open context with current stateid (unless lock context)
+ * @l_ctx:   lock context with current stateid
+ * @fmode:   open mode
+ *
+ * returns
+ * 0:        @stateid does not match current stateid
+ * 1:        @stateid matches current stateid
+ * negative: error
+ */
+static int nfs4_stateid_is_current(nfs4_stateid *stateid,
 		const struct nfs_open_context *ctx,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode)
 {
 	nfs4_stateid current_stateid;
+	int ret;
 
-	if (nfs4_set_rw_stateid(&current_stateid, ctx, l_ctx, fmode))
-		return false;
-	return nfs4_stateid_match(stateid, &current_stateid);
+	ret = nfs4_set_rw_stateid(&current_stateid, ctx, l_ctx, fmode);
+	if (ret == 0) /* current stateid set, see if it matches input stateid */
+		return nfs4_stateid_match(stateid, &current_stateid) ? 1 : 0;
+	return ret;  /* error */
 }
 
 static bool nfs4_error_stateid_expired(int err)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1cfde97..4cabe2c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1112,6 +1112,12 @@ static int nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 /*
  * Byte-range lock aware utility to initialize the stateid of read/write
  * requests.
+ *
+ * returns:
+ * 0:            success, stateid selected and copied
+ * -EWOULDBLOCK: from nfs4_copy_open. stateid change in progress
+ *               with stateid copied
+ * -EIO:         lost lock, fail I/O
  */
 int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 		fmode_t fmode, const struct nfs_lockowner *lockowner)
-- 
1.8.3.1

