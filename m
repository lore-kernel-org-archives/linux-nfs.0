Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754750AbbL3NOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Dec 2015 08:14:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 01/10] NFS4: remove a redundant lock range check
Date: Wed, 30 Dec 2015 08:13:57 -0500
Message-Id: <4b51943c8d3802ece5b99125a971759f77a57270.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

flock64_to_posix_lock() is already doing this check

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
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

