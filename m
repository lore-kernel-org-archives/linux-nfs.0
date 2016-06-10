Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35983 "EHLO
	mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099AbcFJPuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 11:50:25 -0400
Received: by mail-qt0-f194.google.com with SMTP id z36so2788967qtb.3
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 08:50:25 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFS: Fix up O_DIRECT results
Date: Fri, 10 Jun 2016 11:49:58 -0400
Message-Id: <1465573798-80118-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465573798-80118-4-git-send-email-trond.myklebust@primarydata.com>
References: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
 <1465573798-80118-2-git-send-email-trond.myklebust@primarydata.com>
 <1465573798-80118-3-git-send-email-trond.myklebust@primarydata.com>
 <1465573798-80118-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

if we read or wrote something, we must report it

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 979b3c4dee6a..c7326c2af2c3 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -353,10 +353,12 @@ static ssize_t nfs_direct_wait(struct nfs_direct_req *dreq)
 
 	result = wait_for_completion_killable(&dreq->completion);
 
+	if (!result) {
+		result = dreq->count;
+		WARN_ON_ONCE(dreq->count < 0);
+	}
 	if (!result)
 		result = dreq->error;
-	if (!result)
-		result = dreq->count;
 
 out:
 	return (ssize_t) result;
@@ -386,8 +388,10 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq, bool write)
 
 	if (dreq->iocb) {
 		long res = (long) dreq->error;
-		if (!res)
+		if (dreq->count != 0) {
 			res = (long) dreq->count;
+			WARN_ON_ONCE(dreq->count < 0);
+		}
 		dreq->iocb->ki_complete(dreq->iocb, res, 0);
 	}
 
-- 
2.5.5

