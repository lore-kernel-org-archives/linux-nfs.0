Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34535 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932383AbdDZQny (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 12:43:54 -0400
Received: by mail-io0-f195.google.com with SMTP id h41so1109805ioi.1
        for <linux-nfs@vger.kernel.org>; Wed, 26 Apr 2017 09:43:54 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Add a few more fatal I/O errors to nfs_error_is_fatal()
Date: Wed, 26 Apr 2017 12:43:50 -0400
Message-Id: <20170426164351.123953-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

EACCES, EDQUOT, EFBIG and ESTALE are all fatal errors as far as NFS
I/O is concerned. They need to be reported back to the application.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/internal.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7b38fedb7e03..31b26cf1b476 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -756,9 +756,13 @@ static inline bool nfs_error_is_fatal(int err)
 {
 	switch (err) {
 	case -ERESTARTSYS:
+	case -EACCES:
+	case -EDQUOT:
+	case -EFBIG:
 	case -EIO:
 	case -ENOSPC:
 	case -EROFS:
+	case -ESTALE:
 	case -E2BIG:
 		return true;
 	default:
-- 
2.9.3

