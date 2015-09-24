Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34755 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbIXM4L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:56:11 -0400
Received: by padhy16 with SMTP id hy16so72813105pad.1
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:56:11 -0700 (PDT)
Subject: [PATCH 2/8] NFS: Remove the left global variable nfs_callback_tcpport
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F2DF.4090407@gmail.com>
Date: Thu, 24 Sep 2015 20:55:59 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit bbe0a3aa4e22 "NFS: make nfs_callback_tcpport per network context" has
make nfs_callback_tcpport per network, but left the global nfs_callback_tcpport,
remove it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback.h | 1 -
 fs/nfs/super.c    | 2 --
 2 files changed, 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 0a590f0..cbcc903 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -204,6 +204,5 @@ extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
 #define NFS41_BC_MAX_CALLBACKS 1
 
 extern unsigned int nfs_callback_set_tcpport;
-extern unsigned short nfs_callback_tcpport;
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 383a027..f126828 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2816,7 +2816,6 @@ out_invalid_transport_udp:
  * NFS client for backwards compatibility
  */
 unsigned int nfs_callback_set_tcpport;
-unsigned short nfs_callback_tcpport;
 /* Default cache timeout is 10 minutes */
 unsigned int nfs_idmap_cache_timeout = 600;
 /* Turn off NFSv4 uid/gid mapping when using AUTH_SYS */
@@ -2827,7 +2826,6 @@ char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN] = "";
 bool recover_lost_locks = false;
 
 EXPORT_SYMBOL_GPL(nfs_callback_set_tcpport);
-EXPORT_SYMBOL_GPL(nfs_callback_tcpport);
 EXPORT_SYMBOL_GPL(nfs_idmap_cache_timeout);
 EXPORT_SYMBOL_GPL(nfs4_disable_idmapping);
 EXPORT_SYMBOL_GPL(max_session_slots);
-- 
2.5.0

