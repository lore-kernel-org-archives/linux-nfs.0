Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35414 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756047AbaJWP4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2014 11:56:18 -0400
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>
Subject: [PATCH] nfs: Remove dead case from nfs4_map_errors()
Date: Thu, 23 Oct 2014 17:56:11 +0200
Message-Id: <1414079771-2960-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS4ERR_ACCESS has number 13 and thus is matched and returned
immediately at the beginning of nfs4_map_errors() and there's no point
in checking it later.

Coverity-id: 733891
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/nfs4proc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 405bd95c1f58..f45e6ea1b278 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -158,8 +158,6 @@ static int nfs4_map_errors(int err)
 		return -EACCES;
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
 		return -EPROTONOSUPPORT;
-	case -NFS4ERR_ACCESS:
-		return -EACCES;
 	case -NFS4ERR_FILE_OPEN:
 		return -EBUSY;
 	default:
-- 
1.8.1.4

