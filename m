Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:57366 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab3CKCOM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2013 22:14:12 -0400
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfsd: rmmove unused macro in nfsv4
Date: Mon, 11 Mar 2013 10:02:18 +0800
Message-Id: <1362967338-22341-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

lk_new_open_seqid is never used anywhere, and rflags is not defined in struct
nfsd4_lock.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/xdr4.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0889bfb..326724a 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -184,7 +184,6 @@ struct nfsd4_lock {
 #define lk_old_lock_stateid     v.old.lock_stateid
 #define lk_old_lock_seqid       v.old.lock_seqid
 
-#define lk_rflags       u.ok.rflags
 #define lk_resp_stateid u.ok.stateid
 #define lk_denied       u.denied
 
-- 
1.7.4.4

