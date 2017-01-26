Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:32867 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753439AbdAZUOy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 15:14:54 -0500
Received: by mail-io0-f176.google.com with SMTP id v96so45804738ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2017 12:14:54 -0800 (PST)
Subject: [PATCH] nfs: Fix "Don't increment lock sequence ID after
 NFS4ERR_MOVED"
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Date: Thu, 26 Jan 2017 15:14:52 -0500
Message-ID: <20170126201452.6760.70964.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lock sequence IDs are bumped in decode_lock by calling
nfs_increment_seqid(). nfs_increment_sequid() does not use the
seqid_mutating_err() function fixed in commit 059aa7348241 ("Don't
increment lock sequence ID after NFS4ERR_MOVED").

Fixes: 059aa7348241 ("Don't increment lock sequence ID after ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Xuan Qi <xuan.qi@oracle.com>
Cc: stable@vger.kernel.org # v3.7+
---
 fs/nfs/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 90e6193..daeb94e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1091,6 +1091,7 @@ static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 		case -NFS4ERR_BADXDR:
 		case -NFS4ERR_RESOURCE:
 		case -NFS4ERR_NOFILEHANDLE:
+		case -NFS4ERR_MOVED:
 			/* Non-seqid mutating errors */
 			return;
 	};

