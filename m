Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51485 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754537Ab2KHAgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:36:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: don't BUG in delegation break callback
Date: Wed,  7 Nov 2012 19:36:12 -0500
Message-Id: <1352334972-28495-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1352334972-28495-1-git-send-email-bfields@redhat.com>
References: <1352334972-28495-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

These conditions would indeed indicate bugs in the code, but if we want
to hear about them we're likely better off warning and returning than
immediately dying while holding file_lock_lock.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bc8507c..db7258c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2554,9 +2554,14 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	struct nfs4_file *fp = (struct nfs4_file *)fl->fl_owner;
 	struct nfs4_delegation *dp;
 
-	BUG_ON(!fp);
-	/* We assume break_lease is only called once per lease: */
-	BUG_ON(fp->fi_had_conflict);
+	if (!fp) {
+		WARN(1, "(%p)->fl_owner NULL\n", fl);
+		return;
+	}
+	if (fp->fi_had_conflict) {
+		WARN(1, "duplicate break on %p\n", fp);
+		return;
+	}
 	/*
 	 * We don't want the locks code to timeout the lease for us;
 	 * we'll remove it ourself if a delegation isn't returned
-- 
1.7.9.5

