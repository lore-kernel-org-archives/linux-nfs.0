Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:53723 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbaJCNpd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2014 09:45:33 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn15so1847igb.3
        for <linux-nfs@vger.kernel.org>; Fri, 03 Oct 2014 06:45:32 -0700 (PDT)
From: Thomas Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Tom Haynes <loghyr@primarydata.com>
Subject: [PATCH] NFSv4: Remove dead prototype for nfs4_insert_deviceid_node()
Date: Thu,  2 Oct 2014 23:44:11 -0700
Message-Id: <1412318651-53549-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <loghyr@primarydata.com>

nfs4_insert_deviceid_node() was removed in 661373b13d0490ff410a2133d4a7a117f2dd037e

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/pnfs.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 693ce42..509a710 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -270,7 +270,6 @@ nfs4_find_get_deviceid(struct nfs_server *server,
 void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
 			     const struct nfs4_deviceid *);
-struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
 void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
-- 
1.7.7.6

