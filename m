Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34502 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932146AbcLKPgy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 10:36:54 -0500
From: Jia He <hejianet@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>
Subject: [PATCH v2 1/1] lockd: Change nsm_use_hostnames from bool to u32
Date: Sun, 11 Dec 2016 23:36:49 +0800
Message-Id: <1481470609-31488-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1481470609-31488-1-git-send-email-hejianet@gmail.com>
References: <1481470609-31488-1-git-send-email-hejianet@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nsm_use_hostnames is a module paramter and it will be exported to sysctl
procfs. This is to let user sometimes change it from userspace. But the
minimal unit for sysctl procfs read/write it sizeof(int).
In big endian system, the converting from/to  bool to/from int will cause
error for proc items.

This patch changes the type definition of nsm_use_hostnames.

V2: Changes extern type in lockd.h
Signed-off-by: Jia He <hejianet@gmail.com>
---
 fs/lockd/mon.c              | 2 +-
 fs/lockd/svc.c              | 2 +-
 include/linux/lockd/lockd.h | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 19166d4..3e7ff4d 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -57,7 +57,7 @@ static				DEFINE_SPINLOCK(nsm_lock);
  * Local NSM state
  */
 u32	__read_mostly		nsm_local_state;
-bool	__read_mostly		nsm_use_hostnames;
+u32	__read_mostly		nsm_use_hostnames;
 
 static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
 {
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index fc4084e..308033d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -658,7 +658,7 @@ module_param_call(nlm_udpport, param_set_port, param_get_int,
 		  &nlm_udpport, 0644);
 module_param_call(nlm_tcpport, param_set_port, param_get_int,
 		  &nlm_tcpport, 0644);
-module_param(nsm_use_hostnames, bool, 0644);
+module_param(nsm_use_hostnames, u32, 0644);
 module_param(nlm_max_connections, uint, 0644);
 
 static int lockd_init_net(struct net *net)
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index c153738..db52152 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -196,7 +196,7 @@ extern struct svc_procedure	nlmsvc_procedures4[];
 #endif
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
-extern bool			nsm_use_hostnames;
+extern u32			nsm_use_hostnames;
 extern u32			nsm_local_state;
 
 /*
-- 
2.5.5

