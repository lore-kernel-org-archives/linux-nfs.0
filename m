Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:38452 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757141Ab3EKCoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:17 -0400
Received: by mail-we0-f176.google.com with SMTP id p60so4442087wes.21
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:16 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id ff10sm1323075wib.10.2013.05.10.19.44.15
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:15 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 27/38] pnfsd: layout state: introduce ls_file backpointer
Date: Sat, 11 May 2013 05:44:11 +0300
Message-Id: <1368240251-698-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 3 +++
 fs/nfsd/pnfsd.h     | 1 +
 2 files changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 6e0e9d1..b147427 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -132,6 +132,8 @@ struct sbid_tracker {
 	kref_init(&new->ls_ref);
 	nfsd4_init_stid(&new->ls_stid, clp, NFS4_LAYOUT_STID);
 	INIT_LIST_HEAD(&new->ls_perfile);
+	get_nfs4_file(fp);	/* released on destroy_layout_state */
+	new->ls_file = fp;
 	new->ls_roc = false;
 	spin_lock(&layout_lock);
 	list_add(&new->ls_perfile, &fp->fi_lo_states);
@@ -157,6 +159,7 @@ struct sbid_tracker {
 		list_del(&ls->ls_perfile);
 		spin_unlock(&layout_lock);
 	}
+	put_nfs4_file(ls->ls_file);
 	kmem_cache_free(layout_state_slab, ls);
 }
 
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 2507d31..6301c51 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -45,6 +45,7 @@ struct nfs4_layout_state {
 	struct nfs4_stid	ls_stid; /* must be first field */
 	struct kref		ls_ref;
 	struct list_head	ls_perfile;
+	struct nfs4_file	*ls_file;
 	bool			ls_roc;
 };
 
-- 
1.7.11.7

