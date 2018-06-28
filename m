Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:53731 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751065AbeF1DKW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Jun 2018 23:10:22 -0400
From: Chengguang Xu <cgxu519@gmx.com>
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Chengguang Xu <cgxu519@gmx.com>
Subject: [PATCH] nfs: add error check in nfs_idmap_prepare_message()
Date: Thu, 28 Jun 2018 11:09:45 +0800
Message-Id: <20180628030945.24626-1-cgxu519@gmx.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Even though the caller of nfs_idmap_prepare_message() checks return
code in their side but it's better to add an error check for match_int()
so that we can avoid unnecessary operations when bad int arg is
detected.

Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
---
 fs/nfs/nfs4idmap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index b6f9d84ba19b..cf72169d6c64 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -516,6 +516,8 @@ static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
 	case Opt_find_group:
 		im->im_conv = IDMAP_CONV_IDTONAME;
 		ret = match_int(&substr, &im->im_id);
+		if (ret)
+			goto out;
 		break;
 
 	default:
-- 
2.17.1

