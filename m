Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:41469 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbaG3M2M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:12 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so1285120qge.2
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:11 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 19/37] nfsd: add a list_head arg to nfsd_foreach_client_lock
Date: Wed, 30 Jul 2014 08:27:20 -0400
Message-Id: <1406723258-8512-20-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
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
index 8cc3a8c1c2a9..b6020e4a2102 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5807,6 +5807,7 @@ static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 }
 
 static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
+				    struct list_head *collect,
 				    void (*func)(struct nfs4_ol_stateid *))
 {
 	struct nfs4_openowner *oop;
@@ -5819,8 +5820,12 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
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
@@ -5832,12 +5837,12 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
 
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

