Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:20552 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780AbbAETRa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 14:17:30 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] nfs: Remove unused v4 macros
Date: Mon, 5 Jan 2015 14:17:24 -0500
Message-ID: <1420485444-20101-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These functions are never called in the case that NFS v4 is not enabled.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4_fs.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3694895..f39314b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -509,10 +509,5 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 	return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
 }
 
-#else
-
-#define nfs4_close_state(a, b) do { } while (0)
-#define nfs4_close_sync(a, b) do { } while (0)
-
 #endif /* CONFIG_NFS_V4 */
 #endif /* __LINUX_FS_NFS_NFS4_FS.H */
-- 
2.2.1

