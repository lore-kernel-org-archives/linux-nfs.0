From: Manish Katiyar <mkatiyar@gmail.com>
Subject: [PATCH] : Fix compilation warnings in fs/nfsd/nfs4state.c
Date: Wed, 28 Jan 2009 12:08:19 +0530
Message-ID: <ea11fea30901272238t4d11ba15t8bac4cd702ea7440@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, mkatiyar@gmail.com
To: kmsmith@umich.edu, kandros@umich.edu, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:46779 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbZA1GiV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 01:38:21 -0500
Received: by ti-out-0910.google.com with SMTP id b6so3433733tic.23
        for <linux-nfs@vger.kernel.org>; Tue, 27 Jan 2009 22:38:19 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Below patch removes the following warning ;-
fs/nfsd/nfs4state.c:1657: warning: unused variable 'flp'


Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
---
 fs/nfsd/nfs4state.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 69e98ca..2903589 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1654,7 +1654,10 @@ nfs4_open_delegation(struct svc_fh *fh, struct
nfsd4_open *open, struct nfs4_sta
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
 	struct nfs4_callback *cb = &sop->so_client->cl_callback;
-	struct file_lock fl, *flp = &fl;
+	struct file_lock fl;
+#ifdef CONFIG_FILE_LOCKING
+	struct file_lock *flp = &fl;
+#endif
 	int status, flag = 0;

 	flag = NFS4_OPEN_DELEGATE_NONE;
-- 
1.5.4.3


Thanks -
Manish
