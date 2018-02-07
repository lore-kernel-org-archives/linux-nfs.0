Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40011 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753794AbeBGL16 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Feb 2018 06:27:58 -0500
From: Colin King <colin.king@canonical.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: make struct nlmclnt_fl_close_lock_ops static
Date: Wed,  7 Feb 2018 11:27:54 +0000
Message-Id: <20180207112754.30821-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The structure nlmclnt_fl_close_lock_ops s local to the source and does
not need to be in global scope, so make it static.

Cleans up sparse warning:
fs/nfs/nfs3proc.c:876:33: warning: symbol 'nlmclnt_fl_close_lock_ops' was not
declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 fs/nfs/nfs3proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 49f848fd1f04..7327930ad970 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -873,7 +873,7 @@ static void nfs3_nlm_release_call(void *data)
 	}
 }
 
-const struct nlmclnt_operations nlmclnt_fl_close_lock_ops = {
+static const struct nlmclnt_operations nlmclnt_fl_close_lock_ops = {
 	.nlmclnt_alloc_call = nfs3_nlm_alloc_call,
 	.nlmclnt_unlock_prepare = nfs3_nlm_unlock_prepare,
 	.nlmclnt_release_call = nfs3_nlm_release_call,
-- 
2.15.1

