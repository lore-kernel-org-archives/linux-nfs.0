Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:43877 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823Ab3EKCn1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:27 -0400
Received: by mail-wi0-f180.google.com with SMTP id h11so1208610wiv.7
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:26 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id dj7sm1199715wib.6.2013.05.10.19.43.25
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:26 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/38] FIXME: temporarily disable create_layout_recall_list in 3.8
Date: Sat, 11 May 2013 05:43:22 +0300
Message-Id: <1368240202-32263-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Need struct net * for calling filter_confirmed_clients.
Will be replaced by new layout recall API based on the layout stateid
rather than clientid for identifying a specific client
to recall from.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2be124a..0fa0e8b 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1310,6 +1310,7 @@ struct create_recall_list_arg {
 	};
 	int status = 0;
 
+#if 0
 	dprintk("%s: -->\n", __func__);
 
 	/* If client given by fs, just do single client */
@@ -1331,6 +1332,7 @@ struct create_recall_list_arg {
 out:
 	*todo_len = arg.todo_count;
 	dprintk("%s: <-- list len %u status %d\n", __func__, *todo_len, status);
+#endif
 	return status;
 }
 
-- 
1.7.11.7

