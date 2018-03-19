Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41678 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755754AbeCSOgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/10] nfsd4: set fl_owner to delegation, not file pointer
Date: Mon, 19 Mar 2018 10:36:28 -0400
Message-Id: <1521470194-24840-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

For now this makes no difference, as for files having delegations,
there's a one-to-one relationship between an nfs4_file and its
nfs4_delegation.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 51f633c85776..0466312a2a4e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -859,7 +859,7 @@ static void nfs4_put_deleg_lease(struct nfs4_delegation *dp)
 	spin_unlock(&fp->fi_lock);
 
 	if (filp) {
-		vfs_setlease(filp, F_UNLCK, NULL, (void **)&fp);
+		vfs_setlease(filp, F_UNLCK, NULL, (void **)&dp);
 		fput(filp);
 	}
 }
@@ -3909,13 +3909,9 @@ static bool
 nfsd_break_deleg_cb(struct file_lock *fl)
 {
 	bool ret = false;
-	struct nfs4_file *fp = (struct nfs4_file *)fl->fl_owner;
-	struct nfs4_delegation *dp;
+	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
 
-	if (!fp) {
-		WARN(1, "(%p)->fl_owner NULL\n", fl);
-		return ret;
-	}
 	if (fp->fi_had_conflict) {
 		WARN(1, "duplicate break on %p\n", fp);
 		return ret;
@@ -4261,7 +4257,8 @@ static bool nfsd4_cb_channel_good(struct nfs4_client *clp)
 	return clp->cl_minorversion && clp->cl_cb_state == NFSD4_CB_UNKNOWN;
 }
 
-static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
+static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
+						int flag)
 {
 	struct file_lock *fl;
 
@@ -4272,7 +4269,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 	fl->fl_flags = FL_DELEG;
 	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
 	fl->fl_end = OFFSET_MAX;
-	fl->fl_owner = fp;
+	fl->fl_owner = dp;
 	fl->fl_pid = current->tgid;
 	return fl;
 }
@@ -4296,7 +4293,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	struct file *filp;
 	int status = 0;
 
-	fl = nfs4_alloc_init_lease(fp, NFS4_OPEN_DELEGATE_READ);
+	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
 		return -ENOMEM;
 	filp = find_readable_file(fp);
-- 
2.14.3

