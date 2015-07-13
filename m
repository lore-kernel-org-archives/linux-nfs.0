Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36377 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbbGMJeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:34:25 -0400
Received: by pdjr16 with SMTP id r16so60054337pdj.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:34:25 -0700 (PDT)
Message-ID: <55A3861B.9030005@gmail.com>
Date: Mon, 13 Jul 2015 17:34:19 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 12/14] nfsd: Remove macro LOFF_OVERFLOW
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d342769..13df582 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5040,9 +5040,6 @@ out:
 	return status;
 }
 
-
-#define LOFF_OVERFLOW(start, len)      ((u64)(len) > ~(u64)(start))
-
 static inline u64
 end_offset(u64 start, u64 len)
 {
@@ -5295,8 +5292,8 @@ find_or_create_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fi,
 static int
 check_lock_length(u64 offset, u64 length)
 {
-	return ((length == 0)  || ((length != NFS4_MAX_UINT64) &&
-	     LOFF_OVERFLOW(offset, length)));
+	return ((length == 0) || ((length != NFS4_MAX_UINT64) &&
+		(length > ~offset)));
 }
 
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
-- 
2.4.3

