Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62432 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832Ab2C3Nq0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Mar 2012 09:46:26 -0400
Received: by ghrr11 with SMTP id r11so300284ghr.19
        for <linux-nfs@vger.kernel.org>; Fri, 30 Mar 2012 06:46:25 -0700 (PDT)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: trivial: remove unused variable from nfsd4_lock
Date: Fri, 30 Mar 2012 09:46:21 -0400
Message-Id: <1333115181-16659-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

..."fp" is set but never used.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1841f8b..a822e31 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4055,7 +4055,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp;
-	struct nfs4_file *fp;
 	struct file *filp = NULL;
 	struct file_lock file_lock;
 	struct file_lock conflock;
@@ -4123,7 +4122,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 	}
 	lock_sop = lockowner(lock_stp->st_stateowner);
-	fp = lock_stp->st_file;
 
 	lkflg = setlkflg(lock->lk_type);
 	status = nfs4_check_openmode(lock_stp, lkflg);
-- 
1.7.7.6

