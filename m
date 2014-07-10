Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:64975 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbaGJOZr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 10:25:47 -0400
Received: by mail-qa0-f43.google.com with SMTP id w8so332664qac.30
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 07:25:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: "Frank S. Filz" <ffilzlnx@mindspring.com>
Subject: [PATCH] NFSv4: Fix OPEN w/create access mode checking
Date: Thu, 10 Jul 2014 10:25:43 -0400
Message-Id: <1405002343-15802-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

POSIX states that open("foo", O_CREAT|O_RDONLY, 000) should succeed if
the file "foo" does not already exist. With the current NFS client,
it will fail with an EACCES error because of the permissions checks in
nfs4_opendata_access().

Fix is to turn that test off if the server says that we created the file.

Reported-by: "Frank S. Filz" <ffilzlnx@mindspring.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d0e0e54fb2b9..70e53a2ac75e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1954,6 +1954,14 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 	return status;
 }
 
+/*
+ * Additional permission checks in order to distinguish between an
+ * open for read, and an open for execute. This works around the
+ * fact that NFSv4 OPEN treats read and execute permissions as being
+ * the same.
+ * Note that in the non-execute case, we want to turn off permission
+ * checking if we just created a new file (POSIX open() semantics).
+ */
 static int nfs4_opendata_access(struct rpc_cred *cred,
 				struct nfs4_opendata *opendata,
 				struct nfs4_state *state, fmode_t fmode,
@@ -1968,14 +1976,14 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 		return 0;
 
 	mask = 0;
-	/* don't check MAY_WRITE - a newly created file may not have
-	 * write mode bits, but POSIX allows the creating process to write.
-	 * use openflags to check for exec, because fmode won't
-	 * always have FMODE_EXEC set when file open for exec. */
+	/*
+	 * Use openflags to check for exec, because fmode won't
+	 * always have FMODE_EXEC set when file open for exec.
+	 */
 	if (openflags & __FMODE_EXEC) {
 		/* ONLY check for exec rights */
 		mask = MAY_EXEC;
-	} else if (fmode & FMODE_READ)
+	} else if ((fmode & FMODE_READ) && !opendata->file_created)
 		mask = MAY_READ;
 
 	cache.cred = cred;
-- 
1.9.3

