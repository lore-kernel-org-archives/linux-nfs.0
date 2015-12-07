Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932894AbbLGQ0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 11:26:11 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, hch@infradead.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/10] NFS4: remove a redundant lock range check
Date: Mon,  7 Dec 2015 11:26:00 -0500
Message-Id: <09543a9efd73eb12bf7c8421b5fe5377f139e3db.1449503713.git.bcodding@redhat.com>
In-Reply-To: <cover.1449503713.git.bcodding@redhat.com>
References: <cover.1449503713.git.bcodding@redhat.com>
In-Reply-To: <cover.1449503713.git.bcodding@redhat.com>
References: <cover.1449503713.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

flock64_to_posix_lock() is already doing this check

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8981803..2231d7d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6108,9 +6108,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	ctx = nfs_file_open_context(filp);
 	state = ctx->state;
 
-	if (request->fl_start < 0 || request->fl_end < 0)
-		return -EINVAL;
-
 	if (IS_GETLK(cmd)) {
 		if (state != NULL)
 			return nfs4_proc_getlk(state, F_GETLK, request);
-- 
1.7.1

