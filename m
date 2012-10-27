Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:54786 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756161Ab2J0Mej (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:39 -0400
Received: by mail-ye0-f174.google.com with SMTP id m12so638386yen.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:39 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 29/32] vfs: convert do_filp_open to use retry_estale helper
Date: Sat, 27 Oct 2012 08:33:36 -0400
Message-Id: <1351341219-17837-30-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 27bff9b..6930e91 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3012,11 +3012,12 @@ struct file *do_filp_open(int dfd, struct filename *pathname,
 {
 	struct nameidata nd;
 	struct file *filp;
+	unsigned int try = 0;
 
 	filp = path_openat(dfd, pathname, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(filp == ERR_PTR(-ECHILD)))
 		filp = path_openat(dfd, pathname, &nd, op, flags);
-	if (unlikely(filp == ERR_PTR(-ESTALE)))
+	while (retry_estale(PTR_ERR(filp), try++))
 		filp = path_openat(dfd, pathname, &nd, op, flags | LOOKUP_REVAL);
 	return filp;
 }
-- 
1.7.11.7

