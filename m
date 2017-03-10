Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32850 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754626AbdCJAif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 19:38:35 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 10 Mar 2017 11:36:39 +1100
Subject: [PATCH 3/3] NFSD: fix nfsd_reset_versions for NFSv4.
Cc: Trond Myklebust <trondmy@primarydata.com>,
        linux-nfs@vger.kernel.org
Message-ID: <148910619950.3032.18198404532268490131.stgit@noble>
In-Reply-To: <148910618557.3032.8265198632788708076.stgit@noble>
References: <148910618557.3032.8265198632788708076.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If you write "-2 -3 -4" to the "versions" file, it will
notice that no versions are enabled, and nfsd_reset_versions()
is called.
This enables all major versions, not no minor versions.
So we lose the invariant that NFSv4 is only advertised when
at least one minor is enabled.

Fix the code to explicitly enable minor versions for v4,
change it to use nfsd_vers() to test and set, and simplify
the code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfsd/nfssvc.c |   25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 892137b1e330..31e1f9593457 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -416,23 +416,20 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 
 void nfsd_reset_versions(void)
 {
-	int found_one = 0;
 	int i;
 
-	for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++) {
-		if (nfsd_program.pg_vers[i])
-			found_one = 1;
-	}
+	for (i = 0; i < NFSD_NRVERS; i++)
+		if (nfsd_vers(i, NFSD_TEST))
+			return;
 
-	if (!found_one) {
-		for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++)
-			nfsd_program.pg_vers[i] = nfsd_version[i];
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-		for (i = NFSD_ACL_MINVERS; i < NFSD_ACL_NRVERS; i++)
-			nfsd_acl_program.pg_vers[i] =
-				nfsd_acl_version[i];
-#endif
-	}
+	for (i = 0; i < NFSD_NRVERS; i++)
+		if (i != 4)
+			nfsd_vers(i, NFSD_SET);
+		else {
+			int minor = 0;
+			while (nfsd_minorversion(minor, NFSD_SET) >= 0)
+				minor++;
+		}
 }
 
 /*


