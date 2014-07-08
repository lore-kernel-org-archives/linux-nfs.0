Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:53063 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268AbaGHSFD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:03 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so5601989qcy.18
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 020/100] nfsd: nfs4_alloc_init_lease should take a nfs4_file arg
Date: Tue,  8 Jul 2014 14:03:08 -0400
Message-Id: <1404842668-22521-21-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to pass the delegation pointer in here as it's only used to get
the nfs4_file pointer.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 16282f1bf2ea..9dd3571b0ec6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3485,7 +3485,7 @@ static bool nfsd4_cb_channel_good(struct nfs4_client *clp)
 	return clp->cl_minorversion && clp->cl_cb_state == NFSD4_CB_UNKNOWN;
 }
 
-static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int flag)
+static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 {
 	struct file_lock *fl;
 
@@ -3497,7 +3497,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
 	fl->fl_flags = FL_DELEG;
 	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
 	fl->fl_end = OFFSET_MAX;
-	fl->fl_owner = (fl_owner_t)(dp->dl_file);
+	fl->fl_owner = (fl_owner_t)fp;
 	fl->fl_pid = current->tgid;
 	return fl;
 }
@@ -3508,7 +3508,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	struct file_lock *fl;
 	int status;
 
-	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
+	fl = nfs4_alloc_init_lease(fp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
 		return -ENOMEM;
 	fl->fl_file = find_readable_file(fp);
-- 
1.9.3

