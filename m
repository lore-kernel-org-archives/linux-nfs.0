Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:47282 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932443AbaFSOxB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:01 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so2160938qgd.19
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 086/104] nfsd: add a list_head arg to nfsd_foreach_client_lock
Date: Thu, 19 Jun 2014 10:50:32 -0400
Message-Id: <1403189450-18729-87-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we'll want to collect the locks onto a list for later
destruction.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 526aae43c8d3..61102b93902c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5654,7 +5654,9 @@ static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 	printk(KERN_INFO "NFS Client: %s has %u %s\n", buf, count, type);
 }
 
-static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max, void (*func)(struct nfs4_ol_stateid *))
+static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max,
+				    struct list_head *collect,
+				    void (*func)(struct nfs4_ol_stateid *))
 {
 	struct nfs4_openowner *oop;
 	struct nfs4_ol_stateid *stp, *st_next;
@@ -5664,8 +5666,11 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max, void (*fun
 	list_for_each_entry(oop, &clp->cl_openowners, oo_perclient) {
 		list_for_each_entry_safe(stp, st_next, &oop->oo_owner.so_stateids, st_perstateowner) {
 			list_for_each_entry_safe(lst, lst_next, &stp->st_locks, st_locks) {
-				if (func)
+				if (func) {
 					func(lst);
+					if (collect)
+						list_add(&lst->st_locks, collect);
+				}
 				if (++count == max)
 					return count;
 			}
@@ -5677,12 +5682,12 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max, void (*fun
 
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

