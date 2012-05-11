Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:41865 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318Ab2EKNpl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 09:45:41 -0400
Received: by mail-qa0-f46.google.com with SMTP id b17so1246328qad.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 May 2012 06:45:41 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] nfsd: make test_share a bool return
Date: Fri, 11 May 2012 09:45:12 -0400
Message-Id: <1336743914-944-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336743914-944-1-git-send-email-jlayton@redhat.com>
References: <1336743914-944-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All of the callers treat the return that way already.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 64aeaa0..bb9e00e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -459,15 +459,15 @@ bmap_to_share_mode(unsigned long bmap) {
 	return access;
 }
 
-static int
+static bool
 test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
 	unsigned int access, deny;
 
 	access = bmap_to_share_mode(stp->st_access_bmap);
 	deny = bmap_to_share_mode(stp->st_deny_bmap);
 	if ((access & open->op_share_deny) || (deny & open->op_share_access))
-		return 0;
-	return 1;
+		return false;
+	return true;
 }
 
 static int nfs4_access_to_omode(u32 access)
-- 
1.7.7.6

