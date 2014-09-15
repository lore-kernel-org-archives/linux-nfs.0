Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:54016 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbaIONOb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 09:14:31 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so3935626qgd.29
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 06:14:30 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v4 8/9] nfsd: set and test NFSD4_CLIENT_STABLE bit to reduce nfsdcltrack upcalls
Date: Mon, 15 Sep 2014 09:14:09 -0400
Message-Id: <1410786850-18194-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
References: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
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
index aa04d9f62419..41f3efbfd1df 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1291,7 +1291,8 @@ nfsd4_umh_cltrack_create(struct nfs4_client *clp)
 	grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
 
 	nfsd4_cltrack_upcall_lock(clp);
-	nfsd4_umh_cltrack_upcall("create", hexid, has_session, grace_start);
+	if (!nfsd4_umh_cltrack_upcall("create", hexid, has_session, grace_start))
+		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 	nfsd4_cltrack_upcall_unlock(clp);
 
 	kfree(has_session);
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
 	char *hexid, *has_session, *legacy;
 
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return 0;
+
 	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
 	if (!hexid) {
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
@@ -1333,9 +1342,14 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
 
 	nfsd4_cltrack_upcall_lock(clp);
-	ret = nfsd4_umh_cltrack_upcall("check", hexid, has_session, legacy);
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags)) {
+		ret = 0;
+	} else {
+		ret = nfsd4_umh_cltrack_upcall("check", hexid, has_session, legacy);
+		if (ret == 0)
+			set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+	}
 	nfsd4_cltrack_upcall_unlock(clp);
-
 	kfree(has_session);
 	kfree(legacy);
 	kfree(hexid);
-- 
1.9.3

