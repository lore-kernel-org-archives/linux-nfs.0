Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56522 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659Ab2ENIPv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2012 04:15:51 -0400
Received: by bkcji2 with SMTP id ji2so3530137bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2012 01:15:50 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: lior@tonian.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd: apply pnfs export option on pnfs export ops setup
Date: Mon, 14 May 2012 11:15:47 +0300
Message-Id: <1336983347-18737-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4FAFB255.1040804@tonian.com>
References: <4FAFB255.1040804@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/export.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b6e46ab..b2fa749 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -421,7 +421,7 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 		return -EINVAL;
 	}
 
-	return pnfsd_check_export(inode, flags);
+	return 0;
 }
 
 #ifdef CONFIG_NFSD_V4
@@ -624,6 +624,13 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 				   exp.ex_uuid);
 		if (err)
 			goto out4;
+
+		if (exp.ex_pnfs) {
+			err = pnfsd_check_export(exp.ex_path.dentry->d_inode,
+						 &exp.ex_flags);
+			if (err)
+				goto out4;
+		}
 	}
 
 	expp = svc_export_lookup(&exp);
-- 
1.7.6.5

