Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f54.google.com ([209.85.210.54]:50489 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533Ab3CKCzt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2013 22:55:49 -0400
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH v2] nfsd: rmmove unused macro in nfsv4
Date: Mon, 11 Mar 2013 10:43:26 +0800
Message-Id: <1362969806-23907-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

lk_rflags is never used anywhere, and rflags is not defined in struct
nfsd4_lock. Very sorry for my negligence in last version. Maybe I am tired.

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

