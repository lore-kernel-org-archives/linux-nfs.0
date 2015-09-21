Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:33862 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601AbbIUAst (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 20:48:49 -0400
Received: by ykdg206 with SMTP id g206so89861904ykd.1
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 17:48:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] NFSv4: Update the delay statistics counter for synchronous delays
Date: Sun, 20 Sep 2015 20:48:41 -0400
Message-Id: <1442796524-89165-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1442796524-89165-1-git-send-email-trond.myklebust@primarydata.com>
References: <1442796524-89165-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we only do so for asynchronous delays.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a77736bc9d7b..9ab48308f195 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -411,8 +411,9 @@ int nfs4_do_handle_exception(struct nfs_server *server, int errorcode, struct nf
 				ret = -EBUSY;
 				break;
 			}
-		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
+			nfs_inc_server_stats(server, NFSIOS_DELAY);
+		case -NFS4ERR_GRACE:
 			exception->delay = 1;
 			return 0;
 
-- 
2.4.3

