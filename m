Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab2C3TCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 15:02:48 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 03/10] NFS: Fix whitespace errors
Date: Fri, 30 Mar 2012 15:02:30 -0400
Message-Id: <1333134157-17141-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
References: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Remove the space from the beginning of both lines.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1358dc1..7a711e9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2149,7 +2149,7 @@ static void nfs_fill_super(struct super_block *sb,
 		sb->s_xattr = nfs4_xattr_handlers;
 
 	sb->s_op = &nfs_sops;
- 	nfs_initialise_sb(sb);
+	nfs_initialise_sb(sb);
 }
 
 /*
@@ -2174,7 +2174,7 @@ static void nfs_clone_super(struct super_block *sb,
 		sb->s_flags |= MS_POSIXACL;
 	}
 
- 	nfs_initialise_sb(sb);
+	nfs_initialise_sb(sb);
 }
 
 static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
-- 
1.7.9.5

