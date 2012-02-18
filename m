Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60653 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab2BRIRN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2012 03:17:13 -0500
Received: by mail-ww0-f44.google.com with SMTP id dt10so3337209wgb.1
        for <linux-nfs@vger.kernel.org>; Sat, 18 Feb 2012 00:17:13 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd41: refactor nfsd4_deleg_xgrade_none_ext logic out of nfsd4_process_open2
Date: Sat, 18 Feb 2012 10:17:08 +0200
Message-Id: <1329553028-2836-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3F5B30.3000501@tonian.com>
References: <4F3F5B30.3000501@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle the case where the nfsv4.1 client asked to uprade or downgrade
its delegations and server returns no delegation.

In this case, op_delegate_type is set to NFS4_OPEN_DELEGATE_NONE_EXT
and op_why_no_deleg is set respectively to WND4_NOT_SUPP_{UP,DOWN}GRADE

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4state.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 94daab4..5bfc846 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2942,6 +2942,24 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 	goto out;
 }
 
+static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
+					struct nfs4_delegation *dp)
+{
+	if (open->op_deleg_want == NFS4_SHARE_WANT_READ_DELEG &&
+	    dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
+		open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+		open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
+	} else if (open->op_deleg_want == NFS4_SHARE_WANT_WRITE_DELEG &&
+		   dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
+		open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+		open->op_why_no_deleg = WND4_NOT_SUPP_UPGRADE;
+	}
+	/* Otherwise the client must be confused wanting a delegation
+	 * it already has, therefore we don't return
+	 * NFS4_OPEN_DELEGATE_NONE_EXT and reason.
+	 */
+}
+
 /*
  * called with nfs4_lock_state() held.
  */
@@ -3026,21 +3044,8 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 out:
 	/* 4.1 client trying to upgrade/downgrade delegation? */
 	if (open->op_delegate_type == NFS4_OPEN_DELEGATE_NONE && dp &&
-	    open->op_deleg_want) {
-		if (open->op_deleg_want == NFS4_SHARE_WANT_READ_DELEG &&
-		    dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
-			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
-			open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
-		} else if (open->op_deleg_want == NFS4_SHARE_WANT_WRITE_DELEG &&
-			   dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
-			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
-			open->op_why_no_deleg = WND4_NOT_SUPP_UPGRADE;
-		}
-		/* Otherwise the client must be confused wanting a delegation
-		 * it already has, therefore we don't return
-		 * NFS4_OPEN_DELEGATE_NONE_EXT and reason.
-		 */
-	}
+	    open->op_deleg_want)
+		nfsd4_deleg_xgrade_none_ext(open, dp);
 
 	if (fp)
 		put_nfs4_file(fp);
-- 
1.7.6.5

