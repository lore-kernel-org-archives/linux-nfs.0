Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f177.google.com ([74.125.82.177]:37238 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434Ab3EKCoK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:10 -0400
Received: by mail-we0-f177.google.com with SMTP id q58so4521759wes.36
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:08 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id ge7sm1367050wib.6.2013.05.10.19.44.07
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:08 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 25/38] pnfsd: layout state: rename fi_layout_states member
Date: Sat, 11 May 2013 05:44:04 +0300
Message-Id: <1368240244-486-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 +-
 fs/nfsd/nfs4state.c | 2 +-
 fs/nfsd/state.h     | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index d9bf099..1b31432 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -133,7 +133,7 @@ struct sbid_tracker {
 	nfsd4_init_stid(&new->ls_stid, clp, NFS4_LAYOUT_STID);
 	INIT_LIST_HEAD(&new->ls_perfile);
 	spin_lock(&layout_lock);
-	list_add(&new->ls_perfile, &fp->fi_layout_states);
+	list_add(&new->ls_perfile, &fp->fi_lo_states);
 	spin_unlock(&layout_lock);
 	new->ls_roc = false;
 	return new;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 282be50..12eed1d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2364,7 +2364,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 #if defined(CONFIG_PNFSD)
 	INIT_LIST_HEAD(&fp->fi_layouts);
-	INIT_LIST_HEAD(&fp->fi_layout_states);
+	INIT_LIST_HEAD(&fp->fi_lo_states);
 	fp->fi_fsid.major = current_fh->fh_export->ex_fsid;
 	fp->fi_fsid.minor = 0;
 	fp->fi_fhlen = current_fh->fh_handle.fh_size;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5c613ba..c185025 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -412,7 +412,7 @@ struct nfs4_file {
 	bool			fi_had_conflict;
 #if defined(CONFIG_PNFSD)
 	struct list_head	fi_layouts;
-	struct list_head	fi_layout_states;
+	struct list_head	fi_lo_states;
 	/* used by layoutget / layoutrecall */
 	struct nfs4_fsid	fi_fsid;
 	u32			fi_fhlen;
-- 
1.7.11.7

