Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:46566 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405AbaGHSG0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:26 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so5112229qac.39
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:25 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 082/100] nfsd: add a list_head arg to nfsd_foreach_client_lock
Date: Tue,  8 Jul 2014 14:04:10 -0400
Message-Id: <1404842668-22521-83-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we'll want to collect the locks onto a list for later
destruction. If "func" is defined and "collect" is defined, then we'll
add the lock stateid to the list.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 92c12dbcd7df..dbd1f422b3ae 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5790,6 +5790,7 @@ static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 }
 
 static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
+				    struct list_head *collect,
 				    void (*func)(struct nfs4_ol_stateid *))
 {
 	struct nfs4_openowner *oop;
@@ -5802,8 +5803,12 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 				&oop->oo_owner.so_stateids, st_perstateowner) {
 			list_for_each_entry_safe(lst, lst_next,
 					&stp->st_locks, st_locks) {
-				if (func)
+				if (func) {
 					func(lst);
+					if (collect)
+						list_add(&lst->st_locks,
+							 collect);
+				}
 				if (++count == max)
 					return count;
 			}
@@ -5815,12 +5820,12 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 
 u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
 {
-	return nfsd_foreach_client_lock(clp, max, release_lock_stateid);
+	return nfsd_foreach_client_lock(clp, max, NULL, release_lock_stateid);
 }
 
 u64 nfsd_print_client_locks(struct nfs4_client *clp, u64 max)
 {
-	u64 count = nfsd_foreach_client_lock(clp, max, NULL);
+	u64 count = nfsd_foreach_client_lock(clp, max, NULL, NULL);
 	nfsd_print_count(clp, count, "locked files");
 	return count;
 }
-- 
1.9.3

