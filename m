Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755391Ab1LNTkO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 14:40:14 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, cbodley@citi.umich.edu,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFSD: forget_delegations should use list_for_each_entry_safe
Date: Wed, 14 Dec 2011 14:39:56 -0500
Message-Id: <1323891596-30914-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Otherwise the for loop could try to use a file recently removed from the
file_hashtbl list and oops.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4state.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 19ca9b5..7355fe4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4505,18 +4505,19 @@ void nfsd_forget_openowners(u64 num)
 int nfsd_process_n_delegations(u64 num, void (*deleg_func)(struct nfs4_delegation *))
 {
 	int i, count = 0;
-	struct nfs4_file *fp;
-	struct nfs4_delegation *dp, *next;
+	struct nfs4_file *fp, *fnext;
+	struct nfs4_delegation *dp, *dnext;
 
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
-		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
-			list_for_each_entry_safe(dp, next, &fp->fi_delegations, dl_perfile) {
+		list_for_each_entry_safe(fp, fnext, &file_hashtbl[i], fi_hash) {
+			list_for_each_entry_safe(dp, dnext, &fp->fi_delegations, dl_perfile) {
 				deleg_func(dp);
 				if (++count == num)
 					return count;
 			}
 		}
 	}
+
 	return count;
 }
 
-- 
1.7.8

