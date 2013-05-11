Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:63204 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088Ab3EKCoN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:13 -0400
Received: by mail-wg0-f45.google.com with SMTP id l18so4809842wgh.24
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:12 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id q13sm1342749wie.8.2013.05.10.19.44.11
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:12 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 26/38] pnfsd: layout state: move initialization of ls_roc
Date: Sat, 11 May 2013 05:44:07 +0300
Message-Id: <1368240247-525-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

initialize prior to enlisting on fi_lo_states

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 1b31432..6e0e9d1 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -132,10 +132,10 @@ struct sbid_tracker {
 	kref_init(&new->ls_ref);
 	nfsd4_init_stid(&new->ls_stid, clp, NFS4_LAYOUT_STID);
 	INIT_LIST_HEAD(&new->ls_perfile);
+	new->ls_roc = false;
 	spin_lock(&layout_lock);
 	list_add(&new->ls_perfile, &fp->fi_lo_states);
 	spin_unlock(&layout_lock);
-	new->ls_roc = false;
 	return new;
 }
 
-- 
1.7.11.7

