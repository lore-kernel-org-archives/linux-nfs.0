Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:39587 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbaJMPH1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2014 11:07:27 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so10787464igb.2
        for <linux-nfs@vger.kernel.org>; Mon, 13 Oct 2014 08:07:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/2] NFS: Fix a bogus warning in nfs_generic_pgio
Date: Mon, 13 Oct 2014 11:07:19 -0400
Message-Id: <1413212839-6665-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1413212839-6665-1-git-send-email-trond.myklebust@primarydata.com>
References: <1413212839-6665-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is OK for pageused == pagecount in the loop, as long as we don't add
another entry to the *pages array. Move the test so that it only triggers
in that case.

Reported-by: Steve Dickson <SteveD@redhat.com>
Fixes: bba5c1887a92 (nfs: disallow duplicate pages in pgio page vectors)
Cc: Weston Andros Adamson <dros@primarydata.com>
Cc: stable@vger.kernel.org # 3.16.x
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 08085de879ed..ed0db61f8543 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -752,12 +752,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &hdr->pages);
 
-		if (WARN_ON_ONCE(pageused >= pagecount))
-			return nfs_pgio_error(desc, hdr);
-
 		if (!last_page || last_page != req->wb_page) {
-			*pages++ = last_page = req->wb_page;
 			pageused++;
+			if (pageused > pagecount)
+				break;
+			*pages++ = last_page = req->wb_page;
 		}
 	}
 	if (WARN_ON_ONCE(pageused != pagecount))
-- 
1.9.3

