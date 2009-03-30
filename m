From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 5/7] SQUASHME: Revert "NFS: fix decode_fs_locations_maxsz"
Date: Mon, 30 Mar 2009 17:00:42 +0300
Message-ID: <1238421642-25115-1-git-send-email-bhalevy@panasas.com>
References: <49D0D025.2080608@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, andros@netapp.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14402 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752386AbZC3OAv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:00:51 -0400
In-Reply-To: <49D0D025.2080608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit d3a269cdeb581e688dce0eab4684fbe294b99b93.

Conflicts:

	fs/nfs/nfs4xdr.c

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 66922dc..358efe2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -243,7 +243,7 @@ static int nfs4_stat_to_errno(int);
 #define encode_fs_locations_maxsz \
 				(encode_getattr_maxsz)
 #define decode_fs_locations_maxsz \
-				(decode_getattr_maxsz)
+				(0)
 
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_MAX_MACHINE_NAME_LEN (64)
-- 
1.6.2.1

