Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37269 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416Ab3EKCn6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:58 -0400
Received: by mail-wi0-f177.google.com with SMTP id hr14so1207898wib.10
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:57 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id h8sm1332240wiz.9.2013.05.10.19.43.56
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:56 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 22/38] SQUASHME: pnfsd: hanging nfs4_layoutrecall on the client's list must be under the layout_lock
Date: Sat, 11 May 2013 05:43:52 +0300
Message-Id: <1368240232-32576-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index ff688cb..7c454d2 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1416,8 +1416,10 @@ struct create_recall_list_arg {
 		pending->parent = parent;
 		get_layoutrecall(pending);
 		/* Add to list so corresponding layoutreturn can find req */
+		spin_lock(&layout_lock);
 		list_add(&pending->clr_perclnt,
 			 &pending->clr_client->cl_layoutrecalls);
+		spin_unlock(&layout_lock);
 
 		nfsd4_cb_layout(pending);
 		--todo_len;
-- 
1.7.11.7

