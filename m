Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:65306 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaFZTOh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:37 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so3528651qcy.18
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 037/117] nfsd: clean up helper __release_lock_stateid
Date: Thu, 26 Jun 2014 15:12:17 -0400
Message-Id: <1403810017-16062-38-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Use filp_close instead of open coding. filp_close does a bit more than
just release the locks and put the filp. It also calls ->flush and
dnotify_flush, both of which should be done here anyway.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 01970b3cf593..0e42cca6192c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -885,10 +885,8 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
 	file = find_any_file(stp->st_file);
-	if (file) {
-		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
-		fput(file);
-	}
+	if (file)
+		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	close_generic_stateid(stp);
 	free_generic_stateid(stp);
 }
-- 
1.9.3

