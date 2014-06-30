Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:41850 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbaF3Pws (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:48 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so7249127qcq.34
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 096/114] nfsd: add a list_head arg to nfsd_foreach_client_lock
Date: Mon, 30 Jun 2014 11:50:05 -0400
Message-Id: <1404143423-24381-97-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index f395afc19d4c..2f57fa4fd244 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5752,6 +5752,7 @@ static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 }
 
 static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
+				    struct list_head *collect,
 				    void (*func)(struct nfs4_ol_stateid *))
 {
 	struct nfs4_openowner *oop;
@@ -5764,8 +5765,12 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
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
@@ -5777,12 +5782,12 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 
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

