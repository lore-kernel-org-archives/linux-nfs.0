Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39849 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474Ab2BOTmK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 14:42:10 -0500
Received: by mail-iy0-f174.google.com with SMTP id b35so1851170iac.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 11:42:10 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/13] nfs: Clean up debugging in nfs_follow_mountpoint()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 14:42:08 -0500
Message-ID: <20120215194208.2925.16059.stgit@ellison.1015granger.net>
In-Reply-To: <20120215193059.2925.10928.stgit@ellison.1015granger.net>
References: <20120215193059.2925.10928.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Fix a debugging message which had an obsolete function name
in it (nfs_follow_mountpoint).

Introduced by commit 36d43a43 "NFS: Use d_automount() rather than
abusing follow_link()" (January 14, 2011)

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/namespace.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 8102391..1807866 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -276,7 +276,10 @@ out:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fh);
 out_nofree:
-	dprintk("<-- nfs_follow_mountpoint() = %p\n", mnt);
+	if (IS_ERR(mnt))
+		dprintk("<-- %s(): error %ld\n", __func__, PTR_ERR(mnt));
+	else
+		dprintk("<-- %s() = %p\n", __func__, mnt);
 	return mnt;
 }
 

