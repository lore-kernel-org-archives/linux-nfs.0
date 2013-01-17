Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f45.google.com ([209.85.215.45]:60505 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757365Ab3AQQx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 11:53:27 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v2 6/8] CIFS: Translate SHARING_VIOLATION to -ETXTBSY error code for SMB2
Date: Thu, 17 Jan 2013 20:53:02 +0400
Message-Id: <1358441584-8783-6-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

to make it match CIFS and VFS variants.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/cifs/smb2maperror.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/cifs/smb2maperror.c b/fs/cifs/smb2maperror.c
index 494c912..11e589e 100644
--- a/fs/cifs/smb2maperror.c
+++ b/fs/cifs/smb2maperror.c
@@ -356,7 +356,7 @@ static const struct status_to_posix_error smb2_error_map_table[] = {
 	{STATUS_PORT_CONNECTION_REFUSED, -ECONNREFUSED,
 	"STATUS_PORT_CONNECTION_REFUSED"},
 	{STATUS_INVALID_PORT_HANDLE, -EIO, "STATUS_INVALID_PORT_HANDLE"},
-	{STATUS_SHARING_VIOLATION, -EBUSY, "STATUS_SHARING_VIOLATION"},
+	{STATUS_SHARING_VIOLATION, -ETXTBSY, "STATUS_SHARING_VIOLATION"},
 	{STATUS_QUOTA_EXCEEDED, -EDQUOT, "STATUS_QUOTA_EXCEEDED"},
 	{STATUS_INVALID_PAGE_PROTECTION, -EIO,
 	"STATUS_INVALID_PAGE_PROTECTION"},
-- 
1.8.1.1

