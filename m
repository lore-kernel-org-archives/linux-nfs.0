Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:35779 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbaHIOW4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2014 10:22:56 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so6625729qaj.35
        for <linux-nfs@vger.kernel.org>; Sat, 09 Aug 2014 07:22:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfsd: allow find_any_file to return a fi_deleg_file reference
Date: Sat,  9 Aug 2014 10:22:42 -0400
Message-Id: <1407594162-28342-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
References: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that we'll have a nfs4_file that has nothing in its fds
array, but that has a populated fi_deleg_file field. Since that function
is generally happy with any file reference, allow it to find and take
a reference to it in that situation. Also, clean up find_any_file for
better readability.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4356d32479b2..5c5873811bd9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -355,11 +355,20 @@ find_any_file(struct nfs4_file *f)
 
 	spin_lock(&f->fi_lock);
 	ret = __nfs4_get_fd(f, O_RDWR);
-	if (!ret) {
-		ret = __nfs4_get_fd(f, O_WRONLY);
-		if (!ret)
-			ret = __nfs4_get_fd(f, O_RDONLY);
-	}
+	if (ret)
+		goto out;
+
+	ret = __nfs4_get_fd(f, O_WRONLY);
+	if (ret)
+		goto out;
+
+	ret = __nfs4_get_fd(f, O_RDONLY);
+	if (ret)
+		goto out;
+
+	if (f->fi_deleg_file)
+		ret = get_file(f->fi_deleg_file);
+out:
 	spin_unlock(&f->fi_lock);
 	return ret;
 }
-- 
1.9.3

