Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35893 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753553AbcLKOtW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 09:49:22 -0500
From: Jia He <hejianet@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>
Subject: [PATCH 1/1] lockd: Change nsm_use_hostnames from bool to u32
Date: Sun, 11 Dec 2016 22:49:12 +0800
Message-Id: <1481467752-30728-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1481467752-30728-1-git-send-email-hejianet@gmail.com>
References: <1481467752-30728-1-git-send-email-hejianet@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nsm_use_hostnames is a module parameter and it will be exported to sysctl
procfs. This is to let user sometimes change it from userspace. But the
minimal unit for sysctl procfs read/write it sizeof(int).
In big endian system, the converting from/to  bool to/from int will cause
error for proc items.

This patch changes the type definition of nsm_use_hostnames.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 fs/lockd/mon.c | 2 +-
 fs/lockd/svc.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

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
-- 
2.5.5

