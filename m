Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:61846 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757056Ab3EKCnn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:43 -0400
Received: by mail-wi0-f179.google.com with SMTP id hn3so1209486wib.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:42 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id ff10sm1321827wib.10.2013.05.10.19.43.40
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:41 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/38] SQUASHME: pnfsd: fix destroy_layout_state
Date: Sat, 11 May 2013 05:43:37 +0300
Message-Id: <1368240217-32415-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

squash into "pnfsd: layout state allocation"

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 96206d9..24c19b3 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -155,7 +155,7 @@ struct sbid_tracker {
 		list_del(&ls->ls_perfile);
 		spin_unlock(&layout_lock);
 	}
-	kfree(ls);
+	kmem_cache_free(layout_state_slab, ls);
 }
 
 /*
-- 
1.7.11.7

