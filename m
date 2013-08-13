Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:8875 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759174Ab3HMUhx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 16:37:53 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 7/7] nfs4: Map NFS4ERR_WRONG_CRED to EPERM
Date: Tue, 13 Aug 2013 16:37:38 -0400
Message-ID: <1376426258-28244-8-git-send-email-dros@netapp.com>
In-Reply-To: <1376426258-28244-1-git-send-email-dros@netapp.com>
References: <1376426258-28244-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e8a4c0..d41935f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -150,6 +150,7 @@ static int nfs4_map_errors(int err)
 	case -NFS4ERR_RECALLCONFLICT:
 		return -EREMOTEIO;
 	case -NFS4ERR_WRONGSEC:
+	case -NFS4ERR_WRONG_CRED:
 		return -EPERM;
 	case -NFS4ERR_BADOWNER:
 	case -NFS4ERR_BADNAME:
-- 
1.7.12.4 (Apple Git-37)

