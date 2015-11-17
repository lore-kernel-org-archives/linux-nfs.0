Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33110 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbbKQLxu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:50 -0500
Received: by qkas77 with SMTP id s77so1714844qka.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:49 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 31/38] nfs: replace d_add with d_splice_alias in atomic_open
Date: Tue, 17 Nov 2015 06:52:53 -0500
Message-Id: <1447761180-4250-32-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

It's a trival change but follows knfsd export document that asks
for d_splice_alias during lookup.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ce5a21861074..a4df1137878e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1534,7 +1534,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		switch (err) {
 		case -ENOENT:
 			d_drop(dentry);
-			d_add(dentry, NULL);
+			d_splice_alias(NULL, dentry);
 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 			break;
 		case -EISDIR:
-- 
2.4.3

