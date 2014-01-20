Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:56686 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbaATDpu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jan 2014 22:45:50 -0500
Received: by mail-ie0-f170.google.com with SMTP id u16so5982072iet.1
        for <linux-nfs@vger.kernel.org>; Sun, 19 Jan 2014 19:45:50 -0800 (PST)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/2] nfs4: fix comments in discover_server_trunking
Date: Sun, 19 Jan 2014 22:45:37 -0500
Message-Id: <1390189537-9666-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1390189537-9666-1-git-send-email-dros@primarydata.com>
References: <1390189537-9666-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

'result' is not updated if a match isn't found in the
nfs4_discover_server_trunking path.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/nfs4client.c | 4 ++--
 fs/nfs/nfs4state.c  | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 0f9b772..147a752 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -465,7 +465,7 @@ static void nfs4_swap_callback_idents(struct nfs_client *keep,
  * nfs40_walk_client_list - Find server that recognizes a client ID
  *
  * @new: nfs_client with client ID to test
- * @result: OUT: found nfs_client, or new
+ * @result: OUT: found nfs_client
  * @cred: credential to use for trunking test
  *
  * Returns zero, a negative errno, or a negative NFS4ERR status.
@@ -601,7 +601,7 @@ out_major_mismatch:
  * nfs41_walk_client_list - Find nfs_client that matches a client/server owner
  *
  * @new: nfs_client with client ID to test
- * @result: OUT: found nfs_client, or new
+ * @result: OUT: found nfs_client
  * @cred: credential to use for trunking test
  *
  * Returns zero, a negative errno, or a negative NFS4ERR status.
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e5be725..666512e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -328,7 +328,7 @@ out:
  * nfs41_discover_server_trunking - Detect server IP address trunking (mv1)
  *
  * @clp: nfs_client under test
- * @result: OUT: found nfs_client, or clp
+ * @result: OUT: found nfs_client
  * @cred: credential to use for trunking test
  *
  * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
-- 
1.8.3.4 (Apple Git-47)

