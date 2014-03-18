Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36998 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757114AbaCRUDd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Mar 2014 16:03:33 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so7716322iec.21
        for <linux-nfs@vger.kernel.org>; Tue, 18 Mar 2014 13:03:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Ensure we respect soft mount timeouts during trunking discovery
Date: Tue, 18 Mar 2014 16:03:26 -0400
Message-Id: <1395173006-14871-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1395173006-14871-1-git-send-email-trond.myklebust@primarydata.com>
References: <1395173006-14871-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f544a1560c83..2349518eef2c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2075,8 +2075,10 @@ again:
 	switch (status) {
 	case 0:
 		break;
-	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:
+		if (clnt->cl_softrtry)
+			break;
+	case -NFS4ERR_DELAY:
 	case -EAGAIN:
 		ssleep(1);
 	case -NFS4ERR_STALE_CLIENTID:
-- 
1.8.5.3

