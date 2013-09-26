Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:46099 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSlo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:44 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so1047556qcz.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:43 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 27/49] pnfsd: hash layouts on layout state
Date: Thu, 26 Sep 2013 14:41:41 -0400
Message-Id: <1380220901-13918-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 ++
 fs/nfsd/pnfsd.h     | 1 +
 2 files changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2c5d30d..386afa3 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -133,6 +133,7 @@ struct sbid_tracker {
 	new->ls_stid.sc_type = NFS4_LAYOUT_STID;
 	INIT_LIST_HEAD(&new->ls_perclnt);
 	INIT_LIST_HEAD(&new->ls_perfile);
+	INIT_LIST_HEAD(&new->ls_layouts);
 	new->ls_client = clp;
 	get_nfs4_file(fp);	/* released on destroy_layout_state */
 	new->ls_file = fp;
@@ -281,6 +282,7 @@ static void update_layout_stateid_locked(struct nfs4_layout_state *ls, stateid_t
 	lp->lo_state = ls;
 	spin_lock(&layout_lock);
 	update_layout_stateid_locked(ls, stateid);
+	list_add_tail(&lp->lo_perstate, &ls->ls_layouts);
 	spin_unlock(&layout_lock);
 	dprintk("pNFS %s end\n", __func__);
 }
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 852c250..1cd7a87 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -48,6 +48,7 @@ struct nfs4_layout_state {
 	struct nfs4_client	*ls_client;
 	struct list_head	ls_perfile;
 	struct nfs4_file	*ls_file;
+	struct list_head	ls_layouts;
 };
 
 /* outstanding layout */
-- 
1.8.3.1

