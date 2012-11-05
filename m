Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:52182 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932847Ab2KEPXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:23:19 -0500
Received: by mail-ye0-f174.google.com with SMTP id m12so1017184yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:23:19 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 31/34] vfs: convert filename_lookup to use retry_estale helper
Date: Mon,  5 Nov 2012 10:22:10 -0500
Message-Id: <1352128933-28526-32-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index fbfeb88..c3582d4 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2020,10 +2020,11 @@ static int path_lookupat(int dfd, const char *name,
 static int filename_lookup(int dfd, struct filename *name,
 				unsigned int flags, struct nameidata *nd)
 {
+	unsigned int try = 0;
 	int retval = path_lookupat(dfd, name->name, flags | LOOKUP_RCU, nd);
 	if (unlikely(retval == -ECHILD))
 		retval = path_lookupat(dfd, name->name, flags, nd);
-	if (unlikely(retval == -ESTALE))
+	while (retry_estale(retval, try++))
 		retval = path_lookupat(dfd, name->name,
 						flags | LOOKUP_REVAL, nd);
 
-- 
1.7.11.7

