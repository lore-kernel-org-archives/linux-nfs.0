Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:35815 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbbFDRyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 13:54:46 -0400
Received: by yhak3 with SMTP id k3so7622291yha.2
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 10:54:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: nfs4_handle_delegation_recall_error should ignore EAGAIN
Date: Thu,  4 Jun 2015 13:54:43 -0400
Message-Id: <1433440483-3278-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

EAGAIN is a valid return code from nfs4_open_recover(), and should
be handled by nfs4_handle_delegation_recall_error by simply passing
it through.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 55e1e3af23a3..d25de2ab12fb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1684,6 +1684,7 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
 					"%d.\n", __func__, err);
 		case 0:
 		case -ENOENT:
+		case -EAGAIN:
 		case -ESTALE:
 			break;
 		case -NFS4ERR_BADSESSION:
-- 
2.4.2

