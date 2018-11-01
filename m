Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E96BEC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:39:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A9E732081B
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:39:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9E732081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725987AbeKBCnq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 22:43:46 -0400
Received: from mx1.redhat.com ([209.132.183.28]:44150 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725982AbeKBCnq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 22:43:46 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 429BA308403E;
        Thu,  1 Nov 2018 17:39:50 +0000 (UTC)
Received: from bcodding.csb (ovpn-125-247.rdu2.redhat.com [10.10.125.247])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9BEBD4F6A1;
        Thu,  1 Nov 2018 17:39:49 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id 0DED010C30F3; Thu,  1 Nov 2018 13:39:49 -0400 (EDT)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: Show pid of lockd for remote locks
Date:   Thu,  1 Nov 2018 13:39:49 -0400
Message-Id: <62c22ff69bf762085a35d5706bd5e9e421bfbb33.1541093385.git.bcodding@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 01 Nov 2018 17:39:50 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit 9d5b86ac13c5 ("fs/locks: Remove fl_nspid and use fs-specific l_pid
for remote locks") specified that the l_pid returned for F_GETLK on a local
file that has a remote lock should be the pid of the lock manager process.
That commit, while updating other filesystems, failed to update lockd, such
that locks created by lockd had their fl_pid set to that of the remote
process holding the lock.  Fix that here to be the pid of lockd.

Also, fix the client case so that the returned lock pid is negative, which
indicates a remote lock on a remote file.

Fixes: 9d5b86ac13c5 ("fs/locks: Remove fl_nspid and use fs-specific...")
Cc: stable@vger.kernel.org

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/lockd/clntproc.c | 2 +-
 fs/lockd/xdr.c      | 4 ++--
 fs/lockd/xdr4.c     | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index d20b92f271c2..0a67dd4250e9 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -442,7 +442,7 @@ nlmclnt_test(struct nlm_rqst *req, struct file_lock *fl)
 			fl->fl_start = req->a_res.lock.fl.fl_start;
 			fl->fl_end = req->a_res.lock.fl.fl_end;
 			fl->fl_type = req->a_res.lock.fl.fl_type;
-			fl->fl_pid = 0;
+			fl->fl_pid = -req->a_res.lock.fl.fl_pid;
 			break;
 		default:
 			status = nlm_stat_to_errno(req->a_res.status);
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 7147e4aebecc..9846f7e95282 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -127,7 +127,7 @@ nlm_decode_lock(__be32 *p, struct nlm_lock *lock)
 
 	locks_init_lock(fl);
 	fl->fl_owner = current->files;
-	fl->fl_pid   = (pid_t)lock->svid;
+	fl->fl_pid   = current->tgid;
 	fl->fl_flags = FL_POSIX;
 	fl->fl_type  = F_RDLCK;		/* as good as anything else */
 	start = ntohl(*p++);
@@ -269,7 +269,7 @@ nlmsvc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
 	memset(lock, 0, sizeof(*lock));
 	locks_init_lock(&lock->fl);
 	lock->svid = ~(u32) 0;
-	lock->fl.fl_pid = (pid_t)lock->svid;
+	lock->fl.fl_pid = current->tgid;
 
 	if (!(p = nlm_decode_cookie(p, &argp->cookie))
 	 || !(p = xdr_decode_string_inplace(p, &lock->caller,
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index 7ed9edf9aed4..70154f376695 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -119,7 +119,7 @@ nlm4_decode_lock(__be32 *p, struct nlm_lock *lock)
 
 	locks_init_lock(fl);
 	fl->fl_owner = current->files;
-	fl->fl_pid   = (pid_t)lock->svid;
+	fl->fl_pid   = current->tgid;
 	fl->fl_flags = FL_POSIX;
 	fl->fl_type  = F_RDLCK;		/* as good as anything else */
 	p = xdr_decode_hyper(p, &start);
@@ -266,7 +266,7 @@ nlm4svc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
 	memset(lock, 0, sizeof(*lock));
 	locks_init_lock(&lock->fl);
 	lock->svid = ~(u32) 0;
-	lock->fl.fl_pid = (pid_t)lock->svid;
+	lock->fl.fl_pid = current->tgid;
 
 	if (!(p = nlm4_decode_cookie(p, &argp->cookie))
 	 || !(p = xdr_decode_string_inplace(p, &lock->caller,
-- 
2.14.3

