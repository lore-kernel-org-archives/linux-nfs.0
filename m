Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:44055 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760784Ab2IGOTH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:19:07 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so3364211vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 07 Sep 2012 07:19:06 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v6 19/20] vfs: convert do_filp_open to use retry_estale helper
Date: Fri,  7 Sep 2012 10:18:26 -0400
Message-Id: <1347027507-20956-20-git-send-email-jlayton@redhat.com>
In-Reply-To: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
References: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 010d428..66b24fa 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3011,11 +3011,12 @@ struct file *do_filp_open(int dfd, struct getname_info *ginfo,
 {
 	struct nameidata nd;
 	struct file *filp;
+	unsigned int try = 0;
 
 	filp = path_openat(dfd, ginfo, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(filp == ERR_PTR(-ECHILD)))
 		filp = path_openat(dfd, ginfo, &nd, op, flags);
-	if (unlikely(filp == ERR_PTR(-ESTALE)))
+	while (retry_estale(PTR_ERR(filp), try++))
 		filp = path_openat(dfd, ginfo, &nd, op, flags | LOOKUP_REVAL);
 	return filp;
 }
-- 
1.7.11.4

