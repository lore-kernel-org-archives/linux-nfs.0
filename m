Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3629 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755268Ab2JOVdG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:33:06 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/13] lockd: Remove BUG_ON()s from fs/lockd/clntproc.c
Date: Mon, 15 Oct 2012 17:31:07 -0400
Message-Id: <1350336667-18770-15-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-14-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-10-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-11-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-12-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-13-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-14-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/lockd/clntproc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 05d2912..54f9e6c 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -141,7 +141,7 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
 
 static void nlmclnt_release_lockargs(struct nlm_rqst *req)
 {
-	BUG_ON(req->a_args.lock.fl.fl_ops != NULL);
+	WARN_ON_ONCE(req->a_args.lock.fl.fl_ops != NULL);
 }
 
 /**
@@ -465,7 +465,6 @@ static const struct file_lock_operations nlmclnt_lock_ops = {
 
 static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host)
 {
-	BUG_ON(fl->fl_ops != NULL);
 	fl->fl_u.nfs_fl.state = 0;
 	fl->fl_u.nfs_fl.owner = nlm_find_lockowner(host, fl->fl_owner);
 	INIT_LIST_HEAD(&fl->fl_u.nfs_fl.list);
-- 
1.7.11.7

