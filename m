Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt1-f194.google.com ([209.85.160.194]:36593 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727265AbeJSXgT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:36:19 -0400
Received: by mail-qt1-f194.google.com with SMTP id u34-v6so38718741qth.3
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:44 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 11/11] NFS COPY handle ERR_OFFLOAD_DENIED
Date: Fri, 19 Oct 2018 11:29:32 -0400
Message-Id: <20181019152932.32462-12-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

If server sends ERR_OFFLOAD_DENIED error, the client must fall
back on doing copy the normal way. Return ENOTSUPP to the vfs and
fallback to regular copy.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 00809b3..c7c2ffa 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -395,7 +395,8 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			args.sync = true;
 			dst_exception.retry = 1;
 			continue;
-		} else if (err == -ESTALE &&
+		} else if ((err == -ESTALE ||
+				err == -NFS4ERR_OFFLOAD_DENIED) &&
 				!nfs42_files_from_same_server(src, dst)) {
 			nfs42_do_offload_cancel_async(src, &args.src_stateid);
 			err = -EOPNOTSUPP;
-- 
1.8.3.1
