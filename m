Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:59891 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbaIHOrK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 10:47:10 -0400
Received: by mail-qc0-f177.google.com with SMTP id i8so15168370qcq.8
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 07:47:08 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH v3 7/8] nfsd: set and test NFSD4_CLIENT_STABLE bit to reduce nfsdcltrack upcalls
Date: Mon,  8 Sep 2014 10:46:48 -0400
Message-Id: <1410187609-10319-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
References: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfsdcltrack upcall doesn't utilize the NFSD4_CLIENT_STABLE flag,
which basically results in an upcall every time we call into the client
tracking ops.

Change it to set this bit on a successful "check" or "create" request,
and clear it on a "remove" request.  Also, check to see if that bit is
set before upcalling on a "check" or "remove" request, and skip
upcalling appropriately, depending on its state.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4recover.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index ae313861a6f5..5697e9d2e875 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1291,7 +1291,8 @@ nfsd4_umh_cltrack_create(struct nfs4_client *clp)
 	grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
 
 	nfsd4_cltrack_upcall_lock(clp);
-	nfsd4_umh_cltrack_upcall("create", hexid, reclaim_complete, grace_start);
+	if (!nfsd4_umh_cltrack_upcall("create", hexid, reclaim_complete, grace_start))
+		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 	nfsd4_cltrack_upcall_unlock(clp);
 
 	kfree(reclaim_complete);
@@ -1304,6 +1305,9 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
 {
 	char *hexid;
 
+	if (!test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return;
+
 	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
 	if (!hexid) {
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
@@ -1311,7 +1315,9 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
 	}
 
 	nfsd4_cltrack_upcall_lock(clp);
-	nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL);
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags) &&
+	    nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL) == 0)
+		clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 	nfsd4_cltrack_upcall_unlock(clp);
 
 	kfree(hexid);
@@ -1323,6 +1329,9 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 	int ret;
 	char *hexid, *legacy;
 
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return 0;
+
 	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
 	if (!hexid) {
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
@@ -1331,9 +1340,14 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
 
 	nfsd4_cltrack_upcall_lock(clp);
-	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy, NULL);
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags)) {
+		ret = 0;
+	} else {
+		ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy, NULL);
+		if (!ret)
+			set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+	}
 	nfsd4_cltrack_upcall_unlock(clp);
-
 	kfree(legacy);
 	kfree(hexid);
 	return ret;
-- 
1.9.3

