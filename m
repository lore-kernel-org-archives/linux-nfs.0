Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:44247 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSEu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:50 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so5571432qcq.20
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 010/100] nfsd: clean up helper __release_lock_stateid
Date: Tue,  8 Jul 2014 14:02:58 -0400
Message-Id: <1404842668-22521-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Use filp_close instead of open coding. filp_close does a bit more than
just release the locks and put the filp. It also calls ->flush and
dnotify_flush, both of which should be done here anyway.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0b42bd47a7d6..775267ed186a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -805,10 +805,8 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
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

