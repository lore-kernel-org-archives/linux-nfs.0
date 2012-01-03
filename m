Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52493 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755694Ab2ACW4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jan 2012 17:56:24 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: be forgiving in the absence of the recovery directory
Date: Tue,  3 Jan 2012 17:56:19 -0500
Message-Id: <1325631381-9231-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1325631381-9231-1-git-send-email-bfields@redhat.com>
References: <1325631381-9231-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If the recovery directory doesn't exist, then behavior after a reboot
will be suboptimal.  But it's unnecessarily harsh to then prevent the
nfsv4 server from working at all.  Instead just print a warning
(already done in nfsd4_init_recdir()) and soldier on.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4recover.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 28712e2..eb01fff 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -127,10 +127,11 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 
 	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
 
-	if (!rec_file || clp->cl_firststate)
+	if (clp->cl_firststate)
 		return 0;
-
 	clp->cl_firststate = 1;
+	if (!rec_file)
+		return -ENOENT;
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
 		return status;
-- 
1.7.5.4

